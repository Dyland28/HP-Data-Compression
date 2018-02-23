BEGIN

FOR A IN 10..19 LOOP --To keep the number of digits equal to 2 so my column length is 16 for all rows

INSERT INTO CAPSTONE.PARENT_TABLE_TEST

(
PARENT_CHILD_RATIO,
DEVICE_NAME,
MEASUREMENT_TIME
)

SELECT
    '800X_BIG' AS PARENT_CHILD_RATIO,
    'DEVICE_NUMBER_'||A AS DEVICE_NAME,
    TO_DATE(20170101, 'yyyymmdd') + NUMTODSINTERVAL(DBMS_RANDOM.VALUE(0, 31500000), 'second') AS MEASUREMENT_TIME
FROM DUAL
CONNECT BY LEVEL <= 1250; --Total of 12500 rows with looping 10 times

COMMIT;

END LOOP;

END;
/

BEGIN

FOR A IN 10..19 LOOP --Primary Location
FOR B IN 10..89 LOOP --Secondary Location

INSERT INTO CAPSTONE.CHILD_TABLE_TEST

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
    'SEC_LOCN_00000' || B AS SECONDARY_LOCATION,
    DBMS_RANDOM.VALUE(0, 100000)
FROM CAPSTONE.PARENT_TABLE_TEST A
WHERE PARENT_CHILD_RATIO = '800X_BIG';

COMMIT;

END LOOP;
END LOOP;

END;
/