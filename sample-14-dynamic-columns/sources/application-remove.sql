-- =============================================
-- Application: Sample 14 - Dynamic Columns
-- Version 10.13, April 29, 2024
--
-- Copyright 2019-2024 Gartle LLC
--
-- License: MIT
-- =============================================

DELETE FROM XLS.FORMATS         WHERE TABLE_SCHEMA IN ('S14');
DELETE FROM XLS.HANDLERS        WHERE TABLE_SCHEMA IN ('S14');
DELETE FROM XLS.OBJECTS         WHERE TABLE_SCHEMA IN ('S14');
DELETE FROM XLS.TRANSLATIONS    WHERE TABLE_SCHEMA IN ('S14');
DELETE FROM XLS.WORKBOOKS       WHERE TABLE_SCHEMA IN ('S14');

DROP FUNCTION S14.XL_LIST_MEMBER_ID (INT, INT);
DROP FUNCTION S14.XL_LIST_MEMBER_ID1 (INT);
DROP FUNCTION S14.XL_LIST_MEMBER_ID2 (INT);
DROP FUNCTION S14.XL_LIST_MEMBER_ID3 (INT);

DROP VIEW S14.VIEW_ALIASES;
DROP VIEW S14.VIEW_DATA;
DROP VIEW S14.VIEW_MEMBERS;
DROP VIEW S14.XL_LIST_CLIENT_ID;

DROP TABLE S14.ALIASES;
DROP TABLE S14.CLIENTS;
DROP TABLE S14.DATA;
DROP TABLE S14.DIMENSIONS;
DROP TABLE S14.MEMBERS;
DROP TABLE S14.USER_CLIENTS;

DROP SCHEMA S14;

-- print Application removed
