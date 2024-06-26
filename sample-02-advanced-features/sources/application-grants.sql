-- =============================================
-- SaveToDB Sample 02 for Snowflake - Advanced Features
-- Version 10.13, April 29, 2024
--
-- Copyright 2018-2024 Gartle LLC
--
-- License: MIT
-- =============================================

CREATE USER SAMPLE02_USER1 PASSWORD='Usr_2011#_Xls4168';
CREATE USER SAMPLE02_USER2 PASSWORD='Usr_2011#_Xls4168';
CREATE USER SAMPLE02_USER3 PASSWORD='Usr_2011#_Xls4168';

CREATE ROLE SAMPLE02_USERS;
CREATE ROLE SAMPLE02_ADV_USERS;
CREATE ROLE SAMPLE02_XLS_USERS;

GRANT USAGE ON WAREHOUSE COMPUTE_WH                                   TO ROLE SAMPLE02_USERS;
GRANT USAGE ON SCHEMA S02                                             TO ROLE SAMPLE02_USERS;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES      IN SCHEMA S02 TO ROLE SAMPLE02_USERS;
GRANT SELECT                         ON ALL VIEWS       IN SCHEMA S02 TO ROLE SAMPLE02_USERS;
GRANT USAGE                          ON ALL FUNCTIONS   IN SCHEMA S02 TO ROLE SAMPLE02_USERS;
GRANT USAGE                          ON ALL PROCEDURES  IN SCHEMA S02 TO ROLE SAMPLE02_USERS;

GRANT ROLE SAMPLE02_USERS   TO ROLE SAMPLE02_ADV_USERS;

GRANT ROLE SAMPLE02_USERS   TO ROLE SAMPLE02_XLS_USERS;
GRANT ROLE XLS_USERS        TO ROLE SAMPLE02_XLS_USERS;

GRANT ROLE SAMPLE02_ADV_USERS   TO USER SAMPLE02_USER1;
GRANT ROLE SAMPLE02_USERS       TO USER SAMPLE02_USER2;
GRANT ROLE SAMPLE02_XLS_USERS   TO USER SAMPLE02_USER3;

ALTER USER SAMPLE02_USER1 SET DEFAULT_ROLE=SAMPLE02_ADV_USERS;
ALTER USER SAMPLE02_USER2 SET DEFAULT_ROLE=SAMPLE02_USERS;
ALTER USER SAMPLE02_USER3 SET DEFAULT_ROLE=SAMPLE02_XLS_USERS;

ALTER USER SAMPLE02_USER1 SET DEFAULT_WAREHOUSE='COMPUTE_WH';
ALTER USER SAMPLE02_USER2 SET DEFAULT_WAREHOUSE='COMPUTE_WH';
ALTER USER SAMPLE02_USER3 SET DEFAULT_WAREHOUSE='COMPUTE_WH';
