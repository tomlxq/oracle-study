-使用子查询处理数据
		--使用嵌入式视图查询数据
		--从其他表复制数据
		--使用来字某个表值的结果去更新一个表中的数据
		--使用来字某个表值的结果去删除一个表中的记录
	子查询语法：
		SELECT select_list FROM table WHERE expr operator
		(SELECT select_list FROM table);	
		-先执行子查询（内部查询），再执行主查询（外部查询）。
		-主查询会使用子查询的结果。
	子查询是一个SELECT语句，它嵌入到另一个SELECT语句的子句中。通过使用子查询，可以用简单的语句构建功能强大的语句。当需要从表选择行，而选择条件却取决于该表自身中的数据时，子查询非常有用。
	可以在许多SQL 子句中使用子查询，其中包括以下子句：
		- WHERE子句
		- HAVING子句
		- FROM子句
	在该语法中：
		operator包括比较条件，例如>、=或IN
		注：比较条件分为以下两类：
			单行运算符（>、=、>=、<、<>、<=）
			多行运算符（IN、ANY、ALL、EXISTS）。
	子查询通常被称为嵌套SELECT语句、子SELECT语句或内部SELECT语句。通常先执行子查询，然后使用其输出来完善主查询（即外部查询）的查询条件。		
	使用子查询的准则
		- 子查询必须放在括号中。
		- 子查询放在比较条件的右侧可增加可读性。但是，子查询可出现在比较运算符的任意一侧。
		- 在子查询中可以使用两类比较条件：单行运算符和多行运算符。 对单行子查询使用单行运算符，对多行子查询使用多行运算符。
	
-在INSERT 和 UPDATE语句中指定默认值
-向多表插入数据
-使用多表插入数据
	--无条件的INSERT
	--有条件的all insert
	--有条件的first insert
		两者区别： 
			INSERT FIRST：对于每一行数据，只插入到第一个when条件成立的表，不继续检查其他条件，不满足踢一个when则插入后面一个when。 
			INSERT ALL：对于每一行数据，对每一个when条件都进行检查，如果满足条件就执行插入操作。
	--旋转INSERT
-merge融合表数据
-跟踪数据变化的历史版本

SQL> select ename,job,deptno from emp
  2  where deptno=(select deptno from emp where empno=7788);

ENAME      JOB           DEPTNO
---------- --------- ----------
SMITH      CLERK             20
JONES      MANAGER           20
SCOTT      ANALYST           20
ADAMS      CLERK             20
FORD       ANALYST           20

SQL> select ename,job,deptno from emp
  2  where (select deptno from emp where empno=7788)=deptno;

ENAME      JOB           DEPTNO
---------- --------- ----------
SMITH      CLERK             20
JONES      MANAGER           20
SCOTT      ANALYST           20
ADAMS      CLERK             20
FORD       ANALYST           20


SQL> select deptno,min(sal) from emp group by deptno having min(sal)>(select min(sal) from emp where deptno=20);

    DEPTNO   MIN(SAL)
---------- ----------
        30        950
        10       1300


SQL> select deptno,min(sal) from emp group by deptno having min(sal)>(select min(sal) from emp group by deptno);
select deptno,min(sal) from emp group by deptno having min(sal)>(select min(sal) from emp group by deptno)
                                                                 *
ERROR at line 1:
ORA-01427: single-row subquery returns more than one row

--在INSERT 和 UPDATE语句中指定默认值
SQL> create table dept_t as select * from dept;

Table created.

SQL> insert into dept_t(deptno,dname,loc) values(90,'HR',default);

1 row created.

SQL> alter table dept_t modify loc default 'shenzhen';

Table altered.

SQL> update dept_t set loc=default where deptno=10;

1 row updated.

SQL> select * from dept_t;

    DEPTNO DNAME          LOC
---------- -------------- -------------
        10 ACCOUNTING     shenzhen
        20 RESEARCH       DALLAS
        30 SALES          CHICAGO
        40 OPERATIONS     BOSTON
        90 HR
向多表插入数据		
		- INSERT...SELECT 语句可以用于将记录插入到多个表中，如同执行多条简单的DML语句一样
		- 多表INSERT语句可用于数据仓库系统中，可以通一个或多个数据源中将数据传送到一系列表中
		- 性能上优于多个简单的INSERT ... SELECT语句 和使用IF...then语法进行的多表记录插入。
		
	无条件，全部插入	
		INSERT ALL
			INTO table_A VALUES(...,...)
			INTO table_B VALUES(...,...)
			INTO table_C VALUES(...,...)
			INTO table_D VALUES(...,...)
			SELECT ...
			FROM TABLE_Source
			WHERE ...;
--无条件，全部插入			
SQL> create table sal_history(empno number(4) not null,hiredate date,sal  number(7,2));

Table created.

);
SQL> create table mgr_history(empno number(4) not null,mgr number(4),sal  number(7,2));

Table created.

SQL> INSERT ALL
  2  INTO sal_history values(empno,hiredate,sal)
  3  INTO mgr_history values(empno,MGR,sal)
  4  SELECT empno,hiredate,sal,mgr
  5  FROM emp
  6  WHERE empno>0;

28 rows created.

SQL> select count(*) from sal_history;

  COUNT(*)
----------
        14

SQL> select count(*) from mgr_history;

  COUNT(*)
----------
        14		
		
--有条件，符合条件的插入
SQL> truncate table mgr_history;

Table truncated.

SQL> truncate table sal_history;

Table truncated.

SQL> INSERT ALL
  2  WHEN sal>100  AND  sal<5000 THEN
  3  INTO sal_history values(empno,hiredate,sal)
  4  WHEN sal>2500 AND mgr is not null THEN
  5  INTO mgr_history values(empno,MGR,sal)
  6  SELECT empno,hiredate,sal,mgr
  7  FROM emp
  8  WHERE empno>0;

17 rows created.

SQL> select * from sal_history;

     EMPNO HIREDATE         SAL
---------- --------- ----------
      7369 17-DEC-80        800
      7499 20-FEB-81       1600
      7521 22-FEB-81       1250
      7566 02-APR-81       2975
      7654 28-SEP-81       1250
      7698 01-MAY-81       2850
      7782 09-JUN-81       2450
      7788 19-APR-87       3000
      7844 08-SEP-81       1500
      7876 23-MAY-87       1100
      7900 03-DEC-81        950

     EMPNO HIREDATE         SAL
---------- --------- ----------
      7902 03-DEC-81       3000
      7934 23-JAN-82       1300

13 rows selected.

SQL> select * from mgr_history;

     EMPNO        MGR        SAL
---------- ---------- ----------
      7566       7839       2975
      7698       7839       2850
      7788       7566       3000
      7902       7566       3000

--insert first
SQL> truncate table sal_history;

Table truncated.

SQL> truncate table mgr_history;

Table truncated.

--如果第一个 WHEN 子句的值为 true，Oracle 服务器对于给定的行执行相应的 INTO 子句，并且跳过后面的 WHEN 子句(后面的when语句都不再考虑满足第一个When子句的记录，即使该记录满足when语句中的条件)。
SQL> INSERT first
  2      WHEN sal>100  AND  sal<5000 THEN
  3      INTO sal_history values(empno,hiredate,sal)
  4      WHEN sal>2500 AND mgr is not null THEN
  5      INTO mgr_history values(empno,MGR,sal)
  6      SELECT empno,hiredate,sal,mgr
  7      FROM emp
  8      WHERE empno>0;

13 rows created.

SQL> select * from mgr_history;

no rows selected

SQL> select * from sal_history;

     EMPNO HIREDATE         SAL
---------- --------- ----------
      7369 17-DEC-80        800
      7499 20-FEB-81       1600
      7521 22-FEB-81       1250
      7566 02-APR-81       2975
      7654 28-SEP-81       1250
      7698 01-MAY-81       2850
      7782 09-JUN-81       2450
      7788 19-APR-87       3000
      7844 08-SEP-81       1500
      7876 23-MAY-87       1100
      7900 03-DEC-81        950

     EMPNO HIREDATE         SAL
---------- --------- ----------
      7902 03-DEC-81       3000
      7934 23-JAN-82       1300

13 rows selected. 

两者区别： 
	INSERT FIRST：对于每一行数据，只插入到第一个when条件成立的表，不继续检查其他条件，不满足踢一个when则插入后面一个when。 
	INSERT ALL：对于每一行数据，对每一个when条件都进行检查，如果满足条件就执行插入操作。 

--多行子查询in
SQL> SELECT MIN(sal) FROM emp GROUP BY deptno;

  MIN(SAL)
----------
       950
       800
      1300
SQL> SELECT ename,sal,deptno FROM emp
  2  WHERE sal in (SELECT MIN(sal) FROM emp GROUP BY deptno);

ENAME             SAL     DEPTNO
---------- ---------- ----------
SMITH             800         20
JAMES             950         30
MILLER           1300         10
--多行子查询All,ANY
SQL> SELECT sal FROM emp WHERE job='SALESMAN' and job<>'ANALYST';

       SAL
----------
      1600
      1250
      1250
      1500

SQL> select ename,sal,deptno from emp 
    where sal<any
    (select sal from emp where job='SALESMAN' and job<>'ANALYST'); 
ENAME             SAL     DEPTNO
---------- ---------- ----------
SMITH             800         20
JAMES             950         30
ADAMS            1100         20
WARD             1250         30
MARTIN           1250         30
MILLER           1300         10
TURNER           1500         30

7 rows selected.
<ANY表示低于最高值，即小于1600就可以了
SQL>  select ename,sal,deptno from emp 
    where sal>any
  3  (select sal from emp where job='SALESMAN' and job<>'ANALYST');

ENAME             SAL     DEPTNO
---------- ---------- ----------
KING             5000         10
FORD             3000         20
SCOTT            3000         20
JONES            2975         20
BLAKE            2850         30
CLARK            2450         10
ALLEN            1600         30
TURNER           1500         30
MILLER           1300         10

9 rows selected.
>ANY表示高于最低值，即大于1250就可以了
提示：
	<ANY表示低于最高值
	>ANY表示高于最低值
	=ANY等同于IN
SQL> SELECT empno,ename,job,sal FROM emp
  2  WHERE sal<ALL
  3  (SELECT sal FROM emp WHERE job='SALESMAN' and job<>'ANALYST');

     EMPNO ENAME      JOB              SAL
---------- ---------- --------- ----------
      7876 ADAMS      CLERK           1100
      7900 JAMES      CLERK            950
      7369 SMITH      CLERK            800
<ALL表示小于最低值，即小于1250
SQL> SELECT empno,ename,job,sal FROM emp
WHERE sal>ALL
  3  (SELECT sal FROM emp WHERE job='SALESMAN' and job<>'ANALYST');

     EMPNO ENAME      JOB              SAL
---------- ---------- --------- ----------
      7782 CLARK      MANAGER         2450
      7698 BLAKE      MANAGER         2850
      7566 JONES      MANAGER         2975
      7788 SCOTT      ANALYST         3000
      7902 FORD       ANALYST         3000
      7839 KING       PRESIDENT       5000

6 rows selected.
>ALL表示大于最高值,即大于1600

提示：
	>ALL表示大于最高值
	<ALL表示小于最低值	
	
--子查询中的空值	
SQL> SELECT empno,ename,job,sal,DEPTNO FROM emp  
  2  WHERE EMPNO NOT IN
  3  (SELECT MGR FROM EMP);

no rows selected

内部查询返回的值中有一个为空值，所以整个查询不会返回任何行。
原因是所有条件与空值进行比较后都会产生一个空值。
因此，只要子查询的结果集中可能包含空值，就不要使用NOT IN运算符。
NOT IN运算符等同于<> ALL。而IN运算符等同于=ANY。所以可以使用IN
显示有下属的雇员
SQL> SELECT empno,ename,job,sal,DEPTNO FROM emp
  2  WHERE EMPNO IN
  3  (SELECT MGR FROM EMP);

     EMPNO ENAME      JOB              SAL     DEPTNO
---------- ---------- --------- ---------- ----------
      7902 FORD       ANALYST         3000         20
      7698 BLAKE      MANAGER         2850         30
      7839 KING       PRESIDENT       5000         10
      7566 JONES      MANAGER         2975         20
      7788 SCOTT      ANALYST         3000         20
      7782 CLARK      MANAGER         2450         10

6 rows selected.
显示没有下属的雇员
SQL> SELECT empno,ename,job,sal,DEPTNO FROM emp
  2  WHERE EMPNO not IN
  3  (SELECT MGR FROM EMP where mgr is not null);

     EMPNO ENAME      JOB              SAL     DEPTNO
---------- ---------- --------- ---------- ----------
      7844 TURNER     SALESMAN        1500         30
      7521 WARD       SALESMAN        1250         30
      7654 MARTIN     SALESMAN        1250         30
      7499 ALLEN      SALESMAN        1600         30
      7934 MILLER     CLERK           1300         10
      7369 SMITH      CLERK            800         20
      7876 ADAMS      CLERK           1100         20
      7900 JAMES      CLERK            950         30

8 rows selected.

旋转INSERT	
使用pivoting insert 
实质是无条件INSERT ALL的一种特殊应用。
例如：从一个非关系型数据库表中，获取一行销售记录，转存储到典型的关系型数据库中存储。
SQL>  create table sal_source(empno number(4),week_id number(3),mon_s number(7,2),
				tue_s number(7,2),
				wed_s number(7,2),
				thu_s number(7,2),
				fri_s number(7,2));
SQL> insert into sal_source values(11,4,11000,2000,3000,4000,5000);

1 row created.

SQL> insert into sal_source values(12,3,4000,7000,9000,4030,6000);

1 row created.

SQL> create table new_sal(empno number(4),week_id number(3),sales number(7,2));

Table created.

SQL> insert all
into new_sal values(empno,week_id,mon_s)
into new_sal values(empno,week_id,tue_s)
into new_sal values(empno,week_id,thu_s)
into new_sal values(empno,week_id,wed_s)
into new_sal values(empno,week_id,thu_s)
into new_sal values(empno,week_id,fri_s)
select empno,week_id,mon_s,
tue_s,
wed_s,
thu_s,
fri_s
from sal_source;

10 rows created.

SQL> select * from new_sal;

     EMPNO    WEEK_ID      SALES
---------- ---------- ----------
        11          4      11000
        12          3       4000
        11          4       2000
        12          3       7000
        11          4       3000
        12          3       9000
        11          4       4000
        12          3       4030
        11          4       5000
        12          3       6000

10 rows selected.
					