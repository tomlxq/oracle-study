表名列名命名必须
	以字母开头
	必须为1-30字符长度
	只能包含A–Z, a–z, 0–9, _, $, 和# 字符
	同一用户下，不能重名
	不能使用oracle服 务器保留字

SQL> create table dept(
  2  deptno number(2),
  3  dname varchar2(14),
  4  loc varchar2(13),
  5  create_date date default sysdate
  6  );

Table created.
--查询用户的所有表名信息
SQL> select * from tab where tname='DEPT';

TNAME                          TABTYPE  CLUSTERID
------------------------------ ------- ----------
DEPT                           TABLE
SQL> select TABLE_NAME,TABLESPACE_NAME,STATUS from user_tables where table_name='DEPT';

TABLE_NAME                     TABLESPACE_NAME                STATUS
------------------------------ ------------------------------ --------
DEPT                           USERS                          VALID
SQL> col OBJECT_NAME for a30
SQL> select OBJECT_NAME,OBJECT_TYPE,STATUS from user_objects where object_name='DEPT';

OBJECT_NAME                    OBJECT_TYPE         STATUS
------------------------------ ------------------- -------
DEPT                           TABLE               VALID
--查看列名信息
SQL> select table_name,column_name from user_tab_columns where table_name='DEPT';

TABLE_NAME                     COLUMN_NAME
------------------------------ ------------------------------
DEPT                           DEPTNO
DEPT                           DNAME
DEPT                           LOC
DEPT                           CREATE_DATE


数据类型
	VARCHAR2(size)		可变字符型
	CHAR(size)			固定字符型
	LONG				可变字符型
	CLOB				字符型
	NUMBER(p,s)			可变数字型
	DATE				日期时间型
	RAW and LONG RAW	二进制
	BLOB				二进制
	BFILE				二进制
	ROWID				64位行唯一地址标识
TIMESTAMP  带小数秒的日期
INTERVAL YEAR TO MONTH 存储间隔多少年多少月
INTERVAL DAY TO SECOND 存储间隔多少天,小时,分钟,秒

Interval 间隔

SQL> create table coupons(
  2  coupon_id integer constraint coupons_pk primary key,
  3  name varchar2(30) not null,
  4  duration interval year(3) to month
  5  );

Table created.
interval '[+|-][y][-m]' [YEAR[(years_precision)]] [to month]
+|- 可选的指示符，用来说明时间间隔是正数还是负数，默认为正数
y 是一个可选参数，表示时间间隔的年数部分
m 是一个可选参数，表示时间间隔的月数部分
years_precision是一个可选参数，用来说明年数的精度,默认为２
interval '1' year 时间间隔为１年
interval '11' month 时间间隔为１１月
interval '14' month 时间间隔为１４月，即１年２个月
interval '1-3' year to month 时间间隔为１年３个月
interval '0-5' year to month 时间间隔为０年５个月
interval '123' year(3) to month 时间间隔为123年,数度为3
interval '-1-5' year to month 时间间隔为负数，值为1年５个月
interval '1234' year(3) 时间间隔无效，1234包含了４个数字，越过了精度３位所允许的范围
SQL> create table coupons(
  2  coupon_id integer constraint coupons_pk primary key,
  3  name varchar2(30) not null,
  4  duration interval year(3) to month
  5  );

Table created.

SQL> insert into coupons(coupon_id,name,duration) values(1,'$1 off Z Files',interval '1' year);
insert into coupons(coupon_id,name,duration) values(2,'$2 off Pop 3',interval '11' month);
insert into coupons(coupon_id,name,duration) values(3,'$3 off Modern science',interval '14' month);
insert into coupons(coupon_id,name,duration) values(4,'$2 off Tank war',interval '1-3' year to month);
insert into coupons(coupon_id,name,duration) values(5,'$2 off chemistry',interval '0-5' year to month);
insert into coupons(coupon_id,name,duration) values(6,'$2 off creative yell',interval '123' year(3));

1 row created.

SQL> 
1 row created.

SQL> 
1 row created.

SQL> 
1 row created.

SQL> 
1 row created.

SQL> 
1 row created.

约束类型
	NOT NULL 非空
		null约束定义列上不能出现空值
	UNIQUE 唯一
		表级列级都 可以定义，如果定义多列必须在表级定义
	PRIMARY KEY 主键
		一个表只能有一个主键
		主键是唯一的并且非空
		可以联合主键,联合主键要求每列都非空
		主键唯一定位一行,所有主键也叫逻辑ROWID
		主键不是必需的,可以没有
		主键是通过索引实现的
		索引的名称和主键的名称相同
	FOREIGN KEY 外键
		表级列级均可定义
		外键约束只能关联到本表或其它表的主键或唯一键上
		FOREIGN KEY: 表级定义关联到子表中的列
		REFERENCES: 定义父表和表中列
		ON DELETE CASCADE: 父表行 被删除子表行被级联删除
		ON DELETE SET NULL: 父表行被删除将依赖的外键值修改为空值
	CHECK 检查
		用户定义的 条件，每一行必须满足
		不允许使用如下 表达式
			涉及CURRVAL, NEXTVAL, LEVEL和ROWNUM 等伪列
			调用 SYSDATE, UID, USER和USERENV函数
			涉及到其他关 联行的查询
约束可以在 列级或表级定义—非空只能在列级别定义
使用alter table命令
	添加或丢弃约束，不会改变表结构
	启用或禁用约束
		disable禁用约束
		使用cascade选项,可以禁用相关联的约束
			alter table employees disable constaint emp_emp_id_pk cascade;
		约束状态可以通过user_constraints视图的status列查询
		enable 启用当前是处于禁用状态的约束
			alter table employees enable constaint emp_emp_id_pk;
		如果启用了primary key或unique约束，就会自动创建主键或唯一索引
	使用modify子句添加非空约束
ALTER TABLE 修改表语句
	添加新的列
	修改列的定义
	定义默认值
	删除列
	重命名列名
	11g开始更改表为只读
	Add,drop,enable,disable添加删除启用禁用约束
	
	
--子查询建立表
SQL> conn hr/oracle
Connected.
SQL> CREATE TABLE dept80
  2  AS SELECT employee_id, last_name,
  3  salary*12 ANNSAL,
  4  hire_date FROM employees WHERE department_id = 80;

Table created.


列级
CREATE TABLE employees(
	employee_id NUMBER(6) CONSTRAINT emp_emp_id_pk PRIMARY KEY,
	first_name VARCHAR2(20),
	...
);
--PRIMARY KEY Constraint 主键约束
表级
CREATE TABLE employees(
	employee_id NUMBER(6),
	first_name VARCHAR2(20),
	...
	job_id VARCHAR2(10) NOT NULL,
	CONSTRAINT emp_emp_id_pk PRIMARY KEY (EMPLOYEE_ID)
);
--UNIQUE Constraint 唯一性约束
CREATE TABLE employees(
	employee_id NUMBER(6),
	last_name VARCHAR2(25) NOT NULL,
	email VARCHAR2(25),
	salary NUMBER(8,2),
	commission_pct NUMBER(2,2),
	hire_date DATE NOT NULL,
	...
	CONSTRAINT emp_email_uk UNIQUE(email)
);
--已存在的表建立unique约束：
SQL>alter table emp1 add constraint u_emp1 unique(ename);
SQL>alter table emp1 modify(empno unique);
--FOREIGN KEY Constraint 外键约束
CREATE TABLE employees(
	employee_id NUMBER(6),
	last_name VARCHAR2(25) NOT NULL,
	email VARCHAR2(25),
	salary NUMBER(8,2),
	commission_pct NUMBER(2,2),
	hire_date DATE NOT NULL,
	...
	department_id NUMBER(4),
	CONSTRAINT emp_dept_fk FOREIGN KEY (department_id) REFERENCES departments(department_id),
	CONSTRAINT emp_email_uk UNIQUE(email)
);

--外键约束 on delete set null
SQL> conn scott/oracle
Connected.
SQL> create table a as select * from dept;

Table created.

SQL> create table b as select * from emp;

Table created.

SQL> alter table a add constraint pk_a primary key(deptno);

Table altered.

SQL> alter table b add constraint uk_b foreign key (deptno) references a(deptno);

Table altered.

SQL> delete from a where deptno=10;
delete from a where deptno=10
*
ERROR at line 1:
ORA-02292: integrity constraint (SCOTT.UK_B) violated - child record found


SQL> update b set deptno=50;
update b set deptno=50
*
ERROR at line 1:
ORA-02291: integrity constraint (SCOTT.UK_B) violated - parent key not found


SQL> alter table b drop constraint uk_b;

Table altered.
--on delete set null 父表行被删除将依赖的外键值修改为空值
SQL> alter table b add constraint uk_b foreign key (deptno) references a(deptno) on delete set null;

Table altered.

SQL> delete from a where deptno=10; 

1 row deleted.

SQL> select * from b;

     EMPNO ENAME      JOB              MGR HIREDATE                  SAL       COMM     DEPTNO
---------- ---------- --------- ---------- ------------------ ---------- ---------- ----------
      7369 SMITH      CLERK           7902 17-DEC-80                 800                    20
      7499 ALLEN      SALESMAN        7698 20-FEB-81                1600        300         30
      7521 WARD       SALESMAN        7698 22-FEB-81                1250        500         30
      7566 JONES      MANAGER         7839 02-APR-81                2975                    20
      7654 MARTIN     SALESMAN        7698 28-SEP-81                1250       1400         30
      7698 BLAKE      MANAGER         7839 01-MAY-81                2850                    30
      7782 CLARK      MANAGER         7839 09-JUN-81                2450
      7788 SCOTT      ANALYST         7566 19-APR-87                3000                    20
      7839 KING       PRESIDENT            17-NOV-81                5000
      7844 TURNER     SALESMAN        7698 08-SEP-81                1500          0         30
      7876 ADAMS      CLERK           7788 23-MAY-87                1100                    20

     EMPNO ENAME      JOB              MGR HIREDATE                  SAL       COMM     DEPTNO
---------- ---------- --------- ---------- ------------------ ---------- ---------- ----------
      7900 JAMES      CLERK           7698 03-DEC-81                 950                    30
      7902 FORD       ANALYST         7566 03-DEC-81                3000                    20
      7934 MILLER     CLERK           7782 23-JAN-82                1300

14 rows selected.

SQL> update b set deptno=50;
update b set deptno=50
*
ERROR at line 1:
ORA-02291: integrity constraint (SCOTT.UK_B) violated - parent key not found

--只读表 只读表模式避免 维护表期间被DDL,DML修改
SQL> ALTER TABLE employees READ ONLY;

Table altered.

SQL> delete from employees;
delete from employees
            *
ERROR at line 1:
ORA-12081: update operation not allowed on table "HR"."EMPLOYEES"

--维护完毕更改为读 写模式
SQL> ALTER TABLE employees READ WRITE;


--set unused、set unused column及drop unused columns
SQL> create table c as select * from employees;

Table created.
SQL> alter table c set unused (FIRST_NAME,LAST_NAME);

Table altered.
SQL> alter table c set unused column COMMISSION_PCT;

Table altered.
SQL> alter table c drop unused columns;

Table altered.

--修改列名rename column xxx to xxx 10G后才有
SQL> alter table c rename column email to mail;

Table altered.

--Dropping a Table 删除表 
--PURGE 使用purge把表与表附带的数据一起删除
SQL> DROP TABLE dept80;

Table dropped.