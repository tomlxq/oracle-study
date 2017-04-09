常用分组函数
	AVG
		默认分组忽略空值
	COUNT
		COUNT(*) 返回总行数
		COUNT(expr) 返回非空的总行数
		COUNT(DISTINCT expr) 返回非空唯一总行数
	MAX
	MIN
	STDDEV
	SUM
	VARIANCE
group by
	使用group by 可以把表的行分割成多个小组

--对数字，字符，日期类型的可使用MIN,MAX
SQL> SELECT AVG(salary), MAX(salary),
  2  MIN(salary), SUM(salary)
  3  FROM employees
  4  WHERE job_id LIKE '%REP%';

AVG(SALARY) MAX(SALARY) MIN(SALARY) SUM(SALARY)
----------- ----------- ----------- -----------
 8272.72727       11500        6000      273000
 
 
SQL> SELECT AVG(commission_pct) FROM employees; --默认分组忽略空值

AVG(COMMISSION_PCT)
-------------------
         .222857143
SQL> SELECT AVG(NVL(commission_pct, 0)) FROM employees;--nvl可以强制分组函数处理空值

AVG(NVL(COMMISSION_PCT,0))
--------------------------
                .072897196
--非分组列出现在select列表必须用group by
SQL> SELECT department_id, AVG(salary) FROM employees GROUP BY department_id ;

DEPARTMENT_ID AVG(SALARY)
------------- -----------
          100  8601.33333
           30        4150
                     7000
           20        9500
           70       10000
           90  19333.3333
          110       10154
           50  3475.55556
           40        6500
           80  8955.88235
           10        4400

DEPARTMENT_ID AVG(SALARY)
------------- -----------
           60        5760

12 rows selected.

--分组列可以不出现在select列表中
SQL> SELECT AVG(salary)
  2  FROM employees
  3  GROUP BY department_id ;

AVG(SALARY)
-----------
 8601.33333
       4150
       7000
       9500
      10000
 19333.3333
      10154
 3475.55556
       6500
 8955.88235
       4400

AVG(SALARY)
-----------
       5760

12 rows selected.
--多列分组例子
SQL> SELECT department_id, job_id, SUM(salary)
  2  FROM employees
  3  WHERE department_id > 40
  4  GROUP BY department_id, job_id
  5  ORDER BY department_id;

DEPARTMENT_ID JOB_ID     SUM(SALARY)
------------- ---------- -----------
           50 SH_CLERK         64300
           50 ST_CLERK         55700
           50 ST_MAN           36400
           60 IT_PROG          28800
           70 PR_REP           10000
           80 SA_MAN           61000
           80 SA_REP          243500
           90 AD_PRES          24000
           90 AD_VP            34000
          100 FI_ACCOUNT       39600
          100 FI_MGR           12008

DEPARTMENT_ID JOB_ID     SUM(SALARY)
------------- ---------- -----------
          110 AC_ACCOUNT        8300
          110 AC_MGR           12008

13 rows selected.

容易犯错的地方
SELECT department_id, COUNT(last_name) FROM employees;

SELECT department_id, job_id, COUNT(last_name)
FROM employees
GROUP BY department_id;

SELECT department_id, AVG(salary)
FROM employees
WHERE AVG(salary) > 8000
GROUP BY department_id;

--限制分组结果
SELECT department_id, MAX(salary)
FROM employees
GROUP BY department_id
HAVING MAX(salary)>10000 ;
--嵌套
SELECT MAX(AVG(salary))
FROM employees
GROUP BY department_id;