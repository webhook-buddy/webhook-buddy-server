CREATE TABLE public.users
(
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    first_name character varying(100) COLLATE pg_catalog."default",
    last_name character varying(100) COLLATE pg_catalog."default",
    email character varying(200) COLLATE pg_catalog."default",
    CONSTRAINT users_pkey PRIMARY KEY (id)
)
TABLESPACE pg_default;

CREATE TABLE public.endpoints
(
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    reference_id character varying(100) COLLATE pg_catalog."default" NOT NULL,
    name character varying(100) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT endpoints_pkey PRIMARY KEY (id)
)
TABLESPACE pg_default;

CREATE TABLE public.user_endpoints
(
    user_id integer NOT NULL REFERENCES public.users (id) ON UPDATE CASCADE ON DELETE CASCADE,
    endpoint_id integer NOT NULL REFERENCES public.users (id) ON UPDATE CASCADE ON DELETE CASCADE,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    CONSTRAINT user_endpoints_pkey PRIMARY KEY (user_id, endpoint_id)
)
TABLESPACE pg_default;

CREATE UNIQUE INDEX endpoints_idx_unique_reference_id
    ON public.endpoints USING btree
    (reference_id COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;

CREATE TABLE public.webhooks
(
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    endpoint_id integer NOT NULL REFERENCES public.endpoints (id) ON UPDATE CASCADE ON DELETE CASCADE,
    ip_address character varying(39) COLLATE pg_catalog."default" NOT NULL,
    method character varying(10) COLLATE pg_catalog."default" NOT NULL,
    headers jsonb NOT NULL,
	query jsonb NOT NULL,
    content_type character varying(100) COLLATE pg_catalog."default",
    body character varying COLLATE pg_catalog."default",
	body_json jsonb,
    CONSTRAINT webhooks_pkey PRIMARY KEY (id)
)
TABLESPACE pg_default;

CREATE TABLE public.reads
(
    webhook_id integer NOT NULL REFERENCES public.webhooks (id) ON UPDATE CASCADE ON DELETE CASCADE,
    user_id integer NOT NULL REFERENCES public.users (id) ON UPDATE CASCADE ON DELETE CASCADE,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    CONSTRAINT reads_pkey PRIMARY KEY (webhook_id, user_id)
)
TABLESPACE pg_default;

CREATE TABLE public.forwards
(
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    webhook_id integer NOT NULL REFERENCES public.webhooks (id) ON UPDATE CASCADE ON DELETE CASCADE,
    user_id integer NOT NULL REFERENCES public.users (id) ON UPDATE CASCADE ON DELETE CASCADE,
    url character varying(2048) COLLATE pg_catalog."default" NOT NULL,
    method character varying(10) COLLATE pg_catalog."default" NOT NULL,
    status_code integer NOT NULL,
    headers jsonb NOT NULL,
	query jsonb NOT NULL,
    content_type character varying(100) COLLATE pg_catalog."default",
    body character varying COLLATE pg_catalog."default",
	body_json jsonb,
    CONSTRAINT forwards_pkey PRIMARY KEY (id)
)
TABLESPACE pg_default;

CREATE TABLE public.forward_urls
(
    id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    endpoint_id integer NOT NULL REFERENCES public.endpoints (id) ON UPDATE CASCADE ON DELETE CASCADE,
    user_id integer NOT NULL REFERENCES public.users (id) ON UPDATE CASCADE ON DELETE CASCADE,
    url character varying(2048) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT forward_urls_pkey PRIMARY KEY (id)
)
TABLESPACE pg_default;


INSERT INTO public.users(
	created_at, updated_at, first_name, last_name, email)
	VALUES (current_timestamp, current_timestamp, 'Lou', 'Ferigno', 'lou@email.com');
	
INSERT INTO public.endpoints(
	created_at, updated_at, reference_id, name)
	VALUES (current_timestamp, current_timestamp, 'caa0699e-3fab-482c-8c4b-6424d898439f', 'ACME w/ Stripe');
	
INSERT INTO public.user_endpoints(
	user_id, endpoint_id, created_at, updated_at)
	VALUES (1, 1, current_timestamp, current_timestamp);