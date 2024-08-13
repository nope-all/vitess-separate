###############################################################################
# Vitess defaults
###############################################################################
# Vitess-internal database.
CREATE DATABASE IF NOT EXISTS _vt;
# Note that definitions of local_metadata and shard_metadata should be the same
# as in production which is defined in go/vt/mysqlctl/metadata_tables.go.
CREATE TABLE IF NOT EXISTS _vt.local_metadata (
  name VARCHAR(255) NOT NULL,
  value VARCHAR(255) NOT NULL,
  db_name VARBINARY(255) NOT NULL,
  PRIMARY KEY (db_name, name)
  ) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS _vt.shard_metadata (
  name VARCHAR(255) NOT NULL,
  value MEDIUMBLOB NOT NULL,
  db_name VARBINARY(255) NOT NULL,
  PRIMARY KEY (db_name, name)
  ) ENGINE=InnoDB;
# Admin user with all privileges.
CREATE USER 'vt_dba'@'%';
GRANT ALL ON *.* TO 'vt_dba'@'%';
GRANT GRANT OPTION ON *.* TO 'vt_dba'@'%';
# User for app traffic, with global read-write access.
CREATE USER 'vt_app'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, RELOAD, PROCESS, FILE,
  REFERENCES, INDEX, ALTER, SHOW DATABASES, CREATE TEMPORARY TABLES,
  LOCK TABLES, EXECUTE, REPLICATION CLIENT, CREATE VIEW, SHOW VIEW,
  CREATE ROUTINE, ALTER ROUTINE, CREATE USER, EVENT, TRIGGER
  ON *.* TO 'vt_app'@'%';
# User for app debug traffic, with global read access.
CREATE USER 'vt_appdebug'@'%';
GRANT SELECT, SHOW DATABASES, PROCESS ON *.* TO 'vt_appdebug'@'%';
# User for administrative operations that need to be executed as non-SUPER.
# Same permissions as vt_app here.
CREATE USER 'vt_allprivs'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, RELOAD, PROCESS, FILE,
  REFERENCES, INDEX, ALTER, SHOW DATABASES, CREATE TEMPORARY TABLES,
  LOCK TABLES, EXECUTE, REPLICATION SLAVE, REPLICATION CLIENT, CREATE VIEW,
  SHOW VIEW, CREATE ROUTINE, ALTER ROUTINE, CREATE USER, EVENT, TRIGGER
  ON *.* TO 'vt_allprivs'@'%';
# User for slave replication connections.
# TODO: Should we set a password on this since it allows remote connections?
CREATE USER 'vt_repl'@'%';
GRANT REPLICATION SLAVE ON *.* TO 'vt_repl'@'%';
# User for Vitess VReplication (base vstreamers and vplayer).
CREATE USER 'vt_filtered'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, RELOAD, PROCESS, FILE,
  REFERENCES, INDEX, ALTER, SHOW DATABASES, CREATE TEMPORARY TABLES,
  LOCK TABLES, EXECUTE, REPLICATION SLAVE, REPLICATION CLIENT, CREATE VIEW,
  SHOW VIEW, CREATE ROUTINE, ALTER ROUTINE, CREATE USER, EVENT, TRIGGER
  ON *.* TO 'vt_filtered'@'%';

# custom sql is used to add custom scripts like creating users/passwords. We use it in our tests
# {{custom_sql}}
CREATE DATABASE IF NOT EXISTS commerce;
USE commerce;
DROP TABLE IF EXISTS users;
CREATE TABLE IF NOT EXISTS users (
   device_id BIGINT,
   first_name VARCHAR(50),
   last_name VARCHAR(50),
   telephone BIGINT,
   gender VARCHAR(16),
   reference_id INT,
   confidence INT,
   coverage INT,
   refstart DATETIME,
   refstop DATETIME,
   qrystart DATETIME,
   qrystop DATETIME);

LOAD DATA LOCAL INFILE '/docker-entrypoint-initdb.d/dataset.csv' INTO TABLE users FIELDS TERMINATED BY ',';

ALTER TABLE users ADD id INT NOT NULL AUTO_INCREMENT PRIMARY KEY;

# We need to set super_read_only back to what it was before
SET GLOBAL super_read_only=IFNULL(@original_super_read_only, 'ON');
