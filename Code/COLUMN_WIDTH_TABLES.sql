/*
	Script to create tables with varying column widths but equal total row width. 
	
	Creates both compressed and uncompressed versions.
*/

CREATE TABLE CAPSTONE.COL_SIZE_TEST 
(
COL0 VARCHAR(116),
COL1 INT GENERATED ALWAYS AS IDENTITY START WITH 1000000000,
COL2 VARCHAR(8)
)
    PCTFREE 0 
    NOCOMPRESS 
    TABLESPACE CAP8K;


BEGIN

FOR A IN 100..199 LOOP

INSERT INTO CAPSTONE.COL_SIZE_TEST

(
COL0,
COL2
)

SELECT
   'AAA_BBB_CCC_DDD_EEE_FFF_GGG_HHH_III_JJJ_KKK_LLL_MMM_NNN_OOO_PPP_QQQ_RRR_SSS_TTT_UUU_VVV_WWW_XXX_YYY_ZZZ_000000000' || A AS COL0,
   dbms_random.string('U', 8) AS COL2
FROM DUAL
CONNECT BY LEVEL <= 100000;

END LOOP;
commit;
end;

CREATE TABLE CAPSTONE.COL_SIZE_TEST_2 
(
COL0 VARCHAR(8),
COL1 INT GENERATED ALWAYS AS IDENTITY START WITH 1000000000,
COL2 VARCHAR(116)
)
    PCTFREE 0 
    NOCOMPRESS 
    TABLESPACE CAP8K;


BEGIN

FOR A IN 100..199 LOOP

INSERT INTO CAPSTONE.COL_SIZE_TEST_2

(
COL0,
COL2
)

SELECT
   'AAAA_' || A AS COL0,
   dbms_random.string('U', 116) AS COL2
FROM DUAL
CONNECT BY LEVEL <= 100000;

END LOOP;
commit;
end;

create table CAPSTONE.COL_SIZE_TEST_COMP compress basic PCTFREE 0 TABLESPACE CAP8K
as
select * from CAPSTONE.COL_SIZE_TEST;

create table CAPSTONE.COL_SIZE_TEST_COMP_2 compress basic PCTFREE 0 TABLESPACE CAP8K
as
select * from CAPSTONE.COL_SIZE_TEST_2;