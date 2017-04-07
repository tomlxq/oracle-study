case when和decode的用法与区别

case when
case when 类似我们的if ...else ,判断语句
语法如下:
CASE expr WHEN expr1 THEN return_expr1
         [WHEN expr2 THEN return_expr2
          ...
          WHEN exprn THEN return_exprn
          ELSE else_expr]
END

第二种延伸用法:
CASE
         WHEN  expr1 THEN return_expr1
         [WHEN expr2 THEN return_expr2
          ....
          WHEN exprn THEN return_exprn
          ELSE else_expr]
END

-- 如果部门编号为10的，显示为dept10
-- 如果部门编号为20的，显示为dept20
-- 如果部门编号为30的，显示为dept30
-- 否则显示为other
-- 这一列查询的结果，列名显示为 department
SQL> SELECT ENAME,sal,case deptno when 10 then 'dept10' when 20 then 'dept20' else 'other' end  部门 from scott.emp;

ENAME             SAL ??????
---------- ---------- ------
SMITH             800 dept20
ALLEN            1600 other
WARD             1250 other
JONES            2975 dept20
MARTIN           1250 other
BLAKE            2850 other
CLARK            2450 dept10
SCOTT            3000 dept20
KING             5000 dept10
TURNER           1500 other
ADAMS            1100 dept20

ENAME             SAL ??????
---------- ---------- ------
JAMES             950 other
FORD             3000 dept20
MILLER           1300 dept10

14 rows selected.

SQL> SELECT ENAME,sal,case when deptno=10 then 'dept10' when deptno=20 then 'dept20' else 'other' end  部门 from scott.emp;

ENAME             SAL ??????
---------- ---------- ------
SMITH             800 dept20
ALLEN            1600 other
WARD             1250 other
JONES            2975 dept20
MARTIN           1250 other
BLAKE            2850 other
CLARK            2450 dept10
SCOTT            3000 dept20
KING             5000 dept10
TURNER           1500 other
ADAMS            1100 dept20

ENAME             SAL ??????
---------- ---------- ------
JAMES             950 other
FORD             3000 dept20
MILLER           1300 dept10

14 rows selected.
这里是等值，结果是一样的。
如果是不等值的或是有多个表达式，就只能用第二种了，比如:
SQL> select ename,sal,
       case when deptno= 10 or deptno = 20 or deptno = 30 then 'dept'||deptno end dept
  3  from scott.emp;

ENAME             SAL DEPT
---------- ---------- --------------------------------------------
SMITH             800 dept20
ALLEN            1600 dept30
WARD             1250 dept30
JONES            2975 dept20
MARTIN           1250 dept30
BLAKE            2850 dept30
CLARK            2450 dept10
SCOTT            3000 dept20
KING             5000 dept10
TURNER           1500 dept30
ADAMS            1100 dept20

ENAME             SAL DEPT
---------- ---------- --------------------------------------------
JAMES             950 dept30
FORD             3000 dept20
MILLER           1300 dept10

14 rows selected.

SQL> select ename,sal,
  2         case when deptno<=20 then 'dept'||deptno end dept
  3  from scott.emp;

ENAME             SAL DEPT
---------- ---------- --------------------------------------------
SMITH             800 dept20
ALLEN            1600
WARD             1250
JONES            2975 dept20
MARTIN           1250
BLAKE            2850
CLARK            2450 dept10
SCOTT            3000 dept20
KING             5000 dept10
TURNER           1500
ADAMS            1100 dept20

ENAME             SAL DEPT
---------- ---------- --------------------------------------------
JAMES             950
FORD             3000 dept20
MILLER           1300 dept10

14 rows selected.
二、decode
语法:
DECODE(col|expression, search1, result1
					   [, search2, result2,...,]
						...
					   [, searchn, resultn,...,]
					   [, default])
如果 条件=值1,那么显示结果1
如果 条件=值2,那么显示结果2
....
如果 条件=值n,那么显示结果n
都不符合，则显示缺省值

--结果和上面用case when一样，但这句看起来简洁得多了
SQL> select ename,sal,
  2         decode(deptno,10,'dept10',20,'dept20',30,'dept30','other') department  
  3  from scott.emp;

ENAME             SAL DEPART
---------- ---------- ------
SMITH             800 dept20
ALLEN            1600 dept30
WARD             1250 dept30
JONES            2975 dept20
MARTIN           1250 dept30
BLAKE            2850 dept30
CLARK            2450 dept10
SCOTT            3000 dept20
KING             5000 dept10
TURNER           1500 dept30
ADAMS            1100 dept20

ENAME             SAL DEPART
---------- ---------- ------
JAMES             950 dept30
FORD             3000 dept20
MILLER           1300 dept10

14 rows selected.

延伸用法：与sign函数联用比较大小
注：sign()函数根据参数1的值是0、正数还是负数，分别返回0、1、-1
SQL> select ename,sal,decode(sign(sal-3000),-1,'<3000',0,'=3000',1,'>3000') from scott.emp;

ENAME             SAL DECOD
---------- ---------- -----
SMITH             800 <3000
ALLEN            1600 <3000
WARD             1250 <3000
JONES            2975 <3000
MARTIN           1250 <3000
BLAKE            2850 <3000
CLARK            2450 <3000
SCOTT            3000 =3000
KING             5000 >3000
TURNER           1500 <3000
ADAMS            1100 <3000

ENAME             SAL DECOD
---------- ---------- -----
JAMES             950 <3000
FORD             3000 =3000
MILLER           1300 <3000

14 rows selected.

三、DECODE 与CASE WHEN 的比较
1.DECODE 只有Oracle 才有，其它数据库不支持;
2.CASE WHEN的用法， Oracle、SQL Server、 MySQL 都支持;
3.DECODE 只能用做相等判断,但是可以配合sign函数进行大于，小于，等于的判断,CASE when可用于=,>=,<,<=,<>,is null,is not null 等的判断;
4.DECODE 使用其来比较简洁，CASE 虽然复杂但更为灵活;
5.另外，在decode中，null和null是相等的，但在case when中，只能用is null来判断，示例如下：

emp表中有一列comm，如果这列为null,则显示为0，否则，显示为原值：
Warning: You are no longer connected to ORACLE.
SQL> conn scott/oracle
Connected.
--decode可以显示我们要求的结果
SQL> select ename,decode(comm,null,0,comm) comma from emp;

ENAME           COMMA
---------- ----------
SMITH               0
ALLEN             300
WARD              500
JONES               0
MARTIN           1400
BLAKE               0
CLARK               0
SCOTT               0
KING                0
TURNER              0
ADAMS               0

ENAME           COMMA
---------- ----------
JAMES               0
FORD                0
MILLER              0

14 rows selected.
-- null没有转成0，仍然是null,不是我们要求的结果
SQL> select ename,case comm when null then 0 else comm end comma from emp;

ENAME           COMMA
---------- ----------
SMITH
ALLEN             300
WARD              500
JONES
MARTIN           1400
BLAKE
CLARK
SCOTT
KING
TURNER              0
ADAMS

ENAME           COMMA
---------- ----------
JAMES
FORD
MILLER

14 rows selected.
--comm is null才可以成功将null显示为0
SQL> select ename,case when comm is null then 0 else comm end comma from emp;

ENAME           COMMA
---------- ----------
SMITH               0
ALLEN             300
WARD              500
JONES               0
MARTIN           1400
BLAKE               0
CLARK               0
SCOTT               0
KING                0
TURNER              0
ADAMS               0

ENAME           COMMA
---------- ----------
JAMES               0
FORD                0
MILLER              0

14 rows selected.