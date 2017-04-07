oracle NVL、NVL2,、NULLIF、COALESCE函数的用法
1.NVL函数
       NVL(expr1,expr2)

如果expr1和expr2的数据类型一致，则：
如果expr1为空(null),那么显示expr2，
如果expr1的值不为空，则显示expr1。

例如：
QL> conn scott/oracle
Connected.
SQL> select ename,nvl(comm,-1) from emp;

ENAME      NVL(COMM,-1)
---------- ------------
SMITH                -1
ALLEN               300
WARD                500
JONES                -1
MARTIN             1400
BLAKE                -1
CLARK                -1
SCOTT                -1
KING                 -1
TURNER                0
ADAMS                -1

ENAME      NVL(COMM,-1)
---------- ------------
JAMES                -1
FORD                 -1
MILLER               -1

14 rows selected.

当两个参数数据类型不同时，oracle会将两个参数进行隐式转换，如果不能隐式转换刚会报错，隐式转换规则如下：
1.如果参数1为字符型，则把参数2转换为参数1的类型，返回值为VARCHAR2
2.如果参数1为数值型，则判断两个参数的最高数值优先级（如双精实数比单精实数优先级高），然后转换成高优先级的数值，返回该类型的值.

--第一个参数是number类型，第二个参数是varchar类型，无法隐式转换，报错。
SQL> select ename,nvl(comm,'no comm') from emp;
select ename,nvl(comm,'no comm') from emp
                      *
ERROR at line 1:
ORA-01722: invalid number

--将第一个参数变成字符类型，第二个参数是number类型，那么第二个参数自动转成字符类型，返回字符串。
SQL> select ename,NVL(comm || '',-1) from emp;

ENAME      NVL(COMM||'',-1)
---------- ----------------------------------------
SMITH      -1
ALLEN      300
WARD       500
JONES      -1
MARTIN     1400
BLAKE      -1
CLARK      -1
SCOTT      -1
KING       -1
TURNER     0
ADAMS      -1

ENAME      NVL(COMM||'',-1)
---------- ----------------------------------------
JAMES      -1
FORD       -1
MILLER     -1

14 rows selected.

2.NVL2函数
   NVL2(expr1,expr2, expr3)

如果expr1不为NULL，返回expr2； expr1为NULL，返回expr3。
expr2和expr3类型不同的话，expr3会转换为expr2的类型，转换不了，则报错。
QL> select ename,nvl2(comm,comm,-1) from emp;

ENAME      NVL2(COMM,COMM,-1)
---------- ------------------
SMITH                      -1
ALLEN                     300
WARD                      500
JONES                      -1
MARTIN                   1400
BLAKE                      -1
CLARK                      -1
SCOTT                      -1
KING                       -1
TURNER                      0
ADAMS                      -1

ENAME      NVL2(COMM,COMM,-1)
---------- ------------------
JAMES                      -1
FORD                       -1
MILLER                     -1

14 rows selected.
--第二个参数是number类型，第三个参数是varchar类型，无法隐式转换，报错。
SQL> select ename,nvl2(comm,comm,'no comm') from emp;
select ename,nvl2(comm,comm,'no comm') from emp
                            *
ERROR at line 1:
ORA-01722: invalid number
--第二个参数是varchar类型，第三个参数是number类型，隐式转换成varchar，成功返回结果。
SQL> select ename,nvl2(comm,comm||'',-1) from emp;

ENAME      NVL2(COMM,COMM||'',-1)
---------- ----------------------------------------
SMITH      -1
ALLEN      300
WARD       500
JONES      -1
MARTIN     1400
BLAKE      -1
CLARK      -1
SCOTT      -1
KING       -1
TURNER     0
ADAMS      -1

ENAME      NVL2(COMM,COMM||'',-1)
---------- ----------------------------------------
JAMES      -1
FORD       -1
MILLER     -1

14 rows selected.

3. NULLIF函数
NULLIF(expr1,expr2)
如果expr1和expr2相等则返回空(NULL)，否则返回expr1。

-- 显示出那些换过工作的人员原工作、现工作，没有换工作的，显示为null。
SQL>  SELECT e.last_name, e.job_id,j.job_id,NULLIF(e.job_id, j.job_id) "Old Job ID"
  2      FROM employees e, job_history j
  3     WHERE e.employee_id = j.employee_id
  4     ORDER BY last_name;

LAST_NAME                 JOB_ID     JOB_ID     Old Job ID
------------------------- ---------- ---------- ----------
De Haan                   AD_VP      IT_PROG    AD_VP
Hartstein                 MK_MAN     MK_REP     MK_MAN
Kaufling                  ST_MAN     ST_CLERK   ST_MAN
Kochhar                   AD_VP      AC_MGR     AD_VP
Kochhar                   AD_VP      AC_ACCOUNT AD_VP
Raphaely                  PU_MAN     ST_CLERK   PU_MAN
Taylor                    SA_REP     SA_REP
Taylor                    SA_REP     SA_MAN     SA_REP
Whalen                    AD_ASST    AC_ACCOUNT AD_ASST
Whalen                    AD_ASST    AD_ASST

10 rows selected.

4.coalesce函数
	coalesce(expr1, expr2, expr3….. exprn)
返回表达式中第一个非空表达式，如果都为空则返回空值。
所有表达式必须是相同类型，或者可以隐式转换为相同的类型，否则报错。
--Coalese函数和NVL函数功能类似，只不过选项更多。
SQL> select ename,coalesce(comm,-1) from scott.emp;

ENAME      COALESCE(COMM,-1)
---------- -----------------
SMITH                     -1
ALLEN                    300
WARD                     500
JONES                     -1
MARTIN                  1400
BLAKE                     -1
CLARK                     -1
SCOTT                     -1
KING                      -1
TURNER                     0
ADAMS                     -1

ENAME      COALESCE(COMM,-1)
---------- -----------------
JAMES                     -1
FORD                      -1
MILLER                    -1

14 rows selected.
SQL> select ename,coalesce(comm,null,-2,-5) from scott.emp;

ENAME      COALESCE(COMM,NULL,-2,-5)
---------- -------------------------
SMITH                             -2
ALLEN                            300
WARD                             500
JONES                             -2
MARTIN                          1400
BLAKE                             -2
CLARK                             -2
SCOTT                             -2
KING                              -2
TURNER                             0
ADAMS                             -2

ENAME      COALESCE(COMM,NULL,-2,-5)
---------- -------------------------
JAMES                             -2
FORD                              -2
MILLER                            -2

14 rows selected.
--所有表达式必须是相同类型，或者可以隐式转换为相同的类型，否则报错。
SQL> select ename,coalesce(comm,null,'还是为空',-5) from scott.emp;
select ename,coalesce(comm,null,'还是为空',-5) from scott.emp
                                *
ERROR at line 1:
ORA-00932: inconsistent datatypes: expected NUMBER got CHAR
