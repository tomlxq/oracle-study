单行函数 每行返回一个结果
	大小写类
		LOWER
		UPPER
		INITCAP
	字符处理类
		CONCAT
		SUBSTR
		LENGTH
		INSTR
		LPAD | RPAD
		TRIM
		REPLACE
	数字函数
		ROUND: 按照指定的小数位四舍五入
		TRUNC: 按照指定的小数位截断数据
		MOD: 两数相除，返回余数
	日期
		Oracle数据库存储日期格式：世纪,年,月,日,时,分,秒
		默认显示: DD-MON-RR
	日期处理函数
		NEXT_DAY	月最后一天
		LAST_DAY 	指定日期下一天
		ROUND 日期舍入
		TRUNC 日期截取
		MONTHS_BETWEEN 两日期间有多少个月
		ADD_MONTHS 指定日期增加月数
SQL> select 
  2  REPLACE ('JACK and JUE','J','BL'),
  3  LENGTH('HelloWorld'),
  4  INSTR('HelloWorld', 'W'),
  5  LPAD(5000,10,'*'),
  6  RPAD(5000, 10, '*'),
  7  CONCAT('Hello', 'World'),
  8  TRIM('H' FROM 'HelloWorld'),
  9  SUBSTR('HelloWorld',1,5)
 10  from dual;

REPLACE('JACKA LENGTH('HELLOWORLD') INSTR('HELLOWORLD','W') LPAD(5000, RPAD(5000, CONCAT('HE TRIM('H'F SUBST
-------------- -------------------- ----------------------- ---------- ---------- ---------- --------- -----
BLACK and BLUE                   10                       6 ******5000 5000****** HelloWorld elloWorld Hello

SQL> select MOD(1600, 300),ROUND(45.926, 2),TRUNC(45.926, 2) from dual;

MOD(1600,300) ROUND(45.926,2) TRUNC(45.926,2)
------------- --------------- ---------------
          100           45.93           45.92

SQL> drop table t;
create table t(d date);
insert into t values('27-OCT-95');
insert into t values('27-OCT-17');
insert into t values('27-OCT-17');
insert into t values('27-OCT-95');
select to_char(d,'yyyy'),d,to_char(d,'rr'),to_char(d,'yy') from t;

Table dropped.

SQL> 
Table created.

SQL> 
1 row created.

SQL> 
1 row created.

SQL> 
1 row created.

SQL> 
1 row created.

SQL> 
TO_C D                  TO TO
---- ------------------ -- --
1995 27-oct-95          95 95
2017 27-oct-17          17 17
2017 27-oct-17          17 17
1995 27-oct-95          95 95

SQL> select 
  2  MONTHS_BETWEEN('01-SEP-95','11-JAN-94'),
  3  ADD_MONTHS ('31-JAN-96',1),
  4  NEXT_DAY ('01-SEP-95','FRIDAY'),
  5  LAST_DAY ('01-FEB-95')
  6  from dual;

MONTHS_BETWEEN('01-SEP-95','11-JAN-94') ADD_MONTHS('31-JAN NEXT_DAY('01-SEP-9 LAST_DAY('01-FEB-9
--------------------------------------- ------------------ ------------------ ------------------
                             19.6774194 29-feb-96          08-sep-95          28-feb-95

							 
多行函数 每个行组集返回一个结果


