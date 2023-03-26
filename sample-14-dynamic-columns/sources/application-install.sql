-- =============================================
-- Application: Sample 14 - Dynamic Columns
-- Version 10.8, January 9, 2023
--
-- Copyright 2019-2023 Gartle LLC
--
-- License: MIT
-- =============================================

CREATE SCHEMA S14;

CREATE TABLE S14.CLIENTS (
      ID INT IDENTITY(1,1) NOT NULL
    , NAME NVARCHAR(50) NOT NULL
    , CONSTRAINT PK_CLIENTS PRIMARY KEY (ID)
    , CONSTRAINT IX_CLIENTS UNIQUE (NAME)
);

CREATE TABLE S14.DIMENSIONS (
      ID INT NOT NULL
    , NAME NVARCHAR(50) NOT NULL
    , CONSTRAINT PK_DIMENSIONS PRIMARY KEY (ID)
    , CONSTRAINT IX_DIMENSIONS UNIQUE (NAME)
);

CREATE TABLE S14.ALIASES (
      ID INT IDENTITY(1,1) NOT NULL
    , CLIENT_ID INT NULL
    , TABLE_NAME NVARCHAR(128) NULL
    , COLUMN_NAME NVARCHAR(128) NULL
    , ALIAS NVARCHAR(128) NULL
    , IS_ACTIVE BOOLEAN NULL
    , IS_SELECTED BOOLEAN NULL
    , SORT_ORDER INT NULL
    , CONSTRAINT PK_ALIASES PRIMARY KEY (ID)
    , CONSTRAINT IX_ALIASES_XLS UNIQUE (CLIENT_ID, TABLE_NAME, COLUMN_NAME)
);

ALTER TABLE S14.ALIASES ADD CONSTRAINT FK_ALIASES_CLIENTS FOREIGN KEY (CLIENT_ID) REFERENCES S14.CLIENTS (ID) ON DELETE CASCADE ON UPDATE CASCADE;

CREATE TABLE S14.MEMBERS (
      ID INT IDENTITY(1,1) NOT NULL
    , CLIENT_ID INT NOT NULL
    , DIMENSION_ID INT NOT NULL
    , NAME NVARCHAR(50) NOT NULL
    , STRING1 NVARCHAR(50) NULL
    , STRING2 NVARCHAR(50) NULL
    , INT1 INT NULL
    , INT2 INT NULL
    , FLOAT1 FLOAT NULL
    , FLOAT2 FLOAT NULL
    , CONSTRAINT PK_MEMBERS PRIMARY KEY (ID)
);

ALTER TABLE S14.MEMBERS ADD CONSTRAINT FK_MEMBERS_CLIENTS FOREIGN KEY (CLIENT_ID) REFERENCES S14.CLIENTS (ID) ON UPDATE CASCADE;

ALTER TABLE S14.MEMBERS ADD CONSTRAINT FK_MEMBERS_DIMENSIONS FOREIGN KEY (DIMENSION_ID) REFERENCES S14.DIMENSIONS (ID) ON UPDATE CASCADE;

CREATE TABLE S14.USER_CLIENTS (
      USER_NAME NVARCHAR(128) NOT NULL
    , CLIENT_ID INT NOT NULL
    , CONSTRAINT PK_USER_CLIENTS PRIMARY KEY (USER_NAME, CLIENT_ID)
);

ALTER TABLE S14.USER_CLIENTS ADD CONSTRAINT FK_USER_CLIENTS_CLIENTS FOREIGN KEY (CLIENT_ID) REFERENCES S14.CLIENTS (ID);

CREATE TABLE S14.DATA (
      ID INT IDENTITY(1,1) NOT NULL
    , CLIENT_ID INT NULL
    , ID1 INT NULL
    , ID2 INT NULL
    , ID3 INT NULL
    , STRING1 NVARCHAR(50) NULL
    , STRING2 NVARCHAR(50) NULL
    , INT1 INT NULL
    , INT2 INT NULL
    , FLOAT1 FLOAT NULL
    , FLOAT2 FLOAT NULL
    , CONSTRAINT PK_DATA PRIMARY KEY (ID)
);

ALTER TABLE S14.DATA ADD CONSTRAINT FK_DATA_CLIENTS FOREIGN KEY (CLIENT_ID) REFERENCES S14.CLIENTS (ID) ON UPDATE CASCADE;

ALTER TABLE S14.DATA ADD CONSTRAINT FK_DATA_MEMBERS_ID1 FOREIGN KEY (ID1) REFERENCES S14.MEMBERS (ID);

ALTER TABLE S14.DATA ADD CONSTRAINT FK_DATA_MEMBERS_ID2 FOREIGN KEY (ID2) REFERENCES S14.MEMBERS (ID);

ALTER TABLE S14.DATA ADD CONSTRAINT FK_DATA_MEMBERS_ID3 FOREIGN KEY (ID3) REFERENCES S14.MEMBERS (ID);

CREATE VIEW S14.VIEW_ALIASES
AS

SELECT
    A.CLIENT_ID
    , A.TABLE_NAME
    , A.COLUMN_NAME
    , A.ALIAS
    , A.IS_ACTIVE
    , A.IS_SELECTED
    , A.SORT_ORDER
FROM
    S14.ALIASES A
    INNER JOIN S14.USER_CLIENTS UC ON UC.CLIENT_ID = A.CLIENT_ID AND UC.USER_NAME = CURRENT_USER()
;

CREATE VIEW S14.VIEW_DATA
AS

SELECT
    D.ID
    , D.CLIENT_ID
    , D.ID1
    , D.ID2
    , D.ID3
    , D.STRING1
    , D.STRING2
    , D.INT1
    , D.INT2
    , D.FLOAT1
    , D.FLOAT2
FROM
    S14.DATA D
    INNER JOIN S14.USER_CLIENTS UC ON UC.CLIENT_ID = D.CLIENT_ID AND UC.USER_NAME = CURRENT_USER()
;

CREATE VIEW S14.VIEW_MEMBERS
AS

SELECT
    D.ID
    , D.CLIENT_ID
    , D.DIMENSION_ID
    , D.NAME
    , D.STRING1
    , D.STRING2
    , D.INT1
    , D.INT2
    , D.FLOAT1
    , D.FLOAT2
FROM
    S14.MEMBERS D
    INNER JOIN S14.USER_CLIENTS UC ON UC.CLIENT_ID = D.CLIENT_ID AND UC.USER_NAME = CURRENT_USER()
;

CREATE VIEW S14.XL_LIST_CLIENT_ID
AS

SELECT
    C.ID
    , C.NAME
FROM
    S14.CLIENTS C
WHERE
    C.ID IN (SELECT CLIENT_ID FROM S14.USER_CLIENTS WHERE USER_NAME = CURRENT_USER())
;


CREATE FUNCTION S14.XL_LIST_MEMBER_ID (
    DIMENSION_ID INT
    , CLIENT_ID INT
)
RETURNS TABLE (
    ID INT
    , NAME NVARCHAR(50)
    , CLIENT_ID INT
)
AS
'SELECT
    M.ID
    , M.NAME
    , M.CLIENT_ID
FROM
    S14.MEMBERS M
    INNER JOIN S14.USER_CLIENTS UC ON UC.CLIENT_ID = M.CLIENT_ID AND UC.USER_NAME = CURRENT_USER()
WHERE
    M.DIMENSION_ID = DIMENSION_ID
    AND M.CLIENT_ID = COALESCE(CLIENT_ID, M.CLIENT_ID)
ORDER BY
    M.NAME';


CREATE FUNCTION S14.XL_LIST_MEMBER_ID1 (
    CLIENT_ID INT
)
RETURNS TABLE (
    ID INT
    , NAME NVARCHAR(50)
    , CLIENT_ID INT
)
AS
'SELECT ID, NAME, CLIENT_ID FROM TABLE(S14.XL_LIST_MEMBER_ID(1, CLIENT_ID))';


CREATE FUNCTION S14.XL_LIST_MEMBER_ID2 (
    CLIENT_ID INT
)
RETURNS TABLE (
    ID INT
    , NAME NVARCHAR(50)
    , CLIENT_ID INT
)
AS
'SELECT ID, NAME, CLIENT_ID FROM TABLE(S14.XL_LIST_MEMBER_ID(2, CLIENT_ID))';

CREATE FUNCTION S14.XL_LIST_MEMBER_ID3 (
    CLIENT_ID INT
)
RETURNS TABLE (
    ID INT
    , NAME NVARCHAR(50)
    , CLIENT_ID INT
)
AS
'SELECT ID, NAME, CLIENT_ID FROM TABLE(S14.XL_LIST_MEMBER_ID(3, CLIENT_ID))';

INSERT INTO S14.CLIENTS (ID, NAME) VALUES (1, 'Client 1');
INSERT INTO S14.CLIENTS (ID, NAME) VALUES (2, 'Client 2');

INSERT INTO S14.DIMENSIONS (ID, NAME) VALUES (1, 'DIM1');
INSERT INTO S14.DIMENSIONS (ID, NAME) VALUES (2, 'DIM2');
INSERT INTO S14.DIMENSIONS (ID, NAME) VALUES (3, 'DIM3');

INSERT INTO S14.ALIASES (ID, CLIENT_ID, TABLE_NAME, COLUMN_NAME, ALIAS, IS_ACTIVE, IS_SELECTED, SORT_ORDER) VALUES (1, 1, 'S14.DATA', 'STRING1', 'PRODUCT', 1, 1, 4);
INSERT INTO S14.ALIASES (ID, CLIENT_ID, TABLE_NAME, COLUMN_NAME, ALIAS, IS_ACTIVE, IS_SELECTED, SORT_ORDER) VALUES (2, 1, 'S14.DATA', 'ID1', 'STATE', 1, 1, 3);
INSERT INTO S14.ALIASES (ID, CLIENT_ID, TABLE_NAME, COLUMN_NAME, ALIAS, IS_ACTIVE, IS_SELECTED, SORT_ORDER) VALUES (3, 1, 'S14.DATA', 'FLOAT1', 'SALES', 1, 1, 5);
INSERT INTO S14.ALIASES (ID, CLIENT_ID, TABLE_NAME, COLUMN_NAME, ALIAS, IS_ACTIVE, IS_SELECTED, SORT_ORDER) VALUES (4, 2, 'S14.DATA', 'STRING1', 'REGION', 1, 1, 4);
INSERT INTO S14.ALIASES (ID, CLIENT_ID, TABLE_NAME, COLUMN_NAME, ALIAS, IS_ACTIVE, IS_SELECTED, SORT_ORDER) VALUES (5, 2, 'S14.DATA', 'STRING2', 'MANAGER', 1, 1, 3);
INSERT INTO S14.ALIASES (ID, CLIENT_ID, TABLE_NAME, COLUMN_NAME, ALIAS, IS_ACTIVE, IS_SELECTED, SORT_ORDER) VALUES (6, 2, 'S14.DATA', 'FLOAT1', 'SALES', 1, 1, 5);
INSERT INTO S14.ALIASES (ID, CLIENT_ID, TABLE_NAME, COLUMN_NAME, ALIAS, IS_ACTIVE, IS_SELECTED, SORT_ORDER) VALUES (9, 1, 'S14.MEMBERS', 'STRING1', 'COUNTRY', NULL, NULL, NULL);
INSERT INTO S14.ALIASES (ID, CLIENT_ID, TABLE_NAME, COLUMN_NAME, ALIAS, IS_ACTIVE, IS_SELECTED, SORT_ORDER) VALUES (10, 1, 'S14.MEMBERS', 'STRING2', 'STATE', NULL, NULL, NULL);
INSERT INTO S14.ALIASES (ID, CLIENT_ID, TABLE_NAME, COLUMN_NAME, ALIAS, IS_ACTIVE, IS_SELECTED, SORT_ORDER) VALUES (11, 1, 'S14.DATA', 'STRING2', NULL, 0, 0, NULL);
INSERT INTO S14.ALIASES (ID, CLIENT_ID, TABLE_NAME, COLUMN_NAME, ALIAS, IS_ACTIVE, IS_SELECTED, SORT_ORDER) VALUES (12, 1, 'S14.DATA', 'ID2', NULL, 0, 0, NULL);
INSERT INTO S14.ALIASES (ID, CLIENT_ID, TABLE_NAME, COLUMN_NAME, ALIAS, IS_ACTIVE, IS_SELECTED, SORT_ORDER) VALUES (13, 1, 'S14.DATA', 'ID3', NULL, 0, 0, NULL);
INSERT INTO S14.ALIASES (ID, CLIENT_ID, TABLE_NAME, COLUMN_NAME, ALIAS, IS_ACTIVE, IS_SELECTED, SORT_ORDER) VALUES (14, 1, 'S14.DATA', 'INT1', NULL, 0, 0, NULL);
INSERT INTO S14.ALIASES (ID, CLIENT_ID, TABLE_NAME, COLUMN_NAME, ALIAS, IS_ACTIVE, IS_SELECTED, SORT_ORDER) VALUES (15, 1, 'S14.DATA', 'INT2', NULL, 0, 0, NULL);
INSERT INTO S14.ALIASES (ID, CLIENT_ID, TABLE_NAME, COLUMN_NAME, ALIAS, IS_ACTIVE, IS_SELECTED, SORT_ORDER) VALUES (16, 1, 'S14.DATA', 'FLOAT2', NULL, 0, 0, NULL);
INSERT INTO S14.ALIASES (ID, CLIENT_ID, TABLE_NAME, COLUMN_NAME, ALIAS, IS_ACTIVE, IS_SELECTED, SORT_ORDER) VALUES (17, 2, 'S14.DATA', 'FLOAT2', NULL, 0, 0, NULL);
INSERT INTO S14.ALIASES (ID, CLIENT_ID, TABLE_NAME, COLUMN_NAME, ALIAS, IS_ACTIVE, IS_SELECTED, SORT_ORDER) VALUES (18, 2, 'S14.DATA', 'ID1', NULL, 0, 0, NULL);
INSERT INTO S14.ALIASES (ID, CLIENT_ID, TABLE_NAME, COLUMN_NAME, ALIAS, IS_ACTIVE, IS_SELECTED, SORT_ORDER) VALUES (19, 2, 'S14.DATA', 'ID2', NULL, 0, 0, NULL);
INSERT INTO S14.ALIASES (ID, CLIENT_ID, TABLE_NAME, COLUMN_NAME, ALIAS, IS_ACTIVE, IS_SELECTED, SORT_ORDER) VALUES (20, 2, 'S14.DATA', 'ID3', NULL, 0, 0, NULL);
INSERT INTO S14.ALIASES (ID, CLIENT_ID, TABLE_NAME, COLUMN_NAME, ALIAS, IS_ACTIVE, IS_SELECTED, SORT_ORDER) VALUES (21, 2, 'S14.DATA', 'INT1', NULL, 0, 0, NULL);
INSERT INTO S14.ALIASES (ID, CLIENT_ID, TABLE_NAME, COLUMN_NAME, ALIAS, IS_ACTIVE, IS_SELECTED, SORT_ORDER) VALUES (22, 2, 'S14.DATA', 'INT2', NULL, 0, 0, NULL);

INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (1, 1, 1, 'AK', 'USA', 'Alaska', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (2, 1, 1, 'AL', 'USA', 'Alabama', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (3, 1, 1, 'AR', 'USA', 'Arkansas', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (4, 1, 1, 'AZ', 'USA', 'Arizona', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (5, 1, 1, 'CA', 'USA', 'California', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (6, 1, 1, 'CO', 'USA', 'Colorado', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (7, 1, 1, 'CT', 'USA', 'Connecticut', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (8, 1, 1, 'DE', 'USA', 'Delaware', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (9, 1, 1, 'FL', 'USA', 'Florida', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (10, 1, 1, 'GA', 'USA', 'Georgia', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (11, 1, 1, 'HI', 'USA', 'Hawaii', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (12, 1, 1, 'IA', 'USA', 'Iowa', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (13, 1, 1, 'ID', 'USA', 'Idaho', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (14, 1, 1, 'IL', 'USA', 'Illinois', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (15, 1, 1, 'I', 'USA', 'Indiana', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (16, 1, 1, 'KS', 'USA', 'Kansas', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (17, 1, 1, 'KY', 'USA', 'Kentucky', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (18, 1, 1, 'LA', 'USA', 'Louisiana', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (19, 1, 1, 'MA', 'USA', 'Massachusetts', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (20, 1, 1, 'MD', 'USA', 'Maryland', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (21, 1, 1, 'ME', 'USA', 'Maine', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (22, 1, 1, 'MI', 'USA', 'Michigan', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (23, 1, 1, 'M', 'USA', 'Minnesota', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (24, 1, 1, 'MO', 'USA', 'Missouri', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (25, 1, 1, 'MS', 'USA', 'Mississippi', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (26, 1, 1, 'MT', 'USA', 'Montana', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (27, 1, 1, 'NC', 'USA', 'North Carolina', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (28, 1, 1, 'ND', 'USA', 'North Dakota', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (29, 1, 1, 'NE', 'USA', 'Nebraska', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (30, 1, 1, 'NH', 'USA', 'New Hampshire', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (31, 1, 1, 'NJ', 'USA', 'New Jersey', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (32, 1, 1, 'NM', 'USA', 'New Mexico', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (33, 1, 1, 'NV', 'USA', 'Nevada', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (34, 1, 1, 'NY', 'USA', 'New York', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (35, 1, 1, 'OH', 'USA', 'Ohio', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (36, 1, 1, 'OK', 'USA', 'Oklahoma', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (37, 1, 1, 'OR', 'USA', 'Oregon', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (38, 1, 1, 'PA', 'USA', 'Pennsylvania', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (39, 1, 1, 'RI', 'USA', 'Rhode Island', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (40, 1, 1, 'SC', 'USA', 'South Carolina', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (41, 1, 1, 'SD', 'USA', 'South Dakota', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (42, 1, 1, 'T', 'USA', 'Tennessee', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (43, 1, 1, 'TX', 'USA', 'Texas', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (44, 1, 1, 'UT', 'USA', 'Utah', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (45, 1, 1, 'VA', 'USA', 'Virginia', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (46, 1, 1, 'VT', 'USA', 'Vermont', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (47, 1, 1, 'WA', 'USA', 'Washington', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (48, 1, 1, 'WI', 'USA', 'Wisconsin', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (49, 1, 1, 'WV', 'USA', 'West Virginia', NULL, NULL, NULL, NULL);
INSERT INTO S14.MEMBERS (ID, CLIENT_ID, DIMENSION_ID, NAME, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (50, 1, 1, 'WY', 'USA', 'Wyoming', NULL, NULL, NULL, NULL);

INSERT INTO S14.USER_CLIENTS (USER_NAME, CLIENT_ID) VALUES (CURRENT_USER(), 1);
INSERT INTO S14.USER_CLIENTS (USER_NAME, CLIENT_ID) VALUES (CURRENT_USER(), 2);

INSERT INTO S14.DATA (ID, CLIENT_ID, ID1, ID2, ID3, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (1, 1, 2, NULL, NULL, 'Product 1', NULL, NULL, NULL, 1000, NULL);
INSERT INTO S14.DATA (ID, CLIENT_ID, ID1, ID2, ID3, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (2, 1, 2, NULL, NULL, 'Product 2', NULL, NULL, NULL, 2000, NULL);
INSERT INTO S14.DATA (ID, CLIENT_ID, ID1, ID2, ID3, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (3, 2, NULL, NULL, NULL, 'USA', 'Smith', NULL, NULL, 2000, NULL);
INSERT INTO S14.DATA (ID, CLIENT_ID, ID1, ID2, ID3, STRING1, STRING2, INT1, INT2, FLOAT1, FLOAT2) VALUES (4, 2, NULL, NULL, NULL, 'Canada', 'Smith', NULL, NULL, 1000, NULL);

INSERT INTO XLS.HANDLERS (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES ('S14', 'VIEW_DATA', NULL, 'DynamicColumns', 'S14', 'DYNAMIC_COLUMNS', 'CODE', 'SELECT COLUMN_NAME, ALIAS, IS_ACTIVE, IS_SELECTED, SORT_ORDER FROM S14.VIEW_ALIASES WHERE CLIENT_ID = :CLIENT_ID AND TABLE_NAME = ''S14.DATA''', NULL, NULL, NULL);
INSERT INTO XLS.HANDLERS (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES ('S14', 'VIEW_DATA', 'CLIENT_ID', 'ValidationList', 'S14', 'XL_LIST_CLIENT_ID', 'VIEW', NULL, NULL, NULL, NULL);
INSERT INTO XLS.HANDLERS (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES ('S14', 'VIEW_DATA', 'ID1', 'ValidationList', 'S14', 'XL_LIST_MEMBER_ID1', 'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO XLS.HANDLERS (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES ('S14', 'VIEW_DATA', 'ID2', 'ValidationList', 'S14', 'XL_LIST_MEMBER_ID2', 'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO XLS.HANDLERS (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES ('S14', 'VIEW_DATA', 'ID3', 'ValidationList', 'S14', 'XL_LIST_MEMBER_ID3', 'PROCEDURE', NULL, NULL, NULL, NULL);
INSERT INTO XLS.HANDLERS (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES ('S14', 'VIEW_MEMBERS', 'CLIENT_ID', 'ValidationList', 'S14', 'XL_LIST_CLIENT_ID', 'VIEW', NULL, NULL, NULL, NULL);
INSERT INTO XLS.HANDLERS (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES ('S14', 'VIEW_MEMBERS', 'DIMENSION_ID', 'ValidationList', 'S14', 'DIMENSIONS', 'TABLE', 'ID, NAME', NULL, NULL, NULL);
INSERT INTO XLS.HANDLERS (TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, EVENT_NAME, HANDLER_SCHEMA, HANDLER_NAME, HANDLER_TYPE, HANDLER_CODE, TARGET_WORKSHEET, MENU_ORDER, EDIT_PARAMETERS) VALUES ('S14', 'VIEW_MEMBERS', NULL, 'DynamicColumns', 'S14', 'DYNAMIC_COLUMNS', 'CODE', 'SELECT COLUMN_NAME, ALIAS, IS_ACTIVE, IS_SELECTED, SORT_ORDER FROM S14.VIEW_ALIASES WHERE CLIENT_ID = :CLIENT_ID AND TABLE_NAME = ''S14.MEMBERS''', NULL, NULL, NULL);

INSERT INTO XLS.FORMATS (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES ('S14', 'VIEW_DATA', '<table name="S14.VIEW_DATA"><columnFormats><column name="" property="ListObjectName" value="view_data" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="" property="TableStyle.Name" value="TableStyleMedium15" type="String"/><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean"/><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean"/><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean"/><column name="" property="ShowTableStyleRowStripes" value="False" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="_RowNum" property="Address" value="$B$4" type="String"/><column name="_RowNum" property="NumberFormat" value="General" type="String"/><column name="id" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="id" property="Address" value="$C$4" type="String"/><column name="id" property="NumberFormat" value="General" type="String"/><column name="id" property="Validation.Type" value="1" type="Double"/><column name="id" property="Validation.Operator" value="1" type="Double"/><column name="id" property="Validation.Formula1" value="-2147483648" type="String"/><column name="id" property="Validation.Formula2" value="2147483647" type="String"/><column name="id" property="Validation.AlertStyle" value="1" type="Double"/><column name="id" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="id" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="id" property="Validation.ErrorTitle" value="Datatype Control" type="String"/><column name="id" property="Validation.ErrorMessage" value="The column requires values of the int datatype." type="String"/><column name="id" property="Validation.ShowInput" value="True" type="Boolean"/><column name="id" property="Validation.ShowError" value="True" type="Boolean"/><column name="client_id" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="client_id" property="Address" value="$D$4" type="String"/><column name="client_id" property="ColumnWidth" value="12.14" type="Double"/><column name="client_id" property="NumberFormat" value="General" type="String"/><column name="client_id" property="Validation.Type" value="3" type="Double"/><column name="client_id" property="Validation.Operator" value="1" type="Double"/><column name="client_id" property="Validation.Formula1" value="=INDIRECT(&quot;vl_S14_xl_list_client_id[name]&quot;)" type="String"/><column name="client_id" property="Validation.AlertStyle" value="1" type="Double"/><column name="client_id" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="client_id" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="client_id" property="Validation.ShowInput" value="True" type="Boolean"/><column name="client_id" property="Validation.ShowError" value="True" type="Boolean"/><column name="id1" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="id1" property="Address" value="$E$4" type="String"/><column name="id1" property="ColumnWidth" value="12.14" type="Double"/><column name="id1" property="NumberFormat" value="General" type="String"/><column name="id1" property="Validation.Type" value="3" type="Double"/><column name="id1" property="Validation.Operator" value="1" type="Double"/><column name="id1" property="Validation.Formula1" value="=vl_d1_view_data" type="String"/><column name="id1" property="Validation.AlertStyle" value="1" type="Double"/><column name="id1" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="id1" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="id1" property="Validation.ShowInput" value="True" type="Boolean"/><column name="id1" property="Validation.ShowError" value="True" type="Boolean"/><column name="id2" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="id2" property="Address" value="$F$4" type="String"/><column name="id2" property="NumberFormat" value="General" type="String"/><column name="id3" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="id3" property="Address" value="$G$4" type="String"/><column name="id3" property="NumberFormat" value="General" type="String"/><column name="string1" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="string1" property="Address" value="$H$4" type="String"/><column name="string1" property="ColumnWidth" value="12.14" type="Double"/><column name="string1" property="NumberFormat" value="General" type="String"/><column name="string1" property="Validation.Type" value="6" type="Double"/><column name="string1" property="Validation.Operator" value="8" type="Double"/><column name="string1" property="Validation.Formula1" value="50" type="String"/><column name="string1" property="Validation.AlertStyle" value="1" type="Double"/><column name="string1" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="string1" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="string1" property="Validation.ErrorTitle" value="Datatype Control" type="String"/><column name="string1" property="Validation.ErrorMessage" value="The column requires values of the nvarchar(50) datatype." type="String"/><column name="string1" property="Validation.ShowInput" value="True" type="Boolean"/><column name="string1" property="Validation.ShowError" value="True" type="Boolean"/><column name="string2" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="string2" property="Address" value="$I$4" type="String"/><column name="string2" property="ColumnWidth" value="12.14" type="Double"/><column name="string2" property="NumberFormat" value="General" type="String"/><column name="string2" property="Validation.Type" value="6" type="Double"/><column name="string2" property="Validation.Operator" value="8" type="Double"/><column name="string2" property="Validation.Formula1" value="50" type="String"/><column name="string2" property="Validation.AlertStyle" value="1" type="Double"/><column name="string2" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="string2" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="string2" property="Validation.ErrorTitle" value="Datatype Control" type="String"/><column name="string2" property="Validation.ErrorMessage" value="The column requires values of the nvarchar(50) datatype." type="String"/><column name="string2" property="Validation.ShowInput" value="True" type="Boolean"/><column name="string2" property="Validation.ShowError" value="True" type="Boolean"/><column name="int1" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="int1" property="Address" value="$J$4" type="String"/><column name="int1" property="NumberFormat" value="#,##0" type="String"/><column name="int1" property="Validation.Type" value="1" type="Double"/><column name="int1" property="Validation.Operator" value="1" type="Double"/><column name="int1" property="Validation.Formula1" value="-2147483648" type="String"/><column name="int1" property="Validation.Formula2" value="2147483647" type="String"/><column name="int1" property="Validation.AlertStyle" value="1" type="Double"/><column name="int1" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="int1" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="int1" property="Validation.ErrorTitle" value="Datatype Control" type="String"/><column name="int1" property="Validation.ErrorMessage" value="The column requires values of the int datatype." type="String"/><column name="int1" property="Validation.ShowInput" value="True" type="Boolean"/><column name="int1" property="Validation.ShowError" value="True" type="Boolean"/><column name="int2" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="int2" property="Address" value="$K$4" type="String"/><column name="int2" property="NumberFormat" value="#,##0" type="String"/><column name="int2" property="Validation.Type" value="1" type="Double"/><column name="int2" property="Validation.Operator" value="1" type="Double"/><column name="int2" property="Validation.Formula1" value="-2147483648" type="String"/><column name="int2" property="Validation.Formula2" value="2147483647" type="String"/><column name="int2" property="Validation.AlertStyle" value="1" type="Double"/><column name="int2" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="int2" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="int2" property="Validation.ErrorTitle" value="Datatype Control" type="String"/><column name="int2" property="Validation.ErrorMessage" value="The column requires values of the int datatype." type="String"/><column name="int2" property="Validation.ShowInput" value="True" type="Boolean"/><column name="int2" property="Validation.ShowError" value="True" type="Boolean"/><column name="float1" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="float1" property="Address" value="$L$4" type="String"/><column name="float1" property="ColumnWidth" value="12.14" type="Double"/><column name="float1" property="NumberFormat" value="#,##0" type="String"/><column name="float1" property="Validation.Type" value="2" type="Double"/><column name="float1" property="Validation.Operator" value="4" type="Double"/><column name="float1" property="Validation.Formula1" value="-1.11222333444555E+29" type="String"/><column name="float1" property="Validation.AlertStyle" value="1" type="Double"/><column name="float1" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="float1" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="float1" property="Validation.ErrorTitle" value="Datatype Control" type="String"/><column name="float1" property="Validation.ErrorMessage" value="The column requires values of the float datatype." type="String"/><column name="float1" property="Validation.ShowInput" value="True" type="Boolean"/><column name="float1" property="Validation.ShowError" value="True" type="Boolean"/><column name="float2" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="float2" property="Address" value="$M$4" type="String"/><column name="float2" property="NumberFormat" value="#,##0" type="String"/><column name="float2" property="Validation.Type" value="2" type="Double"/><column name="float2" property="Validation.Operator" value="4" type="Double"/><column name="float2" property="Validation.Formula1" value="-1.11222333444555E+29" type="String"/><column name="float2" property="Validation.AlertStyle" value="1" type="Double"/><column name="float2" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="float2" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="float2" property="Validation.ErrorTitle" value="Datatype Control" type="String"/><column name="float2" property="Validation.ErrorMessage" value="The column requires values of the float datatype." type="String"/><column name="float2" property="Validation.ShowInput" value="True" type="Boolean"/><column name="float2" property="Validation.ShowError" value="True" type="Boolean"/><column name="id" property="FormatConditions(1).AppliesTo.Address" value="$C$4:$C$5" type="String"/><column name="id" property="FormatConditions(1).Type" value="2" type="Double"/><column name="id" property="FormatConditions(1).Priority" value="1" type="Double"/><column name="id" property="FormatConditions(1).Formula1" value="=ISBLANK(C4)" type="String"/><column name="id" property="FormatConditions(1).Interior.Color" value="65535" type="Double"/><column name="id" property="FormatConditions(1).Interior.Color" value="65535" type="Double"/><column name="" property="Tab.Color" value="5287936" type="Double"/><column name="" property="Tab.Color" value="5287936" type="Double"/><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean"/><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean"/><column name="" property="ActiveWindow.Split" value="True" type="Boolean"/><column name="" property="ActiveWindow.SplitRow" value="0" type="Double"/><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double"/><column name="" property="PageSetup.Orientation" value="2" type="Double"/><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double"/></columnFormats><views><view name="All columns"><column name="" property="ListObjectName" value="view_data" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="client_id" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="id1" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="id2" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="id3" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="string1" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="string2" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="int1" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="int2" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="float1" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="float2" property="EntireColumn.Hidden" value="False" type="Boolean"/></view><view name="Common columns"><column name="" property="ListObjectName" value="view_data" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="id" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="client_id" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="id1" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="id2" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="id3" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="string1" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="string2" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="int1" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="int2" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="float1" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="float2" property="EntireColumn.Hidden" value="True" type="Boolean"/></view><view name="Client 1"><column name="" property="ListObjectName" value="view_data" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="id" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="client_id" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="id1" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="id2" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="id3" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="string1" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="string2" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="int1" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="int2" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="float1" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="float2" property="EntireColumn.Hidden" value="True" type="Boolean"/></view><view name="Client 2"><column name="" property="ListObjectName" value="view_data" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="id" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="client_id" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="id1" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="id2" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="id3" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="string1" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="string2" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="int1" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="int2" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="float1" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="float2" property="EntireColumn.Hidden" value="True" type="Boolean"/></view></views></table>');
INSERT INTO XLS.FORMATS (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES ('S14', 'VIEW_MEMBERS', '<table name="S14.VIEW_MEMBERS"><columnFormats><column name="" property="ListObjectName" value="members" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="" property="TableStyle.Name" value="TableStyleMedium15" type="String"/><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean"/><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean"/><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean"/><column name="" property="ShowTableStyleRowStripes" value="False" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="_RowNum" property="Address" value="$B$4" type="String"/><column name="_RowNum" property="NumberFormat" value="General" type="String"/><column name="id" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="id" property="Address" value="$C$4" type="String"/><column name="id" property="ColumnWidth" value="4.29" type="Double"/><column name="id" property="NumberFormat" value="General" type="String"/><column name="id" property="Validation.Type" value="1" type="Double"/><column name="id" property="Validation.Operator" value="1" type="Double"/><column name="id" property="Validation.Formula1" value="-2147483648" type="String"/><column name="id" property="Validation.Formula2" value="2147483647" type="String"/><column name="id" property="Validation.AlertStyle" value="1" type="Double"/><column name="id" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="id" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="id" property="Validation.ShowInput" value="True" type="Boolean"/><column name="id" property="Validation.ShowError" value="True" type="Boolean"/><column name="name" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="name" property="Address" value="$D$4" type="String"/><column name="name" property="ColumnWidth" value="12.14" type="Double"/><column name="name" property="NumberFormat" value="General" type="String"/><column name="string1" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="string1" property="Address" value="$E$4" type="String"/><column name="string1" property="ColumnWidth" value="14.86" type="Double"/><column name="string1" property="NumberFormat" value="General" type="String"/><column name="string1" property="Validation.Type" value="6" type="Double"/><column name="string1" property="Validation.Operator" value="8" type="Double"/><column name="string1" property="Validation.Formula1" value="50" type="String"/><column name="string1" property="Validation.AlertStyle" value="1" type="Double"/><column name="string1" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="string1" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="string1" property="Validation.ShowInput" value="True" type="Boolean"/><column name="string1" property="Validation.ShowError" value="True" type="Boolean"/><column name="string2" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="string2" property="Address" value="$F$4" type="String"/><column name="string2" property="ColumnWidth" value="14.57" type="Double"/><column name="string2" property="NumberFormat" value="General" type="String"/><column name="string2" property="Validation.Type" value="6" type="Double"/><column name="string2" property="Validation.Operator" value="8" type="Double"/><column name="string2" property="Validation.Formula1" value="50" type="String"/><column name="string2" property="Validation.AlertStyle" value="1" type="Double"/><column name="string2" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="string2" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="string2" property="Validation.ShowInput" value="True" type="Boolean"/><column name="string2" property="Validation.ShowError" value="True" type="Boolean"/><column name="int1" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="int1" property="Address" value="$G$4" type="String"/><column name="int1" property="NumberFormat" value="General" type="String"/><column name="int1" property="Validation.Type" value="1" type="Double"/><column name="int1" property="Validation.Operator" value="1" type="Double"/><column name="int1" property="Validation.Formula1" value="-2147483648" type="String"/><column name="int1" property="Validation.Formula2" value="2147483647" type="String"/><column name="int1" property="Validation.AlertStyle" value="1" type="Double"/><column name="int1" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="int1" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="int1" property="Validation.ShowInput" value="True" type="Boolean"/><column name="int1" property="Validation.ShowError" value="True" type="Boolean"/><column name="int2" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="int2" property="Address" value="$H$4" type="String"/><column name="int2" property="NumberFormat" value="General" type="String"/><column name="int2" property="Validation.Type" value="1" type="Double"/><column name="int2" property="Validation.Operator" value="1" type="Double"/><column name="int2" property="Validation.Formula1" value="-2147483648" type="String"/><column name="int2" property="Validation.Formula2" value="2147483647" type="String"/><column name="int2" property="Validation.AlertStyle" value="1" type="Double"/><column name="int2" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="int2" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="int2" property="Validation.ShowInput" value="True" type="Boolean"/><column name="int2" property="Validation.ShowError" value="True" type="Boolean"/><column name="float1" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="float1" property="Address" value="$I$4" type="String"/><column name="float1" property="NumberFormat" value="General" type="String"/><column name="float1" property="Validation.Type" value="2" type="Double"/><column name="float1" property="Validation.Operator" value="4" type="Double"/><column name="float1" property="Validation.Formula1" value="-1.11222333444555E+29" type="String"/><column name="float1" property="Validation.AlertStyle" value="1" type="Double"/><column name="float1" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="float1" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="float1" property="Validation.ShowInput" value="True" type="Boolean"/><column name="float1" property="Validation.ShowError" value="True" type="Boolean"/><column name="float2" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="float2" property="Address" value="$J$4" type="String"/><column name="float2" property="NumberFormat" value="General" type="String"/><column name="float2" property="Validation.Type" value="2" type="Double"/><column name="float2" property="Validation.Operator" value="4" type="Double"/><column name="float2" property="Validation.Formula1" value="-1.11222333444555E+29" type="String"/><column name="float2" property="Validation.AlertStyle" value="1" type="Double"/><column name="float2" property="Validation.IgnoreBlank" value="True" type="Boolean"/><column name="float2" property="Validation.InCellDropdown" value="True" type="Boolean"/><column name="float2" property="Validation.ShowInput" value="True" type="Boolean"/><column name="float2" property="Validation.ShowError" value="True" type="Boolean"/><column name="" property="Tab.Color" value="5287936" type="Double"/><column name="" property="Tab.Color" value="5287936" type="Double"/><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean"/><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean"/><column name="" property="ActiveWindow.Split" value="True" type="Boolean"/><column name="" property="ActiveWindow.SplitRow" value="0" type="Double"/><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double"/><column name="" property="PageSetup.Orientation" value="2" type="Double"/><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double"/></columnFormats></table>');
INSERT INTO XLS.FORMATS (TABLE_SCHEMA, TABLE_NAME, TABLE_EXCEL_FORMAT_XML) VALUES ('S14', 'VIEW_ALIASES', '<table name="S14.VIEW_ALIASES"><columnFormats><column name="" property="ListObjectName" value="aliases" type="String"/><column name="" property="ShowTotals" value="False" type="Boolean"/><column name="" property="TableStyle.Name" value="TableStyleMedium15" type="String"/><column name="" property="ShowTableStyleColumnStripes" value="False" type="Boolean"/><column name="" property="ShowTableStyleFirstColumn" value="False" type="Boolean"/><column name="" property="ShowShowTableStyleLastColumn" value="False" type="Boolean"/><column name="" property="ShowTableStyleRowStripes" value="False" type="Boolean"/><column name="_RowNum" property="EntireColumn.Hidden" value="True" type="Boolean"/><column name="_RowNum" property="Address" value="$B$4" type="String"/><column name="_RowNum" property="NumberFormat" value="General" type="String"/><column name="client_id" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="client_id" property="Address" value="$C$4" type="String"/><column name="client_id" property="ColumnWidth" value="10.29" type="Double"/><column name="client_id" property="NumberFormat" value="General" type="String"/><column name="table_name" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="table_name" property="Address" value="$D$4" type="String"/><column name="table_name" property="ColumnWidth" value="13.57" type="Double"/><column name="table_name" property="NumberFormat" value="General" type="String"/><column name="column_name" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="column_name" property="Address" value="$E$4" type="String"/><column name="column_name" property="ColumnWidth" value="15.29" type="Double"/><column name="column_name" property="NumberFormat" value="General" type="String"/><column name="alias" property="EntireColumn.Hidden" value="False" type="Boolean"/><column name="alias" property="Address" value="$F$4" type="String"/><column name="alias" property="ColumnWidth" value="12.14" type="Double"/><column name="alias" property="NumberFormat" value="General" type="String"/><column name="" property="Tab.Color" value="5287936" type="Double"/><column name="" property="Tab.Color" value="5287936" type="Double"/><column name="" property="ActiveWindow.DisplayGridlines" value="False" type="Boolean"/><column name="" property="ActiveWindow.FreezePanes" value="True" type="Boolean"/><column name="" property="ActiveWindow.Split" value="True" type="Boolean"/><column name="" property="ActiveWindow.SplitRow" value="0" type="Double"/><column name="" property="ActiveWindow.SplitColumn" value="-2" type="Double"/><column name="" property="PageSetup.Orientation" value="2" type="Double"/><column name="" property="PageSetup.FitToPagesWide" value="1" type="Double"/><column name="" property="PageSetup.FitToPagesTall" value="1" type="Double"/></columnFormats></table>');

-- print Application installed
