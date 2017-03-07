1．全表扫描（Full Table Scans FTS）
SQL> explain plan for select * from dual;

Explained.

SQL> select * from table(dbms_xplan.display);

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Plan hash value: 272002086

--------------------------------------------------------------------------
| Id  | Operation         | Name | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      |     1 |     2 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS FULL| DUAL |     1 |     2 |     2   (0)| 00:00:01 |
--------------------------------------------------------------------------

8 rows selected.
2．通过ROWID的表存取（Table Access by ROWID或rowid lookup）
SQL> explain plan for select * from dept where rowid = 'AAAAyGAADAAAAATAAF';
SQL> set linesize 200
SQL> select * from table(dbms_xplan.display); --s或用select plan_table_output from table(dbms_xplan.display('PLAN_TABLE'));

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Plan hash value: 1761118538

---------------------------------------------------------------------------------------------------
| Id  | Operation                  | Name | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |
---------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT           |      |     1 |    43 |     1   (0)| 00:00:01 |       |       |
|   1 |  TABLE ACCESS BY USER ROWID| DEPT |     1 |    43 |     1   (0)| 00:00:01 | ROWID | ROWID |
---------------------------------------------------------------------------------------------------

8 rows selected.

3．索引扫描（Index Scan或index lookup）
--1 扫描索引得到对应的rowid 值。
--2 通过找到的rowid 从表中读出具体的数据。
每步都是单独的一次I/O，但是对于索引，由于经常使用，绝大多数都已经CACHE 到内存中，所以第1 步的I/O 经常是逻辑I/O，即数据可以从内存中得到。
但是对于第2 步来说，如果表比较大，则其数据不可能全在内存中，所以其I/O 很有可能是物理I/O，这是一个机械操作，相对逻辑I/O 来说，极其费时间的。所以如果多大表进行索引扫描，取出的数据如果大于总量的5% —— 10%，使用索引扫描会效率下降很多。
但是如果查询的数据能全在索引中找到，就可以避免进行第2 步操作，避免了不必要的I/O，此时即使通过索引扫描取出的数据比较多，效率还是很高的
SQL> explain plan for select empno,ename from scott.emp where empno=10;
SQL> select plan_table_output from table(dbms_xplan.display('PLAN_TABLE'));

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Plan hash value: 2949544139

--------------------------------------------------------------------------------------
| Id  | Operation                   | Name   | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |        |     1 |    10 |     1   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMP    |     1 |    10 |     1   (0)| 00:00:01 |
|*  2 |   INDEX UNIQUE SCAN         | PK_EMP |     1 |       |     0   (0)| 00:00:01 |
--------------------------------------------------------------------------------------

进一步讲，如果sql 语句中对索引列进行排序，因为索引已经预先排序好了，所以在执行计划中不需要再对索引列进行排序
SQL> explain plan for select empno, ename from scott.emp where empno > 7876 order by empno;
SQL> select plan_table_output from table(dbms_xplan.display('PLAN_TABLE'));

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Plan hash value: 169057108

--------------------------------------------------------------------------------------
| Id  | Operation                   | Name   | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |        |     1 |    10 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMP    |     1 |    10 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | PK_EMP |     1 |       |     1   (0)| 00:00:01 |
--------------------------------------------------------------------------------------
因为索引是已经排序了的，所以将按照索引的顺序查询出符合条件的行，因此避免了进一步排序操作。

有4 种类型的索引扫描
1) 索引唯一扫描（index unique scan）
--通过唯一索引查找一个数值经常返回单个ROWID.如果存在UNIQUE 或PRIMARYKEY 约束（它保证了语句只存取单行）的话，Oracle 经常实现唯一性扫描。
SQL> explain plan for select empno,ename from scott.emp where empno=10;
SQL> select * from table(dbms_xplan.display);

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Plan hash value: 2949544139

--------------------------------------------------------------------------------------
| Id  | Operation                   | Name   | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |        |     1 |    10 |     1   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMP    |     1 |    10 |     1   (0)| 00:00:01 |
|*  2 |   INDEX UNIQUE SCAN         | PK_EMP |     1 |       |     0   (0)| 00:00:01 |
--------------------------------------------------------------------------------------
2) 索引范围扫描（index range scan）
--谓词（where 限制条件）中使用了范围操作符（如>、<、<>、>=、<=、between）
SQL> explain plan for select empno,ename from scott.emp where empno<7687 order by empno;

Explained.

SQL> select * from table(dbms_xplan.display);

PLAN_TABLE_OUTPUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Plan hash value: 169057108

--------------------------------------------------------------------------------------
| Id  | Operation                   | Name   | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |        |     8 |    80 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMP    |     8 |    80 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | PK_EMP |     8 |       |     1   (0)| 00:00:01 |
--------------------------------------------------------------------------------------
--使用index rang scan 的3 种情况：
--1 在唯一索引列上使用了range 操作符（> < <> >= <= between）
--2 在组合索引上，只使用部分列进行查询，导致查询出多行
--3 对非唯一索引列上进行的任何查询。
3) 索引全扫描（index full scan）
与全表扫描对应，也有相应的全索引扫描。而且此时查询出的数据都必须从索引中可以直接得到。
SQL> create table big_emp  as select * from scott.emp;
SQL> create index idx_no_name on big_emp(empno,ename);
SQL> explain plan for select empno,ename from big_emp order by empno,ename; --经过实验依然是全表扫描
4) 索引快速扫描（index fast full scan）
扫描索引中的所有的数据块，与index full scan 很类似，但是一个显著的区别就是它不对查询出的数据进行排序，即数据不是以排序顺序被返回。
SQL> create table big_emp  as select * from scott.emp;
SQL> create index idx_no_name on big_emp(empno,ename);
SQL> explain plan for select empno,ename from big_emp; --经过实验依然是全表扫描
