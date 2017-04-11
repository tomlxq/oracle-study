SELECT [LEVEL], column, expr...
FROM table
[WHERE condition(s)]
[START WITH condition(s)]
[CONNECT BY PRIOR condition(s)] ;


--Starting Point 起点
	START WITH last_name = 'Kochhar'
--Top down 自顶向下
	Column1 = Parent Key
	Column2 = Child Key
		CONNECT BY PRIOR employee_id=manager_id
--Bottom up自底向上
	Column1 = Child Key
	Column2 = Parent Key
		CONNECT BY PRIOR manager_id = employee_id

SQL> COLUMN org_chart FORMAT A30
SQL> SELECT LPAD(last_name, LENGTH(last_name)+(LEVEL*2)-2,'_')
  2  AS org_chart
  3  FROM employees
  4  START WITH first_name='Steven' AND last_name='King'
  5  CONNECT BY PRIOR employee_id=manager_id;

ORG_CHART
------------------------------
King
__Kochhar
____Greenberg
______Faviet
______Chen
______Sciarra
______Urman
______Popp
____Whalen
____Mavris
____Baer
