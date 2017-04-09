子查询操作数据
	使用嵌入式视图查询 数据
	从其他表复制数据
	使用来自某个表值的结果去更新一个表中的数据
	使用来自某个表值的结果去删除一个表的行记录
Multitable INSERT多表插入
	无条件insert
		INSERT [conditional_insert_clause]
		[insert_into_clause values_clause] (subquery)
	条件all insert
		[ALL|FIRST]
		[WHEN condition THEN] [insert_into_clause values_clause]
		[ELSE] [insert_into_clause values_clause]
	条件first insert
	旋转insert
MERGE Statement
	MERGE INTO table_name table_alias
	USING (table|view|sub_query) alias
	ON (join condition)
	WHEN MATCHED THEN
		UPDATE SET
		col1 = col1_val,
		col2 = col2_val
	WHEN NOT MATCHED THEN
		INSERT (column_list)
		VALUES (column_values);
跟踪行变化历史版本(闪回版本查询)
	select xxx,
	versions_starttime,versions_endtime 
	from xxx 
	versions between scn minvalue and maxvalue
	where ...


--使用嵌入式视图查询 数据
SQL> SELECT department_name, city
  2  FROM departments
  3  NATURAL JOIN (SELECT l.location_id, l.city, l.country_id
  4  FROM locations l
  5  JOIN countries c
  6  ON(l.country_id = c.country_id)
  7  JOIN regions USING(region_id)
  8  WHERE region_name = 'Europe');

DEPARTMENT_NAME                CITY
------------------------------ ------------------------------
Human Resources                London
Sales                          Oxford
Public Relations               Munich

--Inserting by Using a Subquery as a Target 例子
SQL> create table loc as select * from locations where 1<>1;

Table created.

SQL> INSERT INTO (SELECT l.location_id, l.city, l.country_id
  2  FROM loc l
  3  JOIN countries c
  4  ON(l.country_id = c.country_id)
  5  JOIN regions USING(region_id)
  6  WHERE region_name = 'Europe')
  7  VALUES (3300, 'Cardiff', 'UK');

1 row created.

SQL> select * from loc;

LOCATION_ID STREET_ADDRESS                           POSTAL_CODE  CITY                           STATE_PROVINCE            CO
----------- ---------------------------------------- ------------ ------------------------------ ------------------------- --
       3300                                                       Cardiff                                                  UK

SQL> select * from countries c where c.country_id='UK';

CO COUNTRY_NAME                              REGION_ID
-- ---------------------------------------- ----------
UK United Kingdom                                    1

SQL> select * from regions r where r.region_name='Europe';

 REGION_ID REGION_NAME
---------- -------------------------
         1 Europe
--约束插入的行必须是在子查询中匹配的记录否 则违背检查约束而报错		 
SQL> INSERT INTO ( SELECT location_id, city, country_id
  2  FROM locations
  3  WHERE country_id IN
  4  (SELECT country_id
  5  FROM countries
  6  NATURAL JOIN regions
  7  WHERE region_name = 'Europe')
  8  WITH CHECK OPTION )
  9  VALUES (3600, 'Washington', 'US');
FROM locations
     *
ERROR at line 2:
ORA-01402: view WITH CHECK OPTION where-clause violation


--Using Explicit Default Values 例子
SQL> create table deptm3 as select department_id,d.department_name,e.manager_id from employees e join departments d using(department_id);

Table created.
--DEFAULT with INSERT
SQL> INSERT INTO deptm3
  2  (department_id, department_name, manager_id)
  3  VALUES (300, 'Engineering', DEFAULT);

1 row created.
--DEFAULT with UPDATE:
SQL> UPDATE deptm3
  2  SET manager_id = DEFAULT WHERE department_id = 10;

1 row updated.
SQL> select * from deptm3;

DEPARTMENT_ID DEPARTMENT_NAME                MANAGER_ID
------------- ------------------------------ ----------
           10 Administration
           20 Marketing                             100
           20 Marketing                             201
           30 Purchasing                            100
           30 Purchasing                            114
--使用子查询 复制行
--不指定values关键字
--Insert中的列信息要与子查询的列信息 匹配
SQL> create table sales_reps as 
  2  SELECT employee_id id, last_name name, salary, commission_pct
  3  FROM employees where 1<>1;

Table created.
SQL> INSERT INTO sales_reps(id, name, salary, commission_pct)
  2  SELECT employee_id, last_name, salary, commission_pct
  3  FROM employees
  4  WHERE job_id LIKE '%REP%';

33 rows created.
SQL> select * from sales_reps;

        ID NAME                          SALARY COMMISSION_PCT
---------- ------------------------- ---------- --------------
       202 Fay                             6000
       203 Mavris                          6500
       204 Baer                           10000
       150 Tucker                         10000             .3
       151 Bernstein                       9500            .25
       152 Hall                            9000            .25
       153 Olsen                           8000             .2
       154 Cambrault                       7500             .2
       155 Tuvault                         7000            .15
       156 King                           10000            .35
       157 Sully                           9500            .35
--Unconditional INSERT ALL 例子   
SQL> create table sal_history as SELECT employee_id EMPID, hire_date HIREDATE, salary SAL
  2     FROM employees where 1<>1;

Table created.

SQL> create table mgr_history as SELECT employee_id EMPID,manager_id MGR, salary SAL
  2     FROM employees where 1<>1;

Table created.

SQL> INSERT ALL 
INTO sal_history VALUES(EMPID,HIREDATE,SAL) 
INTO mgr_history VALUES(EMPID,MGR,SAL)
SELECT employee_id EMPID, hire_date HIREDATE, salary SAL, manager_id MGR
FROM employees WHERE employee_id > 200;

12 rows created.

SQL> select count(*) from sal_history;

  COUNT(*)
----------
         6

SQL> select count(*) from mgr_history;

  COUNT(*)
----------
         6

SQL> truncate table sal_history;

Table truncated.

SQL> truncate table mgr_history;

Table truncated.
--Conditional INSERT ALL 例子
SQL> INSERT ALL 
  2  when sal>10000 then
  3  INTO sal_history VALUES(EMPID,HIREDATE,SAL) 
  4  when mgr>200 then
  5  INTO mgr_history VALUES(EMPID,MGR,SAL)
  6  SELECT employee_id EMPID, hire_date HIREDATE, salary SAL, manager_id MGR
  7  FROM employees WHERE employee_id > 200;

4 rows created.

SQL> select * from sal_history;

     EMPID HIREDATE                  SAL
---------- ------------------ ----------
       201 17-FEB-04               13000
       205 07-JUN-02               12008

SQL> select * from mgr_history;

     EMPID        MGR        SAL
---------- ---------- ----------
       202        201       6000
       206        205       8300
	   
--Conditional INSERT FIRST 例子   
SQL> create table sal_low as SELECT employee_id, last_name, salary FROM employees where 1<>1;

Table created.

SQL> create table sal_mid as SELECT employee_id, last_name, salary FROM employees where 1<>1;

Table created.

SQL> create table sal_high as SELECT employee_id, last_name, salary FROM employees where 1<>1;

Table created.
--表示如果第一个条件满足则插入，后面的跳过，如果不满足则判断下一个条件
SQL> insert first 
  2  when salary<5000 then 
  3  into sal_low values(employee_id, last_name, salary)
  4  when salary between 5000 and 10000 then 
  5  into sal_mid values(employee_id, last_name, salary)
  6  else
  7  into sal_high values(employee_id, last_name, salary) 
  8  SELECT employee_id, last_name, salary FROM employees;

107 rows created.

SQL> select count(*) from sal_low;

  COUNT(*)
----------
        49

SQL> select count(*) from sal_mid;

  COUNT(*)
----------
        43

SQL> select count(*) from sal_high;

  COUNT(*)
----------
        15
--Pivoting INSERT 旋转insert
--旋转销售行记录为列记录
create table sales_source_data as 
select 176 EMPLOYEE_ID, 
6 week_id, 
2000 sales_MON, 
3000 sales_TUE, 
4000 sales_WED, 
5000 sales_THUR, 
6000 sales_FRI
from dual;
SQL> create table sales_info as SELECT EMPLOYEE_ID, week_id week, sales_MON sales
  2  FROM sales_source_data where 1<>1;

Table created.

SQL> INSERT ALL 
  2  INTO sales_info VALUES (employee_id,week_id,sales_MON) 
  3  INTO sales_info VALUES (employee_id,week_id,sales_TUE) 
  4  INTO sales_info VALUES (employee_id,week_id,sales_WED) 
  5  INTO sales_info VALUES (employee_id,week_id,sales_THUR) 
  6  INTO sales_info VALUES (employee_id,week_id, sales_FRI) 
  7  SELECT EMPLOYEE_ID, week_id, sales_MON, sales_TUE, sales_WED, sales_THUR,sales_FRI 
  8  FROM sales_source_data;

5 rows created.
SQL> select * from sales_info;

EMPLOYEE_ID       WEEK      SALES
----------- ---------- ----------
        176          6       2000
        176          6       3000
        176          6       4000
        176          6       5000
        176          6       6000
--Merging Rows: Example 例子
create table copy_emp3 as select * from employees where 1<>1;		
MERGE INTO copy_emp3 c
USING (SELECT * FROM EMPLOYEES ) e
ON (c.employee_id = e.employee_id)
WHEN MATCHED THEN
	UPDATE SET
	c.first_name = e.first_name,
	c.last_name = e.last_name,
	c.email =e.email,
	c.phone_number = e.phone_number, 
	c.hire_date =e.hire_date, 
	c.job_id = e.job_id,
	c.salary =e.salary,
	c.commission_pct = e.commission_pct,
	c.manager_id = e.manager_id,
	c.department_id =e.department_id
	DELETE WHERE (e.COMMISSION_PCT IS NOT NULL)
WHEN NOT MATCHED THEN
	INSERT VALUES(e.employee_id, e.first_name, e.last_name,
	e.email, e.phone_number, e.hire_date, e.job_id,
	e.salary, e.commission_pct, e.manager_id,
	e.department_id);
--注意：使用中如果要update操作必须选择连接的列没有重复值

--闪回版本查询
--VERSIONS BETWEEN Clause 例子  
SQL> update copy_emp3 set first_name='jack'  where employee_id=109;

1 row updated.

SQL> commit;

Commit complete.

SQL> select FIRST_NAME,
versions_starttime "START_DATE", 
versions_endtime "END_DATE"  
from copy_emp3 
versions between scn minvalue and maxvalue 
where department_id=100;

FIRST_NAME           START_DATE                END_DATE
-------------------- ------------------------- ---------------------------------------------------------------------------
jack                 09-APR-17 04.38.02 PM
Nancy                09-APR-17 04.34.20 PM
Nancy                09-APR-17 04.33.47 PM     09-APR-17 04.34.20 PM
Daniel               09-APR-17 04.33.47 PM     09-APR-17 04.38.02 PM
John                 09-APR-17 04.33.47 PM
Ismael               09-APR-17 04.33.47 PM
Jose Manuel          09-APR-17 04.33.47 PM
Luis                 09-APR-17 04.33.47 PM

8 rows selected.