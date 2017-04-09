连接
	等值连接
		USING clause
		ON clause
	不等值连接
		SELECT e.last_name, e.salary, j.grade_level
		FROM employees e JOIN job_grades j
		ON e.salary
		BETWEEN j.lowest_sal AND j.highest_sal;
自连接
	自然连接基于连个表的所有列有相同的名字
	从两个表选取所有匹配列的相同值
	如果同名列数据类型不匹配就会返回错误
外连接
	LEFT OUTER join
	RIGHT OUTER join
	FULL OUTER join
两个及以上表的笛卡尔乘积
	SELECT last_name, department_name
	FROM employees
	CROSS JOIN departments ;

	
SQL> SELECT l.city, d.department_name
  2  FROM locations l JOIN departments d
  3  USING (location_id)
  4  WHERE d.location_id = 1400;
WHERE d.location_id = 1400
      *
ERROR at line 4:
ORA-25154: column part of USING clause cannot have qualifier


SQL> SELECT l.city, d.department_name
  2  FROM locations l JOIN departments d
  3  USING (location_id)
  4  WHERE location_id = 1400;

CITY                           DEPARTMENT_NAME
------------------------------ ------------------------------
Southlake                      IT