DROP TABLE CAPSTONE.TABLE_TYPES;
CREATE TABLE CAPSTONE.TABLE_TYPES

(
TABLE_TYPE VARCHAR2(32),
DESCRIPTION VARCHAR2(1000)
);

INSERT INTO CAPSTONE.TABLE_TYPES(TABLE_TYPE, DESCRIPTION) VALUES('NORM', 'Normalized where we store the key instead of the VARCHAR');
INSERT INTO CAPSTONE.TABLE_TYPES(TABLE_TYPE, DESCRIPTION) VALUES('DENORM', 'Denormalized where we store the VARCHAR instead of the KEY');
COMMIT;

DROP TABLE CAPSTONE.TABLESPACE_TYPES;
CREATE TABLE CAPSTONE.TABLESPACE_TYPES

(
TABLESPACE_NAME VARCHAR2(32),
TABLESPACE_SYNTAX VARCHAR2(1000),
BLOCK_SIZE_BYTES NUMBER,
DESCRIPTION VARCHAR2(1000)
);

INSERT INTO CAPSTONE.TABLESPACE_TYPES(TABLESPACE_NAME, TABLESPACE_SYNTAX, BLOCK_SIZE_BYTES, DESCRIPTION) VALUES('CAP8K', 'TABLESPACE CAP8K', 8192, '8K');
INSERT INTO CAPSTONE.TABLESPACE_TYPES(TABLESPACE_NAME, TABLESPACE_SYNTAX, BLOCK_SIZE_BYTES, DESCRIPTION) VALUES('CAP16K', 'TABLESPACE CAP16K', 16384, '16K');
INSERT INTO CAPSTONE.TABLESPACE_TYPES(TABLESPACE_NAME, TABLESPACE_SYNTAX, BLOCK_SIZE_BYTES, DESCRIPTION) VALUES('CAP32K', 'TABLESPACE CAP32K', 32768, '32K');
COMMIT;

DROP TABLE CAPSTONE.COMPRESSION_TYPES;
CREATE TABLE CAPSTONE.COMPRESSION_TYPES

(
OBJECT_TYPE VARCHAR2(32),
COMPRESSION_SYNTAX VARCHAR2(32),
DESCRIPTION VARCHAR2(32)
);

INSERT INTO CAPSTONE.COMPRESSION_TYPES(OBJECT_TYPE, COMPRESSION_SYNTAX, DESCRIPTION) VALUES('TABLE','NOCOMPRESS', 'NOCOMPRESS');
INSERT INTO CAPSTONE.COMPRESSION_TYPES(OBJECT_TYPE, COMPRESSION_SYNTAX, DESCRIPTION) VALUES('TABLE','COMPRESS BASIC', 'BASIC');
INSERT INTO CAPSTONE.COMPRESSION_TYPES(OBJECT_TYPE, COMPRESSION_SYNTAX, DESCRIPTION) VALUES('TABLE','ROW STORE COMPRESS ADVANCED', 'ADVANCED');
COMMIT;

DROP TABLE CAPSTONE.VARCHAR_LENGTH;
CREATE TABLE CAPSTONE.VARCHAR_LENGTH
(
VARCHAR_LENGTH NUMBER,
DESCRIPTION VARCHAR2(1000)
);

INSERT INTO CAPSTONE.VARCHAR_LENGTH(VARCHAR_LENGTH,DESCRIPTION) VALUES(1,'L1');
INSERT INTO CAPSTONE.VARCHAR_LENGTH(VARCHAR_LENGTH,DESCRIPTION) VALUES(2,'L2');
INSERT INTO CAPSTONE.VARCHAR_LENGTH(VARCHAR_LENGTH,DESCRIPTION) VALUES(4,'L4');
INSERT INTO CAPSTONE.VARCHAR_LENGTH(VARCHAR_LENGTH,DESCRIPTION) VALUES(8,'L8');
INSERT INTO CAPSTONE.VARCHAR_LENGTH(VARCHAR_LENGTH,DESCRIPTION) VALUES(16,'L16');
INSERT INTO CAPSTONE.VARCHAR_LENGTH(VARCHAR_LENGTH,DESCRIPTION) VALUES(32,'L32');
INSERT INTO CAPSTONE.VARCHAR_LENGTH(VARCHAR_LENGTH,DESCRIPTION) VALUES(64,'L64');
COMMIT;

DROP TABLE CAPSTONE.BLOCK_CARDINALITY;
CREATE TABLE CAPSTONE.BLOCK_CARDINALITY
(
BLOCK_CARDINALITY NUMBER,
DESCRIPTION VARCHAR2(1000)
);

INSERT INTO CAPSTONE.BLOCK_CARDINALITY(BLOCK_CARDINALITY,DESCRIPTION) VALUES(1,'BC1');
INSERT INTO CAPSTONE.BLOCK_CARDINALITY(BLOCK_CARDINALITY,DESCRIPTION) VALUES(2,'BC2');
INSERT INTO CAPSTONE.BLOCK_CARDINALITY(BLOCK_CARDINALITY,DESCRIPTION) VALUES(4,'BC4');
INSERT INTO CAPSTONE.BLOCK_CARDINALITY(BLOCK_CARDINALITY,DESCRIPTION) VALUES(8,'BC8');
INSERT INTO CAPSTONE.BLOCK_CARDINALITY(BLOCK_CARDINALITY,DESCRIPTION) VALUES(16,'BC16');
INSERT INTO CAPSTONE.BLOCK_CARDINALITY(BLOCK_CARDINALITY,DESCRIPTION) VALUES(32,'BC32');
INSERT INTO CAPSTONE.BLOCK_CARDINALITY(BLOCK_CARDINALITY,DESCRIPTION) VALUES(64,'BC64');
COMMIT;

SELECT * FROM CAPSTONE.T1_REF;
SELECT * FROM CAPSTONE.TABLE_TYPES;
SELECT * FROM CAPSTONE.VARCHAR_LENGTH;
SELECT * FROM CAPSTONE.BLOCK_CARDINALITY;
SELECT * FROM CAPSTONE.COMPRESSION_TYPES;
SELECT * FROM CAPSTONE.TABLESPACE_TYPES;

SELECT
    CASE
        WHEN A.TABLE_TYPE = 'DENORM' THEN
            'CREATE TABLE CAPSTONE.' || A.TABLE_TYPE || '_' || B.DESCRIPTION || '_' || D.DESCRIPTION || '_' || E.DESCRIPTION || '_' || C.DESCRIPTION || ' ' || C.COMPRESSION_SYNTAX || ' ' || B.TABLESPACE_SYNTAX || ' ' || 'PCTFREE 0' ||
            ' AS SELECT * FROM (WITH TESTING AS (SELECT LEVEL AS LEVEL_NUMBER, MOD(LEVEL,' || D.VARCHAR_LENGTH || ') AS MOD_LEVEL FROM DUAL CONNECT BY LEVEL <= 250000) SELECT B.VARCHAR_' || D.VARCHAR_LENGTH || ' FROM TESTING A INNER JOIN CAPSTONE.T1_REF B ON A.MOD_LEVEL = B.VARCHAR_KEY ORDER BY A.LEVEL_NUMBER);'
        WHEN A.TABLE_TYPE = 'NORM' THEN
            'CREATE TABLE CAPSTONE.' || A.TABLE_TYPE || '_' || B.DESCRIPTION || '_' || D.DESCRIPTION || '_' || E.DESCRIPTION || '_' || C.DESCRIPTION || ' ' || C.COMPRESSION_SYNTAX || ' ' || B.TABLESPACE_SYNTAX || ' ' || 'PCTFREE 0' ||
            ' AS SELECT * FROM (WITH TESTING AS (SELECT LEVEL AS LEVEL_NUMBER, MOD(LEVEL,' || D.VARCHAR_LENGTH || ') AS MOD_LEVEL FROM DUAL CONNECT BY LEVEL <= 250000) SELECT B.VARCHAR_KEY' || ' FROM TESTING A INNER JOIN CAPSTONE.T1_REF B ON A.MOD_LEVEL = B.VARCHAR_KEY ORDER BY A.LEVEL_NUMBER);'
    END AS CREATE_TABLE_SYNTAX
FROM CAPSTONE.TABLE_TYPES A
    CROSS JOIN CAPSTONE.TABLESPACE_TYPES B
    CROSS JOIN CAPSTONE.COMPRESSION_TYPES C
    CROSS JOIN CAPSTONE.VARCHAR_LENGTH D
    CROSS JOIN CAPSTONE.BLOCK_CARDINALITY E
WHERE C.OBJECT_TYPE = 'TABLE'
AND C.DESCRIPTION IN ('BASIC','NOCOMPRESS')
AND D.VARCHAR_LENGTH >=4
AND E.BLOCK_CARDINALITY >=4;

