select
   dbms_rowid.rowid_relative_fno(rowid) REL_FNO,
   dbms_rowid.rowid_block_number(rowid) BLOCKNO,
--   dbms_rowid.rowid_row_number(rowid) ROWNO
   COUNT(*)
   from capstone.SIZE_MATH_TEST
   GROUP BY
    dbms_rowid.rowid_relative_fno(rowid),
   dbms_rowid.rowid_block_number(rowid);
   
ALTER SYSTEM DUMP DATAFILE 12 BLOCK 363;