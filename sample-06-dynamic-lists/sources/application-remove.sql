-- =============================================
-- Application: Sample 06 - Dynamic Lists
-- Version 10.8, January 9, 2023
--
-- Copyright 2018-2023 Gartle LLC
--
-- License: MIT
-- =============================================

DELETE FROM XLS.FORMATS         WHERE TABLE_SCHEMA IN ('S06');
DELETE FROM XLS.HANDLERS        WHERE TABLE_SCHEMA IN ('S06');
DELETE FROM XLS.OBJECTS         WHERE TABLE_SCHEMA IN ('S06');
DELETE FROM XLS.TRANSLATIONS    WHERE TABLE_SCHEMA IN ('S06');
DELETE FROM XLS.WORKBOOKS       WHERE TABLE_SCHEMA IN ('S06');

DROP FUNCTION S06.USP_DATA(int);

DROP TABLE S06.COUNTRIES;
DROP TABLE S06.DATA;
DROP TABLE S06.STATES;

DROP SCHEMA S06;

-- print Application removed
