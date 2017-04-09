CURRENT_DATE
	系统当前时间
	是日期类型
CURRENT_TIMESTAMP
	系统当前时间戳
	是timestamp with time zone类型
LOCALTIMESTAMP
	用户会话级别的时间戳
	是timestamp类型
DBTIMEZONE
SESSIONTIMEZONE
EXTRACT
TZ_OFFSET
FROM_TZ
TO_TIMESTAMP
TO_YMINTERVAL
TO_DSINTERVAL

Time Zones 时区
当地时间与英格兰格林威治时间的时差

SQL> select * from v$timezone_names where rownum<5;

TZNAME                                                           TZABBREV
---------------------------------------------------------------- ----------------------------------------------------------------
Africa/Abidjan                                                   LMT
Africa/Abidjan                                                   GMT
Africa/Accra                                                     LMT
Africa/Accra                                                     GMT

会话中修改时区
ALTER SESSION SET TIME_ZONE = '-05:00';--偏移量—tz_offset函数
ALTER SESSION SET TIME_ZONE = dbtimezone;--数据库时区—time_zone参数
ALTER SESSION SET TIME_ZONE = local;--系统本地时区--local
ALTER SESSION SET TIME_ZONE = 'America/New_York';--区域名—v$timezone_names


SQL> col SESSIONTIMEZONE for a30
SQL> ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MON-YYYY HH24:MI:SS';

Session altered.

SQL> ALTER SESSION SET TIME_ZONE = '-5:00';

Session altered.

SQL> SELECT SESSIONTIMEZONE, CURRENT_DATE FROM DUAL;

SESSIONTIMEZONE                CURRENT_DATE
------------------------------ -----------------------------
-05:00                         09-APR-2017 04:51:29

SQL> SELECT SESSIONTIMEZONE, CURRENT_TIMESTAMP FROM DUAL;

SESSIONTIMEZONE                CURRENT_TIMESTAMP
------------------------------ ---------------------------------------------------------------------------
-05:00                         09-APR-17 04.51.29.129342 AM -05:00

SQL> SELECT SESSIONTIMEZONE, LOCALTIMESTAMP FROM DUAL;

SESSIONTIMEZONE                LOCALTIMESTAMP
------------------------------ ---------------------------------------------------------------------------
-05:00                         09-APR-17 04.51.29.148454 AM


SQL> SELECT DBTIMEZONE FROM DUAL;

DBTIME
------
+00:00

SQL> SELECT SESSIONTIMEZONE FROM DUAL;

SESSIONTIMEZONE
------------------------------
-05:00
--Comparing TIMESTAMP Data Types
SQL> CREATE TABLE web_orders (
  2  order_date TIMESTAMP WITH TIME ZONE, 
  3  delivery_time TIMESTAMP WITH LOCAL TIME ZONE
  4  );

Table created.

SQL> INSERT INTO web_orders values (current_date, current_timestamp + 2);

1 row created.

SQL> col ORDER_DATE for a35
SQL> SELECT * FROM web_orders;

ORDER_DATE                          DELIVERY_TIME
----------------------------------- ---------------------------------------------------------------------------
09-APR-17 05.06.59.000000 AM -05:00 11-APR-17 05.06.59.000000 AM

--INTERVAL YEAR TO MONTH
SQL> CREATE TABLE warranty(
  2  prod_id number, 
  3  warranty_time INTERVAL YEAR(3) TO MONTH
  4  );
INSERT INTO warranty VALUES (123, INTERVAL '8' MONTH);
INSERT INTO warranty VALUES (155, INTERVAL '200' YEAR(3));
INSERT INTO warranty VALUES (678, '200-11');
SELECT * FROM warranty;

Table created.

SQL> 
1 row created.

SQL> 
1 row created.

SQL> 
1 row created.

SQL> 
   PROD_ID WARRANTY_TIME
---------- ---------------------------------------------------------------------------
       123 +000-08
       155 +200-00
       678 +200-11
--INTERVAL DAY TO SECOND
SQL> CREATE TABLE lab( 
  2  exp_id number, 
  3  test_time INTERVAL DAY(2) TO SECOND
  4  );
INSERT INTO lab VALUES (100012, '90 00:00:00');
INSERT INTO lab VALUES (56098,INTERVAL '6 03:30:16' DAY TO SECOND);

Table created.

SQL> SELECT * FROM lab;

1 row created.

SQL> 
1 row created.

SQL> 
    EXP_ID TEST_TIME
---------- ---------------------------------------------------------------------------
    100012 +90 00:00:00.000000
     56098 +06 03:30:16.000000
--EXTRACT
SQL> SELECT 
  2  EXTRACT (YEAR FROM SYSDATE),
  3  EXTRACT (month FROM SYSDATE),
  4  EXTRACT (day FROM SYSDATE)
  5  FROM DUAL;

EXTRACT(YEARFROMSYSDATE) EXTRACT(MONTHFROMSYSDATE) EXTRACT(DAYFROMSYSDATE)
------------------------ ------------------------- -----------------------
                    2017                         4                       9
--TZ_OFFSET
SQL> SELECT TZ_OFFSET('US/Eastern'),
  2  TZ_OFFSET('Canada/Yukon'),
  3  TZ_OFFSET('Europe/London'),
     TZ_OFFSET('Asia/Shanghai')
  4  FROM DUAL;

TZ_OFFS TZ_OFFS TZ_OFFS TZ_OFFS
------- ------- ------- -------
-04:00  -07:00  +01:00  +08:00
--US/Pacific-New
SELECT TZ_OFFSET ('US/Pacific-New') from dual;
--Singapore
SELECT TZ_OFFSET ('Singapore') from dual;
--Egypt
SELECT TZ_OFFSET ('Singapore') from dual;
select * from v$timezone_names where tzname like 'Asia%';
SELECT TZ_OFFSET ('Asia/Shanghai') from dual;
SELECT TZ_OFFSET ('Asia/Chongqing') from dual;
SELECT TZ_OFFSET ('Asia/urumqi') from dual;
--FROM_TZ
SQL> SELECT FROM_TZ(TIMESTAMP
  2  '2017-04-09 18:18:00', 'Australia/North')
  3  FROM DUAL;

FROM_TZ(TIMESTAMP'2017-04-0918:18:00','AUSTRALIA/NORTH')
---------------------------------------------------------------------------
09-APR-17 06.18.00.000000000 PM AUSTRALIA/NORTH
--TO_TIMESTAMP
SQL> SELECT TO_TIMESTAMP ('2007-03-06 11:00:00', 'YYYY-MM-DD HH:MI:SS') FROM DUAL;

TO_TIMESTAMP('2007-03-0611:00:00','YYYY-MM-DDHH:MI:SS')
---------------------------------------------------------------------------
06-MAR-07 11.00.00.000000000 AM
--TO_YMINTERVAL  
SQL> SELECT hire_date,
  2  hire_date + TO_YMINTERVAL('01-02') AS HIRE_DATE_YMININTERVAL FROM employees WHERE department_id = 20;

HIRE_DATE                     HIRE_DATE_YMININTERVAL
----------------------------- -----------------------------
17-FEB-2004 00:00:00          17-APR-2005 00:00:00
17-AUG-2005 00:00:00          17-OCT-2006 00:00:00
--TO_DSINTERVAL
SQL> SELECT last_name,
  2  TO_CHAR(hire_date, 'mm-dd-yy:hh:mi:ss') hire_date,
  3  TO_CHAR(hire_date +TO_DSINTERVAL('100 10:00:00'),'mm-dd-yy:hh:mi:ss') hiredate2
  4  FROM employees;

LAST_NAME                 HIRE_DATE         HIREDATE2
------------------------- ----------------- -----------------
OConnell                  06-21-07:12:00:00 09-29-07:10:00:00
Grant                     01-13-08:12:00:00 04-22-08:10:00:00
Whalen                    09-17-03:12:00:00 12-26-03:10:00:00
Hartstein                 02-17-04:12:00:00 05-27-04:10:00:00
Fay                       08-17-05:12:00:00 11-25-05:10:00:00
Mavris                    06-07-02:12:00:00 09-15-02:10:00:00
Baer                      06-07-02:12:00:00 09-15-02:10:00:00
Higgins                   06-07-02:12:00:00 09-15-02:10:00:00
Gietz                     06-07-02:12:00:00 09-15-02:10:00:00
King                      06-17-03:12:00:00 09-25-03:10:00:00
Kochhar                   09-21-05:12:00:00 12-30-05:10:00:00
SQL> SELECT e.last_name, hire_date, sysdate,
  2  (CASE
  3  WHEN (sysdate -TO_YMINTERVAL('15-0'))>=
  4  hire_date THEN '15 years of service'
  5  WHEN (sysdate -TO_YMINTERVAL('10-0'))>= hire_date
  6  THEN '10 years of service'
  7  WHEN (sysdate - TO_YMINTERVAL('5-0'))>= hire_date
  8  THEN '5 years of service'
  9  ELSE 'maybe next year!'
 10  END) AS "Awards"
 11  FROM employees e order by 4;

LAST_NAME                 HIRE_DATE                     SYSDATE                       Awards
------------------------- ----------------------------- ----------------------------- -------------------
Whalen                    17-SEP-2003 00:00:00          09-APR-2017 18:34:02          10 years of service
Hartstein                 17-FEB-2004 00:00:00          09-APR-2017 18:34:02          10 years of service
Fay                       17-AUG-2005 00:00:00          09-APR-2017 18:34:02          10 years of service
Mavris                    07-JUN-2002 00:00:00          09-APR-2017 18:34:02          10 years of service
Baer                      07-JUN-2002 00:00:00          09-APR-2017 18:34:02          10 years of service
Higgins                   07-JUN-2002 00:00:00          09-APR-2017 18:34:02          10 years of service
Gietz                     07-JUN-2002 00:00:00          09-APR-2017 18:34:02          10 years of service
King                      17-JUN-2003 00:00:00          09-APR-2017 18:34:02          10 years of service
Kochhar                   21-SEP-2005 00:00:00          09-APR-2017 18:34:02          10 years of service
Hunold                    03-JAN-2006 00:00:00          09-APR-2017 18:34:02          10 years of service
Austin                    25-JUN-2005 00:00:00          09-APR-2017 18:34:02          10 years of service


Daylight Saving Time
First Sunday in April
	Time jumps from 01:59:59 AM to 03:00:00 AM.
	Values from 02:00:00 AM to 02:59:59 AM are not valid.
Last Sunday in October
	Time jumps from 02:00:00 AM to 01:00:01 AM.
	Values from 01:00:01 AM to 02:00:00 AM are ambiguous because they are visited twice.