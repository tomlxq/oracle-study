实验1) Rows
由CBO 通过动态取样判断得到的行记录数。
SQL> set autotrace off
SQL> drop table t purge;
SQL> create table t as select 1 id,object_name from dba_objects;
SQL> update t set id = 99 where rownum=1;
SQL> set autotrace trace explain;
SQL> select count(*) from t;

Execution Plan
----------------------------------------------------------
Plan hash value: 2966233522

-------------------------------------------------------------------
| Id  | Operation          | Name | Rows  | Cost (%CPU)| Time     |
-------------------------------------------------------------------
|   0 | SELECT STATEMENT   |      |     1 |    95   (2)| 00:00:02 |
|   1 |  SORT AGGREGATE    |      |     1 |            |          |
|   2 |   TABLE ACCESS FULL| T    | 79525 |    95   (2)| 00:00:02 |
-------------------------------------------------------------------

Note
-----
   - dynamic sampling used for this statement (level=2)  
   
使用动态采样 CBO 估算行数为79525 行
SELECT 语句数据1 行

SQL> exec dbms_stats.gather_table_stats(user,'T',cascade=>true); --对T 表收集统计信息
SQL> select count(*) from t;

Execution Plan
----------------------------------------------------------
Plan hash value: 2966233522

-------------------------------------------------------------------
| Id  | Operation          | Name | Rows  | Cost (%CPU)| Time     |
-------------------------------------------------------------------
|   0 | SELECT STATEMENT   |      |     1 |    95   (2)| 00:00:02 |
|   1 |  SORT AGGREGATE    |      |     1 |            |          |
|   2 |   TABLE ACCESS FULL| T    | 75593 |    95   (2)| 00:00:02 |
-------------------------------------------------------------------

SQL> select * from t; --验证SELECT 行数

Execution Plan
----------------------------------------------------------
Plan hash value: 1601196873

--------------------------------------------------------------------------
| Id  | Operation         | Name | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      | 75593 |  1993K|    95   (2)| 00:00:02 |
|   1 |  TABLE ACCESS FULL| T    | 75593 |  1993K|    95   (2)| 00:00:02 |
--------------------------------------------------------------------------
实验2) Bytes
扫描的行的大小。   Bytes=rows/avg_row_len/1024
SQL> select * from t;

Execution Plan
----------------------------------------------------------
Plan hash value: 1601196873

--------------------------------------------------------------------------
| Id  | Operation         | Name | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      | 75593 |  1993K|    95   (2)| 00:00:02 |
|   1 |  TABLE ACCESS FULL| T    | 75593 |  1993K|    95   (2)| 00:00:02 |
--------------------------------------------------------------------------
SQL> set autotrace off;
SQL> select avg_row_len from user_tables where table_name='T';

AVG_ROW_LEN
-----------
         27

SQL> select 75593*27/1024||'KB' "SIZE OF T " from dual;

SIZE OF T
-----------------
1993.1748046875KB

实验3) Cost（%CPU） CPU_COST/COST=(COST-IO_COST)/COST*100%

SQL> set autotrace trace explain
SQL> select id,count(*) from t group by id;

Execution Plan
----------------------------------------------------------
Plan hash value: 47235625

---------------------------------------------------------------------------
| Id  | Operation          | Name | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |      |     2 |     6 |    99   (6)| 00:00:02 |
|   1 |  HASH GROUP BY     |      |     2 |     6 |    99   (6)| 00:00:02 |
|   2 |   TABLE ACCESS FULL| T    | 75593 |   221K|    95   (2)| 00:00:02 |
---------------------------------------------------------------------------
SQL> set autotrace off
SQL> select cost, cpu_cost, io_cost from v$sql_plan sql where sql.plan_HASH_VALUE = '47235625'; --查看CPU 和IO 消耗

      COST   CPU_COST    IO_COST
---------- ---------- ----------
        99
        99   85907619         94  	--IO_COST=94,CPU_COST=99-94=5 5/99≈05.0505051%
        95   13753118         94	--IO_COST=94,CPU_COST=95-94=1 1/95≈01.0526316%
SQL> select (95-94)/95 "CPU COST%" from dual;

 CPU COST%
----------
.010526316
