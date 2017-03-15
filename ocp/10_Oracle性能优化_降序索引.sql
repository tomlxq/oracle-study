
SQL> drop table solo purge;

Table dropped.

SQL> create table solo as select  * from all_objects;

Table created.

SQL> set autotrace traceonly explain;
select owner,object_type from solo where owner between 'T' and  'Z' and object_type is not null order by owner desc ,object_type desc;


Execution Plan
----------------------------------------------------------
Plan hash value: 96137029

---------------------------------------------------------------------------
| Id  | Operation          | Name | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |      |  1007 | 28196 |   286   (2)| 00:00:04 |
|   1 |  SORT ORDER BY     |      |  1007 | 28196 |   286   (2)| 00:00:04 |
|*  2 |   TABLE ACCESS FULL| SOLO |  1007 | 28196 |   285   (1)| 00:00:04 |
---------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter("OBJECT_TYPE" IS NOT NULL AND "OWNER">='T' AND
              "OWNER"<='Z')

Note
-----
   - dynamic sampling used for this statement (level=2)
SQL> create index idx_oo on solo(owner,object_type);

Index created.
SQL> set linesize 200
SQL> select owner,object_type from solo where owner between 'T' and  'Z' and object_type is not null order by owner desc ,object_type desc;

Execution Plan
----------------------------------------------------------
Plan hash value: 904267416

--------------------------------------------------------------------------------------
| Id  | Operation                   | Name   | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |        |  1007 | 28196 |     5   (0)| 00:00:01 |
|*  1 |  INDEX RANGE SCAN DESCENDING| IDX_OO |  1007 | 28196 |     5   (0)| 00:00:01 |
--------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - access("OWNER">='T' AND "OWNER"<='Z')
       filter("OBJECT_TYPE" IS NOT NULL)

Note
-----
   - dynamic sampling used for this statement (level=2)
--交换顺序也是可以的
SQL> select owner,object_type from solo where object_type is not null and owner between 'T' and  'Z' order by owner desc ,object_type desc;

Execution Plan
----------------------------------------------------------
Plan hash value: 904267416

--------------------------------------------------------------------------------------
| Id  | Operation                   | Name   | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |        |  1007 | 28196 |     5   (0)| 00:00:01 |
|*  1 |  INDEX RANGE SCAN DESCENDING| IDX_OO |  1007 | 28196 |     5   (0)| 00:00:01 |
--------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - access("OWNER">='T' AND "OWNER"<='Z')
       filter("OBJECT_TYPE" IS NOT NULL)

Note
-----
   - dynamic sampling used for this statement (level=2)
--改为一个升一个降，则多个排序的步骤，相当于把所有索引取出来，再排序，也比全表扫描成本低
SQL> select owner,object_type from solo where  object_type is not null and owner between 'T' and  'Z' order by owner asc ,object_type desc;

Execution Plan
----------------------------------------------------------
Plan hash value: 1315490797

----------------------------------------------------------------------------
| Id  | Operation         | Name   | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |        |  1007 | 28196 |     6  (17)| 00:00:01 |
|   1 |  SORT ORDER BY    |        |  1007 | 28196 |     6  (17)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN| IDX_OO |  1007 | 28196 |     5   (0)| 00:00:01 |
----------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("OWNER">='T' AND "OWNER"<='Z')
       filter("OBJECT_TYPE" IS NOT NULL)

Note
-----
   - dynamic sampling used for this statement (level=2)
   
--如果想去掉之前的排序步骤
SQL> drop index idx_oo ;

Index dropped.

SQL> create index idx_oo on solo(owner asc ,object_type desc);

Index created.

select owner,object_type from solo where  object_type is not null and owner between 'T' and  'Z' order by owner asc ,object_type desc;


Execution Plan
----------------------------------------------------------
Plan hash value: 120365688

---------------------------------------------------------------------------
| Id  | Operation        | Name   | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------
|   0 | SELECT STATEMENT |        |  1007 | 28196 |     5   (0)| 00:00:01 |
|*  1 |  INDEX RANGE SCAN| IDX_OO |  1007 | 28196 |     5   (0)| 00:00:01 |
---------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - access("OWNER">='T' AND "OWNER"<='Z')
       filter(SYS_OP_UNDESCEND(SYS_OP_DESCEND("OBJECT_TYPE")) IS NOT
              NULL)

Note
-----
   - dynamic sampling used for this statement (level=2)