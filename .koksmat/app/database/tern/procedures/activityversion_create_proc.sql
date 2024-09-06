/* 
File have been automatically created. To prevent the file from getting overwritten
set the Front Matter property ´keep´ to ´true´ syntax for the code snippet
---
keep: false
---
*/   


-- tomat sild

CREATE OR REPLACE FUNCTION create_activityversion(
    p_actor_name VARCHAR,
    p_params JSONB,
    p_koksmat_sync JSONB DEFAULT NULL
   
)
RETURNS JSONB LANGUAGE plpgsql 
AS $$
DECLARE
       v_rows_updated INTEGER;
v_tenant VARCHAR COLLATE pg_catalog."default" ;
    v_searchindex VARCHAR COLLATE pg_catalog."default" ;
    v_name VARCHAR COLLATE pg_catalog."default" ;
    v_description VARCHAR COLLATE pg_catalog."default";
    v_activity_id INTEGER;
    v_version VARCHAR;
    v_accountable_id INTEGER;
    v_responsible_id INTEGER;
    v_started TIMESTAMP WITH TIME ZONE;
    v_stage INTEGER;
    v_substage INTEGER;
    v_triggeredby_id INTEGER;
    v_timestamp TIMESTAMP WITH TIME ZONE;
    v_data JSONB;
    v_id INTEGER;
        v_audit_id integer;  -- Variable to hold the OUT parameter value
    p_auditlog_params jsonb;

BEGIN
    v_tenant := p_params->>'tenant';
    v_searchindex := p_params->>'searchindex';
    v_name := p_params->>'name';
    v_description := p_params->>'description';
    v_activity_id := p_params->>'activity_id';
    v_version := p_params->>'version';
    v_accountable_id := p_params->>'accountable_id';
    v_responsible_id := p_params->>'responsible_id';
    v_started := p_params->>'started';
    v_stage := p_params->>'stage';
    v_substage := p_params->>'substage';
    v_triggeredby_id := p_params->>'triggeredby_id';
    v_timestamp := p_params->>'timestamp';
    v_data := p_params->>'data';
         

    INSERT INTO public.activityversion (
    id,
    created_at,
    updated_at,
        created_by, 
        updated_by, 
        tenant,
        searchindex,
        name,
        description,
        activity_id,
        version,
        accountable_id,
        responsible_id,
        started,
        stage,
        substage,
        triggeredby_id,
        timestamp,
        data
    )
    VALUES (
        DEFAULT,
        DEFAULT,
        DEFAULT,
        p_actor_name, 
        p_actor_name,  -- Use the same value for updated_by
        v_tenant,
        v_searchindex,
        v_name,
        v_description,
        v_activity_id,
        v_version,
        v_accountable_id,
        v_responsible_id,
        v_started,
        v_stage,
        v_substage,
        v_triggeredby_id,
        v_timestamp,
        v_data
    )
    RETURNING id INTO v_id;

    

       p_auditlog_params := jsonb_build_object(
        'tenant', '',
        'searchindex', '',
        'name', 'create_activityversion',
        'status', 'success',
        'description', '',
        'action', 'create_activityversion',
        'entity', 'activityversion',
        'entityid', -1,
        'actor', p_actor_name,
        'metadata', p_params
    );
/*###MAGICAPP-START##
{
   "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://booking.services.koksmat.com/.schema.json",
   
  "type": "object",

  "title": "Create Activity Version",
  "description": "Create operation",

  "properties": {
  
    "tenant": { 
    "type": "string",
    "description":"" },
    "searchindex": { 
    "type": "string",
    "description":"Search Index is used for concatenating all searchable fields in a single field making in easier to search\n" },
    "name": { 
    "type": "string",
    "description":"" },
    "description": { 
    "type": "string",
    "description":"" },
    "activity_id": { 
    "type": "number",
    "description":"" },
    "version": { 
    "type": "string",
    "description":"" },
    "accountable_id": { 
    "type": "number",
    "description":"" },
    "responsible_id": { 
    "type": "number",
    "description":"" },
    "started": { 
    "type": "string",
    "description":"" },
    "stage": { 
    "type": "number",
    "description":"" },
    "substage": { 
    "type": "number",
    "description":"" },
    "triggeredby_id": { 
    "type": "number",
    "description":"" },
    "timestamp": { 
    "type": "string",
    "description":"" },
    "data": { 
    "type": "object",
    "description":"" }

    }
}

##MAGICAPP-END##*/

    -- Call the create_auditlog procedure
    CALL proc.create_auditlog(p_actor_name, p_auditlog_params, v_audit_id);

    return jsonb_build_object(
    'comment','created',
    'id',v_id);

END;
$$ 
;




