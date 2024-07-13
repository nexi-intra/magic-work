/* 
File have been automatically created. To prevent the file from getting overwritten
set the Front Matter property ´keep´ to ´true´ syntax for the code snippet
---
keep: false
---
*/   


-- sherry sild

CREATE OR REPLACE PROCEDURE proc.update_activityversion(
    p_actor_name VARCHAR,
    p_params JSONB
)
LANGUAGE plpgsql
AS $BODY$
DECLARE
    v_id INTEGER;
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
        v_audit_id integer;  -- Variable to hold the OUT parameter value
    p_auditlog_params jsonb;

    
BEGIN
    v_id := p_params->>'id';
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
         
    
        
    UPDATE public.activityversion
    SET updated_by = p_actor_name,
        updated_at = CURRENT_TIMESTAMP,
        tenant = v_tenant,
        searchindex = v_searchindex,
        name = v_name,
        description = v_description,
        activity_id = v_activity_id,
        version = v_version,
        accountable_id = v_accountable_id,
        responsible_id = v_responsible_id,
        started = v_started,
        stage = v_stage,
        substage = v_substage,
        triggeredby_id = v_triggeredby_id,
        timestamp = v_timestamp,
        data = v_data
    WHERE id = v_id;

    GET DIAGNOSTICS v_rows_updated = ROW_COUNT;
    
    IF v_rows_updated < 1 THEN
        RAISE EXCEPTION 'No records updated. activityversion ID % not found', v_id ;
    END IF;

           p_auditlog_params := jsonb_build_object(
        'tenant', '',
        'searchindex', '',
        'name', 'update_activityversion',
        'status', 'success',
        'description', '',
        'action', 'update_activityversion',
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

  "properties": {
    "title": "Update Activity Version",
  "description": "Update operation",
  
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
END;
$BODY$
;


