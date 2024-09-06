
package main

import (
    "encoding/json"
    "fmt"
    "log"
    "net/http"
    "os"
    "sync"
    "time"
    "github.com/nats-io/nats.go"
    "github.com/dgrijalva/jwt-go"
    "strings"
)

var jwtKey = []byte("my_secret_key")

// JWT Middleware to authenticate requests
func jwtAuth(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        authHeader := r.Header.Get("Authorization")
        if authHeader == "" {
            http.Error(w, "Missing Authorization header", http.StatusUnauthorized)
            return
        }

        // Extract the token from the Authorization header (Bearer <token>)
        tokenString := strings.Split(authHeader, "Bearer ")[1]
        claims := &Claims{}

        // Parse the JWT token
        token, err := jwt.ParseWithClaims(tokenString, claims, func(token *jwt.Token) (interface{}, error) {
            return jwtKey, nil
        })

        if err != nil || !token.Valid {
            http.Error(w, "Invalid token", http.StatusUnauthorized)
            return
        }

        // Continue to the next handler if the token is valid
        next.ServeHTTP(w, r)
    })
}

// Claims struct for JWT payload
type Claims struct {
    Username string `json:"username"`
    jwt.StandardClaims
}

// Function to create JWT tokens for users
func createToken(username string) (string, error) {
    expirationTime := time.Now().Add(24 * time.Hour)
    claims := &Claims{
        Username: username,
        StandardClaims: jwt.StandardClaims{
            ExpiresAt: expirationTime.Unix(),
        },
    }

    // Create the JWT token
    token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
    return token.SignedString(jwtKey)
}

// SubObject represents the sub-object in the hashtable
type SubObject struct {
    Data string
}

// Object represents the main object that holds sub-objects
type Object struct {
    mu        sync.Mutex
    subObject map[string]*SubObject
    leases    map[string]time.Time
    undoStack []map[string]*SubObject
    redoStack []map[string]*SubObject
}

// Acquire a lease for updating a sub-object
func (o *Object) acquireLease(subObjectID string, leaseTime time.Duration) error {
    o.mu.Lock()
    defer o.mu.Unlock()

    if expiration, exists := o.leases[subObjectID]; exists {
        if time.Now().Before(expiration) {
            return fmt.Errorf("lease already exists for sub-object: %s", subObjectID)
        }
    }

    o.leases[subObjectID] = time.Now().Add(leaseTime)
    return nil
}

// Release a lease
func (o *Object) releaseLease(subObjectID string) {
    o.mu.Lock()
    defer o.mu.Unlock()

    delete(o.leases, subObjectID)
}

// Extend a lease if keep-alive signal is received
func (o *Object) extendLease(subObjectID string, leaseTime time.Duration) error {
    o.mu.Lock()
    defer o.mu.Unlock()

    if expiration, exists := o.leases[subObjectID]; exists {
        if time.Now().Before(expiration) {
            o.leases[subObjectID] = time.Now().Add(leaseTime)
            return nil
        }
    }
    return fmt.Errorf("no lease exists for sub-object: %s", subObjectID)
}

// Update a sub-object and persist the change
func (o *Object) updateSubObject(subObjectID string, newData string, leaseID string) error {
    o.mu.Lock()
    defer o.mu.Unlock()

    expiration, exists := o.leases[subObjectID]
    if !exists || time.Now().After(expiration) {
        return fmt.Errorf("no valid lease for sub-object: %s", subObjectID)
    }

    o.pushUndo()
    o.subObject[subObjectID].Data = newData
    notifyChange(subObjectID, newData)

    err := persistState(o)
    if err != nil {
        return fmt.Errorf("failed to persist state: %w", err)
    }

    return nil
}

// Push current state for undo
func (o *Object) pushUndo() {
    snapshot := make(map[string]*SubObject)
    for key, value := range o.subObject {
        snapshot[key] = value
    }
    o.undoStack = append(o.undoStack, snapshot)
}

// Undo the last change
func (o *Object) undo() error {
    if len(o.undoStack) == 0 {
        return fmt.Errorf("nothing to undo")
    }

    o.subObject = o.undoStack[len(o.undoStack)-1]
    o.undoStack = o.undoStack[:len(o.undoStack)-1]
    o.pushRedo()
    return nil
}

// Push the undone state to the redo stack
func (o *Object) pushRedo() {
    snapshot := make(map[string]*SubObject)
    for key, value := range o.subObject {
        snapshot[key] = value
    }
    o.redoStack = append(o.redoStack, snapshot)
}

// Redo the last undone change
func (o *Object) redo() error {
    if len(o.redoStack) == 0 {
        return fmt.Errorf("nothing to redo")
    }

    o.subObject = o.redoStack[len(o.redoStack)-1]
    o.redoStack = o.redoStack[:len(o.redoStack)-1]
    return nil
}

// Persist the object state (could be a database or file)
func persistState(obj *Object) error {
    data, err := json.Marshal(obj.subObject)
    if err != nil {
        return err
    }

    err = os.WriteFile("object_state.json", data, 0644)
    if err != nil {
        return err
    }

    fmt.Println("State persisted successfully.")
    return nil
}

// Notify change via NATS (dummy implementation)
func notifyChange(subObjectID string, newData string) {
    nc, _ := nats.Connect(nats.DefaultURL)
    nc.Publish("object.change", []byte(fmt.Sprintf("SubObject %s updated with data: %s", subObjectID, newData)))
    defer nc.Close()
}

// Main handler for updating a sub-object
func updateSubObjectHandler(w http.ResponseWriter, r *http.Request) {
    // Extract and validate request data (e.g., leaseID, subObjectID, newData)
    // ...
    fmt.Fprintln(w, "Update successful!")
}

func main() {
    http.Handle("/update", jwtAuth(http.HandlerFunc(updateSubObjectHandler)))
    log.Fatal(http.ListenAndServe(":8080", nil))
}
