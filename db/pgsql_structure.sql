SET client_encoding = 'UTF8';
CREATE SEQUENCE id
    START WITH 21
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

----------------------------------
---                            ---
---           CLASES           ---
---                            ---
----------------------------------
CREATE TABLE class (
	id         integer  NOT NULL DEFAULT nextval('id') primary key,
	parent_id  integer  NOT NULL REFERENCES class(id) ON UPDATE CASCADE ON DELETE CASCADE,
	name       text     NOT NULL
);

INSERT INTO class (id, parent_id, name) VALUES (1,1,'');



CREATE OR REPLACE FUNCTION class_id(class_name text)
    RETURNS integer
    LANGUAGE sql
    IMMUTABLE STRICT
AS $function$
    SELECT id FROM class WHERE name = $1 ORDER BY id ASC LIMIT 1;
$function$;


CREATE OR REPLACE FUNCTION class_id(parent_class_name text, class_name text)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
    SELECT c1.id FROM class c1 JOIN class c2 ON c1.parent_id = c2.id WHERE c1.name = $2 AND c2.name = $1 ORDER BY c1.id ASC LIMIT 1;
$function$;


CREATE OR REPLACE FUNCTION class_id(parent_class_id integer, class_name text)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
    SELECT id FROM class WHERE name = $2 AND parent_id = $1;
$function$;


CREATE OR REPLACE FUNCTION class_name(class_id integer)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
    SELECT name FROM class WHERE id = $1;
$function$;

CREATE OR REPLACE FUNCTION class_add(in_parent_id integer, in_name text)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
DECLARE
        obj_id  INTEGER;
BEGIN
        SELECT id INTO obj_id FROM class WHERE parent_id = in_parent_id AND name = in_name;
        IF FOUND THEN
            RETURN obj_id;
        END IF;
--      BEGIN
                INSERT INTO class (parent_id, name) VALUES (in_parent_id, in_name) RETURNING id INTO obj_id;
--      EXCEPTION WHEN unique_violation THEN
--      END;
        RETURN obj_id;
END
$function$;

CREATE OR REPLACE FUNCTION class_add(parent_name text, name text)
 RETURNS integer
 LANGUAGE sql
AS $function$
        SELECT class_add(class_id('', $1), $2);
$function$;



----------------------------------
---                            ---
---          LANGUAGES         ---
---                            ---
----------------------------------

CREATE OR REPLACE FUNCTION lang_id(lang_name text)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
    SELECT class_id('lang', $1);
$function$;

CREATE OR REPLACE FUNCTION lang_name(lang_id integer)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
    SELECT class_name($1);
$function$;





----------------------------------
---                            ---
---           STATUS'          ---
---                            ---
----------------------------------

CREATE OR REPLACE FUNCTION status_id(status_name text)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
        SELECT class_id('status', $1);
$function$;

CREATE OR REPLACE FUNCTION status_id(parent_name text, status_name text)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
        SELECT class_id(class_id('status', $1), $2);
$function$;

CREATE OR REPLACE FUNCTION status_name(status_id integer)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
        SELECT class_name($1);
$function$;

----------------------------------
---                            ---
---        STATUS' ADD         ---
---                            ---
----------------------------------
CREATE OR REPLACE FUNCTION status_add(status_category_name text, status_name text) RETURNS integer AS $$
DECLARE
    _cat_id integer;
    _id integer;
BEGIN
--  RAISE NOTICE 'entering role_add function';

    SELECT status_id(status_category_name) INTO _cat_id;
--    RAISE NOTICE '_cat_id: %', _cat_id;
    IF _cat_id IS NULL THEN
        RAISE EXCEPTION 'Nonexistent action category --> %', status_category_name
              USING HINT = 'Please create action category first';
    END IF;

    SELECT status_id(status_category_name, status_name) INTO _id;
    IF _id IS NULL THEN
        SELECT class_add(_cat_id,status_name) INTO _id;
    END IF;
    RETURN _id;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION status_add(status_name text) RETURNS integer AS $$
DECLARE
    _id integer;
BEGIN
    SELECT status_id(status_name) INTO _id;
    IF _id IS NULL THEN
        SELECT class_add('status',status_name) INTO _id;
    END IF;
    RETURN _id;
END;
$$ LANGUAGE 'plpgsql';

---
CREATE OR REPLACE FUNCTION status_remove(status_name text)
 RETURNS boolean
 LANGUAGE sql
 VOLATILE STRICT
AS $function$
    DELETE FROM class WHERE id = status_id($1) RETURNING TRUE;
$function$;
---
CREATE OR REPLACE FUNCTION status_remove(status_category_name text, status_name text)
 RETURNS boolean
 LANGUAGE sql
 VOLATILE STRICT
AS $function$
    DELETE FROM class WHERE  id = status_id($1, $2) RETURNING TRUE;
$function$;


----------------------------------
---                            ---
---           TYPES            ---
---                            ---
----------------------------------

CREATE OR REPLACE FUNCTION type_id(type_name text)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
        SELECT class_id('type', $1);
$function$;

CREATE OR REPLACE FUNCTION type_id(parent_name text, type_name text)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
        SELECT class_id(class_id('type', $1), $2);
$function$;

CREATE OR REPLACE FUNCTION type_name(type_id integer)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
        SELECT class_name($1);
$function$;

----------------------------------
---                            ---
---        TYPES  ADD          ---
---                            ---
----------------------------------
CREATE OR REPLACE FUNCTION type_add(type_category_name text, type_name text) RETURNS integer AS $$
DECLARE
    _cat_id integer;
    _id integer;
BEGIN
--  RAISE NOTICE 'entering role_add function';

    SELECT type_id(type_category_name) INTO _cat_id;
--    RAISE NOTICE '_cat_id: %', _cat_id;
    IF _cat_id IS NULL THEN
        RAISE EXCEPTION 'Nonexistent action category --> %', type_category_name
              USING HINT = 'Please create action category first';
    END IF;

    SELECT type_id(type_category_name, type_name) INTO _id;
    IF _id IS NULL THEN
        SELECT class_add(_cat_id,type_name) INTO _id;
    END IF;
    RETURN _id;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION type_add(type_name text) RETURNS integer AS $$
DECLARE
    _id integer;
BEGIN
    SELECT type_id(type_name) INTO _id;
    IF _id IS NULL THEN
        SELECT class_add('type',type_name) INTO _id;
    END IF;
    RETURN _id;
END;
$$ LANGUAGE 'plpgsql';

---
CREATE OR REPLACE FUNCTION type_remove(type_name text)
 RETURNS boolean
 LANGUAGE sql
 VOLATILE STRICT
AS $function$
    DELETE FROM class WHERE id = type_id($1) RETURNING TRUE;
$function$;
---
CREATE OR REPLACE FUNCTION type_remove(type_category_name text, type_name text)
 RETURNS boolean
 LANGUAGE sql
 VOLATILE STRICT
AS $function$
    DELETE FROM class WHERE  id = type_id($1, $2) RETURNING TRUE;
$function$;







----------------------------------
---                            ---
---           CUSTOMER         ---
---                            ---
----------------------------------

CREATE TABLE customer (
    id         integer  NOT NULL DEFAULT nextval('id') primary key,
    referer_id integer  NULL REFERENCES customer(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    parent_id  integer  NULL REFERENCES customer(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    type_id    integer  NOT NULL REFERENCES class(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    status_id  integer  NOT NULL REFERENCES class(id) ON UPDATE CASCADE ON DELETE RESTRICT DEFAULT status_id('customer', 'new'),
    login      text     NOT NULL UNIQUE
);


CREATE OR REPLACE FUNCTION customer_id(customer_name text)
 RETURNS integer
 LANGUAGE sql
 STABLE STRICT
AS $function$
    SELECT id FROM customer WHERE login = $1;
$function$;

CREATE OR REPLACE FUNCTION customer_name(customer_id integer)
 RETURNS text
 LANGUAGE sql
 STABLE STRICT
AS $function$
    SELECT login FROM customer WHERE id = $1;
$function$;


----------------------------------
---                            ---
---            USER            ---
---                            ---
----------------------------------

CREATE TABLE auth_user (
    id             integer      NOT NULL DEFAULT nextval('id')  primary key,
    customer_id    integer      NOT NULL REFERENCES customer(id) ON UPDATE CASCADE ON DELETE CASCADE,
    username       text         NOT NULL,
    password       text         NOT NULL,
    active         boolean      NOT NULL DEFAULT FALSE,
    email          text         NULL,
    skype          text         NULL,
    icq            text         NULL,
    lang_id        integer      NULL REFERENCES class(id) ON UPDATE CASCADE ON DELETE SET NULL,
    registered     timestamp    NOT NULL DEFAULT now(),
    lastvisit      timestamp    NULL,
--    CONSTRAINT username_check CHECK (username <> ''),
    CONSTRAINT password_check CHECK (password <> ''),
    UNIQUE (customer_id, username)
);
CREATE INDEX auth_user_upa ON auth_user USING btree (customer_id, username, password, active);

CREATE TABLE auth_role_action (
    role_id    integer             NOT NULL    REFERENCES class(id) ON UPDATE CASCADE ON DELETE CASCADE,
    action_id  integer             NOT NULL    REFERENCES class(id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT auth_role_action_pk PRIMARY KEY (role_id, action_id)
);

CREATE TABLE auth_role_user (
    user_id    integer    NOT NULL    REFERENCES auth_user(id) ON UPDATE CASCADE ON DELETE CASCADE,
    role_id    integer    NOT NULL    REFERENCES class(id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT auth_role_user_pk PRIMARY KEY (user_id, role_id)
);


CREATE OR REPLACE FUNCTION user_id(customer_name text, in_username text)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
    SELECT id FROM auth_user WHERE customer_id = customer_id($1) AND username = $2;
$function$;

---
CREATE OR REPLACE FUNCTION username(user_id integer)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
    SELECT username FROM auth_user WHERE id = $1;
$function$;


----------------------------------
---                            ---
---           ROLES ADD        ---
---                            ---
----------------------------------
CREATE OR REPLACE FUNCTION role_add(role_name text) RETURNS integer AS $$
DECLARE
    _id integer;
BEGIN
	SELECT class_id('role', role_name) INTO _id;
	IF _id IS NULL THEN
        SELECT class_add('role', role_name) INTO _id;
    END IF;
    RETURN _id;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION role_remove(role_name text) RETURNS boolean AS $$
DECLARE
    _id integer;
BEGIN
    SELECT class_id('role', role_name) INTO _id;
    IF _id IS NOT NULL THEN
        DELETE FROM auth_role_action WHERE role_id = _id;
        DELETE FROM auth_role_user WHERE role_id = _id;
        DELETE FROM class WHERE id = _id;
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;
$$ LANGUAGE 'plpgsql';

----------------------------------
---                            ---
---        ROLES SELECTS       ---
---                            ---
----------------------------------

---
CREATE OR REPLACE FUNCTION role_id(role_name text)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
    SELECT class_id('role', $1);
$function$;

---
CREATE OR REPLACE FUNCTION role_name(role_id integer)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
    SELECT class_name($1);
$function$;

----------------------------------
---                            ---
---         USER ROLES         ---
---                            ---
----------------------------------

---
CREATE OR REPLACE FUNCTION select_user_roles(in_user_id integer)
 RETURNS TABLE(id integer, role text)
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
    SELECT role_id, role_name(role_id) FROM auth_role_user WHERE user_id = $1;
$function$;

----------------------------------
---                            ---
---          ASSIGN ROLE       ---
---                            ---
----------------------------------

---
CREATE OR REPLACE FUNCTION user_assign_role(in_user_id integer, in_role_id integer) RETURNS boolean AS $$
DECLARE
    _id integer;
BEGIN
--	RAISE NOTICE 'entering role_assign function';
	SELECT role_id FROM auth_role_user WHERE user_id = in_user_id AND role_id = in_role_id INTO _id;
--	RAISE NOTICE 'id: %', _id;
--	RAISE NOTICE 'in_user_id: %', in_user_id;
--    RAISE NOTICE 'in_role_id: %', in_role_id;
    IF NOT FOUND THEN
        INSERT INTO auth_role_user (user_id, role_id) VALUES (in_user_id, in_role_id);
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;
$$ LANGUAGE 'plpgsql';

---
CREATE OR REPLACE FUNCTION user_assign_role(customer_name text, username text, rolename text)
 RETURNS boolean
 LANGUAGE sql
 VOLATILE STRICT
AS $function$
    SELECT user_assign_role(user_id($1, $2), role_id($3));
$function$;

----------------------------------
---                            ---
---          REVOKE ROLE       ---
---                            ---
----------------------------------

---
CREATE OR REPLACE FUNCTION user_revoke_role(in_user_id integer, in_role_id integer) RETURNS boolean AS $$
DECLARE
    _id integer;
BEGIN
	SELECT role_id FROM auth_role_user WHERE user_id = in_user_id AND role_id = in_role_id INTO _id;
    IF NOT FOUND THEN
        RETURN FALSE;
    ELSE
        DELETE FROM auth_role_user WHERE user_id = in_user_id AND role_id = in_role_id;
        RETURN TRUE;
    END IF;
END;
$$ LANGUAGE 'plpgsql';

---
CREATE OR REPLACE FUNCTION user_revoke_role(customer_name text, username text, rolename text)
 RETURNS boolean
 LANGUAGE sql
 VOLATILE STRICT
AS $function$
        SELECT user_revoke_role(user_id($1, $2), role_id($3));
$function$;




---
--- action
---
----------------------------------
---                            ---
---        ACTION SELECTs      ---
---                            ---
----------------------------------
---
CREATE OR REPLACE FUNCTION action_id(action_name text)
 RETURNS integer
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
    SELECT class_id('action', $1);
$function$;


---
CREATE OR REPLACE FUNCTION action_id(action_category_name text, action_name text) RETURNS integer AS $$
DECLARE
    _id integer;
BEGIN
    IF action_category_name = 'action' THEN
        SELECT action_id(action_name) INTO _id;
        RETURN _id;
    ELSE
        SELECT class_id(action_id(action_category_name), action_name) INTO _id;
        RETURN _id;
    END IF;
END;
$$ LANGUAGE 'plpgsql';


---
CREATE OR REPLACE FUNCTION action_name(action_id integer)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
    SELECT class_name($1);
$function$;

---
CREATE OR REPLACE FUNCTION action_get_parent(action_id integer)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
    SELECT class_name(parent_id) FROM class WHERE id = $1;
$function$;

---
CREATE OR REPLACE FUNCTION action_get_children(action_id integer)
 RETURNS TABLE(category text, action text)
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$
    SELECT class_name(parent_id), name FROM class WHERE parent_id = $1;
$function$;


----------------------------------
---                            ---
---        ACTION ADD          ---
---                            ---
----------------------------------
CREATE OR REPLACE FUNCTION action_add(action_category_name text, action_name text) RETURNS integer AS $$
DECLARE
    _cat_id integer;
    _id integer;
BEGIN
--	RAISE NOTICE 'entering role_add function';

	SELECT action_id(action_category_name) INTO _cat_id;
--    RAISE NOTICE '_cat_id: %', _cat_id;
    IF _cat_id IS NULL THEN
        RAISE EXCEPTION 'Nonexistent action category --> %', action_category_name
              USING HINT = 'Please create action category first';
    END IF;

    SELECT action_id(action_category_name, action_name) INTO _id;
    IF _id IS NULL THEN
        SELECT class_add(_cat_id,action_name) INTO _id;
    END IF;
    RETURN _id;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION action_add(action_name text) RETURNS integer AS $$
DECLARE
    _id integer;
BEGIN
    SELECT action_id(action_name) INTO _id;
    IF _id IS NULL THEN
        SELECT class_add('action',action_name) INTO _id;
    END IF;
    RETURN _id;
END;
$$ LANGUAGE 'plpgsql';

---
CREATE OR REPLACE FUNCTION action_remove(action_name text)
 RETURNS boolean
 LANGUAGE sql
 VOLATILE STRICT
AS $function$
    DELETE FROM class WHERE id = action_id($1) RETURNING TRUE;
$function$;
---
CREATE OR REPLACE FUNCTION action_remove(action_category_name text, action_name text)
 RETURNS boolean
 LANGUAGE sql
 VOLATILE STRICT
AS $function$
    DELETE FROM class WHERE id = action_id($1, $2) RETURNING TRUE;
$function$;


----------------------------------
---                            ---
---       ACTIONS TO ROLES     ---
---                            ---
----------------------------------

CREATE OR REPLACE FUNCTION role_assign_action(in_role_id integer, in_action_id integer) RETURNS boolean AS $$
DECLARE
   _id integer;
BEGIN
    SELECT action_id FROM auth_role_action WHERE role_id = in_role_id AND action_id = in_action_id INTO _id;
    IF NOT FOUND THEN
        INSERT INTO auth_role_action (role_id, action_id) VALUES (in_role_id, in_action_id);
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;
$$ LANGUAGE 'plpgsql';

---
CREATE OR REPLACE FUNCTION role_assign_action(in_role_name text, in_action_category_name text)
 RETURNS boolean
 LANGUAGE sql
 VOLATILE STRICT
AS $function$
    SELECT role_assign_action(role_id($1), action_id($2));
$function$;


---
CREATE OR REPLACE FUNCTION role_assign_action(in_role_name text, in_action_category_name text, in_action_name text)
 RETURNS boolean
 LANGUAGE sql
 VOLATILE STRICT
AS $function$
    SELECT role_assign_action(role_id($1), action_id($2, $3));
$function$;



----------------------------------
---                            ---
---        USER ACTIONS        ---
---                            ---
----------------------------------

---
CREATE OR REPLACE FUNCTION select_user_actions(in_user_id integer) RETURNS TABLE(category text, action text) AS $$
DECLARE
    _cat text;
    _act text;
BEGIN
    for _cat,_act in SELECT aua.category, aua.action FROM auth_user_action as aua WHERE user_id = in_user_id loop
        IF _cat = 'action' THEN
            return query SELECT a.category, a.action FROM action_get_children(action_id(_act)) as a;
        ELSE
            return query SELECT _cat, _act;
        END IF;
    end loop;
    return;
END;
$$ LANGUAGE 'plpgsql';
---
CREATE OR REPLACE FUNCTION select_user_actions_full(in_user_id integer) RETURNS TABLE(category text, action text) AS $$
DECLARE
    _cat text;
    _act text;
BEGIN
    for _cat,_act in SELECT aua.category, aua.action FROM auth_user_action as aua WHERE user_id = in_user_id loop
        IF _cat = 'action' THEN
            return query SELECT _cat, _act;
            return query SELECT a.category, a.action FROM action_get_children(action_id(_act)) as a;
        ELSE
            return query SELECT _cat, _act;
        END IF;
    end loop;
    return;
END;
$$ LANGUAGE 'plpgsql';











-- logs
CREATE TABLE global_log_referer (
    time            timestamp  NOT NULL DEFAULT now(),
    accesspoint     text       NOT NULL,
    referer_id      integer    NOT NULL REFERENCES customer(id) ON UPDATE CASCADE ON DELETE CASCADE,
    http_referer    text       NULL,
    ip              cidr       NULL
);
CREATE TABLE global_log_access (
    time            timestamp  NOT NULL DEFAULT now(),
    user_id         integer    NULL REFERENCES auth_user(id) ON UPDATE CASCADE ON DELETE CASCADE,
    accesspoint     text       NOT NULL,
    params          text       NULL,
    referer         text       NULL
);
CREATE INDEX glaxs_time ON global_log_access (date_trunc('second', time));
CREATE TABLE global_log_action (
    time            timestamp   NOT NULL DEFAULT now(),
    user_id         integer     NULL REFERENCES auth_user(id) ON UPDATE CASCADE ON DELETE CASCADE,
    action_id       integer     NULL,
    object_id       integer     NULL,
    action          text        NOT NULL,
    link            text        NULL
);
CREATE INDEX glact_time ON global_log_action (date_trunc('second', time));

-- static
CREATE TABLE static_block (
    id       integer      NOT NULL DEFAULT nextval('id')        primary key,
    lang_id  integer      NOT NULL REFERENCES class(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    name     text         NOT NULL,
    text     text         NOT NULL
);

-- tags
CREATE TABLE tag (
    id        integer NOT NULL DEFAULT nextval('id')      primary key,
    name      text    NOT NULL,
    keyword   text    NOT NULL
);
CREATE INDEX title ON tag USING hash (name);
CREATE INDEX keyword ON tag USING btree (name, keyword);

--tag2item
CREATE TABLE tag2item (
    item_id   integer NOT NULL,
    tag_id    integer NOT NULL REFERENCES tag(id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT tag2item_pk PRIMARY KEY (item_id, tag_id)
);
CREATE INDEX tag2item_item_id ON tag2item USING btree (item_id);


CREATE VIEW auth_user_action AS
    SELECT DISTINCT ON (user_id, category, action) user_id, role_name(role_id) as role, action_name(action_id) as action, action_get_parent(action_id) as category
        FROM auth_role_action as ara
        JOIN auth_role_user as aru USING (role_id)
;

CREATE VIEW auth_role AS
    SELECT id, name FROM class WHERE parent_id = class_id('', 'role')
;

CREATE VIEW view_user AS
    SELECT (CASE WHEN username != '' THEN login || '-' || username ELSE login END) as username FROM auth_user as au LEFT JOIN customer as c ON (c.id = au.customer_id) WHERE au.active = TRUE AND c.status_id = status_id('customer', 'active')
;






SELECT class_add('','lang');
SELECT class_add(class_id('', 'lang'),'en');
SELECT class_add(class_id('', 'lang'),'ru');

SELECT class_add('','status');

SELECT status_add('customer');
SELECT status_add('customer','new');
SELECT status_add('customer','active');
SELECT status_add('customer','blocked');
SELECT status_add('customer','deleted');

SELECT class_add('','type');

SELECT type_add('customer');
SELECT type_add('customer','root');
SELECT type_add('customer','user');
SELECT type_add('customer','free');

SELECT class_add('','role');
SELECT class_add('','action');


--ROLES
SELECT role_add('root');
SELECT role_add('admin');
SELECT role_add('user');

--ACTIONS
SELECT action_add('root');
SELECT action_add('root','edit');
SELECT action_add('root','logs');
SELECT action_add('root','sudo');
SELECT action_add('root','customerlist');
SELECT action_add('root','customermanage');
SELECT action_add('root','customerdelete');

SELECT action_add('auth');
SELECT action_add('auth','register');
SELECT action_add('auth','userlist');
SELECT action_add('auth','edit');
SELECT action_add('auth','delete');

SELECT action_add('comment');
SELECT action_add('comment','add');
SELECT action_add('comment','edit');
SELECT action_add('comment','delete');

SELECT action_add('api');
SELECT action_add('api','request');

--ROLES ACTIONS
SELECT role_assign_action('root','root');
SELECT role_assign_action('admin','auth');
SELECT role_assign_action('admin','comment');
SELECT role_assign_action('user','comment', 'add');


-- USERS
INSERT INTO customer (login, status_id, type_id) VALUES ('root', status_id('customer', 'active'), type_id('customer', 'root'));
INSERT INTO auth_user (customer_id, username, password, active, email) VALUES (customer_id('root'), 'tigra','61f0875e5816ec6f15154f52a06362f7c6838707','TRUE','const@nazarenko.me');

SELECT user_assign_role('root','tigra', 'root');
SELECT user_assign_role('root','tigra', 'admin');




----------------------------------
---                            ---
---          COMMENTS          ---
---                            ---
----------------------------------
-- comments
CREATE TABLE global_comment (
    id              bigint                  NOT NULL DEFAULT nextval('id')  primary key,
    parent          bigint                  NULL                            references global_comment(id) ON UPDATE CASCADE ON DELETE CASCADE,
    leftkey         bigint                  NOT NULL,
    rightkey        bigint                  NOT NULL,
    level           integer                 NOT NULL DEFAULT 1,
    tree            bigint                  NOT NULL,
    _trigger_lock   boolean                 NOT NULL DEFAULT FALSE,

    user_id        bigint                  NULL                            references auth_user(id) ON UPDATE CASCADE ON DELETE CASCADE,
    text            text                    NOT NULL,
    date            timestamp               NOT NULL DEFAULT now(),
    keyword         character varying(256)  NOT NULL,
    deleted         boolean                 NOT NULL DEFAULT FALSE,
    system          boolean                 NOT NULL DEFAULT FALSE
);
CREATE INDEX global_comment_keyword_tree ON global_comment USING btree (keyword, tree);
SELECT now()::timestamp without time zone AS old_time,* INTO global_comment_del FROM global_comment LIMIT 0;
SELECT now()::timestamp without time zone AS old_time,* INTO global_comment_old FROM global_comment LIMIT 0;

CREATE TABLE global_comment_subscribe (
    keyword         character varying(256)  NOT NULL,
    tree            bigint                  NOT NULL,
    user_id        bigint                  NOT NULL    references auth_user(id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT global_comment_subscribe_pk PRIMARY KEY (keyword, tree, user_id)
);
CREATE TABLE global_comment_read (
    keyword         character varying(256)  NOT NULL,
    tree            bigint                  NOT NULL,
    user_id        bigint                  NOT NULL    references auth_user(id) ON UPDATE CASCADE ON DELETE CASCADE,
    read            timestamp               NULL        DEFAULT now(),
    CONSTRAINT global_comment_read_pk PRIMARY KEY (keyword, tree, user_id)
);
CREATE TABLE global_comment_hidden (
    id          bigint                  NOT NULL    references global_comment(id) ON UPDATE CASCADE ON DELETE CASCADE,
    user_id    bigint                  NOT NULL    references auth_user(id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT global_comment_hidden_pk PRIMARY KEY (id, user_id)
);
CREATE TABLE global_comment_starred (
    id          bigint                  NOT NULL    references global_comment(id) ON UPDATE CASCADE ON DELETE CASCADE,
    user_id    bigint                  NOT NULL    references auth_user(id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT global_comment_starred_pk PRIMARY KEY (id, user_id)
);
CREATE TABLE global_comment_attachments (
    id          bigint                  NOT NULL DEFAULT nextval('id')  primary key,
    comm_id     bigint                  NOT NULL                        references global_comment(id) ON UPDATE CASCADE ON DELETE CASCADE,
    xml         text                    NOT NULL,
    type        character varying(255)  NOT NULL,
    title       character varying(255)  NOT NULL,
    taken       timestamp               NULL,
    uploaded    timestamp               NOT NULL DEFAULT now()
);


CREATE OR REPLACE FUNCTION lock_ns_tree(tablename text, tree_id bigint) RETURNS boolean AS $$
DECLARE
    _id bigint;
BEGIN
    EXECUTE 'SELECT id FROM '||tablename||' WHERE tree = $1 FOR UPDATE' USING tree_id INTO _id;
    RETURN TRUE;
END;
$$ LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION fn_change_property (
    tablename   text,
    item_id     bigint,
    property    text,
    newvalue    text
) RETURNS int AS $$
DECLARE
    _id bigint;
BEGIN
    EXECUTE 'SELECT id FROM '||tablename||' WHERE id = $1 AND '||property||' = $2' USING item_id::bigint, newvalue::bigint INTO _id;
    IF _id IS NULL THEN
        EXECUTE 'UPDATE '||tablename||' SET '||property||' = $2 WHERE id = $1'USING item_id::bigint, newvalue::bigint ;
    END IF;
    RETURN _id;
END;
$$ LANGUAGE plpgsql VOLATILE CALLED ON NULL INPUT;


CREATE OR REPLACE FUNCTION ns_tree_move_up (
    tablename   text,
    id    bigint
) RETURNS boolean AS $$
DECLARE
    _id bigint;
    _parent int;
    _leftkey bigint;
    _rightkey bigint;
    n_id bigint;
    n_leftkey bigint;
    n_rightkey bigint;
    l_diff bigint;
    r_diff bigint;
BEGIN
    RAISE NOTICE 'entering move-up function';
    EXECUTE 'SELECT id, parent, leftkey, rightkey FROM '||tablename||' WHERE id = $1' USING id INTO _id, _parent, _leftkey, _rightkey;
    IF _parent IS NULL THEN
        EXECUTE 'SELECT id, leftkey, rightkey FROM '||tablename||' WHERE parent IS NULL AND leftkey < $2 ORDER BY leftkey DESC LIMIT 1' USING _parent, _leftkey INTO n_id, n_leftkey, n_rightkey;
    ELSE
        EXECUTE 'SELECT id, leftkey, rightkey FROM '||tablename||' WHERE parent = $1 AND leftkey < $2 ORDER BY leftkey DESC LIMIT 1' USING _parent, _leftkey INTO n_id, n_leftkey, n_rightkey;
    END IF;

    RAISE NOTICE 'id of element to switch with - %', n_id;

    IF n_id IS NOT NULL THEN
        RAISE NOTICE 'it"s ok to move';
        l_diff = _leftkey - n_leftkey;
        r_diff = _rightkey - n_rightkey;
        EXECUTE 'UPDATE '||tablename||'
                    SET
                    leftkey =
                    CASE WHEN leftkey >= $4
                      THEN leftkey - $1
                      ELSE leftkey + $2
                    END,
                    rightkey =
                    CASE WHEN leftkey >= $4
                      THEN rightkey - $1
                      ELSE rightkey + $2
                    END
                    WHERE leftkey >= $3 AND rightkey <= $5'
        USING l_diff, r_diff, n_leftkey, _leftkey,_rightkey;
        RETURN TRUE;
    END IF;
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql VOLATILE CALLED ON NULL INPUT;


CREATE OR REPLACE FUNCTION ns_tree_move_down (
    tablename   text,
    id    bigint
) RETURNS boolean AS $$
DECLARE
    _id bigint;
    n_parent int;
    _leftkey bigint;
    _rightkey bigint;
    n_id bigint;
    n_leftkey bigint;
    n_rightkey bigint;
    l_diff bigint;
    r_diff bigint;
BEGIN
    RAISE NOTICE 'entering move-down function';
    EXECUTE 'SELECT id, parent, leftkey, rightkey FROM '||tablename||' WHERE id = $1' USING id INTO n_id, n_parent, n_leftkey, n_rightkey;
    IF n_parent IS NULL THEN
        EXECUTE 'SELECT id, leftkey, rightkey FROM '||tablename||' WHERE parent IS NULL AND leftkey = $2 + 1 ORDER BY leftkey DESC LIMIT 1' USING n_parent, n_rightkey INTO _id, _leftkey, _rightkey;
    ELSE
        EXECUTE 'SELECT id, leftkey, rightkey FROM '||tablename||' WHERE parent = $1 AND leftkey = $2 + 1 ORDER BY leftkey DESC LIMIT 1' USING n_parent, n_rightkey INTO _id, _leftkey, _rightkey;
    END IF;
    RAISE NOTICE 'id of element to switch with - %', _id;

    IF _id IS NOT NULL THEN
        RAISE NOTICE 'it"s ok to move';
        l_diff = _leftkey - n_leftkey;
        r_diff = _rightkey - n_rightkey;
        EXECUTE 'UPDATE '||tablename||'
                    SET
                    leftkey =
                    CASE WHEN leftkey >= $4
                      THEN leftkey - $1
                      ELSE leftkey + $2
                    END,
                    rightkey =
                    CASE WHEN leftkey >= $4
                      THEN rightkey - $1
                      ELSE rightkey + $2
                    END
                    WHERE leftkey >= $3 AND rightkey <= $5'
        USING l_diff, r_diff, n_leftkey, _leftkey,_rightkey;
        RETURN TRUE;
    END IF;
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql VOLATILE CALLED ON NULL INPUT;


/* comments read time */
CREATE OR REPLACE FUNCTION comments_read(in_keyword TEXT, in_tree INT, in_user_id INT) RETURNS VOID AS
$$
DECLARE
    newid bigint;
BEGIN
    -- first try to update the key
    UPDATE global_comment_read SET read = NOW() WHERE keyword = keyword AND tree = in_tree AND user_id = in_user_id RETURNING user_id INTO newid;
    IF newid IS NOT NULL THEN
        RETURN;
    END IF;
    -- not there, so try to insert the key
    -- if someone else inserts the same key concurrently,
    -- we could get a unique-key failure
    BEGIN
        INSERT INTO global_comment_read(keyword, tree, user_id) VALUES (in_keyword, in_tree, in_user_id);
        RETURN;
    EXCEPTION WHEN unique_violation THEN
        -- do nothing, and loop to try the UPDATE again
    END;
END;
$$
LANGUAGE plpgsql;





/* INSERT INTO NESTED SETS TREE */
CREATE OR REPLACE FUNCTION ns_tree_before_insert () RETURNS "trigger" AS $$
DECLARE
    _leftkey      INTEGER;
    _level        INTEGER;
    _tmp_leftkey  INTEGER;
    _tmp_rightkey INTEGER;
    _tmp_level    INTEGER;
    _tmp_id       INTEGER;
    _tmp_parent   INTEGER;
BEGIN
    PERFORM lock_ns_tree(TG_RELNAME,NEW.tree);
    -- reseting fields for thechnical porposes
    NEW._trigger_lock := FALSE;
    _leftkey := 0;
    _level := 1;
    -- if parent was defined
    IF NEW.parent IS NOT NULL THEN
        --RAISE NOTICE 'Selecting by parent';
        EXECUTE 'SELECT rightkey, level + 1
                 FROM '||TG_RELNAME||'
                 WHERE id = $1 AND tree = $2'
        INTO _leftkey, _level
        USING NEW.parent, NEW.tree;
        --RAISE NOTICE 'Parent leftkey %',_leftkey;
    END IF;
    -- if lefkey was defined
    IF NEW.leftkey IS NOT NULL AND NEW.leftkey > 0 AND (_leftkey IS NULL OR _leftkey = 0) THEN
        EXECUTE 'SELECT id, leftkey, rightkey, level, parent
                 FROM '||TG_RELNAME||'
                 WHERE tree = $1 AND (leftkey = $2 OR rightkey = $2)'
        INTO _tmp_id, _tmp_leftkey, _tmp_rightkey, _tmp_level, _tmp_parent
        USING NEW.tree, NEW.leftkey;

        IF _tmp_leftkey IS NOT NULL AND _tmp_leftkey > 0 AND NEW.leftkey = _tmp_leftkey THEN
            NEW.parent := _tmp_parent;
            _leftkey := NEW.leftkey;
            _level := _tmp_level;
        ELSIF _tmp_leftkey IS NOT NULL AND _tmp_leftkey > 0 AND NEW.leftkey = _tmp_rightkey THEN
            NEW.parent := _tmp_id;
            _leftkey := NEW.leftkey;
            _level := _tmp_level + 1;
        END IF;

    END IF;
    -- if there are neither parent or leftkey, or they're not in DB
    IF _leftkey IS NULL OR _leftkey = 0 THEN
        --RAISE NOTICE '_leftkey is null or 0';

        EXECUTE 'SELECT MAX(rightkey) + 1
                FROM '||TG_RELNAME||'
                WHERE tree = $1'
        INTO _leftkey
        USING NEW.tree;

        IF _leftkey IS NULL OR _leftkey = 0 THEN
            _leftkey := 1;
        END IF;
        _level := 1;
        NEW.parent := NULL;
    END IF;
    -- seting new values for keys
    NEW.leftkey := _leftkey;
    NEW.rightkey := _leftkey + 1;
    NEW.level := _level;
    -- creating a slot for the row
    --RAISE NOTICE 'updating with new keys';
    EXECUTE 'UPDATE '||TG_RELNAME||'
        SET leftkey = leftkey +
        CASE WHEN leftkey >= $1
          THEN 2
          ELSE 0
        END,
        rightkey = rightkey + 2,
        _trigger_lock = TRUE
        WHERE tree = $2 AND rightkey >= $1'
    USING _leftkey, NEW.tree;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


/* CHANGE RECORD IN THE NESTED SETS TREE */
CREATE OR REPLACE FUNCTION ns_tree_before_update () RETURNS "trigger" AS $$
DECLARE
    _leftkey       INTEGER;
    _level         INTEGER;
    _skew_tree     INTEGER;
    _skew_level    INTEGER;
    _skew_edit     INTEGER;
    _tmp_leftkey   INTEGER;
    _tmp_rightkey  INTEGER;
    _tmp_level     INTEGER;
    _tmp_id        INTEGER;
    _tmp_parent    INTEGER;
BEGIN
    -- checking if there are tree structure changes
    IF NEW.parent = OLD.parent OR (NEW.parent IS NULL AND OLD.parent IS NULL) THEN
        --RAISE NOTICE 'Structure has no changes. Returning.';
        RETURN NEW;
    END IF;
    --RAISE NOTICE 'Structure has changes. Rebuilding structure.';

    -- if parent has changed...
    -- ...to other one
    IF NEW.parent IS NOT NULL THEN
        --RAISE NOTICE 'parent has changed to other one.';
        EXECUTE 'SELECT rightkey, level + 1
               FROM '||TG_RELNAME||'
               WHERE id = $1 AND tree = $2'
        INTO _leftkey, _level
        USING NEW.parent, OLD.tree;
    -- ...or to root
    ELSE
        --RAISE NOTICE 'parent has changed to root.';
        EXECUTE 'SELECT MAX(rightkey) + 1
               FROM '||TG_RELNAME||'
               WHERE tree = $1'
        INTO _leftkey
        USING OLD.tree;
        _level := 1;
    END IF;

    -- if parent in the range of current node
    IF _leftkey IS NOT NULL AND
       _leftkey > 0 AND
       _leftkey > OLD.leftkey AND
       _leftkey <= OLD.rightkey
    THEN
       NEW.parent := OLD.parent;
       RETURN NEW;
    END IF;

    _skew_tree := OLD.rightkey - OLD.leftkey + 1;

    -- now we can move node...
    _skew_level := _level - OLD.level;
    IF _leftkey > OLD.leftkey THEN
        -- ...up
        _skew_edit := _leftkey - OLD.leftkey - _skew_tree;
        EXECUTE 'UPDATE '||TG_RELNAME||'
            SET leftkey = CASE WHEN rightkey <= $1
                                 THEN leftkey + $2
                                 ELSE CASE WHEN leftkey > $1
                                           THEN leftkey - $3
                                           ELSE leftkey
                                      END
                            END,
                level =  CASE WHEN rightkey <= $1
                                 THEN level + $4
                                 ELSE level
                            END,
                rightkey = CASE WHEN rightkey <= $1
                                 THEN rightkey + $2
                                 ELSE CASE WHEN rightkey < $5
                                           THEN rightkey - $3
                                           ELSE rightkey
                                      END
                            END
            WHERE tree = $6 AND
                  rightkey > $7 AND
                  leftkey < $5 AND
                  id <> $8'
        USING OLD.rightkey, _skew_edit, _skew_tree, _skew_level, _leftkey, OLD.tree, OLD.leftkey, OLD.id;
        _leftkey := _leftkey - _skew_tree;
    ELSE
        -- ...down
        _skew_edit := _leftkey - OLD.leftkey;
         EXECUTE 'UPDATE '||TG_RELNAME||'
            SET rightkey = CASE WHEN leftkey >= $1
                                 THEN rightkey + $2
                                 ELSE CASE WHEN rightkey < $1
                                           THEN rightkey + $3
                                           ELSE rightkey
                                      END
                            END,
                level =   CASE WHEN leftkey >= $1
                                 THEN level + $4
                                 ELSE level
                            END,
                leftkey =  CASE WHEN leftkey >= $1
                                 THEN leftkey + $2
                                 ELSE CASE WHEN leftkey >= $5
                                           THEN leftkey + $3
                                           ELSE leftkey
                                      END
                            END
            WHERE tree = $6 AND
                  rightkey >= $5 AND
                  leftkey < $7 AND
                  id <> $8'
        USING OLD.leftkey, _skew_edit, _skew_tree, _skew_level, _leftkey, OLD.tree, OLD.rightkey, OLD.id;
    END IF;
    -- after tree's structure changed, changing current node
    NEW.leftkey := _leftkey;
    NEW.level := _level;
    NEW.rightkey := _leftkey + _skew_tree - 1;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


/* DELETE RECORD FROM THE NESTED SETS TREE */
CREATE OR REPLACE FUNCTION ns_tree_after_delete () RETURNS "trigger" AS $$
DECLARE
    _skew_tree INTEGER;
BEGIN
    PERFORM lock_ns_tree(TG_RELNAME, OLD.tree);
    EXECUTE 'UPDATE '||TG_RELNAME||'
        SET leftkey = CASE WHEN leftkey < $1
                            THEN leftkey
                            ELSE CASE WHEN rightkey < $2
                                      THEN leftkey - 1
                                      ELSE leftkey - 2
                                 END
                       END,
            level = CASE WHEN rightkey < $2
                           THEN level - 1
                           ELSE level
                      END,
            parent = CASE WHEN rightkey < $2 AND level = $3 + 1
                           THEN $4
                           ELSE parent
                        END,
            rightkey = CASE WHEN rightkey < $2
                             THEN rightkey - 1
                             ELSE rightkey - 2
                        END,
            _trigger_lock = TRUE
        WHERE (rightkey > $2 OR
            (leftkey > $1 AND rightkey < $2)) AND
            tree = $5'
    USING OLD.leftkey, OLD.rightkey, OLD.level, OLD.parent, OLD.tree;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

/* COMMENTS */
/* loggin deleted comments */
CREATE OR REPLACE FUNCTION glb_cmmts_before_delete () RETURNS "trigger" AS $$
BEGIN
    INSERT INTO global_comment_del SELECT now(),* FROM global_comment WHERE id=OLD.id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
/* loggin updated comments */
CREATE OR REPLACE FUNCTION glb_cmmts_before_update () RETURNS "trigger" AS $$
BEGIN
    INSERT INTO global_comment_old SELECT now(),* FROM global_comment WHERE id=OLD.id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
/* subscribing for comments */
CREATE OR REPLACE FUNCTION glb_cmmts_subscribe_bi () RETURNS "trigger" AS $$
DECLARE
    _id bigint;
BEGIN
    SELECT user_id FROM global_comment_subscribe WHERE keyword=NEW.keyword AND tree=NEW.tree AND user_id=NEW.user_id INTO _id;
    IF _id IS NOT NULL THEN
        DELETE FROM global_comment_subscribe WHERE keyword=NEW.keyword AND tree=NEW.tree AND user_id=NEW.user_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
/* ^COMMENTS^ */


-- global_comment triggers
CREATE TRIGGER ns_tree_after_delete         AFTER  DELETE   ON global_comment      FOR EACH ROW    EXECUTE PROCEDURE ns_tree_after_delete();
CREATE TRIGGER ns_tree_before_insert        BEFORE INSERT   ON global_comment      FOR EACH ROW    EXECUTE PROCEDURE ns_tree_before_insert();
CREATE TRIGGER ns_tree_before_update        BEFORE UPDATE   ON global_comment      FOR EACH ROW    EXECUTE PROCEDURE ns_tree_before_update();
CREATE TRIGGER glb_cmmts_before_delete      BEFORE DELETE   ON global_comment      FOR EACH ROW    EXECUTE PROCEDURE glb_cmmts_before_delete();
CREATE TRIGGER glb_cmmts_before_update      BEFORE UPDATE   ON global_comment      FOR EACH ROW    EXECUTE PROCEDURE glb_cmmts_before_update();

CREATE TRIGGER glb_cmmts_subscribe_bi       BEFORE INSERT   ON global_comment_subscribe        FOR EACH ROW    EXECUTE PROCEDURE glb_cmmts_subscribe_bi();