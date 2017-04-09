表达式必须在数量上匹配
后一个语句中列的数据类型必须与前一个语句中的对应列数 据类型一致
UNION/UNION ALL
INTERSECT
MINUS

SQL> SELECT employee_id, job_id
  2  FROM employees
  3  UNION
  4  SELECT employee_id, job_id
  5  FROM job_history;

EMPLOYEE_ID JOB_ID
----------- ----------
        100 AD_PRES
        101 AC_ACCOUNT
        101 AC_MGR
        101 AD_VP
        102 AD_VP
        102 IT_PROG
        103 IT_PROG
        104 IT_PROG
        105 IT_PROG
        106 IT_PROG
        107 IT_PROG
QL> SELECT employee_id, job_id, department_id
  2  FROM employees
  3  UNION ALL
  4  SELECT employee_id, job_id, department_id
  5  FROM job_history
  6  ORDER BY employee_id;

EMPLOYEE_ID JOB_ID     DEPARTMENT_ID
----------- ---------- -------------
        100 AD_PRES               90
        101 AD_VP                 90
        101 AC_ACCOUNT           110
        101 AC_MGR               110
        102 AD_VP                 90
        102 IT_PROG               60
        103 IT_PROG               60
        104 IT_PROG               60
        105 IT_PROG               60
        106 IT_PROG               60
        107 IT_PROG               60
SQL> SELECT employee_id, job_id
  2  FROM employees
  3  INTERSECT
  4  SELECT employee_id, job_id
  5  FROM job_history;

EMPLOYEE_ID JOB_ID
----------- ----------
        176 SA_REP
        200 AD_ASST
SQL> SELECT employee_id
  2  FROM employees
  3  MINUS
  4  SELECT employee_id
  5  FROM job_history;