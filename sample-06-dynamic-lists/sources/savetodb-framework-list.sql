-- =============================================
-- SaveToDB Framework for Snowflake
-- Version 10.13, April 29, 2024
--
-- Copyright 2018-2024 Gartle LLC
--
-- License: MIT
-- =============================================

SELECT
    LEFT(t.TABLE_SCHEMA, 15) AS SCHEMA
    , LEFT(t.TABLE_NAME, 50) AS NAME
    , REPLACE(t.TABLE_TYPE, 'BASE ', '') AS TYPE
FROM
    INFORMATION_SCHEMA.TABLES t
WHERE
    t.TABLE_SCHEMA IN ('XLS')
ORDER BY
    t.TABLE_SCHEMA
    , t.TABLE_NAME
