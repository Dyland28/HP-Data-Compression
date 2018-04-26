/*
	Run on all four tables with varying column width
*/

SELECT /*+ NOPARALLEL MONITORING */
    COL0,
    AVG(COL1) AS AVG_COL1
FROM COL_SIZE_TEST
GROUP BY
    COL0;
	
	