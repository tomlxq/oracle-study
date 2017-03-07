cardinality   报错
 英 [kɑːdɪ'nælɪtɪ]   美  跟读 口语练习
n. 基数；集的势
optimizer   报错
 英 ['ɒptɪmaɪzə]   美   全球发音 跟读 口语练习
n. [计] 优化程序；最优控制器


cardinality 的值对于CBO 做出正确的执行计划来说至关重要。如果CBO 获得的
cardinality 值不够准确（通常是没有做分析或者分析数据过旧导致的），在执行成本计算上
就会出现偏差，从而导致CBO 错误的执行处执行计划。

优化器是SQL 分析和执行的优化工具，他负责制定SQL 的执行计划
	全表扫描（FTS full table scan）
	索引范围搜索（Index Range Scan）
	全索引扫描（INDEX fast full scan，INDEX_FFS）
表与表之间连接
	HASH_JOIN
	NESTED LOOPS
	MERGE JOIN
优化器的种类
	Rule Based Optimizer（RBO）基于规则
	Cost Based Optimizer（CBO）基于成本，或者讲统计信息
	
实验1：RBO和CBO的比较
创建了一张表T，表里面的ID=99 的记录有1 条，ID=1 的记录有49813 条；
这是一个数据分布非常不平均的表。
SQL> drop table t purge;
SQL> create table t as select 1 as id, object_name from dba_objects;
SQL> update t set id=99 where rownum=1;
SQL> select id,count(*) from t group by id;

        ID   COUNT(*)
---------- ----------
         1      75590
        99          1

SQL> create index t_idx on t(id);

SQL> select /*+ rule +*/ * from t where id=1;

Execution Plan
----------------------------------------------------------
Plan hash value: 470836197

---------------------------------------------
| Id  | Operation                   | Name  |
---------------------------------------------
|   0 | SELECT STATEMENT            |       |
|   1 |  TABLE ACCESS BY INDEX ROWID| T     |
|*  2 |   INDEX RANGE SCAN          | T_IDX |
---------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("ID"=1)

Note
-----
   - rule based optimizer used (consider using cbo) 

SQL> select /*+ rule +*/ * from t where id=99;

Execution Plan
----------------------------------------------------------
Plan hash value: 470836197

---------------------------------------------
| Id  | Operation                   | Name  |
---------------------------------------------
|   0 | SELECT STATEMENT            |       |
|   1 |  TABLE ACCESS BY INDEX ROWID| T     |
|*  2 |   INDEX RANGE SCAN          | T_IDX |
---------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("ID"=99)

Note
-----
   - rule based optimizer used (consider using cbo)

SQL> select * from t where id=1;

Execution Plan
----------------------------------------------------------
Plan hash value: 1601196873

--------------------------------------------------------------------------
| Id  | Operation         | Name | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      | 79525 |  6135K|    95   (2)| 00:00:02 |
|*  1 |  TABLE ACCESS FULL| T    | 79525 |  6135K|    95   (2)| 00:00:02 |
--------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("ID"=1)

Note
-----
   - dynamic sampling used for this statement (level=2)
QL> select * from t where id=99;

Execution Plan
----------------------------------------------------------
Plan hash value: 470836197

-------------------------------------------------------------------------------------
| Id  | Operation                   | Name  | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |       |     1 |    79 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| T     |     1 |    79 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | T_IDX |     1 |       |     1   (0)| 00:00:01 |
-------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("ID"=99)

Note
-----
   - dynamic sampling used for this statement (level=2)
/*
RBO 比较呆板，只要有索引，就使用索引。无论效率高低。
CBO 方式：它是看语句的代价(Cost),这里的代价主要指Cpu 和内存。优化器在判断是否
用这种方式时,主要参照的是表及索引的统计信息。统计信息给出表的大小、有少行、每行
的长度等信息。这些统计信息起初在库内是没有的，是做analyze 后才出现的，很多的时侯
过期统计信息会令优化器做出一个错误的执行计划,因些应及时更新这些信息。
注意：走索引不一定就是优的，比如一个表只有两行数据，一次IO 就可以完成全表的
检索,而此时走索引时则需要两次IO,这时全表扫描(full table scan)是最好。
*/

实验2：验证动态采样
SQL> set linesize 700
SQL> set autotrace traceonly
SQL> select /*+dynamic_sampling(t 0)+*/ * from t where id=1;

75590 rows selected.


Execution Plan
----------------------------------------------------------
Plan hash value: 470836197

-------------------------------------------------------------------------------------
| Id  | Operation                   | Name  | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |       |   277 | 21883 |    76   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| T     |   277 | 21883 |    76   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | T_IDX |   111 |       |    74   (0)| 00:00:01 |
-------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("ID"=1)
从结果中可以看到，CBO 猜出的ID=1 的数据量只有277 条，这个数值对于表的总和来说，
是一个比较小的值，所以CBO 选择了索引而不是全表扫描。


SQL> select * from t where id = 1;

75590 rows selected.


Execution Plan
----------------------------------------------------------
Plan hash value: 1601196873

--------------------------------------------------------------------------
| Id  | Operation         | Name | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      | 79525 |  6135K|    95   (2)| 00:00:02 |
|*  1 |  TABLE ACCESS FULL| T    | 79525 |  6135K|    95   (2)| 00:00:02 |
--------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("ID"=1)

Note
-----
   - dynamic sampling used for this statement (level=2)
通过动态采样（10g 的数据库下面，如果表没有做分析，Oracle 自动通过动态采样的方
式来收集分析数据），CBO 估算出表中的实际数据量79525 条（cardinality），从执行计划中
看到，这个数据值还是非常接近实际的数据量50317，CBO 断定ID=1 的数据基本上等同于
表中的数据，所以选择了全表扫描。
SQL> exec dbms_stats.gather_table_stats(user,'T',cascade=>true);
SQL> select * from t where id = 99;


Execution Plan
----------------------------------------------------------
Plan hash value: 470836197

-------------------------------------------------------------------------------------
| Id  | Operation                   | Name  | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |       |    14 |   378 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| T     |    14 |   378 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | T_IDX |    14 |       |     1   (0)| 00:00:01 |
-------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("ID"=99)
--上面的例子显示，CBO从分析数据中得到了id=99 的数据记录是1，所以选择了索引，这种情况下，索引的效率是相当高的。
实验3：分析表的意义
SQL> set autotrace off
SQL> update t set id=99;

75591 rows updated.

SQL> commit;

Commit complete.

SQL> set autotrace trace explain
SQL> select * from t where id = 99;

Execution Plan
----------------------------------------------------------
Plan hash value: 470836197

-------------------------------------------------------------------------------------
| Id  | Operation                   | Name  | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |       |    14 |   378 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| T     |    14 |   378 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | T_IDX |    14 |       |     1   (0)| 00:00:01 |
-------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("ID"=99)
然后我们把表中所有记录的id 更新为99，因为没有对表进行分析，所以表中的分析数
据还是之前的信息，CBO 并不知道，可以看到，此时cardinality 的值为14，就是说，此时
CBO 仍然认为表T 中id=99 的值只有1 条，所以选择的仍然是索引。

SQL> exec dbms_stats.gather_table_stats(user,'T',cascade=>true);

PL/SQL procedure successfully completed.

SQL> select * from t where id = 99;

Execution Plan
----------------------------------------------------------
Plan hash value: 1601196873

--------------------------------------------------------------------------
| Id  | Operation         | Name | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      | 75584 |  1992K|    95   (2)| 00:00:02 |
|*  1 |  TABLE ACCESS FULL| T    | 75584 |  1992K|    95   (2)| 00:00:02 |
--------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("ID"=99)
重新对表进行分析后，CBO 获得了正确的cardinality 值———— 75584，表中id=1 的
记录有75584 条，所以是全表扫描，这种情况下全表扫描是最佳的执行计划。 


实验4：在子查询中，cardinality 是如何影响主查询的执行计划的 
create table t1(id int,name varchar2(1000));
create table t2(id int,name varchar2(1000));
create index ind_t1 on t1(id);
create index ind_t2 on t2(id);
create index ind_t2_name on t2(name);
insert into t1 select object_id,object_name from dba_objects;
commit;
exec dbms_stats.gather_table_stats(user,'T1',cascade=>true,method_opt=>'for all indexed columns');
set autotrace traceonly
SQL> select * from t1 where id in(select /*+ dynamic_sampling(t2 0) cardinality(t2 30000) +*/ id from t2 where name='AA');

no rows selected


Execution Plan
----------------------------------------------------------
Plan hash value: 3845242534

---------------------------------------------------------------------------------------------
| Id  | Operation                     | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT              |             | 75594 |  3100K|   102   (2)| 00:00:02 |
|*  1 |  HASH JOIN RIGHT SEMI         |             | 75594 |  3100K|   102   (2)| 00:00:02 |
|   2 |   VIEW                        | VW_NSO_1    | 30000 |   380K|     1   (0)| 00:00:01 |
|   3 |    TABLE ACCESS BY INDEX ROWID| T2          | 30000 |    14M|     1   (0)| 00:00:01 |
|*  4 |     INDEX RANGE SCAN          | IND_T2_NAME |     1 |       |     1   (0)| 00:00:01 |
|   5 |   TABLE ACCESS FULL           | T1          | 75594 |  2140K|   100   (1)| 00:00:02 |
---------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - access("ID"="ID")
   4 - access("NAME"='AA')
其中：
cardinality(t2 30000)的作用是告诉CBO 从t2 表将获得30000 条数据。
dynamic_sampling(t2 0)的作用是禁止动态采样。
通过这种方式，我们模拟子查询中返回的结果数，同时为了让CBO 完全依赖这个信息生成执行计划，禁止子查询使用动态采样(dynamic_sampling 设置为0)。
可以看到，当CBO 得到来自于子查询中返回的结果集（row source）的记录数为30000条时候，采用了hash join 的执行计划，hash join 通常适用于两张关联的表都比较大的时候。
--再把子查询的结果集变的很小
SQL> select * from t1 where id in(select /*+ dynamic_sampling(t2 0) cardinality(t2 1) +*/ id from t2 where name='AA');

no rows selected


Execution Plan
----------------------------------------------------------
Plan hash value: 3526363319

-----------------------------------------------------------------------------------------------
| Id  | Operation                       | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                |             |     1 |    42 |     4  (25)| 00:00:01 |
|   1 |  NESTED LOOPS                   |             |       |       |            |          |
|   2 |   NESTED LOOPS                  |             |     1 |    42 |     4  (25)| 00:00:01 |
|   3 |    VIEW                         | VW_NSO_1    |     1 |    13 |     1   (0)| 00:00:01 |
|   4 |     HASH UNIQUE                 |             |     1 |   515 |            |          |
|   5 |      TABLE ACCESS BY INDEX ROWID| T2          |     1 |   515 |     1   (0)| 00:00:01 |
|*  6 |       INDEX RANGE SCAN          | IND_T2_NAME |     1 |       |     1   (0)| 00:00:01 |
|*  7 |    INDEX RANGE SCAN             | IND_T1      |     1 |       |     1   (0)| 00:00:01 |
|   8 |   TABLE ACCESS BY INDEX ROWID   | T1          |     1 |    29 |     2   (0)| 00:00:01 |
-----------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   6 - access("NAME"='AA')
   7 - access("ID"="ID")
此时CBO 选择了两表通过NESTED LOOPS join 进行关联的执行计划，因为子查询只有1 条记录，这时候CBO 会选择最合适这种情况的nested loop join 关联方式。

   