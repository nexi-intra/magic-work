/* 
File have been automatically created. To prevent the file from getting overwritten
set the Front Matter property ´keep´ to ´true´ syntax for the code snippet
---
keep: false
---
*/   


-- sure sild

CREATE TABLE public.activityversion
(
    id SERIAL PRIMARY KEY,
    created_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by character varying COLLATE pg_catalog."default"  ,

    updated_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying COLLATE pg_catalog."default" ,

    deleted_at timestamp with time zone
    ,tenant character varying COLLATE pg_catalog."default"  NOT NULL
    ,searchindex character varying COLLATE pg_catalog."default"  NOT NULL
    ,name character varying COLLATE pg_catalog."default"  NOT NULL
    ,description character varying COLLATE pg_catalog."default" 
    ,activity_id int   NOT NULL
    ,version character varying COLLATE pg_catalog."default"  NOT NULL
    ,accountable_id int   NOT NULL
    ,responsible_id int   NOT NULL
    ,started character varying COLLATE pg_catalog."default"   NOT NULL
    ,stage character varying COLLATE pg_catalog."default"   NOT NULL
    ,substage character varying COLLATE pg_catalog."default"   NOT NULL
    ,triggeredby_id int   NOT NULL
    ,timestamp character varying COLLATE pg_catalog."default"   NOT NULL
    ,data JSONB   NOT NULL


);

                ALTER TABLE IF EXISTS public.activityversion
                ADD FOREIGN KEY (activity_id)
                REFERENCES public.activity (id) MATCH SIMPLE
                ON UPDATE NO ACTION
                ON DELETE NO ACTION
                NOT VALID;                ALTER TABLE IF EXISTS public.activityversion
                ADD FOREIGN KEY (accountable_id)
                REFERENCES public.actor (id) MATCH SIMPLE
                ON UPDATE NO ACTION
                ON DELETE NO ACTION
                NOT VALID;                ALTER TABLE IF EXISTS public.activityversion
                ADD FOREIGN KEY (responsible_id)
                REFERENCES public.actor (id) MATCH SIMPLE
                ON UPDATE NO ACTION
                ON DELETE NO ACTION
                NOT VALID;                ALTER TABLE IF EXISTS public.activityversion
                ADD FOREIGN KEY (triggeredby_id)
                REFERENCES public.event (id) MATCH SIMPLE
                ON UPDATE NO ACTION
                ON DELETE NO ACTION
                NOT VALID;


---- create above / drop below ----

DROP TABLE public.activityversion;

