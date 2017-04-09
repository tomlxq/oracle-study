在主查询执行之前,子查询(内查询)会执行一次
子查询结果被用于主查询(外查询)

单行子查询
	=
	>
	>=
	<=
	<>
多行子查询
	IN
	ANY
	ALL
SQL> SELECT last_name, salary
  2  FROM employees
  3  WHERE salary >
  4  (SELECT salary
  5  FROM employees
  6  WHERE last_name = 'Abel');

LAST_NAME                     SALARY
------------------------- ----------
Hartstein                      13000
Higgins                        12008
King                           24000
Kochhar                        17000
De Haan                        17000
Greenberg                      12008
Russell                        14000
Partners                       13500
Errazuriz                      12000
Ozer                           11500

10 rows selected.
--内查询无结果会怎样
SQL> SELECT last_name, job_id
  2  FROM employees
  3  WHERE job_id =
  4  (SELECT job_id
  5  FROM employees
  6  WHERE last_name = 'Haas');

no rows selected



常见错误
SELECT employee_id, last_name
FROM employees
WHERE salary =
(SELECT MIN(salary)
FROM employees
GROUP BY department_id);

SQL> SELECT distinct salary
  2  FROM employees
  3  WHERE job_id = 'IT_PROG';

    SALARY
----------
      9000
      4800
      4200
      6000
--查询的结果要小于任何一个子查询中查出来的值，即只需要小于最大的即可
SQL> SELECT employee_id, last_name, job_id, salary
  2  FROM employees
  3  WHERE salary < ANY
  4  (SELECT salary
  5  FROM employees
  6  WHERE job_id = 'IT_PROG')
  7  AND job_id <> 'IT_PROG';

EMPLOYEE_ID LAST_NAME                 JOB_ID         SALARY
----------- ------------------------- ---------- ----------
        132 Olson                     ST_CLERK         2100
        136 Philtanker                ST_CLERK         2200
        128 Markle                    ST_CLERK         2200
        135 Gee                       ST_CLERK         2400
        127 Landry                    ST_CLERK         2400
        119 Colmenares                PU_CLERK         2500
        191 Perkins                   SH_CLERK         2500
        182 Sullivan                  SH_CLERK         2500
        144 Vargas                    ST_CLERK         2500
        140 Patel                     ST_CLERK         2500
        131 Marlow                    ST_CLERK         2500
--查询的结果要小于所有的值，即小于最小的就可以了
SQL> SELECT employee_id, last_name, job_id, salary
  2  FROM employees
  3  WHERE salary < ALL
  4  (SELECT salary
  5  FROM employees
  6  WHERE job_id = 'IT_PROG')
  7  AND job_id <> 'IT_PROG';

EMPLOYEE_ID LAST_NAME                 JOB_ID         SALARY
----------- ------------------------- ---------- ----------
        185 Bull                      SH_CLERK         4100
        192 Bell                      SH_CLERK         4000
        193 Everett                   SH_CLERK         3900
        188 Chung                     SH_CLERK         3800
        137 Ladwig                    ST_CLERK         3600
        189 Dilly                     SH_CLERK         3600
        141 Rajs                      ST_CLERK         3500
        186 Dellinger                 SH_CLERK         3400
        133 Mallin                    ST_CLERK         3300
        129 Bissot                    ST_CLERK         3300
        180 Taylor                    SH_CLERK         3200
--exists操作
SQL> SELECT * FROM departments
  2  WHERE NOT EXISTS
  3  (SELECT * FROM employees
  4  WHERE employees.department_id=departments.department_id);

DEPARTMENT_ID DEPARTMENT_NAME                MANAGER_ID LOCATION_ID
------------- ------------------------------ ---------- -----------
          120 Treasury                                         1700
          130 Corporate Tax                                    1700
          140 Control And Credit                               1700
          150 Shareholder Services                             1700
          160 Benefits                                         1700
          170 Manufacturing                                    1700
          180 Construction                                     1700
          190 Contracting                                      1700
          200 Operations                                       1700
          210 IT Support                                       1700
          220 NOC                                              1700
--子查询中的空值
SQL> SELECT emp.last_name
  2  FROM employees emp
  3  WHERE emp.employee_id NOT IN
  4  (SELECT mgr.manager_id
  5  FROM employees mgr);

no rows selected

