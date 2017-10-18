DROP TABLE T1_BASE;
CREATE TABLE T1_BASE

(
DEVICE_KEY NUMBER,
DEVICE_LOCAL_TIME TIMESTAMP(6),
SENSOR_OUTPUT NUMBER
)
PCTFREE 2
INITRANS 1 
MAXTRANS 255
NOCOMPRESS;
ROW STORE COMPRESS ADVANCED;


BEGIN

FOR A IN 1..8 LOOP

INSERT INTO T1_BASE

SELECT
    A AS DEVICE_ID,
    TO_TIMESTAMP('20170101 00:00:00.000', 'yyyymmdd hh24:mi:ss.ff') + NUMTODSINTERVAL(DBMS_RANDOM.VALUE(0, 364),'DAY') AS DEVICE_LOCAL_TIME,
    ROUND(DBMS_RANDOM.VALUE(1001, 1999)) AS SENSOR_OUTPUT
FROM DUAL
CONNECT BY LEVEL <= 1000000/8;

END LOOP;

COMMIT;

DBMS_STATS.GATHER_TABLE_STATS(OWNNAME => 'KIRBYS', TABNAME => 'T1_BASE', GRANULARITY => 'ALL', ESTIMATE_PERCENT => DBMS_STATS.AUTO_SAMPLE_SIZE, DEGREE => 16, CASCADE => DBMS_STATS.AUTO_CASCADE);

END;
/
BEGIN
DBMS_STATS.GATHER_TABLE_STATS(OWNNAME => 'KIRBYS', TABNAME => 'T1_BASE', GRANULARITY => 'ALL', ESTIMATE_PERCENT => DBMS_STATS.AUTO_SAMPLE_SIZE, DEGREE => 16, CASCADE => DBMS_STATS.AUTO_CASCADE);
END;
/
SELECT * FROM T1_BASE;

SELECT
    A.COMPRESS_FOR,
    A.OWNER,
    A.TABLE_NAME,
    A.TABLESPACE_NAME,
    A.NUM_ROWS,
    B.BLOCK_SIZE,
    A.BLOCKS,
    B.BLOCK_SIZE * A.BLOCKS / POWER(1024,2) AS TABLE_SIZE_MB
FROM DBA_TABLES A
    INNER JOIN DBA_TABLESPACES B
        ON A.TABLESPACE_NAME = B.TABLESPACE_NAME
WHERE A.TABLE_NAME IN('T1_BASE','T1_COMP');

SELECT * FROM DBA_EXTENTS WHERE OWNER = 'KIRBYS' AND SEGMENT_NAME = 'T1_BASE';
SELECT 
    INITIAL_EXTENT/POWER(1024,2)
FROM DBA_TABLES WHERE OWNER = 'KIRBYS' AND TABLE_NAME = 'T1_BASE';

CREATE TABLE T1_COMP
ROW STORE COMPRESS ADVANCED

AS SELECT * FROM T1_BASE;