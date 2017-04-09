修改表语句
	Add a new column 增加新的列
		ALTER TABLE table
		ADD (column datatype [DEFAULT expr]
		[, column datatype]...);
	Modify an existing column 修改存在的列
		ALTER TABLE table
		MODIFY (column datatype [DEFAULT expr]
		[, column datatype]...);
	Define a default value for the new column 定义默认值
	Drop a column 删除列
		ALTER TABLE table
		DROP (column [, column] …);
	set unused选项
		1. ALTER TABLE <table_name>
			SET UNUSED(<column_name> [ , <column_name>]);
		2. ALTER TABLE <table_name>
			SET UNUSED COLUMN <column_name> [ , <column_name>];
		3. ALTER TABLE <table_name>
			DROP UNUSED COLUMNS;
	增加约束
		ALTER TABLE <table_name>
		ADD [CONSTRAINT <constraint_name>]
		type (<column_name>);
	Deferring Constraints 延迟约束
		INITIALLY DEFERRED 初始化延迟执行 事务结束时检查
		INITIALLY IMMEDIATE 初始化立即执行 语句执行时检查
	Dropping a Constraint 删除约束
		删除外键依赖的主键约束 使用cascade
	Disabling Constraints 禁止约束
		CASCADE禁止约束和有依赖的约束
	Enabling Constraints 启用约束
	在删除主键约束时使用
		cascade关键字可以删除参照该列的那些外键
		on delete cascade关键字级联删除参照该关键字的数据
		cascade constraint在删除列的同删除约事，如主键约束
	更改表名和约束名字
		ALTER TABLE marketing RENAME COLUMN team_id TO id;
		ALTER TABLE marketing RENAME CONSTRAINT mktg_pk TO new_mktg_pk;
		
索引建立时机
	Automatically 自动建立
		PRIMARY KEY creation 主键约束建立
		UNIQUE KEY creation 唯一性约束建立
	Manually 手工建立
		The CREATE INDEX statement create index语句
		The CREATE TABLE statement create table语句
Function-Based Indexes 函数索引
	可以是基本表达式
	CREATE INDEX upper_dept_name_idx　ON dept2(UPPER(department_name));
	可以是列表达式,常数,函数,自定义函数.
Removing an Index 删除索引
	DROP INDEX index;
DROP TABLE … PURGE 删除表purge语句
	Purge是直接删除表,不保留到回收站,10g开始默认删除表是改名移动到回收站
FLASHBACK TABLE Statement 闪回语句
	能在一个语句中把表恢复到指定的 时间点
	恢复表数据连同索引与约束信息
	能返回表及 其内容到指定时间点或系统变更号
	Syntax: 语法
		FLASHBACK TABLE[schema.]table[, [ schema.]table ]...
		TO { TIMESTAMP | SCN } expr
		[ { ENABLE | DISABLE } TRIGGERS ];
临时表
	CREATE GLOBAL TEMPORARY TABLE cart ON COMMIT DELETE ROWS;
	CREATE GLOBAL TEMPORARY TABLE today_sales
	ON COMMIT PRESERVE ROWS AS
	SELECT * FROM orders
	WHERE order_date = SYSDATE;
外部表
	创建 一个目录对象,相对应的目录可存放外部表的数据文件
	CREATE TABLE <table_name> ( <col_name> <datatype>, … )
	ORGANIZATION EXTERNAL
	(TYPE <access_driver_type>
	DEFAULT DIRECTORY <directory_name>
	ACCESS PARAMETERS
	(… ) )
	LOCATION ('<location_specifier>') REJECT LIMIT [0 | <number> | UNLIMITED];
	
	
SQL> create table dept80 as select * from dept;
SQL> ALTER TABLE dept80 ADD (job_id VARCHAR2(9));
SQL> ALTER TABLE dept80 MODIFY (last_name VARCHAR2(30));
SQL> ALTER TABLE dept80 DROP COLUMN job_id;
--增加约束
SQL> create table emp2 as select * from emp;

Table created.


SQL> ALTER TABLE emp2
  2  MODIFY employee_id PRIMARY KEY;

Table altered.

SQL> ALTER TABLE emp2
  2  ADD CONSTRAINT emp_mgr_fk
  3  FOREIGN KEY(manager_id)
  4  REFERENCES emp2(employee_id);

Table altered.
--ON DELETE CASCADE 父表行删除子表行也被删除
SQL> ALTER TABLE emp2 ADD CONSTRAINT emp_dt_fk
  2  FOREIGN KEY (Department_id)
  3  REFERENCES departments(department_id) ON DELETE CASCADE;

Table altered.
SQL> alter table emp2 drop constraint emp_dt_fk;

Table altered.
--ON DELETE SET NULL 父表行删 除子表行对应的列更改为空值
SQL> ALTER TABLE emp2 ADD CONSTRAINT emp_dt_fk
  2  FOREIGN KEY (Department_id)
  3  REFERENCES departments(department_id) ON DELETE SET NULL;

Table altered.


--延迟约束
SQL> create table dept2 as select * from departments;

Table created.
--Deferring constraint on creation
SQL> ALTER TABLE dept2
  2  ADD CONSTRAINT dept2_id_pk
  3  PRIMARY KEY (department_id)
  4  DEFERRABLE INITIALLY DEFERRED;

Table altered.
--Changing a specific constraint attribute
SQL> SET CONSTRAINTS dept2_id_pk IMMEDIATE;

Constraint set.
--Changing all constraints for a session
SQL> ALTER SESSION SET CONSTRAINTS= IMMEDIATE;

Session altered.

SQL> CREATE TABLE emp_new_sal (salary NUMBER
  2  CONSTRAINT sal_ck
  3  CHECK (salary > 100)
  4  DEFERRABLE INITIALLY IMMEDIATE,
  5  bonus NUMBER
  6  CONSTRAINT bonus_ck
  7  CHECK (bonus > 0 )
  8  DEFERRABLE INITIALLY DEFERRED );

Table created.
--删除约束
SQL> ALTER TABLE emp2
  2  DROP CONSTRAINT emp_mgr_fk;

Table altered.

SQL> ALTER TABLE emp2 DROP PRIMARY KEY CASCADE;

Table altered.

--启用禁用约束
SQL> ALTER TABLE emp2
  2  DISABLE CONSTRAINT emp_dt_fk;

Table altered.

SQL> ALTER TABLE emp2
  2  ENABLE CONSTRAINT emp_dt_fk;

Table altered.
--CASCADE CONSTRAINTS 
SQL> ALTER TABLE emp2
  2  DROP COLUMN employee_id CASCADE CONSTRAINTS;

Table altered.

SQL> ALTER TABLE test1
  2  DROP (col1_pk, col2_fk, col1) CASCADE CONSTRAINTS;
 
--创建表时就创建了索引
SQL> CREATE TABLE NEW_EMP
  2  (employee_id NUMBER(6) PRIMARY KEY USING INDEX (CREATE INDEX emp_id_idx ON NEW_EMP(employee_id)),
  3  first_name VARCHAR2(20), last_name VARCHAR2(25));

Table created.
SQL> SELECT INDEX_NAME, TABLE_NAME FROM USER_INDEXES WHERE TABLE_NAME = 'NEW_EMP';

INDEX_NAME                     TABLE_NAME
------------------------------ ------------------------------
EMP_ID_IDX                     NEW_EMP

--从回收站中找回误删的表
SQL> DROP TABLE emp2;

Table dropped.

SQL> SELECT original_name, operation, droptime FROM recyclebin;

ORIGINAL_NAME                    OPERATION DROPTIME
-------------------------------- --------- -------------------
DEPT80                           DROP      2017-04-09:09:09:24
DEPT2                            DROP      2017-04-09:12:08:06
EMP2                             DROP      2017-04-09:12:30:34
SQL> Show recyclebin;
ORIGINAL NAME    RECYCLEBIN NAME                OBJECT TYPE  DROP TIME
---------------- ------------------------------ ------------ -------------------
DEPT2            BIN$TLUBhSLOG3HgUwYVqMAuxw==$0 TABLE        2017-04-09:12:08:06
DEPT80           BIN$TLGCbLEbGRTgUwYVqMDc8w==$0 TABLE        2017-04-09:09:09:24
EMPLOYEES2       BIN$TLTdZIzFHb3gUwYVqMAEJQ==$0 TABLE        2017-04-09:13:09:35

SQL> FLASHBACK TABLE emp2 TO BEFORE DROP;

Flashback complete.
--创建外部表ORACLE_LOADER
SQL> conn / as sysdba
SQL> col name for a50
SQL> select FILE#,STATUS,NAME from v$datafile;

     FILE# STATUS  NAME
---------- ------- --------------------------------------------------
         1 SYSTEM  /u01/app/oracle/oradata/prod/system01.dbf
         2 ONLINE  /u01/app/oracle/oradata/prod/sysaux01.dbf
         3 ONLINE  /u01/app/oracle/oradata/prod/undotbs01.dbf
         4 ONLINE  /u01/app/oracle/oradata/prod/users01.dbf
         5 ONLINE  /u01/app/oracle/oradata/prod/example01.dbf

SQL> create or replace directory emp_dir as '/u01/emp_dir';

Directory created.

SQL> grant read on directory emp_dir to hr;

Grant succeeded.

SQL> grant write on directory emp_dir to hr;

Grant succeeded.

SQL> !
[oracle@oel ~]$ mkdir /u01/emp_dir
[oracle@oel ~]$ cd /u01/emp_dir/
[oracle@oel emp_dir]$ vi emp.dat
tom,luo
jack,chen
li,jhon                                                                                                                                 
"emp.dat" [New] 3L, 26C written                                                                                   
[oracle@oel emp_dir]$ exit
exit

SQL> conn hr/oracle
Connected.
SQL> CREATE TABLE oldemp ( 
fname char(25), lname CHAR(25)) 
ORGANIZATION EXTERNAL 
(TYPE ORACLE_LOADER 
DEFAULT DIRECTORY emp_dir 
ACCESS PARAMETERS 
(RECORDS DELIMITED BY NEWLINE 
NOBADFILE 
NOLOGFILE 
FIELDS TERMINATED BY ',' 
(fname POSITION ( 1:20) CHAR, 
lname POSITION (22:41) CHAR)) 
LOCATION ('emp.dat')) 
PARALLEL 5 
REJECT LIMIT 200;
Table created.

SQL> select * from oldemp;

FNAME                     LNAME
------------------------- -------------------------
tom,luo
jack,chen
li,jhon
--ORACLE_DATAPUMP
SQL> CREATE TABLE emp_ext
  2  (employee_id, first_name, last_name)
  3  ORGANIZATION EXTERNAL
  4  (
  5  TYPE ORACLE_DATAPUMP
  6  DEFAULT DIRECTORY emp_dir
  7  LOCATION
  8  ('emp1.exp','emp2.exp')
  9  )
 10  PARALLEL
 11  AS
 12  SELECT employee_id, first_name, last_name
 13  FROM employees;

Table created.

--子查询创建表时重命名column name
SQL> conn hr/oracle
Connected.

SQL> CREATE TABLE employees2 AS
  2  SELECT employee_id id, first_name, last_name, salary,department_id dept_id
  3  FROM employees;

Table created.

SQL> desc employees2;
 Name                                      Null?    Type
 ----------------------------------------- -------- ----------------------------
 ID                                                 NUMBER(6)
 FIRST_NAME                                         VARCHAR2(20)
 LAST_NAME                                 NOT NULL VARCHAR2(25)
 SALARY                                             NUMBER(8,2)
 DEPT_ID                                            NUMBER(4)
--创建外部表例子２
SQL> !
[oracle@oel ~]$ cd /u01/emp_dir/
[oracle@oel emp_dir]$ vi library_items.dat
2354, 2264, 13.21, 150,
2355, 2289, 46.23, 200,
2355, 2264, 50.00, 100,                                                                      
"library_items.dat" [New] 3L, 72C written
exit

SQL> CREATE TABLE library_items_ext ( category_id number(12)
  2  , book_id number(6)
  3  , book_price number(8,2)
  4  , quantity number(8)
  5  )
  6  ORGANIZATION EXTERNAL
  7  (TYPE ORACLE_LOADER
  8  DEFAULT DIRECTORY emp_dir
  9  ACCESS PARAMETERS (RECORDS DELIMITED BY NEWLINE
 10  FIELDS TERMINATED BY ',')
 11  LOCATION ('library_items.dat')
 12  )
 13  REJECT LIMIT UNLIMITED;

Table created.

SQL> SELECT * FROM library_items_ext;

CATEGORY_ID    BOOK_ID BOOK_PRICE   QUANTITY
----------- ---------- ---------- ----------
       2354       2264      13.21        150
       2355       2289      46.23        200
       2355       2264         50        100