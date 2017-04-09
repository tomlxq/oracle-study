DML
	向表中插入数据
	更新现有数据
	从表删除数据
事务控制
	数据库事务由以下某一个产生
		DML语句\DDL语句\DCL语句
	执行第一个DML语句就是事务开始
	结束
		使用commit,rollback
		DDL,DCL语句执行(自动结束)
		使用exits正常退出
		The system crashes.
	用savepoint对当前事务做个保存点
	回到指定保存点用rollback to savepoint

从其他表复制行
create table sales_reps as SELECT employee_id, last_name, salary, commission_pct
  FROM employees where 1<>1;
--insert列表中的列个数，类型，顺序须与子查询相匹配
--子查询返回的所有行被插入到指定表中
INSERT INTO sales_reps(employee_id, last_name, salary, commission_pct)
SELECT employee_id, last_name, salary, commission_pct
FROM employees
  WHERE job_id LIKE '%REP%';

--子查询例子
SQL> create table emp1 as select * from employees;
Table created.
SQL> UPDATE emp1
  2  SET job_id = (SELECT job_id
  3  FROM emp1
  4  WHERE employee_id = 205),
  5  salary = (SELECT salary
  6  FROM emp1
  7  WHERE employee_id = 205)
  8  WHERE employee_id = 113;

1 row updated.
--子查询例子
SQL> DELETE FROM emp1
  2  WHERE department_id =
  3  (SELECT department_id
  4  FROM departments
  5  WHERE department_name
  6  LIKE '%Public%');

1 row deleted.
--从表删除所有行，保留表结构 是DDL语句，不容易恢复
SQL> truncate table emp1;

Table truncated.

SQL> conn hr/oracle
Connected.
SQL> SELECT employee_id, salary, commission_pct, job_id
  2  FROM employees
  3  WHERE job_id = 'SA_REP'
  4  FOR UPDATE
  5  ORDER BY employee_id;

EMPLOYEE_ID     SALARY COMMISSION_PCT JOB_ID
----------- ---------- -------------- ----------
        150      10000             .3 SA_REP
        151       9500            .25 SA_REP
        152       9000            .25 SA_REP
        153       8000             .2 SA_REP
        154       7500             .2 SA_REP
        155       7000            .15 SA_REP
        156      10000            .35 SA_REP
        157       9500            .35 SA_REP
        158       9000            .35 SA_REP
SQL> SELECT e.employee_id, e.salary, e.commission_pct
  2  FROM employees e JOIN departments d
  3  USING (department_id)
  4  WHERE job_id = 'ST_CLERK'
  5  AND location_id = 1500
  6  FOR UPDATE
  7  ORDER BY e.employee_id;

EMPLOYEE_ID     SALARY COMMISSION_PCT
----------- ---------- --------------
        125       3200
        126       2700
        127       2400
        128       2200
        129       3300
        130       2800
        131       2500
        132       2100
        133       3300
        134       2900
        135       2400