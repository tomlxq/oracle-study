
SQL> create table t as select * from hr.employees;

Table created.

SQL> select FIRST_NAME,LAST_NAME from t where FIRST_NAME='hello';

Execution Plan
----------------------------------------------------------
Plan hash value: 1601196873

--------------------------------------------------------------------------
| Id  | Operation         | Name | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      |     1 |    26 |     2   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| T    |     1 |    26 |     2   (0)| 00:00:01 |
--------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("FIRST_NAME"='hello')

Note
-----
   - dynamic sampling used for this statement (level=2)

SQL> create index idx_name on t(first_name);

Index created.
--此时看到是索引范围扫描
SQL> select FIRST_NAME,LAST_NAME from t where FIRST_NAME='hello';

Execution Plan
----------------------------------------------------------
Plan hash value: 110985676

----------------------------------------------------------------------------------------
| Id  | Operation                   | Name     | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |          |     1 |    26 |     1   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| T        |     1 |    26 |     1   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | IDX_NAME |     1 |       |     1   (0)| 00:00:01 |
----------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("FIRST_NAME"='hello')

Note
-----
   - dynamic sampling used for this statement (level=2)
--但改成函数lower(FIRST_NAME)，此时看到是全表扫描！！！
SQL> select FIRST_NAME,LAST_NAME from t where lower(FIRST_NAME)='hello';

Execution Plan
----------------------------------------------------------
Plan hash value: 1601196873

--------------------------------------------------------------------------
| Id  | Operation         | Name | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      |     1 |    26 |     2   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| T    |     1 |    26 |     2   (0)| 00:00:01 |
--------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter(LOWER("FIRST_NAME")='hello')

Note
-----
   - dynamic sampling used for this statement (level=2)
SQL> create index idx_name on t(lower(first_name));

Index created.
--此时看到是索引范围扫描
SQL> select FIRST_NAME,LAST_NAME from t where lower(FIRST_NAME)='hello';

Execution Plan
----------------------------------------------------------
Plan hash value: 110985676

----------------------------------------------------------------------------------------
| Id  | Operation                   | Name     | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |          |     1 |    38 |     1   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| T        |     1 |    38 |     1   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | IDX_NAME |     1 |       |     1   (0)| 00:00:01 |
----------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access(LOWER("FIRST_NAME")='hello')

Note
-----
   - dynamic sampling used for this statement (level=2)