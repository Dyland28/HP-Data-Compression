TRUNCATE TABLE CAPSTONE.ROWS_PER_BLOCK;
DROP TABLE CAPSTONE.ROWS_PER_BLOCK;
CREATE TABLE CAPSTONE.ROWS_PER_BLOCK
(
OWNER VARCHAR2(30),
TABLE_NAME VARCHAR2(30),
REL_FNO NUMBER,
BLOCKNO NUMBER,
TOTAL_ROWS NUMBER
);

INSERT INTO CAPSTONE.BLOCKS_PER_ROW
/
SELECT
    :OWNER AS OWNER,
    :TABLE_NAME AS TABLE_NAME,
    dbms_rowid.rowid_relative_fno(rowid) REL_FNO,
    dbms_rowid.rowid_block_number(rowid) BLOCKNO,
    COUNT(*) AS TOTAL_ROWS
FROM capstone.C_8K_COMP_SORT
GROUP BY
    dbms_rowid.rowid_relative_fno(rowid),
    dbms_rowid.rowid_block_number(rowid)
ORDER BY
    TOTAL_ROWS DESC;
    
COMMIT;

SELECT
    OWNER,
    TABLE_NAME,
    MAX(TOTAL_ROWS) AS ROWS_PER_BLOCK
FROM CAPSTONE.

   
ALTER SYSTEM DUMP DATAFILE 12 BLOCK 363;