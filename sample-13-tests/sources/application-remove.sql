-- =============================================
-- SaveToDB Sample 13 for Snowflake - Tests
-- Version 10.8, January 9, 2023
--
-- Copyright 2021-2023 Gartle LLC
--
-- License: MIT
-- =============================================

DROP USER SAMPLE01_USER1;

DROP ROLE SAMPLE01_USERS;

DROP FUNCTION S13.USP_DATATYPES();
DROP FUNCTION S13.USP_ODBC_DATATYPES();

DROP VIEW S13.VIEW_DATATYPE_COLUMNS;
DROP VIEW S13.VIEW_DATATYPE_PARAMETERS;

DROP TABLE S13.DATATYPES;

DROP SCHEMA S13;

-- print Application removed
