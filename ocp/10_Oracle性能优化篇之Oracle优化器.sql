1. RBO（Rule-Based Optimization）
2. CBO（Cost-Based Optimization）


实验1: RBO和CBO效果验证
RBO 比较呆板，只要有索引，就使用索引。无论效率高低。
SQL> drop table t purge;

Table dropped.

SQL> create table t as select 1 id,object_name from dba_objects;

Table created.

SQL> update t set id = 99 where rownum=1;

1 row updated.

SQL> commit;

Commit complete.

SQL> select id,count(*) from t group by id;

        ID   COUNT(*)
---------- ----------
         1      75582
        99          1

SQL> create index t_ind on t(id);

Index created.

SQL> set autotrace trace explain
SQL> select /*+ rule +*/ * from t where id = 99;

Execution Plan
----------------------------------------------------------
Plan hash value: 1376202287

---------------------------------------------
| Id  | Operation                   | Name  |
---------------------------------------------
|   0 | SELECT STATEMENT            |       |
|   1 |  TABLE ACCESS BY INDEX ROWID| T     |
|*  2 |   INDEX RANGE SCAN          | T_IND |
---------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("ID"=99)

Note
-----
   - rule based optimizer used (consider using cbo)

SQL> select /*+ rule +*/ * from t where id = 1;

Execution Plan
----------------------------------------------------------
Plan hash value: 1376202287

---------------------------------------------
| Id  | Operation                   | Name  |
---------------------------------------------
|   0 | SELECT STATEMENT            |       |
|   1 |  TABLE ACCESS BY INDEX ROWID| T     |
|*  2 |   INDEX RANGE SCAN          | T_IND |
---------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("ID"=1)

Note
-----
   - rule based optimizer used (consider using cbo)

SQL> set linesize 200
SQL> select * from t where id=99;

Execution Plan
----------------------------------------------------------
Plan hash value: 1376202287

-------------------------------------------------------------------------------------
| Id  | Operation                   | Name  | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |       |     1 |    79 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| T     |     1 |    79 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | T_IND |     1 |       |     1   (0)| 00:00:01 |
-------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("ID"=99)

Note
-----
   - dynamic sampling used for this statement (level=2)

SQL> select * from t where id=1;

Execution Plan
----------------------------------------------------------
Plan hash value: 1601196873

--------------------------------------------------------------------------
| Id  | Operation         | Name | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      | 63528 |  4901K|    95   (2)| 00:00:02 |
|*  1 |  TABLE ACCESS FULL| T    | 63528 |  4901K|    95   (2)| 00:00:02 |
--------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("ID"=1)

Note
-----
   - dynamic sampling used for this statement (level=2)
实验2: 验证动态采样
SQL> set autotrace trace explain
SQL> select /*+ dynamic_sampling(t,0) +*/ * from t where id=1;  --hints /*+ dynamic_sampling(t 0) +*/ 是让CBO 无法通过动态采样获得表中实际数据的情况

Execution Plan
----------------------------------------------------------
Plan hash value: 1376202287

-------------------------------------------------------------------------------------
| Id  | Operation                   | Name  | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |       |   277 | 21883 |    76   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| T     |   277 | 21883 |    76   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | T_IND |   111 |       |    74   (0)| 00:00:01 |
-------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("ID"=1)
--CBO 猜出的ID=1 的数据量只有277 条，这个数值对于表的总和来说，是一个比较小的值，所以CBO 选择了索引而不是全表扫描。
SQL> select * from t where id = 1;

Execution Plan
----------------------------------------------------------
Plan hash value: 1601196873

--------------------------------------------------------------------------
| Id  | Operation         | Name | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      | 63528 |  4901K|    95   (2)| 00:00:02 |
|*  1 |  TABLE ACCESS FULL| T    | 63528 |  4901K|    95   (2)| 00:00:02 |
--------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("ID"=1)

Note
-----
   - dynamic sampling used for this statement (level=2)
--通过动态采样（10g 的数据库下面，如果表没有做分析，Oracle 自动通过动态采样的方式来收集分析数据），CBO 估算出表中的实际数据量63528 条（cardinality），
--从执行计划中看到，这个数据值还是非常接近实际的数据量50317，CBO 断定ID=1 的数据基本上等同于表中的数据，所以选择了全表扫描。
QL> exec dbms_stats.gather_table_stats(user,'T',cascade=>true);

PL/SQL procedure successfully completed.

SQL> select * from t where id = 99;

Execution Plan
----------------------------------------------------------
Plan hash value: 1376202287

-------------------------------------------------------------------------------------
| Id  | Operation                   | Name  | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |       |    14 |   378 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| T     |    14 |   378 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | T_IND |    14 |       |     1   (0)| 00:00:01 |
-------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("ID"=99)
--通过对表的分析，CBO 就可以获得T 表和索引的充足的信息。上面的例子显示，CBO从分析数据中得到了id=99 的数据记录是1，所以选择了索引，这种情况下，索引的效率是相当高的。

实验3: 分析表的意义
SQL> set autotrace off;

SQL> update t set id = 99;

75583 rows updated.

SQL> commit;

Commit complete.

SQL> set autotrace trace explain;
SQL> select * from t where id = 99;

Execution Plan
----------------------------------------------------------
Plan hash value: 1376202287

-------------------------------------------------------------------------------------
| Id  | Operation                   | Name  | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |       |    14 |   378 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| T     |    14 |   378 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | T_IND |    14 |       |     1   (0)| 00:00:01 |
-------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("ID"=99)
--然后我们把表中所有记录的id 更新为99，因为没有对表进行分析，所以表中的分析数据还是之前的信息，CBO 并不知道，可以看到，此时cardinality 的值为1，就是说，此时CBO 仍然认为表T 中id=99 的值只有1 条，所以选择的仍然是索引。
SQL> exec dbms_stats.gather_table_stats(user,'t',cascade=>true);

PL/SQL procedure successfully completed.

SQL> select * from t where id = 99;

Execution Plan
----------------------------------------------------------
Plan hash value: 1601196873

--------------------------------------------------------------------------
| Id  | Operation         | Name | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      | 75576 |  1992K|    95   (2)| 00:00:02 |
|*  1 |  TABLE ACCESS FULL| T    | 75576 |  1992K|    95   (2)| 00:00:02 |
--------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("ID"=99)
--重新对表进行分析后，CBO 获得了正确的cardinality 值———— 75576，表中id=1 的记录有75576 条，所以是全表扫描，这种情况下全表扫描是最佳的执行计划。

实验4:在子查询中，cardinality 是如何影响主查询的执行计划的。
SQL> set autotrace off
SQL> create table t1(id int,name varchar2(1000));
create table t2(id int,name varchar2(1000));
insert into t1 select object_id,object_name from dba_objects;
create index ind_t1 on t1(id);
create index ind_t2 on t2(id);
create index ind_t2_name on t2(name);

Table created.

SQL> commit;
SQL> exec dbms_stats.gather_table_stats(user,'T1',cascade=>true,method_opt=>'for all indexed columns');

PL/SQL procedure successfully completed.
SQL> select * from t1 where id in(select /*+ dynamic_sampling(t2 0) cardinality(t2 30000) +*/ id from t2 where name='AA');

no rows selected


Execution Plan
----------------------------------------------------------
Plan hash value: 3845242534

---------------------------------------------------------------------------------------------
| Id  | Operation                     | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT              |             | 75581 |  3100K|   102   (2)| 00:00:02 |
|*  1 |  HASH JOIN RIGHT SEMI         |             | 75581 |  3100K|   102   (2)| 00:00:02 |
|   2 |   VIEW                        | VW_NSO_1    | 30000 |   380K|     1   (0)| 00:00:01 |
|   3 |    TABLE ACCESS BY INDEX ROWID| T2          | 30000 |    14M|     1   (0)| 00:00:01 |
|*  4 |     INDEX RANGE SCAN          | IND_T2_NAME |     1 |       |     1   (0)| 00:00:01 |
|   5 |   TABLE ACCESS FULL           | T1          | 75581 |  2140K|   100   (1)| 00:00:02 |
---------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - access("ID"="ID")
   4 - access("NAME"='AA')


Statistics
----------------------------------------------------------
          9  recursive calls
          0  db block gets
         18  consistent gets
          0  physical reads
          0  redo size
        340  bytes sent via SQL*Net to client
        408  bytes received via SQL*Net from client
          1  SQL*Net roundtrips to/from client
          4  sorts (memory)
          0  sorts (disk)
          0  rows processed
/*
其中：
cardinality(t2 30000)的作用是告诉CBO 从t2 表将获得30000 条数据。
dynamic_sampling(t2 0)的作用是禁止动态采样。
通过这种方式，我们模拟子查询中返回的结果数，同时为了让CBO 完全依赖这个信息生成执行计划，禁止子查询使用动态采样(dynamic_sampling 设置为0)。
可以看到，当CBO 得到来自于子查询中返回的结果集（row source）的记录数为30000条时候，采用了hash join 的执行计划，hash join 通常适用于两张关联的表都比较大的时候。
*/
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


Statistics
----------------------------------------------------------
          1  recursive calls
          0  db block gets
          1  consistent gets
          0  physical reads
          0  redo size
        340  bytes sent via SQL*Net to client
        408  bytes received via SQL*Net from client
          1  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
          0  rows processed
/*
将子查询的返回值设置为1，即：
cardinality(t2 1)
此时CBO 选择了两表通过NESTED LOOPS join 进行关联的执行计划，因为子查询只有1 条记录，这时候CBO 会选择最合适这种情况的nested loop join 关联方式。	
从这里我们得到这样的一个结论：
子查询的cardinality 值直接影响了主查询的执行计划，如果CBO 对子查询的cardinality判断有误，那么主查询的执行计划很有可能是错误的。	
*/  