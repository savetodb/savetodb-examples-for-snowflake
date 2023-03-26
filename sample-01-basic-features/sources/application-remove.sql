-- =============================================
-- SaveToDB Sample 01 for Snowflake - Basic Features
-- Version 10.8, January 9, 2023
--
-- Copyright 2018-2023 Gartle LLC
--
-- License: MIT
-- =============================================

DROP USER SAMPLE01_USER1;
DROP USER SAMPLE01_USER2;

DROP ROLE SAMPLE01_ADV_USERS;
DROP ROLE SAMPLE01_USERS;

DROP FUNCTION S01.USP_CASHBOOK(varchar, varchar, varchar);

DROP VIEW S01.VIEW_CASHBOOK;

DROP TABLE S01.CASHBOOK;
DROP TABLE S01.FORMATS;
DROP TABLE S01.WORKBOOKS;

DROP SCHEMA S01;

-- print Application removed
