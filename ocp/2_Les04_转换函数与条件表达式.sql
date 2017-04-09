数据类型转换
	隐式数据转换
	显式数据转换
		TO_CHAR 
		TO_DATE　
			to_date函数里可用fx选项精确匹配之后的字符或日期是否忽略多个空格还是只能有1个空格
		TO_NUMBER 
嵌套函数
	单行函数可嵌套多层
空值函数
	NVL (expr1, expr2) 
		如果expr1为空则返回expr2否则返回expr1
		数据类型必须匹配
	NVL2 (expr1, expr2, expr3) 如果expr1不为空返回expr2，为空返回expr3
	NULLIF (expr1, expr2) 如果相同返回空否则返回expr1
	COALESCE (expr1, expr2, ..., exprn)
条件表达式
	CASE
		CASE expr WHEN comparison_expr1 THEN return_expr1
			[WHEN comparison_expr2 THEN return_expr2
			WHEN comparison_exprn THEN return_exprn
			ELSE else_expr]
		END
	DECODE
		DECODE(col|expression, search1, result1
		[, search2, result2,...,]
		[, default])


SQL> select to_char(sysdate,'YYYY'), --数字形式的年份，４位数
  2  to_char(sysdate,'year'),　--年份的全拼写格式
  3  to_char(sysdate,'mm'), --数字形式的月份，２位数
  4  to_char(sysdate,'month'),--月份全拼写格式
  5  to_char(sysdate,'mon'),--月份三位缩写格式
  6  to_char(sysdate,'dy'),--星期的３位缩写格式
  7  to_char(sysdate,'day'),--星期的全拼写格式
  8  to_char(sysdate,'dd')--数字形式日期，２位数字
  9  from dual;

TO_C TO_CHAR(SYSDATE,'YEAR')                    TO TO_CHAR(SYSDATE,'MONTH')             TO_CHAR(SYSD TO_CHAR(SYSD TO_CHAR(SYSDATE,'DAY')           TO
---- ------------------------------------------ -- ------------------------------------ ------------ ------------ ------------------------------------ --
2017 twenty seventeen                           04 april                                apr          sat          saturday       08
SQL> select 
  2  to_char(sysdate,'HH24:MI:SS AM'),--时间元素
  3  to_char(sysdate,'DD "of" MONTH'),--加入的字符串用双引号引起来
  4  to_char(sysdate,'ddspth') --序数
  5  from dual;

TO_CHAR(SYS TO_CHAR(SYSDATE,'DD"OF"MONTH')             TO_CHAR(SYSDAT
----------- ------------------------------------------ --------------
16:41:13 PM 08 of APRIL                                eighth

SQL> SELECT last_name,
  2  TO_CHAR(hire_date, 'fmDD Month YYYY'), --fm 能去除填充的空格或前置的零
	 TO_CHAR(hire_date, 'DD Month YYYY') AS HIREDATE
  4  FROM employees where rownum<5;

LAST_NAME                 TO_CHAR(HIRE_DATE,'FMDDMONTHYYYY')           HIREDATE
------------------------- -------------------------------------------- --------------------------------------------
OConnell                  21 June 2007                                 21 June      2007
Grant                     13 January 2008                              13 January   2008
Whalen                    17 September 2003                            17 September 2003
Hartstein                 17 February 2004                             17 February  2004

TO_CHAR(number, 'format_model')
9 代表一个数字
0 显示０
$ 使用$符号
L 使用本地货币符号
. 小数点
, 千分位分隔符
SQL> SELECT TO_CHAR(salary, '$99,999.00') SALARY
  2  FROM employees
  3  WHERE last_name = 'Ernst';

SALARY
-----------
  $6,000.00
SQL> SELECT TO_CHAR(987022.559, '$99,999.00') FROM dual; --整数部分不能超

TO_CHAR(987
-----------
###########

SQL> SELECT TO_CHAR(87022.559, '$99,999.00') FROM dual;

TO_CHAR(870
-----------
 $87,022.56
SQL> SELECT TO_CHAR(87022.2, '$99,999.00') FROM dual;

TO_CHAR(870
-----------
 $87,022.20
  
--单行函数可嵌套多层
--嵌套函数的计算过程是从最内层向最外层运算
SQL> SELECT last_name,
  2  UPPER(CONCAT(SUBSTR (LAST_NAME, 1, 8), '_US'))
  3  FROM employees
  4  WHERE department_id = 60;

LAST_NAME                 UPPER(CONCAT(SUBSTR(LAST_NAME,1,8),
------------------------- -----------------------------------
Hunold                    HUNOLD_US
Ernst                     ERNST_US
Austin                    AUSTIN_US
Pataballa                 PATABALL_US
Lorentz                   LORENTZ_US
SQL> SELECT TO_CHAR(ROUND((salary/7), 2),'99G999D99',
  2  'NLS_NUMERIC_CHARACTERS = '',.'' ')
  3  "Formatted Salary"
  4  FROM employees;

Formatted
----------
    371,43
    371,43
    628,57
  1.857,14
    857,14
    928,57
	
SQL> SELECT last_name || ' earns '
  2  || TO_CHAR(salary, 'fm$99,999.00')
  3  || ' monthly but wants '
  4  || TO_CHAR(salary * 3, 'fm$99,999.00')
  5  || '.' "Dream Salaries"
  6  FROM employees;

Dream Salaries
--------------------------------------------------------------------------
OConnell earns $2,600.00 monthly but wants $7,800.00.
Grant earns $2,600.00 monthly but wants $7,800.00.
Whalen earns $4,400.00 monthly but wants $13,200.00.
Hartstein earns $13,000.00 monthly but wants $39,000.00.
Fay earns $6,000.00 monthly but wants $18,000.00.
Mavris earns $6,500.00 monthly but wants $19,500.00.
Baer earns $10,000.00 monthly but wants $30,000.00.
SQL> SELECT last_name || ' earns '
  2  || TO_CHAR(salary, '$99,999.00')
  3  || ' monthly but wants '
  4  || TO_CHAR(salary * 3, '$99,999.00')
  5  || '.' "Dream Salaries"
  6  FROM employees;

Dream Salaries
--------------------------------------------------------------------------
OConnell earns   $2,600.00 monthly but wants   $7,800.00.
Grant earns   $2,600.00 monthly but wants   $7,800.00.
Whalen earns   $4,400.00 monthly but wants  $13,200.00.
Hartstein earns  $13,000.00 monthly but wants  $39,000.00.
Fay earns   $6,000.00 monthly but wants  $18,000.00.