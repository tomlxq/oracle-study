数据库对象
	Table
	View
		优点
			限制数据访问
			复杂查询简单化
			提供数据独立性
			相同数据显示不同视图
		通 过子查询建立视图
		子查询 可以包含复杂的select语法
		子查询不能使用order by
		视图DML操作限制
			简单视图上可以进行DML操作
			碰到如下语法不能删除视图行数据
				使用分组函数
				使用group by语法
				使用去除重复行语句
				使用了rownum伪列
			update修改限 制
				使用分组函数
				使用group by语法
				使用去除重复行语句
				使用了rownum伪列
				使用了表达式
			insert 操作限制
				使用分组函数
				使用group by语法
				使用去除重复行语句
				使用了rownum伪列
				使用了表达式
				非空约束的列没在select列表中引用
	Sequence
		定义序列用于自动产生数值
			CREATE SEQUENCE sequence
			[INCREMENT BY n] --步长
			[START WITH n] --启始值
			[{MAXVALUE n | NOMAXVALUE}] –-最大值
			[{MINVALUE n | NOMINVALUE}] –-最小值
			[{CYCLE | NOCYCLE}] –-循环
			[{CACHE n | NOCACHE}];--缓存
		NEXTVAL、CURRVAL的使用原则
		以下内容中可以使用
			select列表，非子查询
			insert语句的子查询select列表中
			insert语句的values子句中
			update语句的set子句中
		在以下内容中不能使用
			视图的select列表中
			有group by、having或order by子句的select语句
			在select、delete或update语句的子查询中
			在create table或alter　table语句的default表达式中
	Index
		可以在以下情况创建索引
			某列包含的数据范围很广
			某列含有大量的空值
			一列或多列经常作为条件出现在where子句或用于联接条件
			表很大，而大多数的查询只占所有行的2%~4%
		可以在以下情况不需要创建索引
			表很小
			列不是经常用作查询条件
			大多数查询的行超过所有行的2%~4%
			表会经常更新
			索引的列作为表达式的一部分被关联
		语法:
			CREATE [UNIQUE][BITMAP]INDEX index
			ON table (column[, column]...);	
	Synonym
		CREATE [PUBLIC] SYNONYM synonym FOR object;
	
SQL> CREATE OR REPLACE VIEW empvu80
  2  (id_number, name, sal, department_id)
  3  AS SELECT employee_id, first_name || ' '
  4  || last_name, salary, department_id
  5  FROM employees
  6  WHERE department_id = 80;

View created.
SQL> CREATE OR REPLACE VIEW dept_sum_vu
  2  (name, minsal, maxsal, avgsal)
  3  AS SELECT d.department_name, MIN(e.salary),
  4  MAX(e.salary),AVG(e.salary)
  5  FROM employees e JOIN departments d
  6  ON (e.department_id = d.department_id)
  7  GROUP BY d.department_name;

View created.

--WITH CHECK OPTION 
SQL> CREATE OR REPLACE VIEW empvu20
AS SELECT *
  3  FROM employees
  4  WHERE department_id = 20
  5  WITH CHECK OPTION CONSTRAINT empvu20_ck ;

View created.
SQL> update empvu20 set department_id=102 WHERE department_id = 20;
update empvu20 set department_id=102 WHERE department_id = 20
       *
ERROR at line 1:
ORA-01402: view WITH CHECK OPTION where-clause violation

SQL> insert into empvu20(EMPLOYEE_ID,LAST_NAME,EMAIL,HIRE_DATE,JOB_ID) values(11,'jack','jack@gmail.com','01-jan-17','sales_man');
insert into empvu20(EMPLOYEE_ID,LAST_NAME,EMAIL,HIRE_DATE,JOB_ID) values(11,'jack','jack@gmail.com','01-jan-17','sales_man')
            *
ERROR at line 1:
ORA-01402: view WITH CHECK OPTION where-clause violation
-- WITH READ ONLY
SQL> CREATE OR REPLACE VIEW empvu10
  2  (employee_number, employee_name, job_title)
  3  AS SELECT employee_id, last_name, job_id
  4  FROM employees
  5  WHERE department_id = 10
  6  WITH READ ONLY ;

View created.


SQL> create sequence seq nocache;

Sequence created.

SQL> create sequence seq1;

Sequence created.

SQL> select * from user_sequences; --如果指定了cache，那么LAST_NUMBER是下一个值，则不准确

SEQUENCE_NAME                   MIN_VALUE  MAX_VALUE INCREMENT_BY C O CACHE_SIZE LAST_NUMBER
------------------------------ ---------- ---------- ------------ - - ---------- -----------
DEPARTMENTS_SEQ                         1       9990           10 N N          0         280
EMPLOYEES_SEQ                           1 1.0000E+28            1 N N          0         207
LOCATIONS_SEQ                           1       9900          100 N N          0        3300
SEQ                                     1 1.0000E+28            1 N N          0           1
SEQ1                                    1 1.0000E+28            1 N N         20           1
--修改序列
SQL> ALTER SEQUENCE seq
  2  INCREMENT BY 20
  3  MAXVALUE 999999
  4  NOCACHE
  5  NOCYCLE;

Sequence altered.

--创建索引
SQL> CREATE INDEX emp_last_name_idx
ON employees(last_name);
SQL> col COLUMN_NAME for a20
--user_indexes包含了索引名和唯一性、user_ind_columns包含了索引名，表名和列名
SQL> select ic.index_name,ic.column_name,ic.column_position,ix.UNIQUENESS 
from user_indexes ix,user_ind_columns ic 
where ic.index_name=ix.index_name and ic.table_name='EMPLOYEES';

INDEX_NAME                     COLUMN_NAME          COLUMN_POSITION UNIQUENES
------------------------------ -------------------- --------------- ---------
EMP_LAST_NAME_IDX              LAST_NAME                          1 NONUNIQUE
EMP_NAME_IX                    LAST_NAME                          1 NONUNIQUE
EMP_NAME_IX                    FIRST_NAME                         2 NONUNIQUE
EMP_MANAGER_IX                 MANAGER_ID                         1 NONUNIQUE
EMP_EMP_ID_PK                  EMPLOYEE_ID                        1 UNIQUE
EMP_EMAIL_UK                   EMAIL                              1 UNIQUE
EMP_DEPARTMENT_IX              DEPARTMENT_ID                      1 NONUNIQUE
EMP_JOB_IX                     JOB_ID                             1 NONUNIQUE

8 rows selected.
--基于函数的索引
SQL> create index upper_dept_name_idx on departments(upper(department_name));

Index created.
SQL> set autotrace traceonly;
SQL> select * from departments where upper(department_name)='SALES';


Execution Plan
----------------------------------------------------------
Plan hash value: 92875273

---------------------------------------------------------------------------------------------------
| Id  | Operation                   | Name                | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |                     |     1 |    21 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| DEPARTMENTS         |     1 |    21 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | UPPER_DEPT_NAME_IDX |     1 |       |     1   (0)| 00:00:01 |
---------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access(UPPER("DEPARTMENT_NAME")='SALES')


Statistics
----------------------------------------------------------
          2  recursive calls
          0  db block gets
          5  consistent gets
          0  physical reads
          0  redo size
        638  bytes sent via SQL*Net to client
        415  bytes received via SQL*Net from client
          2  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
          1  rows processed
--删除索引　
SQL> DROP INDEX emp_last_name_idx;

Index dropped.
--建 立同义词
SQL> CREATE SYNONYM d_sum
  2  FOR dept_sum_vu;

Synonym created.
--删除同义词
SQL> DROP SYNONYM d_sum;

Synonym dropped.