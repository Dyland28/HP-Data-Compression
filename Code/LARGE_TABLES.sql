/*
	This script creates the larger test tables

	These first lines turn autoextend on for the tablespaces so the temp doesn't get full
*/

ALTER DATABASE DATAFILE '/u01/app/oracle/oradata/cdb1/pdb1/cap8k.dbf' 
    AUTOEXTEND ON;
	
ALTER DATABASE DATAFILE '/u01/app/oracle/oradata/cdb1/pdb1/cap16k.dbf' 
    AUTOEXTEND ON;
	
ALTER DATABASE DATAFILE '/u01/app/oracle/oradata/cdb1/pdb1/cap32k.dbf' 
    AUTOEXTEND ON;

CREATE TABLE CAPSTONE.PARENT_TABLE_TEST_LARGE

(
PARENT_CHILD_RATIO VARCHAR2(16),
PARENT_KEY NUMBER GENERATED ALWAYS AS IDENTITY START WITH 1000000000, --want to create a key that is at least 1B rows to match the typical length for our big tables
DEVICE_NAME VARCHAR(16),
MEASUREMENT_TIME TIMESTAMP(6)
)
NOLOGGING;

BEGIN

FOR A IN 10..19 LOOP

INSERT INTO CAPSTONE.PARENT_TABLE_TEST_LARGE

(
PARENT_CHILD_RATIO,
DEVICE_NAME,
MEASUREMENT_TIME
)

SELECT
    '800X' AS PARENT_CHILD_RATIO,
    'DEVICE_NUMBER_'||A AS DEVICE_NAME,
    TO_DATE(20170101, 'yyyymmdd') + NUMTODSINTERVAL(DBMS_RANDOM.VALUE(0, 31500000), 'second') AS MEASUREMENT_TIME
FROM DUAL
CONNECT BY LEVEL <= 1250; --Total of 12500 rows with looping 10 times

COMMIT;

END LOOP;

END;
/


CREATE TABLE CAPSTONE.CHILD_TABLE_TEST_LARGE

(
PARENT_CHILD_RATIO VARCHAR(16),
PARENT_KEY NUMBER,
PRIMARY_LOCATION VARCHAR(16),
SECONDARY_LOCATION VARCHAR(16),
MEASUREMENT_VALUE NUMBER GENERATED ALWAYS AS IDENTITY START WITH 1000000000000, --starting with 1E12 digits like our drop count table
RANDOM_VALUE NUMBER
);

BEGIN

FOR A IN 10..19 LOOP --Primary Location
FOR B IN 10..89 LOOP --Secondary Location

INSERT INTO CAPSTONE.CHILD_TABLE_TEST_LARGE

(
PARENT_CHILD_RATIO,
PARENT_KEY,
PRIMARY_LOCATION,
SECONDARY_LOCATION,
RANDOM_VALUE
)

SELECT
    A.PARENT_CHILD_RATIO,
    A.PARENT_KEY,
    'PRIM_LOCN_0000' || A AS PRIMARY_LOCATION,
    'SEC_LOCN_0000' || B AS SECONDARY_LOCATION,
    DBMS_RANDOM.VALUE(0, 1000000)
FROM CAPSTONE.PARENT_TABLE_TEST_LARGE A
WHERE PARENT_CHILD_RATIO = '800X';

COMMIT;

END LOOP;
END LOOP;

END;
/

CREATE TABLE CAPSTONE.P_8K_800X_NOCOMPRESS_LARGE 
    PCTFREE 0
    NOCOMPRESS 
    TABLESPACE CAP8K 
    
AS 

SELECT 
    PARENT_KEY,
    DEVICE_NAME,
    MEASUREMENT_TIME
FROM CAPSTONE.PARENT_TABLE_TEST_LARGE
WHERE PARENT_CHILD_RATIO = '800X';

CREATE TABLE CAPSTONE.C_8K_800X_NOCOMPRESS_LARGE
    PCTFREE 0 
    NOCOMPRESS 
    TABLESPACE CAP8K 
    
AS 

SELECT 
    PARENT_KEY,
    PRIMARY_LOCATION,
    SECONDARY_LOCATION,
    MEASUREMENT_VALUE
FROM CAPSTONE.CHILD_TABLE_TEST_LARGE
WHERE PARENT_CHILD_RATIO = '800X';

CREATE TABLE CAPSTONE.P_8K_800X_RAND_LARGE
    PCTFREE 0 
    COMPRESS BASIC 
    TABLESPACE CAP8K 
    
AS 

SELECT 
    PARENT_KEY,
    DEVICE_NAME,
    MEASUREMENT_TIME
FROM CAPSTONE.PARENT_TABLE_TEST_LARGE
WHERE PARENT_CHILD_RATIO = '800X'
ORDER BY
    MEASUREMENT_TIME,
    PARENT_KEY,
    DEVICE_NAME;
    
CREATE TABLE CAPSTONE.C_8K_800X_RAND_LARGE
    PCTFREE 0 
    COMPRESS BASIC 
    TABLESPACE CAP8K 
    
AS 

SELECT 
    PARENT_KEY,
    PRIMARY_LOCATION,
    SECONDARY_LOCATION,
    MEASUREMENT_VALUE
FROM CAPSTONE.CHILD_TABLE_TEST_LARGE
WHERE PARENT_CHILD_RATIO = '800X'
ORDER BY
    RANDOM_VALUE,
    MEASUREMENT_VALUE;
    
CREATE TABLE CAPSTONE.P_8K_800X_SORT_LARGE
    PCTFREE 0 
    COMPRESS BASIC 
    TABLESPACE CAP8K 
    
AS 

SELECT 
    PARENT_KEY,
    DEVICE_NAME,
    MEASUREMENT_TIME
FROM CAPSTONE.PARENT_TABLE_TEST_LARGE
WHERE PARENT_CHILD_RATIO = '800X'
ORDER BY
    DEVICE_NAME,
    PARENT_KEY,
    MEASUREMENT_TIME;
    
CREATE TABLE CAPSTONE.C_8K_800X_SORT_LARGE
    PCTFREE 0 
    COMPRESS BASIC
    TABLESPACE CAP8K 
    
AS 

SELECT 
    PARENT_KEY,
    PRIMARY_LOCATION,
    SECONDARY_LOCATION,
    MEASUREMENT_VALUE
FROM CAPSTONE.CHILD_TABLE_TEST_LARGE
WHERE PARENT_CHILD_RATIO = '800X'
ORDER BY
    PRIMARY_LOCATION,
    SECONDARY_LOCATION,
    PARENT_KEY,
    MEASUREMENT_VALUE;
    
CREATE TABLE CAPSTONE.P_32K_800X_SORT_LARGE
    PCTFREE 0 
    COMPRESS BASIC 
    TABLESPACE CAP32K 
    
AS 

SELECT 
    PARENT_KEY,
    DEVICE_NAME,
    MEASUREMENT_TIME
FROM CAPSTONE.PARENT_TABLE_TEST_LARGE
WHERE PARENT_CHILD_RATIO = '800X'
ORDER BY
    DEVICE_NAME,
    PARENT_KEY,
    MEASUREMENT_TIME;
    
CREATE TABLE CAPSTONE.C_32K_800X_SORT_LARGE
    PCTFREE 0 
    COMPRESS BASIC
    TABLESPACE CAP32K 
    
AS 

SELECT 
    PARENT_KEY,
    PRIMARY_LOCATION,
    SECONDARY_LOCATION,
    MEASUREMENT_VALUE
FROM CAPSTONE.CHILD_TABLE_TEST_LARGE
WHERE PARENT_CHILD_RATIO = '800X'
ORDER BY
    PRIMARY_LOCATION,
    SECONDARY_LOCATION,
    PARENT_KEY,
    MEASUREMENT_VALUE;
    
CREATE TABLE CAPSTONE.PC_8K_800X_SORT_LARGE
    PCTFREE 0 
    COMPRESS BASIC
    TABLESPACE CAP8K 

AS

SELECT
    A.DEVICE_NAME,
    A.MEASUREMENT_TIME,
    B.PRIMARY_LOCATION,
    B.SECONDARY_LOCATION,
    B.MEASUREMENT_VALUE
FROM CAPSTONE.P_8K_800X_SORT_LARGE A
    INNER JOIN CAPSTONE.C_8K_800X_SORT_LARGE B
        ON A.PARENT_KEY = B.PARENT_KEY
ORDER BY
    PRIMARY_LOCATION,
    SECONDARY_LOCATION,
    DEVICE_NAME;
    
CREATE TABLE CAPSTONE.PC_32K_800X_SORT_LARGE
    PCTFREE 0 
    COMPRESS BASIC
    TABLESPACE CAP32K 

AS

SELECT
    A.DEVICE_NAME,
    A.MEASUREMENT_TIME,
    B.PRIMARY_LOCATION,
    B.SECONDARY_LOCATION,
    B.MEASUREMENT_VALUE
FROM CAPSTONE.P_32K_800X_SORT_LARGE A
    INNER JOIN CAPSTONE.C_32K_800X_SORT_LARGE B
        ON A.PARENT_KEY = B.PARENT_KEY
ORDER BY
    PRIMARY_LOCATION,
    SECONDARY_LOCATION,
    DEVICE_NAME;
    

CREATE TABLE CAPSTONE.DEVICE_NAME_REF_LARGE

(
DEVICE_NAME_KEY NUMBER GENERATED ALWAYS AS IDENTITY START WITH 10,
DEVICE_NAME VARCHAR2(16) NOT NULL
)
PARALLEL (DEGREE DEFAULT)
NOLOGGING;

ALTER TABLE CAPSTONE.DEVICE_NAME_REF_LARGE ADD CONSTRAINT DEVICE_NAME_REF_LARGE_PK PRIMARY KEY (DEVICE_NAME);


INSERT INTO CAPSTONE.DEVICE_NAME_REF_LARGE

(
DEVICE_NAME
)

SELECT DISTINCT
  DEVICE_NAME
FROM CAPSTONE.PARENT_TABLE_TEST_LARGE;

COMMIT;

SELECT * FROM CAPSTONE.DEVICE_NAME_REF_LARGE ORDER BY DEVICE_NAME;

CREATE TABLE CAPSTONE.PRIMARY_LOCATION_REF_LARGE

(
PRIMARY_LOCATION_KEY NUMBER GENERATED ALWAYS AS IDENTITY START WITH 10,
PRIMARY_LOCATION VARCHAR2(16) NOT NULL
)
PARALLEL (DEGREE DEFAULT)
NOLOGGING;

ALTER TABLE CAPSTONE.PRIMARY_LOCATION_REF_LARGE ADD CONSTRAINT PRIMARY_LOCATION_REF_LARGE_PK PRIMARY KEY (PRIMARY_LOCATION);


INSERT INTO CAPSTONE.PRIMARY_LOCATION_REF_LARGE

(
PRIMARY_LOCATION
)

SELECT DISTINCT
  PRIMARY_LOCATION
FROM CAPSTONE.CHILD_TABLE_TEST_LARGE;

COMMIT;

SELECT * FROM CAPSTONE.PRIMARY_LOCATION_REF_LARGE ORDER BY PRIMARY_LOCATION;

CREATE TABLE CAPSTONE.SECONDARY_LOCATION_REF_LARGE

(
SECONDARY_LOCATION_KEY NUMBER GENERATED ALWAYS AS IDENTITY START WITH 10,
SECONDARY_LOCATION VARCHAR2(16) NOT NULL
)
PARALLEL (DEGREE DEFAULT)
NOLOGGING;

ALTER TABLE CAPSTONE.SECONDARY_LOCATION_REF_LARGE ADD CONSTRAINT SECONDARY_LOCATION_REF_LARGE_PK PRIMARY KEY (SECONDARY_LOCATION);


INSERT INTO CAPSTONE.SECONDARY_LOCATION_REF_LARGE

(
SECONDARY_LOCATION
)

SELECT DISTINCT
  SECONDARY_LOCATION
FROM CAPSTONE.CHILD_TABLE_TEST_LARGE;

COMMIT;

CREATE TABLE CAPSTONE.PC_8K_800X_SORT_NORM_LARGE
    PCTFREE 0 
    COMPRESS BASIC
    TABLESPACE CAP8K 

AS

SELECT
    B.DEVICE_NAME_KEY,
    A.MEASUREMENT_TIME,
    C.PRIMARY_LOCATION_KEY,
    D.SECONDARY_LOCATION_KEY,
    A.MEASUREMENT_VALUE
FROM CAPSTONE.PC_8K_800X_SORT_LARGE A
    INNER JOIN CAPSTONE.DEVICE_NAME_REF_LARGE B
        ON A.DEVICE_NAME = B.DEVICE_NAME
    INNER JOIN CAPSTONE.PRIMARY_LOCATION_REF_LARGE C
        ON A.PRIMARY_LOCATION = C.PRIMARY_LOCATION
    INNER JOIN CAPSTONE.SECONDARY_LOCATION_REF_LARGE D
        ON A.SECONDARY_LOCATION = D.SECONDARY_LOCATION
ORDER BY
    C.PRIMARY_LOCATION_KEY,
    D.SECONDARY_LOCATION_KEY,
    B.DEVICE_NAME_KEY;
    
CREATE TABLE CAPSTONE.PC_32K_800X_SORT_NORM_LARGE
    PCTFREE 0 
    COMPRESS BASIC
    TABLESPACE CAP32K

AS

SELECT
    B.DEVICE_NAME_KEY,
    A.MEASUREMENT_TIME,
    C.PRIMARY_LOCATION_KEY,
    D.SECONDARY_LOCATION_KEY,
    A.MEASUREMENT_VALUE
FROM CAPSTONE.PC_32K_800X_SORT_LARGE A
    INNER JOIN CAPSTONE.DEVICE_NAME_REF_LARGE B
        ON A.DEVICE_NAME = B.DEVICE_NAME
    INNER JOIN CAPSTONE.PRIMARY_LOCATION_REF_LARGE C
        ON A.PRIMARY_LOCATION = C.PRIMARY_LOCATION
    INNER JOIN CAPSTONE.SECONDARY_LOCATION_REF_LARGE D
        ON A.SECONDARY_LOCATION = D.SECONDARY_LOCATION
ORDER BY
    C.PRIMARY_LOCATION_KEY,
    D.SECONDARY_LOCATION_KEY,
    B.DEVICE_NAME_KEY;
