SET foreign_key_checks = 0;

DROP TABLE IF EXISTS class CASCADE;
CREATE TABLE class (
    id         int(11)  NOT NULL AUTO_INCREMENT,
    parent_id  int(11)  NOT NULL,
    name       text     NOT NULL,
    PRIMARY KEY (id),
    INDEX (name(255)),
    CONSTRAINT FOREIGN KEY (parent_id) REFERENCES class(id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
INSERT INTO class (id, parent_id, name) VALUES (1,1,'');

DROP FUNCTION IF EXISTS class_id;
delimiter //

CREATE FUNCTION class_id(parent_class_name text, class_name text)
    RETURNS integer
    LANGUAGE sql
    DETERMINISTIC
BEGIN
    RETURN (SELECT c1.id FROM class c1 JOIN class c2 ON c1.parent_id = c2.id WHERE c1.name = class_name AND c2.name = parent_class_name ORDER BY c1.id ASC LIMIT 1);
END//
delimiter ;


DROP FUNCTION IF EXISTS class_id_pid;
delimiter //

CREATE FUNCTION class_id_pid(parent_class_id integer, class_name text)
    RETURNS integer
    LANGUAGE sql
    DETERMINISTIC
BEGIN
    RETURN (SELECT c1.id FROM class c1 JOIN class c2 ON c1.parent_id = c2.id WHERE c1.name = class_name AND c2.id = parent_class_id ORDER BY c1.id ASC LIMIT 1);
END//
delimiter ;



DROP FUNCTION IF EXISTS class_name;
delimiter //

CREATE FUNCTION class_name(in_class_id integer)
    RETURNS text
    LANGUAGE sql
    DETERMINISTIC
BEGIN
    RETURN (SELECT name FROM class WHERE id = in_class_id);
END//
delimiter ;




DROP FUNCTION IF EXISTS class_add;
delimiter //
CREATE FUNCTION class_add(in_parent_name text, in_name text)
    RETURNS integer
    LANGUAGE sql
    DETERMINISTIC
BEGIN
DECLARE obj_id  INTEGER;

    SET obj_id = (SELECT id FROM class WHERE parent_id = class_id('', in_parent_name) AND name = in_name);
    IF obj_id IS NOT NULL THEN
        RETURN obj_id;
    END IF;

    INSERT INTO class (parent_id, name) VALUES (class_id('', in_parent_name), in_name);

    RETURN (SELECT LAST_INSERT_ID());
END//
delimiter ;

DROP FUNCTION IF EXISTS class_add_pid;
delimiter //
CREATE FUNCTION class_add_pid(in_parent_id integer, in_name text)
    RETURNS integer
    LANGUAGE sql
    DETERMINISTIC
BEGIN
DECLARE obj_id  INTEGER;

    SET obj_id = (SELECT id FROM class WHERE parent_id = in_parent_id AND name = in_name);
    IF obj_id IS NOT NULL THEN
        RETURN obj_id;
    END IF;

    INSERT INTO class (parent_id, name) VALUES (in_parent_id, in_name);

    RETURN (SELECT LAST_INSERT_ID());
END//
delimiter ;





DROP FUNCTION IF EXISTS lang_id;
delimiter //
CREATE FUNCTION lang_id(lang_name text)
	RETURNS integer
	LANGUAGE sql
    DETERMINISTIC
BEGIN
    RETURN (SELECT class_id('lang', lang_name));
END//
delimiter ;


DROP FUNCTION IF EXISTS lang_name;
delimiter //
CREATE FUNCTION lang_name(lang_id integer)
    RETURNS text
    LANGUAGE sql
    DETERMINISTIC
BEGIN
    RETURN (SELECT class_name(lang_id));
END//
delimiter ;



DROP FUNCTION IF EXISTS status_id;
delimiter //
CREATE FUNCTION status_id(parent_name text, in_name text)
    RETURNS integer
    LANGUAGE sql
    DETERMINISTIC
BEGIN
    RETURN (SELECT class_id_pid(class_id('status', parent_name), in_name));
END//
delimiter ;



DROP FUNCTION IF EXISTS status_name;
delimiter //
CREATE FUNCTION status_name(in_id integer)
    RETURNS text
    LANGUAGE sql
    DETERMINISTIC
BEGIN
    RETURN (SELECT class_name(in_id));
END//
delimiter ;



DROP FUNCTION IF EXISTS status_add;
delimiter //
CREATE FUNCTION status_add(in_category_name text, in_name text)
    RETURNS integer
    LANGUAGE sql
    DETERMINISTIC
BEGIN
    DECLARE _id integer;

    IF (SELECT class_id('status', in_category_name)) IS NULL THEN
        RETURN NULL;
    END IF;

    SET _id = (SELECT status_id(in_category_name, in_name));

    IF _id IS NULL THEN
        INSERT INTO class (parent_id, name) VALUES (class_id('status', in_category_name), in_name);

        SET _id = (SELECT LAST_INSERT_ID());
    END IF;

    RETURN _id;
END//
delimiter ;



DROP FUNCTION IF EXISTS status_category_add;
delimiter //
CREATE FUNCTION status_category_add(in_category_name text)
    RETURNS integer
    LANGUAGE sql
    DETERMINISTIC
BEGIN
    DECLARE _id integer;

    SET _id = (SELECT class_id('status',in_category_name));
    IF _id IS NULL THEN
        SET _id = (SELECT class_add('status',in_category_name));
    END IF;
    RETURN _id;
END//
delimiter ;



DROP FUNCTION IF EXISTS status_remove;
delimiter //
CREATE FUNCTION status_remove(in_category_name text, in_name text)
    RETURNS BOOLEAN
    LANGUAGE sql
    DETERMINISTIC
BEGIN
    DELETE FROM class WHERE id = status_id(in_category_name, in_name);
    RETURN TRUE;
END//
delimiter ;



DROP FUNCTION IF EXISTS status_category_remove;
delimiter //
CREATE FUNCTION status_category_remove(in_category_name text)
    RETURNS BOOLEAN
    LANGUAGE sql
    DETERMINISTIC
BEGIN
    DELETE FROM class WHERE  id = class_id('status', in_category_name);
    RETURN TRUE;
END//
delimiter ;







DROP FUNCTION IF EXISTS type_id;
delimiter //
CREATE FUNCTION type_id(parent_name text, type_name text)
    RETURNS integer
    LANGUAGE sql
    DETERMINISTIC
BEGIN
    RETURN (SELECT class_id_pid(class_id('type', parent_name), type_name));
END//
delimiter ;


DROP FUNCTION IF EXISTS type_name;
delimiter //
CREATE FUNCTION type_name(type_id integer)
    RETURNS text
    LANGUAGE sql
    DETERMINISTIC
BEGIN
    RETURN (SELECT class_name(type_id));
END//
delimiter ;



DROP FUNCTION IF EXISTS type_add;
delimiter //
CREATE FUNCTION type_add(type_category_name text, type_name text)
    RETURNS integer
    LANGUAGE sql
    DETERMINISTIC
BEGIN
    DECLARE _id integer;

    IF (SELECT class_id('type', type_category_name)) IS NULL THEN
        RETURN NULL;
    END IF;

    SET _id = (SELECT type_id(type_category_name, type_name));

    IF _id IS NULL THEN
        INSERT INTO class (parent_id, name) VALUES (class_id('type', type_category_name), type_name);

        SET _id = (SELECT LAST_INSERT_ID());
    END IF;

    RETURN _id;
END//
delimiter ;


DROP FUNCTION IF EXISTS type_category_add;
delimiter //
CREATE FUNCTION type_category_add(type_category_name text)
    RETURNS integer
    LANGUAGE sql
    DETERMINISTIC
BEGIN
    DECLARE _id integer;

    SET _id = (SELECT class_id('type',type_category_name));
    IF _id IS NULL THEN
        SET _id = (SELECT class_add('type',type_category_name));
    END IF;
    RETURN _id;
END//
delimiter ;


DROP FUNCTION IF EXISTS type_remove;
delimiter //
CREATE FUNCTION type_remove(type_category_name text, type_name text)
    RETURNS BOOLEAN
    LANGUAGE sql
    DETERMINISTIC
BEGIN
    DELETE FROM class WHERE id = type_id(type_category_name, type_name);
    RETURN TRUE;
END//
delimiter ;


DROP FUNCTION IF EXISTS type_category_remove;
delimiter //
CREATE FUNCTION type_category_remove(type_category_name text)
    RETURNS BOOLEAN
    LANGUAGE sql
    DETERMINISTIC
BEGIN
    DELETE FROM class WHERE  id = class_id('type', type_category_name);
    RETURN TRUE;
END//
delimiter ;








DROP TABLE IF EXISTS customer CASCADE;
CREATE TABLE customer (
    id         int(11)  NOT NULL AUTO_INCREMENT,
    referer_id int(11)  NULL,
    parent_id  int(11)  NULL,
    type_id    int(11)  NOT NULL,
    status_id  int(11)  NOT NULL,
    login      varchar(255)     NOT NULL UNIQUE,
    PRIMARY KEY (id),
    INDEX(login(255)),
    FOREIGN KEY (referer_id) REFERENCES customer(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (parent_id) REFERENCES customer(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (type_id) REFERENCES class(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (status_id) REFERENCES class(id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TRIGGER IF EXISTS bi_customer;
delimiter //
CREATE TRIGGER bi_customer BEFORE INSERT ON customer
FOR EACH ROW
BEGIN
    SET new.status_id = status_id('customer', 'new');
END//
delimiter ;


DROP FUNCTION IF EXISTS customer_id;
delimiter //
CREATE FUNCTION customer_id(in_customer_name text)
    RETURNS integer
    LANGUAGE sql
    DETERMINISTIC
BEGIN
    RETURN (SELECT id FROM customer WHERE login = in_customer_name);
END//
delimiter ;

DROP FUNCTION IF EXISTS customer_name;
delimiter //
CREATE FUNCTION customer_name(in_customer_id integer)
    RETURNS text
    LANGUAGE sql
    DETERMINISTIC
BEGIN
    RETURN (SELECT login FROM customer WHERE id = in_customer_id);
END//
delimiter ;







DROP TABLE IF EXISTS auth_user CASCADE;
CREATE TABLE auth_user (
    id             int(11)      NOT NULL AUTO_INCREMENT,
    customer_id    int(11)      NOT NULL,
    username       text         NOT NULL,
    password       text         NOT NULL,
    active         boolean      NOT NULL DEFAULT FALSE,
    email          text         NULL,
    skype          text         NULL,
    icq            text         NULL,
    lang_id        integer      NULL REFERENCES class(id) ON UPDATE CASCADE ON DELETE SET NULL,
    registered     timestamp    NOT NULL DEFAULT now(),
    lastvisit      timestamp    NULL,
    PRIMARY KEY (id),
    CONSTRAINT password_check CHECK (password <> ''),
    UNIQUE (customer_id, username(255)),
    FOREIGN KEY (customer_id) REFERENCES customer(id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS auth_role_action CASCADE;
CREATE TABLE auth_role_action (
    role_id    integer             NOT NULL,
    action_id  integer             NOT NULL,
    CONSTRAINT auth_role_action_pk PRIMARY KEY (role_id, action_id),
    FOREIGN KEY (role_id) REFERENCES class(id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (action_id) REFERENCES class(id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS auth_role_user CASCADE;
CREATE TABLE auth_role_user (
    user_id    integer    NOT NULL,
    role_id    integer    NOT NULL,
    PRIMARY KEY (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES auth_user(id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES class(id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP FUNCTION IF EXISTS user_id;
delimiter //
CREATE FUNCTION user_id(in_customer_name text, in_user_name text)
    RETURNS integer
    LANGUAGE sql
    DETERMINISTIC
BEGIN
    RETURN (SELECT id FROM auth_user WHERE username = in_user_name AND customer_id = customer_id(in_customer_name));
END//
delimiter ;

DROP FUNCTION IF EXISTS username;
delimiter //
CREATE FUNCTION username(in_user_id integer)
    RETURNS text
    LANGUAGE sql
    DETERMINISTIC
BEGIN
    RETURN (SELECT username FROM auth_user WHERE id = in_user_id);
END//
delimiter ;






DROP FUNCTION IF EXISTS role_add;
delimiter //
CREATE FUNCTION role_add(role_name text)
    RETURNS integer
    LANGUAGE sql
    DETERMINISTIC
BEGIN
    DECLARE _id integer;

    SET _id = (SELECT class_id('role',role_name));
    IF _id IS NULL THEN
        SET _id = (SELECT class_add('role',role_name));
    END IF;
    RETURN _id;
END//
delimiter ;


DROP FUNCTION IF EXISTS role_remove;
delimiter //
CREATE FUNCTION role_remove(role_name text)
    RETURNS BOOLEAN
    LANGUAGE sql
    DETERMINISTIC
BEGIN
    DELETE FROM class WHERE  id = class_id('type', role_name);
    RETURN TRUE;
END//
delimiter ;







DROP FUNCTION IF EXISTS role_id;
delimiter //
CREATE FUNCTION role_id(in_role_name text)
    RETURNS integer
    LANGUAGE sql
    DETERMINISTIC
BEGIN
    RETURN (SELECT class_id('role', in_role_name));
END//
delimiter ;

DROP FUNCTION IF EXISTS role_name;
delimiter //
CREATE FUNCTION role_name(in_role_id integer)
    RETURNS text
    LANGUAGE sql
    DETERMINISTIC
BEGIN
    RETURN (SELECT class_name(in_role_id));
END//
delimiter ;






DROP FUNCTION IF EXISTS user_assign_role;
delimiter //
CREATE FUNCTION user_assign_role(in_user_id integer, in_role_id integer)
    RETURNS boolean
    LANGUAGE sql
BEGIN
    DECLARE _id integer;

	SET _id = (SELECT role_id FROM auth_role_user WHERE user_id = in_user_id AND role_id = in_role_id);

    IF _id IS NULL THEN
        INSERT INTO auth_role_user (user_id, role_id) VALUES (in_user_id, in_role_id);
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END//
delimiter ;







DROP FUNCTION IF EXISTS user_revoke_role;
delimiter //
CREATE FUNCTION user_revoke_role(in_user_id integer, in_role_id integer)
    RETURNS boolean
    LANGUAGE sql
BEGIN
    DECLARE _id integer;
	SET _id = (SELECT role_id FROM auth_role_user WHERE user_id = in_user_id AND role_id = in_role_id);
    IF _id IS NULL THEN
        RETURN FALSE;
    ELSE
        DELETE FROM auth_role_user WHERE user_id = in_user_id AND role_id = in_role_id;
        RETURN TRUE;
    END IF;
END//
delimiter ;









DROP FUNCTION IF EXISTS action_id;
delimiter //
CREATE FUNCTION action_id(parent_name text, in_name text)
    RETURNS integer
    LANGUAGE sql
    DETERMINISTIC
BEGIN
    RETURN (SELECT class_id_pid(class_id('action', parent_name), in_name));
END//
delimiter ;

DROP FUNCTION IF EXISTS action_name;
delimiter //
CREATE FUNCTION action_name(in_id integer)
    RETURNS text
    LANGUAGE sql
    DETERMINISTIC
BEGIN
    RETURN (SELECT class_name(in_id));
END//
delimiter ;


DROP FUNCTION IF EXISTS action_get_parent;
delimiter //
CREATE FUNCTION action_get_parent(in_id integer)
    RETURNS text
    LANGUAGE sql
    DETERMINISTIC
BEGIN
    RETURN (SELECT class_name(parent_id) FROM class WHERE id = in_id);
END//
delimiter ;




DROP FUNCTION IF EXISTS action_add;
delimiter //
CREATE FUNCTION action_add(in_category_name text, in_name text)
    RETURNS integer
    LANGUAGE sql
    DETERMINISTIC
BEGIN
    DECLARE _id integer;

    IF (SELECT class_id('action', in_category_name)) IS NULL THEN
        RETURN NULL;
    END IF;

    SET _id = (SELECT action_id(in_category_name, in_name));

    IF _id IS NULL THEN
        INSERT INTO class (parent_id, name) VALUES (class_id('action', in_category_name), in_name);

        SET _id = (SELECT LAST_INSERT_ID());
    END IF;

    RETURN _id;
END//
delimiter ;


DROP FUNCTION IF EXISTS action_category_add;
delimiter //
CREATE FUNCTION action_category_add(in_category_name text)
    RETURNS integer
    LANGUAGE sql
    DETERMINISTIC
BEGIN
    DECLARE _id integer;

    SET _id = (SELECT class_id('action',in_category_name));
    IF _id IS NULL THEN
        SET _id = (SELECT class_add('action',in_category_name));
    END IF;
    RETURN _id;
END//
delimiter ;



DROP FUNCTION IF EXISTS action_remove;
delimiter //
CREATE FUNCTION action_remove(in_category_name text, in_name text)
    RETURNS BOOLEAN
    LANGUAGE sql
    DETERMINISTIC
BEGIN
    DELETE FROM class WHERE id = action_id(in_category_name, in_name);
    RETURN TRUE;
END//
delimiter ;



DROP FUNCTION IF EXISTS action_category_remove;
delimiter //
CREATE FUNCTION action_category_remove(in_category_name text)
    RETURNS BOOLEAN
    LANGUAGE sql
    DETERMINISTIC
BEGIN
    DELETE FROM class WHERE  id = class_id('action', in_category_name);
    RETURN TRUE;
END//
delimiter ;





DROP FUNCTION IF EXISTS role_assign_action;
delimiter //
CREATE FUNCTION role_assign_action(in_role_id integer, in_action_id integer)
    RETURNS boolean
    LANGUAGE sql
    DETERMINISTIC
BEGIN
    DECLARE _id integer;
    SET _id = (SELECT action_id FROM auth_role_action WHERE role_id = in_role_id AND action_id = in_action_id);
    IF _id IS NULL THEN
        INSERT INTO auth_role_action (role_id, action_id) VALUES (in_role_id, in_action_id);
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END//
delimiter ;


DROP FUNCTION IF EXISTS role_revoke_action;
delimiter //
CREATE FUNCTION role_revoke_action(in_role_id integer, in_action_id integer)
    RETURNS boolean
    LANGUAGE sql
    DETERMINISTIC
BEGIN
    DECLARE _id integer;
    SET _id = (SELECT action_id FROM auth_role_action WHERE role_id = in_role_id AND action_id = in_action_id);
    IF _id IS NOT NULL THEN
        DELETE FROM auth_role_action WHERE role_id = in_role_id AND action_id = in_action_id;
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END//
delimiter ;






DROP TABLE IF EXISTS global_log_referer CASCADE;
CREATE TABLE global_log_referer (
    time            timestamp  NOT NULL DEFAULT now(),
    accesspoint     text       NOT NULL,
    referer_id      integer    NOT NULL,
    http_referer    text       NULL,
    ip              text       NULL,
    FOREIGN KEY (referer_id) REFERENCES customer(id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
DROP TABLE IF EXISTS global_log_access CASCADE;
CREATE TABLE global_log_access (
    time            timestamp  NOT NULL DEFAULT now(),
    user_id         integer    NULL,
    accesspoint     text       NOT NULL,
    params          text       NULL,
    referer         text       NULL,
    FOREIGN KEY (user_id) REFERENCES auth_user(id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
DROP TABLE IF EXISTS global_log_action CASCADE;
CREATE TABLE global_log_action (
    time            timestamp   NOT NULL DEFAULT now(),
    user_id         integer     NULL,
    action_id       integer     NULL,
    object_id       integer     NULL,
    action          text        NOT NULL,
    link            text        NULL,
    FOREIGN KEY (user_id) REFERENCES auth_user(id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS static_block CASCADE;
CREATE TABLE static_block (
    id       integer      NOT NULL AUTO_INCREMENT,
    lang_id  integer      NOT NULL,
    name     text         NOT NULL,
    text     text         NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (lang_id) REFERENCES class(id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS tag CASCADE;
CREATE TABLE tag (
    id        integer NOT NULL AUTO_INCREMENT,
    name      text    NOT NULL,
    keyword   text    NOT NULL,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS tag2item CASCADE;
CREATE TABLE tag2item (
    item_id   integer NOT NULL,
    tag_id    integer NOT NULL,
    PRIMARY KEY (item_id, tag_id),
    FOREIGN KEY (tag_id) REFERENCES tag(id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE OR REPLACE VIEW auth_user_action AS
    SELECT user_id, role_name(role_id) as role, action_name(action_id) as action, action_get_parent(action_id) as category
        FROM auth_role_action as ara
        JOIN auth_role_user as aru USING (role_id)
        GROUP BY user_id, category, action
;

CREATE OR REPLACE VIEW auth_role AS
    SELECT id, name FROM class WHERE parent_id = class_id('', 'role')
;

CREATE OR REPLACE VIEW view_user AS
    SELECT (CASE WHEN username != '' THEN CONCAT(login,'-',username) ELSE login END) as username FROM auth_user as au LEFT JOIN customer as c ON (c.id = au.customer_id)
;






SELECT class_add('','lang');
SELECT class_add_pid(class_id('', 'lang'),'en');
SELECT class_add_pid(class_id('', 'lang'),'ru');

SELECT class_add('','status');

SELECT class_add_pid(class_id('', 'status'),'customer');
SELECT status_add('customer','new');
SELECT status_add('customer','active');
SELECT status_add('customer','blocked');
SELECT status_add('customer','deleted');

SELECT class_add('','type');

SELECT class_add_pid(class_id('', 'type'),'customer');
SELECT type_add('customer','root');
SELECT type_add('customer','user');
SELECT type_add('customer','free');

SELECT class_add('','role');
SELECT class_add('','action');



SELECT role_add('root');
SELECT role_add('admin');
SELECT role_add('user');


SELECT class_add_pid(class_id('', 'action'),'root');
SELECT action_add('root','edit');
SELECT action_add('root','logs');
SELECT action_add('root','sudo');
SELECT action_add('root','customerlist');
SELECT action_add('root','customermanage');
SELECT action_add('root','customerdelete');

SELECT class_add_pid(class_id('', 'action'),'auth');
SELECT action_add('auth','register');
SELECT action_add('auth','userlist');
SELECT action_add('auth','edit');
SELECT action_add('auth','delete');

SELECT class_add_pid(class_id('', 'action'),'api');
SELECT action_add('api','request');


SELECT role_assign_action(role_id('root'),class_id('action', 'root'));
SELECT role_assign_action(role_id('admin'),class_id('action', 'auth'));



INSERT INTO customer (login, status_id, type_id) VALUES ('root', status_id('customer', 'active'), type_id('customer', 'root'));
INSERT INTO auth_user (customer_id, username, password, active, email) VALUES (customer_id('root'), 'tigra','bea6074b601dab19cec0535da030245fa00ee1da',TRUE,'const@nazarenko.me');

SELECT user_assign_role(user_id('root','tigra'), role_id('root'));
SELECT user_assign_role(user_id('root','tigra'), role_id('admin'));

SET foreign_key_checks = 1;
