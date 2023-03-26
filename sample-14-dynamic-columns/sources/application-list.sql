-- =============================================
-- Application: Sample 14 - Dynamic Columns
-- Version 10.8, January 9, 2023
--
-- Copyright 2019-2023 Gartle LLC
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
    t.TABLE_SCHEMA IN ('S14')
UNION ALL
SELECT
    f.FUNCTION_SCHEMA AS SCHEMA
    , f.FUNCTION_NAME AS NAME
    , 'FUNCTION' AS TYPE
FROM
    INFORMATION_SCHEMA.FUNCTIONS f
WHERE
    f.FUNCTION_SCHEMA IN ('S14')
    AND f.FUNCTION_LANGUAGE = 'SQL'
ORDER BY
    SCHEMA
    , NAME
