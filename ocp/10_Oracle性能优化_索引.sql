索引是一张比较瘦的表
	1. 扫描索引，找到rowid
		SQL> select deptno,rowid from scott.dept;
		DEPTNO ROWID
		---------- ------------------
		10 AAASYxAAEAAAACHAAA
		20 AAASYxAAEAAAACHAAB
		30 AAASYxAAEAAAACHAAC
		40 AAASYxAAEAAAACHAAD
		rowid
		AAASYx		AAE			AAA			ACHAAD
		object_id	file_id		block_id	block的行编号
	2. 根据rowid,提取数据
维护索引的成本很高，不适用于增删改频繁的表
where条件的字段

分类
	B*tree	
		一对一
		重复率低
	bitmap	
		一对多
		重复率高
		位置段　导致更多的行被锁
	
SQL> drop table solo;
SQL> create table solo as select * from all_objects;
SQL> select index_name,blevel,num_rows from dba_indexes where table_name='SOLO';
SQL> create index idx_id on solo(object_id);
SQL> select index_name,blevel,num_rows from dba_indexes where table_name='SOLO';

INDEX_NAME                         BLEVEL   NUM_ROWS
------------------------------ ---------- ----------
IDX_ID                                  1      73205
注意： BLEVEL为1 (这是分支层数，比HEIGHT小1,因为BLEVEL不把叶子块层算在内)
说明HEIGHT为2，要找到叶子需要1个I/O，（访问叶子本身还需要第二个I/O）
SQL> create table solo2 as select * from solo;
SQL> create index idx_id2 on solo2(object_id) pctfree 90; --pct free 90% 意味着占用更多的空间，io次数增加
SQL> select index_name,blevel,num_rows from dba_indexes where table_name='SOLO2';

INDEX_NAME                         BLEVEL   NUM_ROWS
------------------------------ ---------- ----------
IDX_ID2                                 2      73205	
SQL> drop table solo2 purge;
SQL> set autotrace on

SQL> select object_id from solo where object_id=26;


Execution Plan
----------------------------------------------------------
Plan hash value: 578627003

---------------------------------------------------------------------------
| Id  | Operation        | Name   | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------
|   0 | SELECT STATEMENT |        |     1 |     5 |     1   (0)| 00:00:01 |
|*  1 |  INDEX RANGE SCAN| IDX_ID |     1 |     5 |     1   (0)| 00:00:01 |
---------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - access("OBJECT_ID"=26)


Statistics
----------------------------------------------------------
          1  recursive calls
          0  db block gets
          3  consistent gets
          0  physical reads
          0  redo size
        423  bytes sent via SQL*Net to client
        419  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
          1  rows processed
BLEVEL　为分支层次

SQL> select object_id from solo where object_id=49460;


Execution Plan
----------------------------------------------------------
Plan hash value: 578627003

---------------------------------------------------------------------------
| Id  | Operation        | Name   | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------
|   0 | SELECT STATEMENT |        |     1 |     5 |     1   (0)| 00:00:01 |
|*  1 |  INDEX RANGE SCAN| IDX_ID |     1 |     5 |     1   (0)| 00:00:01 |
---------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - access("OBJECT_ID"=49460)


Statistics
----------------------------------------------------------
          1  recursive calls
          0  db block gets
          3  consistent gets
          0  physical reads
          0  redo size
        425  bytes sent via SQL*Net to client
        419  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
          1  rows processed
--B*树索引的使用？
--a.索引用于访问表中的行：通过读索引来访问表中的行，此时希望访问表中很少的一部分行（只占一个很小的百分比5%~10%)
--b.索引用于回答一个查询：索引包含了足够的信息来回答整个查询，不必去访问表。此时，索引就是一个较瘦的表
SQL> select * from solo where object_id=26;


Execution Plan
----------------------------------------------------------
Plan hash value: 3385881420

--------------------------------------------------------------------------------------
| Id  | Operation                   | Name   | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |        |     1 |    97 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| SOLO   |     1 |    97 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | IDX_ID |     1 |       |     1   (0)| 00:00:01 |
--------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("OBJECT_ID"=26)


Statistics
----------------------------------------------------------
          0  recursive calls
          0  db block gets
          4  consistent gets
          0  physical reads
          0  redo size
       1407  bytes sent via SQL*Net to client
        419  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
          1  rows processed
SQL> create index  in_solo on solo(owner);

Index created.

SQL> select owner,status from solo where owner='USER';

Execution Plan
----------------------------------------------------------
Plan hash value: 1901426986

---------------------------------------------------------------------------------------
| Id  | Operation                   | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |         |  2361 | 30693 |    69   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| SOLO    |  2361 | 30693 |    69   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | IN_SOLO |  2361 |       |     6   (0)| 00:00:01 |
---------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("OWNER"='USER')
		  
--这是正确索引的执行计划,在查询谓语的列上建立索引
--如果必须完成TABLE ACCESS BY INDEX ROWID，就必须确保访问表中很少的一部分块（只占很小的百分比)，B*树才适合
SQL> select count(*) from solo where owner='USER';

Execution Plan
----------------------------------------------------------
Plan hash value: 2313721506

-----------------------------------------------------------------------------
| Id  | Operation         | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |         |     1 |     6 |     6   (0)| 00:00:01 |
|   1 |  SORT AGGREGATE   |         |     1 |     6 |            |          |
|*  2 |   INDEX RANGE SCAN| IN_SOLO |  2361 | 14166 |     6   (0)| 00:00:01 |
-----------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("OWNER"='USER')
--这里会读一个索引块，选出许多“行"来处理，然后再到另一个索引块中，如此继续，从不访问表
SQL> select count(*) from solo;

Execution Plan
----------------------------------------------------------
Plan hash value: 2929617283

------------------------------------------------------------------------
| Id  | Operation             | Name   | Rows  | Cost (%CPU)| Time     |
------------------------------------------------------------------------
|   0 | SELECT STATEMENT      |        |     1 |    47   (3)| 00:00:01 |
|   1 |  SORT AGGREGATE       |        |     1 |            |          |
|   2 |   INDEX FAST FULL SCAN| IDX_ID | 73205 |    47   (3)| 00:00:01 |
------------------------------------------------------------------------
--快速全面扫描，数据库不按特定的顺序读取索引块，而只是开始读取它们，这里索引更像一个瘦表
--如采用快速全面扫描，将不再按索引条目的顺序来得到行.

SQL>  create table colocated (x int,y varchar2(80) );
SQL> begin
  2  for i in 1.. 100000
  3  loop
  4  insert into colocated(x,y)
  5  values(i,rpad(dbms_random.random,75,'*'));
  6  end loop;
  7  end;
  8  /
SQL> alter table colocated
  2  add constraint colocated_pk
  3  primary key(x);
SQL> exec dbms_stats.gather_table_stats(user,'colocated',cascade=>true);
SQL> create table disoragnized
  2  as
  3  select  x,y
  4  from colocated
  5  order by y;
SQL> alter table disoragnized
  2   add  constraint disoragnized_pk
  3  primary key(x);
SQL> exec dbms_stats.gather_table_stats(user,'disoragnized',cascade=>true);
SQL> set autotrace traceonly explain;
SQL> select  * from colocated where x between 20000 and 40000;

Execution Plan
----------------------------------------------------------
Plan hash value: 1550765370

--------------------------------------------------------------------------------------------
| Id  | Operation                   | Name         | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |              | 20002 |  1582K|   283   (1)| 00:00:04 |
|   1 |  TABLE ACCESS BY INDEX ROWID| COLOCATED    | 20002 |  1582K|   283   (1)| 00:00:04 |
|*  2 |   INDEX RANGE SCAN          | COLOCATED_PK | 20002 |       |    43   (0)| 00:00:01 |
--------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("X">=20000 AND "X"<=40000)

tween 20000 and 40000;
SQL> select /*+ index(disoragnized  disoragnized_pk) */* from disoragnized where x between 20000 and 40000;

Execution Plan
----------------------------------------------------------
Plan hash value: 936682199

-----------------------------------------------------------------------------------------------
| Id  | Operation                   | Name            | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |                 | 20002 |  1582K| 20042   (1)| 00:04:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| DISORAGNIZED    | 20002 |  1582K| 20042   (1)| 00:04:01 |
|*  2 |   INDEX RANGE SCAN          | DISORAGNIZED_PK | 20002 |       |    43   (0)| 00:00:01 |
-----------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("X">=20000 AND "X"<=40000)

SQL> set autotrace off
SQL> select table_name,blocks from user_tables where table_name in('COLOCATED','DISORAGNIZED');

TABLE_NAME                         BLOCKS
------------------------------ ----------
COLOCATED                            1191
DISORAGNIZED                         1191
--察看tkprof跟踪
--对于物理上公同放置的数据COLOCATED，逻辑I/O次数则大幅下降，对无组织的查询正如先前计算一样，作了20000次逻辑I/O这里我做的是2个查询走的同样的执行计划
--每个逻辑I/O都涉及缓冲区缓存的一个或多个锁存器，在一个多用户/CPU情况下，在我们自旋并等待锁存器时，与第一个查询相比，第二个查询所用的CPU时间无疑会高出几倍。
SQL> select a.index_name, b.num_rows,b.blocks,a.clustering_factor
  2      from user_indexes a,user_tables b
  3     where index_name in('COLOCATED_PK','DISORAGNIZED_PK')
  4    and a.table_name=b.table_name;

INDEX_NAME                       NUM_ROWS     BLOCKS CLUSTERING_FACTOR
------------------------------ ---------- ---------- -----------------
COLOCATED_PK                       100000       1191              1190
DISORAGNIZED_PK                    100000       1191             99936
如果通过索引COLOCATED_PK从头到尾读取COLOCATED表中的每一行，就要执行1190次I/O，不过，如果对DISORAGNIZED做同样操作，会对表执行99936次I/O
原因是，当oracle对索引结构执行区间扫描时，如果发现索引中下一行与前一行在同一个数据块上，就不会再执行另一个I/O从缓冲区缓存中获得表块

SQL> set autotrace traceonly
SQL> select count(y) from  (select /*+ index(colocated colocated_pk)*/* from colocated);


Execution Plan
----------------------------------------------------------
Plan hash value: 3483305348

---------------------------------------------------------------------------------------------
| Id  | Operation                    | Name         | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |              |     1 |    76 |  1402   (1)| 00:00:17 |
|   1 |  SORT AGGREGATE              |              |     1 |    76 |            |          |
|   2 |   TABLE ACCESS BY INDEX ROWID| COLOCATED    |   100K|  7421K|  1402   (1)| 00:00:17 |
|   3 |    INDEX FULL SCAN           | COLOCATED_PK |   100K|       |   210   (1)| 00:00:03 |
---------------------------------------------------------------------------------------------


Statistics
----------------------------------------------------------
          1  recursive calls
          0  db block gets
       1399  consistent gets
          0  physical reads
          0  redo size
        422  bytes sent via SQL*Net to client
        419  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
          1  rows processed
SQL> select count(y) from (select /*+ index(DISORAGNIZED DISORAGNIZED_pk) */* from DISORAGNIZED);


Execution Plan
----------------------------------------------------------
Plan hash value: 2321141640

------------------------------------------------------------------------------------------------
| Id  | Operation                    | Name            | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |                 |     1 |    76 |   100K  (1)| 00:20:03 |
|   1 |  SORT AGGREGATE              |                 |     1 |    76 |            |          |
|   2 |   TABLE ACCESS BY INDEX ROWID| DISORAGNIZED    |   100K|  7421K|   100K  (1)| 00:20:03 |
|   3 |    INDEX FULL SCAN           | DISORAGNIZED_PK |   100K|       |   210   (1)| 00:00:03 |
------------------------------------------------------------------------------------------------


Statistics
----------------------------------------------------------
          1  recursive calls
          0  db block gets
     100145  consistent gets
          0  physical reads
          0  redo size
        422  bytes sent via SQL*Net to client
        419  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
          1  rows processed
总结：让优化器使用索引全扫描来读取整个表，在统计非null的y值个数，来观察通过索引读取整个表需要执行多少次I/O
两种情况下，一致读（consistent gets）总次数（包括对索引执行的逻辑I/O次数 + 对表执行的逻辑I/O次数）
发现对表执行的逻辑I/O次数与各个索引的聚簇因子相等

-----------------------------------
全表扫描　full table scan
根据rowid查找
索引扫描
	索引唯一扫描	create unique index
	索引范围扫描	where ... <> = between
	索引快速全扫描	不排序　like 'a%'
	索引全表扫描	排序 order by  
	


SQL> drop table t purge;

Table dropped.

SQL> create table t as select * from hr.employees;

Table created.

SQL> create unique index idx_emp_id on t(employee_id);

Index created.
SQL> select * from t where employee_id=110;

Execution Plan
----------------------------------------------------------
Plan hash value: 3436217163

------------------------------------------------------------------------------------------
| Id  | Operation                   | Name       | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |            |     1 |   133 |     1   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| T          |     1 |   133 |     1   (0)| 00:00:01 |
|*  2 |   INDEX UNIQUE SCAN         | IDX_EMP_ID |     1 |       |     0   (0)| 00:00:01 |
------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("EMPLOYEE_ID"=110)