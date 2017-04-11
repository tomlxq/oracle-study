Write a multiple-column subquery 多列子查询
	成对子查询
	非成对子查询
Use scalar subqueries in SQL 标准子查询
Solve problems with correlated subqueries 关联子查询
	子查询关联的某个列引用父查询
Update and delete rows by using correlated subqueries 使 用关联子查询更新删除行记录
Use the EXISTS and NOT EXISTS operators 使用exists和 not exists操作符
	用于测试外查询在子查询的结果集的存在性
	如果子查询被找到，条件被标志为true，内层查询不再继续
	如果子查询没有被找到，条件被标志为false，内层查询继续
Use the WITH clause with子查询
	使用with子句，你能在同一查询块中，使用多个基于复合查询的select语句
	with子句返回的查询块的结果集并将其存储于用的临时表空间，因此使用with子句能搞高性能

--多列子查询
SQL> conn hr/oracle
Connected.
SQL> create table empl_demo as select * from employees;

Table created.

SQL> SELECT manager_id, department_id
  2      FROM empl_demo
  3      WHERE first_name = 'John';

MANAGER_ID DEPARTMENT_ID
---------- -------------
       108           100
       123            50
       100            80
--成对比较 显示与John在同一个领 导同一个部门的其他员工编号，管理编号，部门编号   
SQL> SELECT employee_id, manager_id, department_id
  2  FROM empl_demo
  3  WHERE (manager_id, department_id) IN
  4  (SELECT manager_id, department_id
  5  FROM empl_demo
  6  WHERE first_name = 'John')
  7  AND first_name <> 'John';

EMPLOYEE_ID MANAGER_ID DEPARTMENT_ID
----------- ---------- -------------
        113        108           100
        112        108           100
        111        108           100
        109        108           100
        195        123            50
        194        123            50
        193        123            50
        192        123            50
        140        123            50
        138        123            50
        137        123            50

EMPLOYEE_ID MANAGER_ID DEPARTMENT_ID
----------- ---------- -------------
        149        100            80
        148        100            80
        147        100            80
        146        100            80

15 rows selected.
--非成对比较 显示跟John在同一个领导和跟John在同一 个部门的员工信息
SQL> SELECT employee_id, manager_id, department_id
  2  FROM empl_demo
  3  WHERE manager_id IN
  4  (SELECT manager_id
  5  FROM empl_demo
  6  WHERE first_name = 'John')
  7  AND department_id IN
  8  (SELECT department_id
  9  FROM empl_demo
 10  WHERE first_name = 'John')
 11  AND first_name <> 'John';

EMPLOYEE_ID MANAGER_ID DEPARTMENT_ID
----------- ---------- -------------
        109        108           100
        111        108           100
        112        108           100
        113        108           100
        120        100            50
        121        100            50
        122        100            50
        123        100            50
        124        100            50
        137        123            50
        138        123            50

EMPLOYEE_ID MANAGER_ID DEPARTMENT_ID
----------- ---------- -------------
        140        123            50
        192        123            50
        193        123            50
        194        123            50
        195        123            50
        146        100            80
        147        100            80
        148        100            80
        149        100            80

20 rows selected.


SQL> SELECT department_id FROM departments
  2  WHERE location_id = 1800;

DEPARTMENT_ID
-------------
           20
--Scalar Subqueries,CASE expressions
SQL> SELECT employee_id, last_name,
  2  (CASE
  3  WHEN department_id =
  4  (SELECT department_id FROM departments
  5  WHERE location_id = 1800)
  6  THEN 'Canada' ELSE 'USA' END) location
  7  FROM employees;

EMPLOYEE_ID LAST_NAME                 LOCATI
----------- ------------------------- ------
        198 OConnell                  USA
        199 Grant                     USA
        200 Whalen                    USA
        201 Hartstein                 Canada
        202 Fay                       Canada
        203 Mavris                    USA
        204 Baer                      USA
        205 Higgins                   USA
        206 Gietz                     USA
--Scalar subqueries in the ORDER BY clause:
SQL> SELECT employee_id, last_name
  2  FROM employees e
  3  ORDER BY (SELECT department_name
  4  FROM departments d
  5  WHERE e.department_id = d.department_id);

EMPLOYEE_ID LAST_NAME
----------- -------------------------
        205 Higgins
        206 Gietz
        200 Whalen
        100 King
        101 Kochhar
        102 De Haan
        112 Urman
        108 Greenberg
        109 Faviet
        110 Chen
        111 Sciarra
--关联子查询: 找出所有薪水超过他所在部门的平均薪水的员 工信息
SQL> SELECT last_name, salary, department_id
  2  FROM employees outer_table
  3  WHERE salary > (SELECT AVG(salary)
  4  FROM employees inner_table
  5  WHERE inner_table.department_id =
  6  outer_table.department_id);

LAST_NAME                     SALARY DEPARTMENT_ID
------------------------- ---------- -------------
Hartstein                      13000            20
Higgins                        12008           110
King                           24000            90
Hunold                          9000            60
Ernst                           6000            60
Greenberg                      12008           100
Faviet                          9000           100
Raphaely                       11000            30
Weiss                           8000            50
Fripp                           8200            50
--关联子查询: 显示至少更换过两次工作岗位的员工信息
SQL> SELECT e.employee_id, last_name,e.job_id
  2  FROM employees e
  3  WHERE 2 <= (SELECT COUNT(*)
  4  FROM job_history
  5  WHERE employee_id = e.employee_id);

EMPLOYEE_ID LAST_NAME                 JOB_ID
----------- ------------------------- ----------
        200 Whalen                    AD_ASST
        101 Kochhar                   AD_VP
        176 Taylor                    SA_REP
--使用exists和 not exists操作符		
SQL> SELECT employee_id, last_name, job_id, department_id
  2  FROM employees outer
  3  WHERE EXISTS ( SELECT 'X'
  4  FROM employees
  5  WHERE manager_id =
  6  outer.employee_id);

EMPLOYEE_ID LAST_NAME                 JOB_ID     DEPARTMENT_ID
----------- ------------------------- ---------- -------------
        201 Hartstein                 MK_MAN                20
        205 Higgins                   AC_MGR               110
        100 King                      AD_PRES               90
        101 Kochhar                   AD_VP                 90
        102 De Haan                   AD_VP                 90
        103 Hunold                    IT_PROG               60
        108 Greenberg                 FI_MGR               100
        114 Raphaely                  PU_MAN                30
        120 Weiss                     ST_MAN                50
        121 Fripp                     ST_MAN                50
        122 Kaufling                  ST_MAN                50

SQL> SELECT employee_id, last_name, job_id, department_id
  2  FROM employees outer
  3  WHERE not EXISTS ( SELECT 'X'
  4  FROM employees
  5  WHERE manager_id =
  6  outer.employee_id);

EMPLOYEE_ID LAST_NAME                 JOB_ID     DEPARTMENT_ID
----------- ------------------------- ---------- -------------
        198 OConnell                  SH_CLERK              50
        199 Grant                     SH_CLERK              50
        200 Whalen                    AD_ASST               10
        202 Fay                       MK_REP                20
        203 Mavris                    HR_REP                40
        204 Baer                      PR_REP                70
        206 Gietz                     AC_ACCOUNT           110
        104 Ernst                     IT_PROG               60
        105 Austin                    IT_PROG               60
        106 Pataballa                 IT_PROG               60
        107 Lorentz                   IT_PROG               60
--关联子查询的更新
SQL> create table emp16 as select department_id,employee_id,first_name,last_name from employees;
SQL> alter table emp16 add(department_name varchar2(25));  
SQL> UPDATE empl6 e
SET department_name =
(SELECT department_name
FROM departments d
WHERE e.department_id = d.department_id);
SQL> set linesize 200
SQL> select * from emp16 where rownum<5;

DEPARTMENT_ID EMPLOYEE_ID FIRST_NAME           LAST_NAME                 DEPARTMENT_NAME
------------- ----------- -------------------- ------------------------- -------------------------
           50         198 Donald               OConnell                  Shipping
           50         199 Douglas              Grant                     Shipping
           10         200 Jennifer             Whalen                    Administration
           20         201 Michael              Hartstein                 Marketing
--关联子查询删除
SQL> DELETE FROM EMP16 e
  2  WHERE employee_id =
  3  (SELECT distinct employee_id
  4  FROM JOB_HISTORY
  5  WHERE employee_id = e.employee_id);

7 rows deleted.
--WITH Clause
SQL> WITH dept_costs AS (
  2  SELECT d.department_name, SUM(e.salary) AS dept_total
  3  FROM employees e JOIN departments d
  4  ON e.department_id = d.department_id
  5  GROUP BY d.department_name),
  6  avg_cost AS (
  7  SELECT SUM(dept_total)/COUNT(*) AS dept_avg
  8  FROM dept_costs)
  9  SELECT *
 10  FROM dept_costs
 11  WHERE dept_total >
 12  (SELECT dept_avg
 13  FROM avg_cost)
 14  ORDER BY department_name;

DEPARTMENT_NAME                DEPT_TOTAL
------------------------------ ----------
Sales                              304500
Shipping                           156400

--Recursive WITH Clause
SQL> create table flights(
source varchar2(10),
destin varchar2(10),
flight_time NUMBER
);
SQL> insert into flights VALUES('上海','北京',1.3);
SQL> INSERT INTO flights values('广州','深圳',1.1);
SQL> insert into flights VALUES('北京','广州',5.8);
SQL> select * from flights;

SOURCE     DESTIN     FLIGHT_TIME
---------- ---------- -----------
上海       北京               1.3
广州       深圳               1.1
北京       广州               5.8

SQL> WITH reachable_from(SOURCE,
  2  destin,
  3  totalFlightTime) AS
  4   (SELECT SOURCE, destin, flight_time
  5      FROM flights
  6    UNION ALL
  7    SELECT incoming.source,
  8           outgoing.destin,
  9           incoming.totalFlightTime + outgoing.flight_time
 10      FROM reachable_from incoming, flights outgoing
 11     WHERE incoming.destin = outgoing.source)
 12  SELECT * FROM reachable_from;

SOURCE     DESTIN     TOTALFLIGHTTIME
---------- ---------- ---------------
上海       北京                   1.3
广州       深圳                   1.1
北京       广州                   5.8
北京       深圳                   6.9
上海       广州                   7.1
上海       深圳                   8.2

6 rows selected.