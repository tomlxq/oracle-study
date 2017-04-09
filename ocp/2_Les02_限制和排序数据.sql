限制行用：
–-where子句
SQL> SELECT employee_id, last_name, job_id, department_id
  2  FROM employees
  3  WHERE department_id = 90 ;

EMPLOYEE_ID LAST_NAME                 JOB_ID     DEPARTMENT_ID
----------- ------------------------- ---------- -------------
        100 King                      AD_PRES               90
        101 Kochhar                   AD_VP                 90
        102 De Haan                   AD_VP                 90

--默认日期显示格式:DD-MON-RR
SQL> SELECT last_name
  2  FROM employees
  3  WHERE hire_date = '17-FEB-96' ;

no rows selected
–-比较条件用=, <=, BETWEEN, IN, LIKE和null
SQL> SELECT last_name, salary
  2  FROM employees
  3  WHERE salary <= 3000 ;

LAST_NAME                     SALARY
------------------------- ----------
OConnell                        2600
Grant                           2600
Baida                           2900
Tobias                          2800
Himuro                          2600
Colmenares                      2500
Mikkilineni                     2700
Landry                          2400
--between注意，第一个值小，第二值大，否则查不出值
SQL> SELECT last_name, salary
  2  FROM employees
  3  WHERE salary BETWEEN 2500 AND 3500 ;

LAST_NAME                     SALARY
------------------------- ----------
OConnell                        2600
Grant                           2600
Khoo                            3100
Baida                           2900
Tobias                          2800
Himuro                          2600
Colmenares                      2500
Nayer                           3200
Mikkilineni                     2700
Bissot                          3300
Atkinson                        2800


SQL> SELECT last_name, salary
  2  FROM employees
  3  WHERE salary BETWEEN 3500 AND 2500 ;

no rows selected
--使用Like条件
-- %表示零或多个字符
-- _表示一个字符
SQL> SELECT first_name
  2  FROM employees
  3  WHERE first_name LIKE 'S%' ;

FIRST_NAME
--------------------
Sundar
Shelli
Sarah
Shelley
Steven
Sundita
Steven
Susan
Samuel
Sarath
Stephen

FIRST_NAME
--------------------
Sigal
Shanta

13 rows selected.

SQL> SELECT last_name
  2  FROM employees
  3  WHERE last_name LIKE '_o%' ;

LAST_NAME
-------------------------
Colmenares
Doran
Fox
Johnson
Jones
Kochhar
Lorentz
Mourgos
Popp
Rogers
Tobias

LAST_NAME
-------------------------
Vollman

12 rows selected.
--使用ESCAPE 转义% 与_ 匹配字符为本来含义
SQL> conn scott/oracle
Connected.
SQL> create table emp1 as select * from emp where 1<>1;

Table created.

SQL> desc emp1;
 Name                                      Null?    Type
 ----------------------------------------- -------- ----------------------------
 EMPNO                                              NUMBER(4)
 ENAME                                              VARCHAR2(10)
 JOB                                                VARCHAR2(9)
 MGR                                                NUMBER(4)
 HIREDATE                                           DATE
 SAL                                                NUMBER(7,2)
 COMM                                               NUMBER(7,2)
 DEPTNO                                             NUMBER(2)

SQL> insert into emp1(ename) values('a_%bccc');

1 row created.

SQL> select ename from emp1 where ename like 'a\_\%%' escape '\';

ENAME
----------
a_%bccc

--nulls 使用IS NULL或IS NOT NULL 进行比较操作
SQL> SELECT last_name, manager_id
  2  FROM employees
  3  WHERE manager_id IS NULL ;

LAST_NAME                 MANAGER_ID
------------------------- ----------
King

-- 逻辑条件用and,or,not操作符

SQL> SELECT employee_id, last_name, job_id, salary
  2  FROM employees
  3  WHERE salary >= 10000
  4  AND job_id LIKE '%MAN%' ;

EMPLOYEE_ID LAST_NAME                 JOB_ID         SALARY
----------- ------------------------- ---------- ----------
        201 Hartstein                 MK_MAN          13000
        114 Raphaely                  PU_MAN          11000
        145 Russell                   SA_MAN          14000
        146 Partners                  SA_MAN          13500
        147 Errazuriz                 SA_MAN          12000
        148 Cambrault                 SA_MAN          11000
        149 Zlotkey                   SA_MAN          10500

7 rows selected.
--使用order by子句
–-ASC: Ascending order, default 升序排列，默认
–-DESC: Descending order 降序排列
SQL> SELECT last_name, job_id, department_id, hire_date
  2  FROM employees
  3  where rownum<5 ORDER BY 3;

LAST_NAME                 JOB_ID     DEPARTMENT_ID HIRE_DATE
------------------------- ---------- ------------- ------------------
Whalen                    AD_ASST               10 17-SEP-03
Hartstein                 MK_MAN                20 17-FEB-04
OConnell                  SH_CLERK              50 21-JUN-07
Grant                     SH_CLERK              50 13-JAN-08
SQL> SELECT last_name, department_id, salary
  2  FROM employees where rownum<10
  3  ORDER BY department_id, salary DESC;

LAST_NAME                 DEPARTMENT_ID     SALARY
------------------------- ------------- ----------
Whalen                               10       4400
Hartstein                            20      13000
Fay                                  20       6000
Mavris                               40       6500
OConnell                             50       2600
Grant                                50       2600
Baer                                 70      10000
Higgins                             110      12008
Gietz                               110       8300

9 rows selected.

SQL> SELECT last_name, department_id, salary
  2  FROM employees where rownum<10
  3  ORDER BY 2, 3 DESC;

LAST_NAME                 DEPARTMENT_ID     SALARY
------------------------- ------------- ----------
Whalen                               10       4400
Hartstein                            20      13000
Fay                                  20       6000
Mavris                               40       6500
OConnell                             50       2600
Grant                                50       2600
Baer                                 70      10000
Higgins                             110      12008
Gietz                               110       8300

9 rows selected.
--空值排序
SQL> create table t(a varchar2(30));

Table created.

SQL> insert into t values(null);

1 row created.

SQL> insert into t values(default);

1 row created.

SQL> insert into t values('zhangshan');

1 row created.

SQL> insert into t values('lishi');

1 row created.

SQL> insert into t values(null);

1 row created.

SQL> insert into t values('jack');

1 row created.

SQL> select * from t;

A
------------------------------


zhangshan
lishi

jack

6 rows selected.

SQL> select * from t order by a nulls first;

A
------------------------------



jack
lishi
zhangshan

6 rows selected.

SQL> select * from t order by a nulls last;

A
------------------------------
jack
lishi
zhangshan




6 rows selected.

--替代变量
--临时变量用&，调用替代变量用&&
SQL> SELECT employee_id, last_name, salary, department_id
  2  FROM employees
  3  WHERE employee_id = &employee_num ;
Enter value for employee_num: 150
old   3: WHERE employee_id = &employee_num
new   3: WHERE employee_id = 150

EMPLOYEE_ID LAST_NAME                     SALARY DEPARTMENT_ID
----------- ------------------------- ---------- -------------
        150 Tucker                         10000            80
--字符和日期使用变量要用单引号引起来:
SQL> SELECT last_name, department_id, salary*12
  2  FROM employees
  3  WHERE job_id = '&job_title' ;
Enter value for job_title: IT_PROG
old   3: WHERE job_id = '&job_title'
new   3: WHERE job_id = 'IT_PROG'

LAST_NAME                 DEPARTMENT_ID  SALARY*12
------------------------- ------------- ----------
Hunold                               60     108000
Ernst                                60      72000
Austin                               60      57600
Pataballa                            60      57600
Lorentz                              60      50400
--列，表达式，文本
SQL> SELECT employee_id, last_name, job_id,&column_name
  2  FROM employees
  3  WHERE &condition
  4  ORDER BY &order_column ;
Enter value for column_name: salary
old   1: SELECT employee_id, last_name, job_id,&column_name
new   1: SELECT employee_id, last_name, job_id,salary
Enter value for condition: salary<5000
old   3: WHERE &condition
new   3: WHERE salary<5000
Enter value for order_column: 4 desc
old   4: ORDER BY &order_column
new   4: ORDER BY 4 desc

EMPLOYEE_ID LAST_NAME                 JOB_ID         SALARY
----------- ------------------------- ---------- ----------
        105 Austin                    IT_PROG          4800
        106 Pataballa                 IT_PROG          4800
        200 Whalen                    AD_ASST          4400
        184 Sarchand                  SH_CLERK         4200
        107 Lorentz                   IT_PROG          4200
        185 Bull                      SH_CLERK         4100
        192 Bell                      SH_CLERK         4000
        193 Everett                   SH_CLERK         3900
        188 Chung                     SH_CLERK         3800
        137 Ladwig                    ST_CLERK         3600
        189 Dilly                     SH_CLERK         3600
--define命令
SQL> define emp_id=200
SQL> select employee_id,last_name from employees where employee_id=&emp_id;
old   1: select employee_id,last_name from employees where employee_id=&emp_id
new   1: select employee_id,last_name from employees where employee_id=200

EMPLOYEE_ID LAST_NAME
----------- -------------------------
        200 Whalen

SQL> undefine emp_id 后面这个值失效了，要你重新输！！
SQL> select employee_id,last_name from employees where employee_id=&emp_id;
Enter value for emp_id: 150
old   1: select employee_id,last_name from employees where employee_id=&emp_id
new   1: select employee_id,last_name from employees where employee_id=150

EMPLOYEE_ID LAST_NAME
----------- -------------------------
        150 Tucker
		
--变量替换的过程新旧值是否显示用:set verify on|off
SQL> SET VERIFY ON
SQL> SELECT employee_id, last_name, salary
  2  FROM employees
  3  WHERE employee_id = &employee_num;
Enter value for employee_num: 200
old   3: WHERE employee_id = &employee_num
new   3: WHERE employee_id = 200

EMPLOYEE_ID LAST_NAME                     SALARY
----------- ------------------------- ----------
        200 Whalen                          4400

SQL> SET VERIFY OFF
SQL> SELECT employee_id, last_name, salary
  2  FROM employees
  3  WHERE employee_id = &employee_num;
Enter value for employee_num: 200

EMPLOYEE_ID LAST_NAME                     SALARY
----------- ------------------------- ----------
        200 Whalen                          4400

--like用法和修改临时日期格式
SQL> SELECT last_name, hire_date
  2  FROM employees
  3  WHERE hire_date LIKE '%02';

LAST_NAME                 HIRE_DATE
------------------------- ------------------
Mavris                    07-JUN-02
Baer                      07-JUN-02
Higgins                   07-JUN-02
Gietz                     07-JUN-02
Greenberg                 17-AUG-02
Faviet                    16-AUG-02
Raphaely                  07-DEC-02

7 rows selected.

SQL> alter session set nls_date_format='yyyy-mm-dd';

Session altered.

SQL>  SELECT last_name, hire_date
  2      FROM employees
  3      WHERE hire_date LIKE '2002%';

LAST_NAME                 HIRE_DATE
------------------------- ----------
Mavris                    2002-06-07
Baer                      2002-06-07
Higgins                   2002-06-07
Gietz                     2002-06-07
Greenberg                 2002-08-17
Faviet                    2002-08-16
Raphaely                  2002-12-07

7 rows selected.

SQL> alter session set nls_date_format='dd-mon-rr';

Session altered.