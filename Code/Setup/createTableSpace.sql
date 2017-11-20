--make sure to run this script as a sysdba
--you may also need to open your pluggable database

alter session set container=cdb$root;
alter system set db_16k_cache_size=20M;
alter system set db_32k_cache_size=20M;
alter session set container=capstone;
create tablespace cap8k datafile '/u01/app/oracle/oradata/cdb1/pdb1/cap8k.dbf' size 1g extent management local uniform size 40k;
create tablespace cap16k datafile '/u01/app/oracle/oradata/cdb1/pdb1/cap16k.dbf' size 1g blocksize 16k extent management local uniform size 80k;
create tablespace cap32k datafile '/u01/app/oracle/oradata/cdb1/pdb1/cap32k.dbf' size 1g blocksize 32k extent management local uniform size 160k;
select * from DBA_DATA_FILES;

DROP TABLESPACE CAP8K INCLUDING CONTENTS;
DROP TABLESPACE CAP16K INCLUDING CONTENTS;
DROP TABLESPACE CAP32K INCLUDING CONTENTS;