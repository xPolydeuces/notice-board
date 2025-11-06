SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: locations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.locations (
    id bigint NOT NULL,
    code character varying NOT NULL,
    name character varying NOT NULL,
    active boolean DEFAULT true NOT NULL,
    news_posts_count integer DEFAULT 0 NOT NULL,
    users_count integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: locations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.locations_id_seq OWNED BY public.locations.id;


--
-- Name: news_posts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.news_posts (
    id bigint NOT NULL,
    title character varying NOT NULL,
    content text NOT NULL,
    post_type character varying NOT NULL,
    location_id bigint,
    user_id bigint NOT NULL,
    published boolean DEFAULT false NOT NULL,
    published_at timestamp(6) without time zone,
    archived boolean DEFAULT false NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: news_posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.news_posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: news_posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.news_posts_id_seq OWNED BY public.news_posts.id;


--
-- Name: rss_feeds; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rss_feeds (
    id bigint NOT NULL,
    name character varying NOT NULL,
    url character varying NOT NULL,
    active boolean DEFAULT true NOT NULL,
    last_fetched_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: rss_feeds_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rss_feeds_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rss_feeds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rss_feeds_id_seq OWNED BY public.rss_feeds.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email character varying,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp(6) without time zone,
    remember_created_at timestamp(6) without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp(6) without time zone,
    last_sign_in_at timestamp(6) without time zone,
    current_sign_in_ip character varying,
    last_sign_in_ip character varying,
    username character varying,
    location_id bigint,
    role integer DEFAULT 0 NOT NULL,
    news_posts_count integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: locations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locations ALTER COLUMN id SET DEFAULT nextval('public.locations_id_seq'::regclass);


--
-- Name: news_posts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.news_posts ALTER COLUMN id SET DEFAULT nextval('public.news_posts_id_seq'::regclass);


--
-- Name: rss_feeds id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rss_feeds ALTER COLUMN id SET DEFAULT nextval('public.rss_feeds_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: locations locations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (id);


--
-- Name: news_posts news_posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.news_posts
    ADD CONSTRAINT news_posts_pkey PRIMARY KEY (id);


--
-- Name: rss_feeds rss_feeds_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rss_feeds
    ADD CONSTRAINT rss_feeds_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_locations_on_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_locations_on_active ON public.locations USING btree (active);


--
-- Name: index_locations_on_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_locations_on_code ON public.locations USING btree (code);


--
-- Name: index_news_posts_on_archived; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_news_posts_on_archived ON public.news_posts USING btree (archived);


--
-- Name: index_news_posts_on_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_news_posts_on_location_id ON public.news_posts USING btree (location_id);


--
-- Name: index_news_posts_on_location_id_and_published; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_news_posts_on_location_id_and_published ON public.news_posts USING btree (location_id, published);


--
-- Name: index_news_posts_on_location_published_archived; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_news_posts_on_location_published_archived ON public.news_posts USING btree (location_id, published, archived);


--
-- Name: index_news_posts_on_post_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_news_posts_on_post_type ON public.news_posts USING btree (post_type);


--
-- Name: index_news_posts_on_published; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_news_posts_on_published ON public.news_posts USING btree (published);


--
-- Name: index_news_posts_on_published_archived_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_news_posts_on_published_archived_created ON public.news_posts USING btree (published, archived, created_at);


--
-- Name: index_news_posts_on_published_at_archived; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_news_posts_on_published_at_archived ON public.news_posts USING btree (published_at, archived);


--
-- Name: index_news_posts_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_news_posts_on_user_id ON public.news_posts USING btree (user_id);


--
-- Name: index_rss_feeds_on_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rss_feeds_on_active ON public.rss_feeds USING btree (active);


--
-- Name: index_rss_feeds_on_url; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_rss_feeds_on_url ON public.rss_feeds USING btree (url);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_location_id ON public.users USING btree (location_id);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: index_users_on_role; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_role ON public.users USING btree (role);


--
-- Name: index_users_on_username; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_username ON public.users USING btree (username);


--
-- Name: news_posts fk_rails_0870e2541b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.news_posts
    ADD CONSTRAINT fk_rails_0870e2541b FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: news_posts fk_rails_2c37a32e6c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.news_posts
    ADD CONSTRAINT fk_rails_2c37a32e6c FOREIGN KEY (location_id) REFERENCES public.locations(id);


--
-- Name: users fk_rails_5d96f79c2b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_5d96f79c2b FOREIGN KEY (location_id) REFERENCES public.locations(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20251106000001');