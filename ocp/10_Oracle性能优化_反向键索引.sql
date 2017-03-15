
SQL> drop table t purge;

Table dropped.

SQL> create table t as select * from dba_objects;

Table created.

SQL> select * from t where object_name like '%t';

Execution Plan
----------------------------------------------------------
Plan hash value: 1601196873

--------------------------------------------------------------------------
| Id  | Operation         | Name | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      |  4539 |   917K|   294   (1)| 00:00:04 |
|*  1 |  TABLE ACCESS FULL| T    |  4539 |   917K|   294   (1)| 00:00:04 |
--------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("OBJECT_NAME" IS NOT NULL AND "OBJECT_NAME" LIKE '%t')

Note
-----
   - dynamic sampling used for this statement (level=2)
SQL> select count(*) from t where object_name like '%t';

Execution Plan
----------------------------------------------------------
Plan hash value: 2020242125

----------------------------------------------------------------------------------
| Id  | Operation             | Name     | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------
|   0 | SELECT STATEMENT      |          |     1 |    66 |   105   (1)| 00:00:02 |
|   1 |  SORT AGGREGATE       |          |     1 |    66 |            |          |
|*  2 |   INDEX FAST FULL SCAN| IDX_NAME |  4539 |   292K|   105   (1)| 00:00:02 |
----------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter("OBJECT_NAME" IS NOT NULL AND "OBJECT_NAME" LIKE '%t')

Note
-----
   - dynamic sampling used for this statement (level=2)
SQL> drop index idx_name;

Index dropped.
SQL> create index idx_name on t(reverse(object_name));

Index created.

SQL> select count(*) from t where reverse(object_name) like 't%';

Execution Plan
----------------------------------------------------------
Plan hash value: 1659404065

------------------------------------------------------------------------------
| Id  | Operation         | Name     | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |          |     1 |    66 |     6   (0)| 00:00:01 |
|   1 |  SORT AGGREGATE   |          |     1 |    66 |            |          |
|*  2 |   INDEX RANGE SCAN| IDX_NAME |  3822 |   246K|     6   (0)| 00:00:01 |
------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access(REVERSE("OBJECT_NAME") LIKE 't%')
       filter(REVERSE("OBJECT_NAME") LIKE 't%')

Note
-----
   - dynamic sampling used for this statement (level=2)