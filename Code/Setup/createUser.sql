--make sure to run this as a sysdba

alter session set container=pdb1;

--username: capstone
--password: cappas
create user capstone identified by cappas;
grant create session, create table to capstone;
alter user capstone quota unlimited on cap8k;
alter user capstone quota unlimited on cap16k;
alter user capstone quota unlimited on cap32k;
alter user capstone quota unlimited on users;
