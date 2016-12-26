/*
基本概念

数据库对象
表　table
约束 contraint
视图　view
索引 index
同义词 synonym
存储过程　procedure
函数　function
包 package
触发器 trigger

数据库安全
用户 user
方案 schema
权限 privilege
角色 role
配额　quota

数据库文件与存储
数据文件 datafile
表空间 tablespace
控件文件　control file
重做日志文件 redo log
初始化参数文件　pfile sfile

数据库网络访问
数据库名　db_name
实例名　instance_name
服务名 service_name
连接字符串　ip:port/tnsname　或　ip:(description...)
服务命名　tnsname
监听器 listener

DBA守则　
备份重于一切
三思而后行 think before you act!  想清楚再做
rm是危险的
你来制定规范
*/
--dbc数据库配置助手
sqlplus sys/orcl@orcl as sysdba
shutdown immediate
conn sys/orcl as sysdba
startup 

show parameter sga
show parameter pga

--创建表空间
create tablespace test datafile 'F:\test.dbf' size 20m;
--表空间命名
alter tablespace test rename to test1；
--查看表空间
select * from v$datafile;
--创建表
create table student(id number, name varchar2(20)) tablespace test_data;
--查看表是不是创建成功
select table_name,tablespace_name from user_tables where lower(table_name)='student';
--增加列
alter table student add(age number);
--查看表结构
desc student;
--删除表及相关的约束(有时由于某些约束存在，无法删除表，例如当前表的主键被其它表用作外键，会导致表无法成功删除，利用cascade constraints选项可以同时将约束删除)
drop table student cascade constraints;
--特殊表
select * from dual;--其它用户使用同义词
select * from sys.dual;
--配置监听器net manager,启动监听器
--F:\server\Oracle\product\11.2.0\dbhome_1\NETWORK\ADMIN\listener.ora
lsnrctl start listener orcl;
--查看服务
--F:\server\Oracle\product\11.2.0\dbhome_1\NETWORK\ADMIN\tnsnames.ora
--根据列名查表名
desc user_tab_cols;

--普通查询
SELECT  emp.first_name FROM hr.employees emp;
--指定过滤条件
SELECT emp.first_name,
       emp.salary,
       ROUND((trunc(SYSDATE) - TRUNC(emp.hire_date)) / 365) AS 雇佣年限
  FROM hr.employees emp
 WHERE ROUND((trunc(SYSDATE) - TRUNC(emp.hire_date)) / 365) > 10;
--唯一性查询distinct,只针对结果集的列作过滤
SELECT DISTINCT emp.first_name,emp.last_name,dept.department_name FROM hr.departments dept,hr.employees emp WHERE dept.department_id=emp.department_id;
--group by分组子句
SELECT emp.department_id,round(AVG(emp.salary),2) avg_salary FROM hr.employees emp GROUP BY emp.department_id;
--过滤子句having
SELECT dept.department_name AS 部门名称, SUM(emp.salary) AS 总工资
  FROM hr.employees emp
  JOIN hr.departments dept
    ON emp.department_id = dept.department_id
 GROUP BY dept.department_name
HAVING SUM(emp.salary) > 100000;
--排序order by，asc升序，desc降序,针对最终的结果集进行排序
SELECT c.country_name FROM hr.countries c ORDER BY c.country_name ASC;
--order by与group by同时存在时，oracle将先group by,然后再order by
--order by与distinct同时使用时，出现在order by的列，必须出现在select的表达式中
SELECT DISTINCT emp.first_name FROM hr.employees emp ORDER BY emp.first_name,emp.last_name;--错误语句

/*
子查询是指在查询语句中内部嵌入查询，以获得临进的结果集
如果子查询中的数据源与父查询中的数据库可以进行连结操作，oracle首先转化为连结，再进行查询，否则先进行子查询，再进行父查询
*/
--查询条件中的子查询
SELECT *
  FROM hr.employees emp
 WHERE emp.department_id IN
       (SELECT dept.department_id FROM hr.departments dept);
--建表语句中的子查询
CREATE TABLE temp_user_obj AS SELECT * FROM User_Objects WHERE 1<>1;     --user_objects描述当前用户所有的对象信息　1<>1表明查询条件永远为假，搜出来的结果为空，只创建相同的表结构 
SELECT * FROM temp_user_obj;
--插入语句中的子查询，相当于批量插入
TRUNCATE TABLE temp_user_obj;
INSERT INTO temp_user_obj SELECT * FROM User_Objects uo WHERE uo.object_type='TABLE' AND ROWNUM<10;

/*
联合查询，对多个查询结果集进行集合操作, union,union all, intersect,minus
*/
--union对两个结果集合并并去重
CREATE TABLE stu1(ID NUMBER,NAME VARCHAR2(30));
CREATE TABLE stu2 AS SELECT * FROM stu1 WHERE 1<>1;
INSERT INTO stu1 SELECT 1,'罗小强' FROM dual UNION SELECT 2,'马云' FROM dual UNION SELECT 3,'刘强东'　FROM dual;
INSERT INTO stu2 SELECT 4,'柳传志' FROM dual UNION SELECT 2,'马云' FROM dual UNION SELECT 3,'刘强东'　FROM dual;

SELECT * FROM stu1 UNION SELECT * FROM stu2;
--union all将两个结果集合并，不去重
SELECT * FROM stu1 UNION ALL SELECT * FROM stu2;
--insertsect求交集，将两个结果集中都存在的记录筛选出来
SELECT * FROM stu1 INTERSECT SELECT * FROM stu2;
--minus差集，在第一个结果集中存在，在第二个集果中不存在的记录筛选出来
SELECT * FROM stu1 MINUS SELECT * FROM stu2;

/*
连接，在大多数情况下，所用的数据源往往有多个，连接即用来指定多个数据源之间的组合关系，
默认的情况下多个数据源之间使用的是笛卡尔积的方式，但还有其它特殊方式，这些特殊方式弥补了笛卡积的不足。
内连接所指定的两个数据源，处于平等的地位，而外连接不同，
外连接总是以一个数据源为基础，将另外一个数据源与与进行条件匹配，即使条件不匹配，基础数据源中的数据总是出现在结果集中。
*/
--自然连接natural join，顾名思义，即无需用户指定任何条件，只需指定的连接的两个数据源。强制使用两个表的公共列作为搜寻条件，而且要求公共列的值必须相等。
SELECT * FROM hr.employees NATURAL JOIN hr.departments;
--内连接inner join突破了自然连接的限制，可以连接列和连接条件
SELECT emp.first_name,emp.last_name,dept.department_name FROM hr.employees emp INNER JOIN hr.departments dept ON emp.department_id=dept.department_id;
--外连接，左外连接，右外连接，全连接
DROP TABLE stu;
CREATE TABLE stu(ID NUMBER,NAME VARCHAR2(30),school_id NUMBER);
INSERT INTO stu SELECT 1,'张三'，1 FROM dual UNION SELECT 2,'李四'，2 FROM dual UNION SELECT 3,'王二麻子'，3 FROM dual UNION SELECT 4,'流川枫'，5 FROM dual;
DROP TABLE school;
CREATE TABLE school(school_id NUMBER,NAME VARCHAR2(30));
INSERT INTO school SELECT 1,'清华' FROM dual UNION SELECT 2,'北大' FROM dual UNION SELECT 3,'南开' FROM dual UNION SELECT 4,'浙大' FROM dual UNION SELECT 6,'川大' FROM dual;
SELECT * FROM stu;
SELECT * FROM school;

SELECT * FROM stu st LEFT OUTER JOIN school sc ON st.school_id=sc.school_id;--左连接，以左边的记录全部要出现，不管右边的能不能匹配上
SELECT * FROM stu st RIGHT OUTER JOIN school sc ON st.school_id=sc.school_id;--右连接，以右边的记录全部要出现，不管左边的能不能匹配上
SELECT * FROM stu st FULL OUTER JOIN school sc ON st.school_id=sc.school_id;
--简略写法
SELECT * FROM stu st , school sc WHERE st.school_id=sc.school_id(+);
SELECT * FROM stu st , school sc WHERE st.school_id(+)=sc.school_id;

/*
层次化查询
关系性数据库中，同一个数据表中的记录具有相同的列，因此，不同的记录之间存在着平行关系。
但是，有时候，各记录之间也可能存着父子关系，当这些父子关系较为复杂时，我们可以将整个表中的数据看做树状结构，而基于树状结构数据的查询，称为层次化查询
*/
CREATE TABLE market(ID NUMBER,NAME VARCHAR2(30),parent_id NUMBER);
INSERT INTO market 
SELECT 1,'全球',0 FROM dual UNION 
SELECT 2,'亚洲',1 FROM dual UNION 
SELECT 3,'非洲',1 FROM dual UNION 
SELECT 4,'拉丁美洲',1 FROM dual UNION 
SELECT 5,'欧洲',1 FROM dual UNION
SELECT 6,'美洲',1 FROM dual UNION 
SELECT 7,'中国',2 FROM dual UNION 
SELECT 8,'韩国',2 FROM dual UNION 
SELECT 9,'朝鲜',2 FROM dual UNION 
SELECT 10,'天津',7 FROM dual UNION 
SELECT 11,'沈阳',7 FROM dual UNION 
SELECT 12,'深圳',7 FROM dual;
SELECT ID,lpad(' ',2*(level-1))||NAME AS NAME,parent_id,LEVEL FROM market START WITH NAME='亚洲' CONNECT BY PRIOR ID=parent_id ORDER BY LEVEL;--prior放的左右位置决定自顶向下查找叶子块
SELECT ID,lpad(' ',2*(level-1))||NAME AS NAME,parent_id,LEVEL FROM market START WITH NAME='天津' CONNECT BY id= PRIOR parent_id ORDER BY LEVEL;--prior放的左右位置决定自底往上查找根结点
/*层次化查询的相关函数
sys_connect_by_path()函数，层次化查询总是以某条记录为起点，根据connect by所指定的条件递归获得结果集合，而此函数可以对起如到当前之记录之间的结果集进行聚合操作。
*/
SELECT ID,sys_connect_by_path(NAME,'/') AS NAME,parent_id,LEVEL FROM market START WITH NAME='亚洲' CONNECT BY PRIOR ID=parent_id ORDER BY LEVEL;

--小技巧: COPY列名，通过Objects->TABLES->表名，展开，右键->Columns->copy comma separated
--手动修改记录
SELECT * FROM stu FOR UPDATE;--FOR UPDATE锁定数据并修改

/*
Oracle数据类型:
字符型 character:　
  固定长度 char(n)　n最大为2000,不足用空格填充　
  可变长度字符串类型 varchar(n) n最大为4000 
  oracle在工业标准之外，自定义类型，可以获得oracle向后兼容性的保证 varchar2(n) n最大为4000 
数值型 number 
    number[(precision,[scale])]  1<=precision<=38 -84<=scale<=127
日期型 date 
    date,timestamp
大对象型 lob 
*/
CREATE TABLE test_char(NAME CHAR(2001));
CREATE TABLE test_varchar(NAME VARCHAR(4001));
CREATE TABLE test_varchar2(NAME VARCHAR2(4001));

CREATE TABLE test_c(f_char CHAR(2000),f_varchar VARCHAR(4000),f_varchar2 VARCHAR2(4000));
INSERT INTO test_c VALUES('000','000','000');
SELECT LENGTH(f_char),LENGTH(f_varchar),LENGTH(f_varchar2) FROM test_c;
--字符串函数
SELECT LPAD('1',4,'*'),RPAD('1',4,'*') FROM dual;
SELECT LPAD(' ',4,'*')||'luo' FROM dual UNION ALL SELECT RPAD(' ',4,'*')||'luo' FROM dual;
SELECT UPPER('LuoXiaoQiang'),LOWER('LuoXiaoQiang'),initcap('hello, world') FROM dual;
SELECT SUBSTR('hello, world',1,5),SUBSTR('hello, world',2,5) FROM dual;
SELECT INSTR('hello, world','hello'),INSTR('hello, world','world'),INSTR('hello, world,world...','world',1,2) FROM dual;
SELECT LTRIM('  lxq'),RTRIM('lxq   '),TRIM('   lxq ') FROM dual;
SELECT CONCAT('hello',', oracle'), 'hello'||', oracle' FROM dual;
--translate第一个字符串每个字符在第二字符串中的位置，在第三个字符串中找到并替换
SELECT TRANSLATE('hello','+h-*e&^l%$o#@!','abcdefghijklmnopqrstuvwxyz') FROM dual;
--空值往往也返回空值
SELECT LENGTH(''),LENGTH(NULL) FROM dual;


CREATE TABLE test_num(num1 NUMBER(5,2),num2 NUMBER(2,5),num3 NUMBER(5,-2));
INSERT INTO test_num(num1) VALUES(12345);--插入失败,超过它所能表示的位数
INSERT INTO test_num(num1) VALUES(123);
INSERT INTO test_num(num2) VALUES(0.000123);
INSERT INTO test_num(num3) VALUES(12345);
SELECT * FROM test_num;
SELECT ABS(-123.0099),ABS(8.99) FROM dual;
SELECT ROUND(-123.0099),ROUND(8.99),ROUND(-123.0099,2),ROUND(8.981235,3) FROM dual;
SELECT CEIL(-123.0099),CEIL(8.99) FROM dual;
SELECT FLOOR(-123.0099),FLOOR(8.99) FROM dual;
SELECT MOD(-123.0099,2),MOD(8.99,2) FROM dual;
SELECT SIGN(-123.0099),SIGN(8.99) FROM dual;--判断数字的正负
SELECT SQRT(4),POWER(4,3) FROM dual;
SELECT TRUNC(3.789,2),ROUND(3.789,2),SYSDATE,TRUNC(SYSDATE),TRUNC(SYSDATE)-1 FROM dual;
--将ascii转化为字符
SELECT CHR(65),'ddd'||CHR(13)||'eee','ddd'||CHR(10)||'eee',CHR(14) FROM dual;
SELECT to_char('0.98','9.99'),to_char('0.98','0.00') FROM dual;
SELECT to_char(68,'xxx') FROM dual;

--日期
SELECT SYSDATE,
       add_months(SYSDATE, 1),
       add_months(SYSDATE, -1),
       add_months(to_date('2016-12-30', 'yyyy-mm-dd'), -1)
  FROM dual;
--特定日期所在月的最后一天  
SELECT last_day(SYSDATE),
       last_day(to_date('2016-12-30', 'yyyy-mm-dd'))
  FROM dual;
--返回两个日期所差的月数  
SELECT months_between(SYSDATE, to_date('2016-5-30', 'yyyy-mm-dd')),
       months_between(to_date('2016-5-30', 'yyyy-mm-dd'), SYSDATE)
  FROM dual;
--返回特定日期之后的日期
/*西方国家以星期天标识为1,周一标识为2....周六标识为7
Sunday                                     1            
Monday                                     2    
Tuesday                                    3
Wednesday                                  4
Thirsday                                   5
Firday                                     6     
Saturday                                   7                    
*/
SELECT next_day(SYSDATE,1),next_day(SYSDATE,2),next_day(SYSDATE,3) FROM dual;

SELECT TRUNC(SYSDATE, 'MI'),
       TRUNC(SYSDATE, 'HH'),
       TRUNC(SYSDATE),
       TRUNC(SYSDATE, 'DD'),
       TRUNC(SYSDATE, 'MM'),
       TRUNC(SYSDATE, 'YYYY')
  FROM dual;
--返回当前会话时区的当前日期
SELECT SESSIONTIMEZONE,
       to_char(current_date, 'yyyy-mm-dd hh:mi:ss'),
       to_char(current_date, 'yyyy-mm-dd hh24:mi:ss')
  FROM dual;
--返回当前会话时区的当前时间戳
SELECT SESSIONTIMEZONE,current_timestamp FROM dual;
--extract返回日期的某个域
SELECT EXTRACT(YEAR FROM SYSDATE),
       EXTRACT(MONTH FROM SYSDATE),
       EXTRACT(DAY FROM SYSDATE)
  FROM dual;
--创建满足个性化的抽取时分秒的函数
CREATE OR REPLACE FUNCTION get_field(p_date DATE, p_formate VARCHAR2)
  RETURN VARCHAR2 IS
  v_result  VARCHAR2(10);
  tmp_var   VARCHAR2(40);
  v_formate VARCHAR2(10);
BEGIN
  v_result  := '';
  tmp_var   := to_char(p_date, 'yyyy-mm-dd hh24:mi:ss');
  v_formate := LOWER(p_formate);
  IF v_formate = 'year' THEN
    v_result := SUBSTR(tmp_var, 1, 4);
  END IF;
  IF v_formate = 'month' THEN
    v_result := SUBSTR(tmp_var, 6, 2);
  END IF;
  IF v_formate = 'day' THEN
    v_result := SUBSTR(tmp_var, 9, 2);
  END IF;
  IF v_formate = 'hour' THEN
    v_result := SUBSTR(tmp_var, 12, 2);
  END IF;
  IF v_formate = 'minute' THEN
    v_result := SUBSTR(tmp_var, 15, 2);
  END IF;
  IF v_formate = 'second' THEN
    v_result := SUBSTR(tmp_var, 18, 2);
  END IF;
  RETURN v_result;
END;
/

SELECT get_field(SYSDATE, 'YEAR'), 
get_field(SYSDATE, 'MONTH'), 
get_field(SYSDATE, 'DAY'), 
get_field(SYSDATE, 'HOUR'), 
get_field(SYSDATE, 'MINUTE'), 
get_field(SYSDATE, 'SECOND')
FROM dual;



--聚合函数
SELECT MAX(emp.salary), MIN(emp.salary), AVG(emp.salary), SUM(emp.salary)
  FROM hr.employees emp;
--统计函数
SELECT COUNT(*), COUNT(emp.employee_id), COUNT(1) FROM hr.employees emp
--多值判断decode()
SELECT emp.first_name||' '||emp.last_name AS 姓名,
       ROUND(months_between(SYSDATE, emp.hire_date) / 12) AS 工作年限,
       decode(sign(months_between(SYSDATE, emp.hire_date) / 12 - 15),
              1,
              '项目经理',
              decode(sign(months_between(SYSDATE, emp.hire_date) / 12 - 10),
                     1,
                     '高级工程师',
                     '一般程序员')) AS 级别
  FROM hr.employees emp;
--为空值重新赋值nvl()
SELECT st.name, NVL(sc.name, '待定') AS 学校
  FROM stu st
  LEFT JOIN school sc
    ON st.school_id = sc.school_id;
--结果集的行号rownum 主要用于分页如当前页为2,每页显示10条记录，显示范围为11~20
--rownum是在排序order by之前就己经决定其值
SELECT *
  FROM (SELECT t.*, ROWNUM rn
          FROM (SELECT * FROM hr.employees) t
         WHERE ROWNUM < 10 * 2 + 1)
 WHERE rn > 10 * (2 - 1);
--强制转化数据类型cast()
--CAST()函数可以进行数据类型的转换。
--CAST()函数的参数有两部分，源值和目标数据类型，中间用AS关键字分隔。
create table cast_salary AS 
select cast(empno as varchar2(100)) empno,
cast(sal as varchar2(100)) sal, 
cast(job as varchar2(100)) job,
cast(comm as varchar2(100)) comm, 
ename 
from scott.emp;

--oracle数字运算+-*/
--oracle逻辑运算> >= < <= = <> != not and or
--按位运算 按位与　按位或 按位异或 bitand()
SELECT BITAND(7,5) FROM dual;--按位与
SELECT 7+5-BITAND(7,5) FROM dual; --按位或
SELECT 7+5-BITAND(7,5)－BITAND(7,5) FROM dual; --按位异或
/*
7=111 
5=101
---------
 =101 对应位都为1才为1，否则为0
 
7=111 
5=101
---------
 =111 对应位有任何位为1，否则为0
 
7=111 
5=101
---------
 =010 对应位相同为1，否则为0 
*/

/*
oracle中的特殊判式
between范围测试
in集合成员测试
like模糊匹配 
 %匹配任意字符
 _匹配单个字符
 原义字符
is null空值判断
exists存在性判断
all,some,any数量判式
*/
--oracle中的特殊判式-between范围测试
SELECT * FROM hr.employees emp WHERE emp.salary BETWEEN 10000 AND 20000;
--oracle中的特殊判式-in集合成员测试
SELECT * FROM hr.employees emp WHERE emp.department_id IN (SELECT department_id FROM hr.departments);
--oracle中的特殊判式-like模糊匹配 
SELECT *
  FROM (SELECT 'hello,world,we live on earth' AS str, 'jack' AS NAME
          FROM dual
        UNION ALL
        SELECT 'star,star,twitle star' AS str, 'wangyao' AS NAME
          FROM dual
        UNION ALL
        SELECT 'World is our world' AS str, 'tinghai' AS NAME
          FROM dual
        UNION ALL
        SELECT 'coffee,sunsum,japean' AS str, 'lintao' AS NAME
          FROM dual) t
 WHERE t.str LIKE '%world%';

SELECT *
  FROM (SELECT 'hello,world,we live on earth' AS str, 'jack' AS NAME
          FROM dual
        UNION ALL
        SELECT 'star,star,twitle star' AS str, 'wangyao' AS NAME
          FROM dual
        UNION ALL
        SELECT 'World is our world' AS str, 'tinghai' AS NAME
          FROM dual
        UNION ALL
        SELECT 'coffee,sunsum,japean' AS str, 'lintao' AS NAME
          FROM dual) t
 WHERE t.str LIKE '_tar%';

SELECT *
  FROM (SELECT 'hello,world,we live on earth' AS str, 'jack' AS NAME
          FROM dual
        UNION ALL
        SELECT 'star,star,twitle star' AS str, 'wangyao' AS NAME
          FROM dual
        UNION ALL
        SELECT 'World is our world' AS str, 'tinghai' AS NAME
          FROM dual
        UNION ALL
        SELECT 'coffee,sunsum,japean' AS str, 'lintao' AS NAME
          FROM dual) t
 WHERE t.NAME LIKE 'lintao';
--模糊查询，特殊字符的转义
 SELECT *
  FROM (SELECT 'hello,world,we live on earth' AS str, 'jack' AS NAME
          FROM dual
        UNION ALL
        SELECT 'star,star,twitle star' AS str, 'wangyao' AS NAME
          FROM dual
        UNION ALL
        SELECT 'World is our %world%' AS str, 'tinghai' AS NAME
          FROM dual
        UNION ALL
        SELECT 'coffee,sunsum,_japean' AS str, 'lintao' AS NAME
          FROM dual) t
 WHERE t.str LIKE '%%%world%%%' OR t.str LIKE '%__japean%';
--oracle中的特殊判式-is null空值判断 
SELECT * FROM stu st,school sc WHERE st.school_id=sc.school_id(+) AND sc.name IS NOT NULL;
SELECT * FROM stu st,school sc WHERE st.school_id=sc.school_id(+) AND sc.name IS  NULL;
--oracle中的特殊判式-exists存在性判断
SELECT * FROM stu st WHERE EXISTS (SELECT NULL FROM school sc WHERE sc.school_id=st.school_id);
SELECT * FROM stu st WHERE NOT EXISTS (SELECT NULL FROM school sc WHERE sc.school_id=st.school_id);
--ANY数量判式
SELECT * FROM stu st WHERE st.school_id IN (SELECT sc.school_id FROM school sc);  
SELECT * FROM stu st WHERE st.school_id =ANY(SELECT sc.school_id FROM school sc);
--ALL数量判式
SELECT * FROM hr.employees emp WHERE emp.salary>(SELECT MAX(salary) FROM hr.employees WHERE department_id='60');
SELECT * FROM hr.employees emp WHERE emp.salary> ALL (SELECT salary FROM hr.employees WHERE department_id='60');
--some表示任何一个或没有
SELECT * FROM stu st WHERE st.school_id=SOME(SELECT sc.school_id FROM school sc);

/*
窗口函数为每条记录打开一个窗口，实际每个窗口是一个集合。针对这些集合作一些操作就要用到分析函数。
所以窗口函数和分析函数总是成对出现。
其中分析函数：
       聚合函数 max(),min(),sum(),avg()
       排名函数 rank() 具有跳跃性,dense_rank() 不具有跳跃性,row_number() 直接返回行号,排名函数对应的窗口函数必须指定排序规则order by子句
over 指定窗口，这里通过order by来指定排序,具有相同order by规则的，匀属同一窗口，窗口是指从第一条记录到最后一条记录
*/
--排名函数rank(),具有跳跃性,排名序号不连续
SELECT emp.first_name,
       emp.salary,
       rank() OVER(ORDER BY emp.salary) position  --排名标准为工资
  FROM hr.employees emp;
--排名函数 dense_rank(),不具有跳跃性,排名序号连续
SELECT emp.first_name,
       emp.salary,
       dense_rank() OVER(ORDER BY emp.salary) position  --排名标准为工资
  FROM hr.employees emp;
--排名函数 row_number() 直接返回行号
SELECT emp.first_name,
       emp.salary,
       row_number() OVER(ORDER BY emp.salary) position  --排名标准为工资
  FROM hr.employees emp;
 
--分区窗口 partition 具有相同列值的为同一分区
SELECT emp.first_name,
       emp.department_id,
       emp.salary,
       dense_rank() OVER(PARTITION BY emp.department_id ORDER BY emp.salary) position  --排名标准为工资
  FROM hr.employees emp; 
/*
窗口子句
对于每条记录,一旦使用了窗口函数，都有对应的窗口记录的集合。而使用窗口子句，可以进一步限制窗口子句的范围。
  利用rows子句进行限制
  利用rang子句进行限制
  current row
  unbounded
*/
SELECT emp.first_name,
       emp.department_id,
       emp.salary,
       count(emp.first_name) OVER(PARTITION BY emp.department_id ORDER BY emp.salary
       ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
       ) amount 
  FROM hr.employees emp;
--常用分析函数
--first_value();
--last_value();
--lead();
--lag();
SELECT emp.first_name,
       emp.department_id,
       emp.salary,
       first_value(emp.first_name) OVER(PARTITION BY emp.department_id ORDER BY emp.salary
       ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
       ) fname,
         last_value(emp.first_name) OVER(PARTITION BY emp.department_id ORDER BY emp.salary
       ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
       ) lname 
  FROM hr.employees emp;
SELECT emp.first_name,
       emp.department_id,
       emp.salary,
       first_value(emp.first_name) OVER(PARTITION BY emp.department_id ORDER BY emp.salary
       ) fname,
         last_value(emp.first_name) OVER(PARTITION BY emp.department_id ORDER BY emp.salary
       ) lname 
  FROM hr.employees emp;
--分页代码  
  SELECT t.*
    FROM (SELECT t.*, ROWNUM rn
            FROM (SELECT * FROM hr.employees) t
           WHERE ROWNUM <= 20) t
   WHERE t.rn > 10;
/*
oracle中的条件语句
条件语句     if else
条件语句     case when
循环语句     无条件语句
循环语句     while循环
循环语句     for循环

*/
--edit
--set serveroutput on
--/
--循环语句     无条件语句
DECLARE
  v_work_year NUMBER;
BEGIN
  SELECT round(avg(months_between(SYSDATE, emp.hire_date) / 12))
    INTO v_work_year
    FROM hr.employees emp;
  IF v_work_year > 5 THEN
    dbms_output.put_line(v_work_year || '　平均工作年限己超过5年!');
  ELSE
    dbms_output.put_line(v_work_year || '　平均工作年限没有超过5年!');
  END IF;
END;
/

DECLARE
  v_num  NUMBER := 100;
  v_name VARCHAR2(30);
  v_sal  VARCHAR2(30);
BEGIN
  LOOP
    /*IF v_num > 105 THEN
      EXIT;
    END IF;*/
    EXIT WHEN v_num > 105;
    SELECT emp.first_name, emp.salary
      INTO v_name, v_sal
      FROM hr.employees emp
     WHERE emp.employee_id = v_num;
    dbms_output.put_line(v_name || '的工资为: ' || v_sal);
    v_num := v_num + 1;
  END LOOP;
END;
/
--循环语句     while循环
DECLARE
  v_num  NUMBER := 100;
  v_name VARCHAR2(30);
  v_sal  VARCHAR2(30);
BEGIN
  WHILE v_num <= 105 LOOP
    SELECT emp.first_name, emp.salary
      INTO v_name, v_sal
      FROM hr.employees emp
     WHERE emp.employee_id = v_num;
    dbms_output.put_line(v_name || '的工资为: ' || v_sal);
    v_num := v_num + 1;
  END LOOP;
END;
/
--循环语句     for循环
DECLARE
  v_name VARCHAR2(30);
  v_sal  VARCHAR2(30);
BEGIN
  FOR v_num IN 100..105 LOOP
    SELECT emp.first_name, emp.salary
      INTO v_name, v_sal
      FROM hr.employees emp
     WHERE emp.employee_id = v_num;
    dbms_output.put_line(v_name || '的工资为: ' || v_sal);
  END LOOP;
END;
/
--游标在循环中的使用
DECLARE
  CURSOR emp_cur IS
    SELECT emp.first_name, emp.salary
      FROM hr.employees emp
     WHERE ROWNUM <= 5;
  v_name hr.employees.first_name%TYPE;
  v_sal  hr.employees.salary%TYPE;
BEGIN
  OPEN emp_cur;
  FETCH emp_cur
    INTO v_name, v_sal;
  WHILE emp_cur%FOUND LOOP
    dbms_output.put_line(v_name || '的工资为: ' || v_sal);
    FETCH emp_cur
      INTO v_name, v_sal;
  END LOOP;
  CLOSE emp_cur;
END;
/

/*
视图　用户可以像操作普通表一样操作视图，视图往往不占用数据库额外的存储空间，而只存储定义。
关系视图
内嵌视图 内嵌视图在于无需创建真正的数据库对象，而只是封装查询，因此会节约数据库资源，同时不会增加维护成本。
但是内嵌视图不具有可复用性，因此当预期将在多处调用到同一查询定义时，还是应该使用关系视图。
内嵌视图内层查询为子查询，外层查询为父查询。

对象视图
oracle可以定义对象类型，并根据对象类型来创建对象实例。对象视图正是通过对象的支持来实现的。

物化视图
物化视图是oracle 8i才出现的概念，在更早的版本中，被称为快照snapshot,与其它视图不同，物化视图是存储数据，因此
会占用空间。

好处:　封装查询(将基础数据表隐藏起来)　灵活的安全性控制(不同的人员看到不同的字段)
*/
--关系视图
DROP VIEW vm_emp;
CREATE OR REPLACE VIEW vm_emp AS 
SELECT emp.employee_id,emp.first_name,emp.last_name,job.job_title,emp.salary FROM hr.employees emp,hr.jobs job WHERE emp.job_id=job.job_id;

SELECT * FROM vm_emp;

UPDATE vm_emp v SET v.job_title='女状元'　WHERE v.employee_id=206;
INSERT INTO vm_emp (employee_id,first_name,last_name,job_title,salary) VALUES(1,'luo','xiaoqiang','武状元',100000);
DELETE FROM vm_emp v WHERE v.employee_id=206;
--内嵌视图  获得工作年限最少的两名员工
SELECT *
  FROM (SELECT *
          FROM hr.employees emp
         ORDER BY months_between(SYSDATE, emp.hire_date) / 12 ASC) t
 WHERE ROWNUM <= 2;

CREATE OR REPLACE TYPE employee AS OBJECT
(
  employee_id       NUMBER,
  employee_name     VARCHAR2(30),
  employee_position VARCHAR2(30)
)

CREATE TABLE o_employees OF employee;
SELECT * FROM o_employees;

DECLARE
  e employee;
BEGIN
  e := employee(1, 'lxq', 'QA');
  INSERT INTO o_employees VALUES (e);
END;


DECLARE
  e employee;
BEGIN
  SELECT VALUE(t) INTO e FROM o_employees t WHERE t.employee_id=1;
  dbms_output.put_line(e.employee_name||'的职位是'||e.employee_position);
END;

--创建对象视图
CREATE OR REPLACE VIEW ov_employee OF employee WITH OBJECT OID(employee_id) AS
SELECT employee_id,employee_name,employee_position FROM o_employees;

SELECT * FROM ov_employee;
--用对象视图进行添删改查
INSERT INTO ov_employee VALUES (2, 'lintao', '算法工程师');
SELECT t.*,ROWNUM FROM ov_employee t FOR UPDATE;
INSERT INTO ov_employee SELECT 3, 'hanmeimei', '架构师' FROM dual UNION  SELECT 4, 'polly', '项目经理' FROM dual;
UPDATE ov_employee SET employee_position='需求设计师' WHERE employee_id=1;
DELETE FROM ov_employee WHERE employee_id=1;

--物化视图
SELECT COUNT(*) FROM tmp_user_objects;
CREATE MATERIALIZED VIEW mv_employee_count AS 
SELECT t.department_id,COUNT(*) 
FROM hr.employees t 
GROUP BY t.department_id;

SELECT * FROM mv_employee_count;--f5查看执行计划

DROP MATERIALIZED VIEW mv_employee_count;
--创建物化视图时采用延迟加载的策略
CREATE MATERIALIZED VIEW mv_employee_count BUILD DEFERRED AS 
SELECT t.department_id,COUNT(*) 
FROM hr.employees t 
GROUP BY t.department_id;

--命令行下执行
EXEC dbms_mview.refresh('mv_employee_count');

--使物化视图支持查询重写
ALTER MATERIALIZED VIEW mv_employee_count ENABLE QUERY REWRITE;
--再次按f5查看执行计划可以看到成本与物化视图查询一致
SELECT * FROM mv_employee_count;

/*
约束
约束用于保证数据库中数据的完整性和可靠性
数据表设计时，数据表一般要求满足bcnf范式，这要求至少有一个候选码（可看作唯一性约束），而其中一个候选码又被选为主码。这里的主码可以看做数据表的主键。
oracle的主要约束包括：
主键约束(与业务无关)
外键约束(与业务相关的唯一性约束，作为主键约束的有益补充)
唯一性约束
检查约束
默认值约束
非空约束
*/

DROP TABLE employees;
CREATE TABLE employees(
  employee_id NUMBER,
  employee_name VARCHAR2(30),
  employee_job VARCHAR2(30),
  employee_age NUMBER
);
--主键约束
ALTER TABLE employees ADD CONSTRAINT pk_employee_id PRIMARY KEY(employee_id);

INSERT INTO employees SELECT 1,'林涛','高级工程师',25 FROM dual UNION  
SELECT 2,'Polly','高级工程师',25 FROM dual UNION
SELECT 3,'韩妹妹','高级工程师',29 FROM dual UNION
SELECT 4,'李雷','高级工程师',27 FROM dual UNION
SELECT 5,'Uncle Wang','高级工程师',28 FROM dual UNION
SELECT 6,'吉姆格林','开发经理',32 FROM dual UNION
SELECT 7,'杰克','测试工程师',32 FROM dual UNION
SELECT 8,'Lili','项目工程师',38 FROM dual;
SELECT * FROM employees;
--测试违反主主键约束
INSERT INTO employees(employee_id,employee_name,employee_job,employee_age) VALUES(8,'东东'，'测试工程师',32);
--查看主键情况
SELECT * FROM User_Constraints;
SELECT * FROM User_Cons_Columns;
--启用、禁用主键
ALTER TABLE employees DISABLE PRIMARY KEY;
ALTER TABLE employees ENABLE PRIMARY KEY;
--重命名主键
ALTER TABLE employees RENAME CONSTRAINT pk_employee_id TO pk_empl_id;
ALTER TABLE employees DROP PRIMARY KEY;
--查看索引情况
SELECT t.TABLE_NAME, t.INDEX_NAME, t.index_type FROM User_Indexes t WHERE lower(t.TABLE_NAME)='employees';
SELECT * FROM user_ind_columns;
DROP TABLE purchase_order;
DROP TABLE customer;
CREATE TABLE customer(
  customer_id NUMBER,
  customer_name VARCHAR2(20),
  customer_phone VARCHAR2(20),
  customer_address VARCHAR2(20)
);

CREATE TABLE purchase_order(
  order_id NUMBER,
  prod_name VARCHAR2(20),
  prod_quantity NUMBER,
  customer_id NUMBER
);
INSERT INTO customer SELECT 1,'林涛','13590785440','中山路' FROM dual UNION  
SELECT 2,'Polly','13590785441','厚街' FROM dual UNION
SELECT 3,'韩妹妹','13590785442','火炬路' FROM dual UNION
SELECT 4,'李雷','13590785443','风门东路' FROM dual UNION
SELECT 5,'Uncle Wang','13590785444','罗湖商业街' FROM dual UNION
SELECT 6,'吉姆格林','13590785445','东门' FROM dual UNION
SELECT 7,'杰克','13590785446','罗湖侨社' FROM dual UNION
SELECT 8,'Lili','13590785447','东部华侨城' FROM dual;

INSERT INTO purchase_order SELECT 1,'T恤',1200,1 FROM dual UNION  
SELECT 2,'短裙',1500,2 FROM dual;
SELECT * FROM customer;
SELECT * FROM purchase_order;
--不能插入，因为没有这个客户
INSERT INTO purchase_order VALUES(1,'西裤',1600,9);
DELETE FROM customer WHERE customer_id=1;
--ALTER TABLE customer ADD PRIMARY KEY (customer_id);
ALTER TABLE customer ADD CONSTRAINT pk_cu_id PRIMARY KEY (customer_id);
ALTER TABLE purchase_order
ADD CONSTRAINT fk_customer_order
FOREIGN KEY(customer_id) REFERENCES customer(customer_id);

SELECT * FROM User_Constraints WHERE LOWER(table_name)='purchase_order';

--级联删除，级联更新,延迟校验
ALTER TABLE purchase_order DROP CONSTRAINT fk_customer_order;
ALTER TABLE purchase_order ADD CONSTRAINT fk_customer_order FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
ON DELETE CASCADE
DEFERRABLE INITIALLY DEFERRED;
--更新主表的同时还要更新从表()
UPDATE customer SET customer_id=9 WHERE customer_id=1;
UPDATE purchase_order SET customer_id=9 WHERE customer_id=1;
--删除主表的同时会把附表也删除
DELETE FROM customer WHERE customer_id=9;
--唯一性约束
ALTER TABLE customer ADD CONSTRAINT uk_cu_name UNIQUE(customer_name);
INSERT INTO customer VALUES( 8,'Lili','13590785447','东部华侨城');
--检查性约束
DROP TABLE student_score;
CREATE TABLE student_score(
  student_id NUMBER,
  student_name VARCHAR2(20),
  subject VARCHAR2(20),
  score NUMBER
);
INSERT INTO student_score SELECT 1,'林涛','数学',100 FROM dual UNION  
SELECT 2,'Polly','语文',95 FROM dual UNION
SELECT 3,'韩妹妹','化学',86.5 FROM dual UNION
SELECT 4,'李雷','英语',78 FROM dual UNION
SELECT 5,'Uncle Wang','物理',99 FROM dual UNION
SELECT 6,'吉姆格林','生物',78 FROM dual UNION
SELECT 7,'杰克','生物',89 FROM dual UNION
SELECT 8,'Lili','物理',96 FROM dual;
SELECT * FROM student_score;
ALTER TABLE student_score ADD CONSTRAINT chk_score CHECK(score>=0 AND score<=100);
SELECT * FROM User_Constraints WHERE lower(table_name)='student_score';
INSERT INTO student_score VALUES(9,'Lili','计算机原理',190);
ALTER TABLE student_score ADD CONSTRAINT chk_subject CHECK(subject IN ('数学','语文','化学','英语','物理','生物'));
INSERT INTO student_score VALUES(9,'Lili','天文',23);

ALTER TABLE student_score DROP CONSTRAINT chk_score;
ALTER TABLE student_score DROP CONSTRAINT chk_subject;
ALTER TABLE student_score ADD CONSTRAINT chk_subject_score CHECK(subject IN ('数学','语文','化学','英语','物理','生物') AND score>=0 AND score<=100);

--默认值约束
DROP TABLE contract;
CREATE TABLE contract(
  contract_id NUMBER,
  contract_name VARCHAR2(20),
  start_date DATE,
  end_date DATE,
  status VARCHAR2(5)
);
INSERT INTO contract SELECT 1,'劳动合同',to_date('2016-01-02','yyyy-mm-dd'),to_date('2016-02-02','yyyy-mm-dd'),'CXL' FROM dual UNION  
SELECT 2,'供销合同',to_date('2016-02-05','yyyy-mm-dd'),NULL,'ACT' FROM dual UNION
SELECT 3,'租赁合同',to_date('2016-03-02','yyyy-mm-dd'),NULL,'ACT' FROM dual UNION
SELECT 4,'承包合同',to_date('2016-04-02','yyyy-mm-dd'),NULL,'ACT' FROM dual;
SELECT * FROM contract;
ALTER TABLE contract MODIFY status DEFAULT 'ACT';
SELECT * FROM user_tab_cols WHERE lower(table_name)='contract' AND lower(column_name)='status';
INSERT INTO contract(contract_id,contract_name,start_date) VALUES(5,'承包合同',to_date('2016-04-02','yyyy-mm-dd'));
ALTER TABLE contract MODIFY start_date DEFAULT SYSDATE;
INSERT INTO contract(contract_id,contract_name) VALUES(6,'分包合同');
--删除默认值
ALTER TABLE contract MODIFY(start_date DEFAULT NULL,end_date DEFAULT NULL);
INSERT INTO contract(contract_id,contract_name) VALUES(8,'分包合同');
--非空约束
DROP TABLE debit;
CREATE TABLE debit(
  debit_id NUMBER,
  debit_name VARCHAR2(20),
  debit_amount NUMBER
);
INSERT INTO debit SELECT 1,'林涛',100 FROM dual UNION  
SELECT 2,'Polly',95 FROM dual UNION
SELECT 3,'韩妹妹',86.5 FROM dual; 
SELECT * FROM debit;
ALTER TABLE debit MODIFY debit_name NOT NULL;
INSERT INTO debit(debit_id,debit_amount) VALUES(4,150);
--删除非空约束
ALTER TABLE debit MODIFY(debit_name NULL);

/*
游标
显示游标
隐式游标:使用oracle预定义的名为SQL的隐式游标和使用cursor for loop来进行循环的隐式游标
动态游标:强类型游标和弱类型游标

游标申明
cursor cu_游标 is select ....
辅助变量
v_field 类型
v_field 表.列%type
v_row  表%rowtype
使用游标
open cu_游标
fetch cu_游标 into v_变量
close cu_游标

游标属性
found/not found/rowcount/isopen

动态游标
type 游标类型　is ref cursor
return 记录类型
*/
--显示游标
DECLARE
  CURSOR cu_employee IS
    SELECT t.employee_id, t.employee_name, t.employee_age FROM employees t;
  v_id   NUMBER;
  v_name VARCHAR(30);
  v_age  NUMBER;
BEGIN
  OPEN cu_employee;
  FETCH cu_employee
    INTO v_id, v_name, v_age;
  WHILE cu_employee%FOUND LOOP
    dbms_output.put_line(v_id||'　' || v_name || ',年龄是' || v_age);
    FETCH cu_employee
      INTO v_id, v_name, v_age;
  END LOOP;
  CLOSE cu_employee;
END;
/

--隐式游标
DECLARE
  v_age NUMBER;
BEGIN
  SELECT t.employee_age
    INTO v_age
    FROM employees t
   WHERE t.employee_id = 1;
  IF SQL%ISOPEN THEN
    dbms_output.put_line('游标打开了');
  ELSE
    dbms_output.put_line('游标没有打开');
  END IF;
  dbms_output.put_line('捕获的记录数为' || SQL%ROWCOUNT);
END;
/

DECLARE
BEGIN
  UPDATE employees t SET t.employee_age=15
   WHERE t.employee_id = 1;
  IF SQL%ISOPEN THEN
    dbms_output.put_line('游标打开了');
  ELSE
    dbms_output.put_line('游标没有打开');
  END IF;
  dbms_output.put_line('捕获的记录数为' || SQL%ROWCOUNT);
END;
/

BEGIN
  FOR emp IN (SELECT * FROM employees) LOOP
    dbms_output.put_line(emp.employee_name || '的年龄是' || emp.employee_age);
  END LOOP;
END;
/
--动态游标　强类型游标
SELECT * FROM employees;
DECLARE
  TYPE emp_type IS REF CURSOR RETURN employees%ROWTYPE;
  cu_emp  emp_type;
  v_emp   employees%ROWTYPE;
  v_count NUMBER;
BEGIN
  SELECT COUNT(1)
    INTO v_count
    FROM employees
   WHERE employee_job = '开发经理';
  IF v_count > 0 THEN
    OPEN cu_emp FOR
      SELECT * FROM employees WHERE employee_job = '开发经理';
  ELSE
    OPEN cu_emp FOR
      SELECT * FROM employees;
  END IF;
  FETCH cu_emp
    INTO v_emp;
  WHILE cu_emp%FOUND LOOP
    dbms_output.put_line(v_emp.employee_name || '的年龄是' ||
                         v_emp.employee_age || ' 职位是' ||
                         v_emp.employee_job);
    FETCH cu_emp
      INTO v_emp;
  END LOOP;
END;
/

--动态游标 弱类型游标
SELECT t.customer_id FROM customer t;
DECLARE
  TYPE emp_type IS REF CURSOR;
  cu_emp  emp_type;
  v_emp   employees%ROWTYPE;
  v_cust  customer%ROWTYPE;
  v_count NUMBER;
BEGIN
  SELECT COUNT(1)
    INTO v_count
    FROM employees
   WHERE employee_job = '开发经理';
  IF v_count = 0 THEN
    OPEN cu_emp FOR
      SELECT * FROM employees WHERE employee_job = '开发经理';
    FETCH cu_emp
      INTO v_emp;
    WHILE cu_emp%FOUND LOOP
      dbms_output.put_line(v_emp.employee_name || '的年龄是' ||
                           v_emp.employee_age || ' 职位是' ||
                           v_emp.employee_job);
      FETCH cu_emp
        INTO v_emp;  
    END LOOP;
    CLOSE cu_emp;
  ELSE
    OPEN cu_emp FOR
      SELECT * FROM customer;
    FETCH cu_emp
      INTO v_cust;
    WHILE cu_emp%FOUND LOOP
      dbms_output.put_line(v_cust.customer_name || '的电话是' ||
                           v_cust.customer_phone || ' 地址是' ||
                           v_cust.customer_address);
      FETCH cu_emp
        INTO v_cust;
    END LOOP;
     CLOSE cu_emp;
  END IF;
END;
/


/*
MERGE INTO table_name alias1 
USING (table|view|sub_query) alias2
ON (join condition) 
WHEN MATCHED THEN 
    UPDATE table_name 
    SET col1 = col_val1, 
           col2 = col_val2 
WHEN NOT MATCHED THEN 
    INSERT (column_list) VALUES (column_values); 
    
使用merge into  是为了根据匹配条件on(condition)利用stu1 的数据更新合并stu2的数据。
merge into 的内部处理是将stu1 的每一条记录和stu2的每一条记录对比匹配，
匹配到符合条件的记录就会进行修改，
匹配不到的话就会insert。
如果stu1的匹配列中有重复值的话，等到第二次重复的列值匹配的时候，就会将第一次的update后的值再一次update,
就是说合并后的stu2中会丢失在stu1中的记录！！！
如果记录丢失的话，两表合并的意义何在？！！
因此我们使用merge into要注意：源表匹配列中不能有重复值，否则无法匹配
*/
DROP TABLE stu1;
DROP TABLE stu2;
CREATE TABLE stu1(stu_id NUMBER,stu_name VARCHAR2(30));
INSERT INTO stu1 SELECT 1,'林涛' FROM dual UNION  
SELECT 2,'Polly' FROM dual UNION
SELECT 3,'韩妹妹' FROM dual UNION
SELECT 4,'李雷' FROM dual UNION
SELECT 5,'Uncle Wang' FROM dual UNION
SELECT 6,'吉姆格林' FROM dual UNION
SELECT 7,'杰克' FROM dual UNION
SELECT 8,'Lili' FROM dual;
CREATE TABLE stu2 AS SELECT * FROM stu1 WHERE 1<>1;

SELECT * FROM stu1;
SELECT * FROM stu2;
--ORA-30926: 无法在源表中获得一组稳定的行,利用源表重复数据
DELETE FROM stu1 WHERE stu1.stu_id=8;
DELETE FROM stu2 WHERE stu2.stu_id=8;
INSERT INTO stu1 VALUES(8,'Lili');
INSERT INTO stu1 VALUES(8,'jack');
INSERT INTO stu2 VALUES(8,'rose');
MERGE INTO stu2
USING stu1
ON (stu2.stu_id = stu1.stu_id)
WHEN NOT MATCHED THEN
  INSERT VALUES (stu1.stu_id, stu1.stu_name)
WHEN MATCHED THEN
  UPDATE SET stu2.stu_name = stu1.stu_name;
--源表不重复，目标表重复会不会出错呢  
DELETE FROM stu1 WHERE stu1.stu_id=8;
DELETE FROM stu2 WHERE stu2.stu_id=8;
INSERT INTO stu1 VALUES(8,'Lili');
INSERT INTO stu2 VALUES(8,'jack');
INSERT INTO stu2 VALUES(8,'rose');
MERGE INTO stu2
USING stu1
ON (stu2.stu_id = stu1.stu_id)
WHEN NOT MATCHED THEN
  INSERT VALUES (stu1.stu_id, stu1.stu_name)
WHEN MATCHED THEN
  UPDATE SET stu2.stu_name = stu1.stu_name;  
SELECT * FROM stu1;
SELECT * FROM stu2; 
--ORA-30926: 无法在源表中获得一组稳定的行，利用dual造重复数据
DELETE FROM stu2;
INSERT INTO stu2 VALUES(8,'Hanmeimei');
MERGE INTO stu2
USING (SELECT 8 AS stu_id, 'rose' AS stu_name
         FROM dual
       UNION ALL
       SELECT 8 AS stu_id, 'jack' AS stu_name
         FROM dual) stu1
ON (stu2.stu_id = stu1.stu_id)
WHEN NOT MATCHED THEN
  INSERT VALUES (stu1.stu_id, stu1.stu_name)
WHEN MATCHED THEN
  UPDATE SET stu2.stu_name = stu1.stu_name;
--解决办法:建议在关联的列上创建主键或者创建unique index。还有一个解决办法就是将值相等的行合并成一行来处理

--利用merge插入一条新记录
DELETE FROM stu2 t WHERE t.stu_id=1;
MERGE INTO stu2 T1
USING (SELECT 1 AS stu_id,'Polly' AS stu_name FROM dual) T2
ON ( T1.stu_id=T2.stu_id)
WHEN MATCHED THEN
    UPDATE SET T1.stu_name = T2.stu_name
WHEN NOT MATCHED THEN 
    INSERT (stu_id,stu_name) VALUES(T2.stu_id,T2.stu_name);
MERGE INTO stu2 T1
--利用merge更新一条新记录
MERGE INTO stu2 T1
USING (SELECT 1 AS stu_id,'TianTian' AS stu_name FROM dual) T2
ON ( T1.stu_id=T2.stu_id)
WHEN MATCHED THEN
    UPDATE SET T1.stu_name = T2.stu_name
WHEN NOT MATCHED THEN 
    INSERT (stu_id,stu_name) VALUES(T2.stu_id,T2.stu_name);    
--源表中有2行重复数据，但目标表中没有匹配的行，会不会有错误 
DELETE FROM stu2 t WHERE t.stu_id=8;
MERGE INTO stu2
USING (SELECT 8 AS stu_id, 'rose' AS stu_name
         FROM dual
       UNION ALL
       SELECT 8 AS stu_id, 'jack' AS stu_name
         FROM dual) stu1
ON (stu2.stu_id = stu1.stu_id)
WHEN NOT MATCHED THEN
  INSERT VALUES (stu1.stu_id, stu1.stu_name)
WHEN MATCHED THEN
  UPDATE SET stu2.stu_name = stu1.stu_name;  
SELECT * FROM stu2;  
--源表中有3行重复数据，但目标表中没有匹配的行，会不会有错误 
DELETE FROM stu2 t WHERE t.stu_id=8;
MERGE INTO stu2
USING (SELECT 8 AS stu_id, 'rose' AS stu_name
         FROM dual
       UNION ALL
       SELECT 8 AS stu_id, 'jack' AS stu_name
         FROM dual
       UNION ALL
       SELECT 8 AS stu_id, 'jim' AS stu_name
         FROM dual) stu1
ON (stu2.stu_id = stu1.stu_id)
WHEN NOT MATCHED THEN
  INSERT VALUES (stu1.stu_id, stu1.stu_name)
WHEN MATCHED THEN
  UPDATE SET stu2.stu_name = stu1.stu_name;
SELECT * FROM stu2; 
--merge当引用表中没数据的解决办法
DELETE FROM stu1;
DELETE FROM stu2;
INSERT INTO stu2 VALUES(1,'liliwang');
INSERT INTO stu2 VALUES(2,'jackluo');
--下面这句不行
MERGE INTO stu2
USING stu1
ON (stu1.stu_id=stu2.stu_id)
WHEN MATCHED THEN
 UPDATE SET stu2.stu_name='lilei'
WHEN NOT MATCHED THEN 
  INSERT VALUES(3,'lilei'); 
--这句可以插入 
MERGE INTO stu2
USING (SELECT count(*) cnt FROM stu1) t
ON (t.cnt<>0)
WHEN MATCHED THEN
 UPDATE SET stu2.stu_name='lilei'
WHEN NOT MATCHED THEN 
  INSERT VALUES(3,'lilei'); 
SELECT * FROM stu1;
SELECT * FROM stu2;  
--测试删除  delete子句的where必须在最后
DELETE FROM stu1;
DELETE FROM stu2;
INSERT INTO stu1 VALUES(1,'Lili');
INSERT INTO stu1 VALUES(2,'jack');
INSERT INTO stu1 VALUES(3,'rose');
INSERT INTO stu1 VALUES(4,'pink');
INSERT INTO stu2 VALUES(1,'liliwang');
INSERT INTO stu2 VALUES(2,'jackluo');
MERGE INTO stu2
USING stu1
ON (stu1.stu_id=stu2.stu_id)
WHEN MATCHED THEN
  UPDATE SET stu2.stu_name=stu1.stu_name
  --WHERE stu1.stu_id=1
   --DELETE WHERE (stu2.stu_id=1);
   DELETE WHERE (stu1.stu_id=1);
 SELECT * FROM stu1; 
 SELECT * FROM stu2; 
/*
触发器:

语句触发器
create trigger 触发器名称 on 作用对象
before/after 触发动作
as 触发器动作

行触发器
instead of触发器
系统和用户触发器
*/

--语句触发器
DROP TABLE t_user;
CREATE TABLE t_user(user_id NUMBER,user_name VARCHAR2(30),role_name VARCHAR2(30));
SELECT * FROM t_user;
DROP TRIGGER tr_insert_user;
CREATE OR REPLACE TRIGGER tr_user
  BEFORE INSERT OR UPDATE ON t_user
BEGIN
  dbms_output.put_line('当前用户' || USER);
  IF USER != 'SYSTEM' THEN
    raise_application_error(-20001, '权限不足，不能创建或更新用户!');
  END IF;
END;

--触发器谓词 inserting,updating,deleting
ALTER TRIGGER tr_user DISABLE;
CREATE TABLE t_user_log(username VARCHAR2(30),act VARCHAR2(30),act_date DATE);
  CREATE OR REPLACE TRIGGER tr_t_user_log
    BEFORE INSERT OR UPDATE OR DELETE ON t_user
  BEGIN
    IF updating THEN
      INSERT INTO t_user_log VALUES(USER, 'update', SYSDATE);
    END IF;
    IF inserting THEN
      INSERT INTO t_user_log VALUES(USER, 'insert', SYSDATE);
    END IF;
    IF deleting THEN
      INSERT INTO t_user_log VALUES(USER, 'delete', SYSDATE);
    END IF;
  END;
INSERT INTO t_user VALUES(1,'zhanglan','admin');
UPDATE t_user SET user_name='liling' WHERE user_id=1;
DELETE FROM t_user WHERE user_id=1;
SELECT * FROM t_user_log;

CREATE TABLE t_user_history AS SELECT * FROM t_user WHERE 1<>1;
ALTER TABLE t_user_history ADD  (operate_act VARCHAR2(30),operate_date DATE);
SELECT * FROM t_user_history;
--行触发器
ALTER TRIGGER tr_t_user_log DISABLE;
DROP TRIGGER t_user_hostry_row;
CREATE OR REPLACE TRIGGER tr_user_hostry
BEFORE UPDATE OR DELETE
ON t_user
FOR EACH ROW
  BEGIN
    INSERT INTO t_user_history VALUES(:old.user_id,:old.user_name,:old.role_name,USER,SYSDATE);
    END;
    
CREATE OR REPLACE TRIGGER tr_user_hostry
BEFORE UPDATE OR DELETE
ON t_user
REFERENCING OLD AS v_old NEW AS v_new 
FOR EACH ROW
  BEGIN
    INSERT INTO t_user_history VALUES(:v_old.user_id,:v_old.user_name,:v_old.role_name,USER,SYSDATE);
    END;   

ALTER TRIGGER tr_user_hostry DISABLE;
CREATE OR REPLACE TRIGGER tr_insert_user
  BEFORE INSERT ON t_user
  REFERENCING OLD AS v_old NEW AS v_new
  FOR EACH ROW
DECLARE
  max_user_id NUMBER;
BEGIN
  SELECT MAX(user_id) INTO max_user_id FROM t_user;
  IF max_user_id IS NULL THEN
    :v_new.user_id := 1;
  ELSE
    :v_new.user_id := max_user_id + 1;
    :v_new.user_name :=UPPER(:v_new.user_name);
    :v_new.role_name :='admin';
  END IF;
END;
/*
多个触发器执行顺序 高－低 表级触发器先于行级触发器 
如级别相同，创建时间晚的触发器先于较早的触发器
*/
INSERT INTO t_user(user_name,role_name) VALUES('zhanglan','admin');
INSERT INTO t_user(user_name,role_name) VALUES('lishi','admin');
INSERT INTO t_user(user_name) VALUES('jack');
SELECT * FROM t_user;

--触发器指定限制条件
ALTER TRIGGER tr_insert_user DISABLE;
CREATE OR REPLACE TRIGGER tr_user_ct
  BEFORE UPDATE ON t_user
  REFERENCING OLD AS v_old NEW AS v_new
  FOR EACH ROW   
  WHEN (v_old.role_name != 'admin')
BEGIN
  :v_new.role_name := upper(:v_old.role_name);
END;

TRUNCATE TABLE t_user;
INSERT INTO t_user VALUES(1,'lishi','manager');
INSERT INTO t_user VALUES(2,'liming','admin');
UPDATE t_user SET user_name='lishiming' WHERE user_id=1;
UPDATE t_user SET user_name='zhangdada' WHERE user_id=2;

--instead of 触发器
/*
instead of触发器的触发动作包括update,insert和delete
针对每一种动作的每行数据，instead of触发器都会执行一次
instead of触发器实际是一个行触发器，但无需显示声明为for each row
instead of触发器虽可以直接引用原、新数据，但不能改这些引用的值 
*/
SELECT * FROM employees;
CREATE TABLE salary(employee_id NUMBER,salary NUMBER,salary_month DATE);
INSERT INTO salary 
SELECT 1,8000,to_date('2016-01-01','yyyy-mm-dd') FROM dual UNION 
SELECT 1,8000,to_date('2016-02-01','yyyy-mm-dd') FROM dual UNION 
SELECT 1,8000,to_date('2016-03-01','yyyy-mm-dd') FROM dual UNION 
SELECT 1,8000,to_date('2016-04-01','yyyy-mm-dd') FROM dual UNION 
SELECT 1,8000,to_date('2016-05-01','yyyy-mm-dd') FROM dual UNION 
SELECT 1,8000,to_date('2016-06-01','yyyy-mm-dd') FROM dual UNION 
SELECT 1,9000,to_date('2016-07-01','yyyy-mm-dd') FROM dual UNION 
SELECT 1,9000,to_date('2016-08-01','yyyy-mm-dd') FROM dual UNION 
SELECT 1,9000,to_date('2016-09-01','yyyy-mm-dd') FROM dual UNION 
SELECT 1,9000,to_date('2016-10-01','yyyy-mm-dd') FROM dual UNION 
SELECT 1,9000,to_date('2016-11-01','yyyy-mm-dd') FROM dual UNION 
SELECT 1,9000,to_date('2016-12-01','yyyy-mm-dd') FROM dual UNION 

SELECT 2,12000,to_date('2016-01-01','yyyy-mm-dd') FROM dual UNION 
SELECT 2,12000,to_date('2016-02-01','yyyy-mm-dd') FROM dual UNION 
SELECT 2,12000,to_date('2016-03-01','yyyy-mm-dd') FROM dual UNION 
SELECT 2,12000,to_date('2016-04-01','yyyy-mm-dd') FROM dual UNION 
SELECT 2,12000,to_date('2016-05-01','yyyy-mm-dd') FROM dual UNION 
SELECT 2,12000,to_date('2016-06-01','yyyy-mm-dd') FROM dual UNION 
SELECT 2,13000,to_date('2016-07-01','yyyy-mm-dd') FROM dual UNION 
SELECT 2,13000,to_date('2016-08-01','yyyy-mm-dd') FROM dual UNION 
SELECT 2,13000,to_date('2016-09-01','yyyy-mm-dd') FROM dual UNION 
SELECT 2,13000,to_date('2016-10-01','yyyy-mm-dd') FROM dual UNION 
SELECT 2,13000,to_date('2016-11-01','yyyy-mm-dd') FROM dual UNION 
SELECT 2,13000,to_date('2016-12-01','yyyy-mm-dd') FROM dual UNION

SELECT 3,15000,to_date('2016-01-01','yyyy-mm-dd') FROM dual UNION 
SELECT 3,15000,to_date('2016-02-01','yyyy-mm-dd') FROM dual UNION 
SELECT 3,15000,to_date('2016-03-01','yyyy-mm-dd') FROM dual UNION 
SELECT 3,15000,to_date('2016-04-01','yyyy-mm-dd') FROM dual UNION 
SELECT 3,15000,to_date('2016-05-01','yyyy-mm-dd') FROM dual UNION 
SELECT 3,15000,to_date('2016-06-01','yyyy-mm-dd') FROM dual UNION 
SELECT 3,18000,to_date('2016-07-01','yyyy-mm-dd') FROM dual UNION 
SELECT 3,18000,to_date('2016-08-01','yyyy-mm-dd') FROM dual UNION 
SELECT 3,18000,to_date('2016-09-01','yyyy-mm-dd') FROM dual UNION 
SELECT 3,18000,to_date('2016-10-01','yyyy-mm-dd') FROM dual UNION 
SELECT 3,18000,to_date('2016-11-01','yyyy-mm-dd') FROM dual UNION 
SELECT 3,18000,to_date('2016-12-01','yyyy-mm-dd') FROM dual;

CREATE OR REPLACE VIEW vw_total_salary AS 
SELECT e.employee_id,e.employee_name,sum(s.salary) total_salary FROM employees  e,salary s WHERE e.employee_id=s.employee_id GROUP BY e.employee_id,e.employee_name;

SELECT * FROM  vw_total_salary;
--ORA-01732: 此视图的数据操纵操作非法
UPDATE vw_total_salary ts SET ts.total_salary=20000 WHERE ts.employee_id=1;

CREATE OR REPLACE TRIGGER tr_emp_salary
  INSTEAD OF UPDATE ON vw_total_salary
DECLARE
  total_months NUMBER;
  deffer       NUMBER;
BEGIN
  SELECT COUNT(s.salary_month)
    INTO total_months
    FROM salary s
   WHERE s.employee_id = :old.employee_id;
  deffer := (:new.total_salary - :old.total_salary) / total_months;
  UPDATE salary s
     SET s.salary = s.salary + deffer
   WHERE s.employee_id = :old.employee_id;
END;
 
UPDATE vw_total_salary ts SET ts.total_salary=20000 WHERE ts.employee_id=1;
UPDATE vw_total_salary ts SET ts.total_salary=200000 WHERE ts.employee_id=2;
SELECT * FROM salary s;
--用户事件与系统事件触发器
/*
DML  data manipulation language 数据操作语言
系统事件是指数据库级别的动作所触发的事件：数据库启动，数据库关闭，系统错误等。
用户事件是对于用户所执行的表或视图等DML操作而言的。
主要有:create/truncate/drop/alter/commit/rollback等事件
*/
--系统事件触发器以记录系统的启动时间
CREATE TABLE db_log(username VARCHAR2(30),act VARCHAR2(30),act_date DATE);
CREATE OR REPLACE TRIGGER tr_db_log
  AFTER startup ON DATABASE
BEGIN
  INSERT INTO db_log VALUES (USER, 'startup', SYSDATE);
END;
--用户事件
CREATE OR REPLACE TRIGGER tr_table_truncate
AFTER TRUNCATE
ON system.schema
BEGIN
  INSERT INTO db_log VALUES(USER,ora_dict_obj_name||' truncated',SYSDATE);
  END;
CREATE TABLE temp(ID NUMBER);
TRUNCATE TABLE temp;
SELECT * FROM db_log;
--触发器的禁用与启用
ALTER TRIGGER tr_table_truncate DISABLE;
TRUNCATE TABLE temp;
ALTER TRIGGER tr_table_truncate ENABLE;
--在数据库中查看触发器的信息
SELECT * FROM user_triggers WHERE lower(trigger_name)='tr_table_truncate';
SELECT * FROM User_Objects WHERE lower(object_name)='tr_table_truncate' AND object_type='TRIGGER';
--触发器的级联
SELECT * FROM employees;
SELECT * FROM salary;
CREATE OR REPLACE TRIGGER tr_delete_emp_salary
AFTER DELETE
ON employees
FOR EACH ROW
  BEGIN
    DELETE FROM salary s WHERE s.employee_id=:old.employee_id;
    END;
DELETE FROM employees e WHERE e.employee_id=1 OR e.employee_id=2;
--序列
DROP SEQUENCE employee_seq;
CREATE SEQUENCE employee_seq START WITH 2;
SELECT employee_seq.currval,employee_seq.nextval FROM dual;
ALTER SEQUENCE employee_seq MINVALUE 2 MAXVALUE 1000; 
ALTER SEQUENCE employee_seq INCREMENT BY 2; 

CREATE SEQUENCE employee_seq START WITH 2
MINVALUE 2 MAXVALUE 30
INCREMENT BY 2 ;
ALTER SEQUENCE employee_seq CACHE 10 CYCLE;

SELECT * FROM user_objects;
CREATE SEQUENCE obj_seq;
CREATE TABLE tmp_obj AS 
SELECT obj_seq.nextval AS obj_id,o.OBJECT_NAME,o.OBJECT_TYPE FROM user_objects o;

SELECT * FROM tmp_obj;

--用户，权限，角色
SELECT u.username,u.account_status,u.default_tablespace FROM Dba_Users u;
--创建用户
CREATE USER lxq IDENTIFIED BY lxq;
SELECT u.username,u.account_status,u.default_tablespace FROM Dba_Users u WHERE u.username='LXQ';
/*
模式schema是用户的附属对象，依赖于对象的存在而存在。
一个用户在数据库中所有拥有的所有对象的集合即为该用户的模式。
这些对象包括：表，索引，视图、存储过程。
sys的角色为sysdba，数据库管理员
system的角色sysoper,数据库操作员，权限权次于sys用户。
*/
ALTER USER scott ACCOUNT LOCK;
ALTER USER scott ACCOUNT UNLOCK;
ALTER USER scott IDENTIFIED BY scott;
--系统权限
SELECT NAME FROM System_Privilege_Map;
SELECT * FROM dba_sys_privs p WHERE p.GRANTEE='LXQ';
GRANT CREATE SESSION TO lxq;
GRANT CREATE TABLE TO lxq;
ALTER USER lxq QUOTA 20m ON USERS;
DROP TABLE TEST;
CREATE TABLE TEST(ID NUMBER);
--收回权限
REVOKE CREATE TABLE FROM lxq;
/*
对象权限是指用户在己存在对象上的权限。这些权限主要包括以下几种：
select: 可用于查询表、视图和序列
insert: 向表或视图中插入新的记录
update: 更新表中的数据
delete: 删除表中的数据
execute: 函数、存储过程、程序包等的调用和执行
index: 为表创建索引
references: 为表创建外键
alter: 修改表或序列的属性
*/
SELECT * FROM system.employees;
GRANT SELECT ON system.employees TO lxq;
/*
DBA 数据库管理员角色
connect
resource
*/
--创建角色并授权
CREATE ROLE employee_role;
GRANT SELECT,UPDATE,DELETE,INSERT ON system.Employees TO employee_role;
GRANT employee_role TO lxq;
INSERT INTO system.employees VALUES(9,'王大帅','前端工程师',36);
UPDATE system.employees t SET t.employee_age=32 WHERE t.employee_id=9;
DELETE FROM system.employees t  WHERE t.employee_id=9;
--查看自身的角色信息
SELECT * FROM session_roles;
ALTER USER lxq DEFAULT ROLES NONE;
SET ROLE employee_role;

SELECT * FROM dba_sys_privs p WHERE p.GRANTEE IN('CONNECT','RESOURCE');

--自定义函数 
CREATE OR REPLACE FUNCTION getHello RETURN VARCHAR AS
BEGIN
  RETURN 'Hello,world';
END getHello;
/
--查看自定义函数
SELECT s.name,s.TYPE,s.text FROM user_source s WHERE lower(s.name)=lower('getHello');
SELECT * FROM User_Objects o WHERE lower(o.OBJECT_NAME)=lower('getHello') 
AND lower(o.OBJECT_TYPE)=lower('function');
--调用自定义函数
SELECT getHello FROM dual;

CREATE OR REPLACE FUNCTION getTableAccount(table_name VARCHAR2)
  RETURN NUMBER AS
BEGIN
  DECLARE
    total_num NUMBER;
    sql_query VARCHAR2(300);
  BEGIN
    sql_query := 'select count(1) from ' || table_name;
    EXECUTE IMMEDIATE sql_query
      INTO total_num;
    RETURN total_num;
  END;
END getTableAccount;
/
SELECT getTableAccount('employees') FROM dual;

--确定性函数
CREATE OR REPLACE FUNCTION getWaterAccount(ton NUMBER, unit_price NUMBER)
  RETURN NUMBER DETERMINISTIC AS
BEGIN
  DECLARE
    water_account NUMBER;
  BEGIN
    water_account := 0;
    IF ton <= 2 THEN
      water_account := 2 * unit_price;
    END IF;
    IF ton > 2 AND ton <= 4 THEN
      water_account := 2 * unit_price + (4 - ton) * 2 * unit_price;
    END IF;
    IF ton > 4 THEN
      water_account := unit_price * 2 + unit_price * 2 * 2 +
                       unit_price * ton * 4 - 4;
    END IF;
    RETURN water_account;
  END;
END getWaterAccount;

SELECT getWaterAccount(1,1.5) FROM dual;
SELECT getWaterAccount(2.5,1.5) FROM dual;
SELECT getWaterAccount(5,1.5) FROM dual;
--通过函数实现行转列
CREATE OR REPLACE FUNCTION row2column(query_sql VARCHAR2) RETURN VARCHAR2 AS
BEGIN
  DECLARE
    TYPE cur_ref IS REF CURSOR;
    v_cur cur_ref;
    v_row     VARCHAR2(100);
    v_result  VARCHAR2(500);
  BEGIN
    v_result := '';
    OPEN v_cur FOR query_sql;
    FETCH v_cur
      INTO v_row;
    WHILE v_cur%FOUND LOOP
      v_result := v_result || v_row || ',';
      FETCH v_cur
        INTO v_row;
    END LOOP;
    RETURN RTRIM(v_result, ',');
  END;
END row2column;
/
SELECT e.employee_name FROM employees e;
SELECT  row2column('SELECT e.employee_name FROM employees e') FROM dual; 

--存储过程
create table student(student_id number, student_name varchar2(20),student_status varchar2(20));
INSERT INTO student SELECT 1,'林涛','在校' FROM dual UNION  
SELECT 2,'Polly','在校' FROM dual UNION
SELECT 3,'韩妹妹','在校' FROM dual UNION
SELECT 4,'李雷','在校' FROM dual UNION
SELECT 5,'Uncle Wang','在校' FROM dual UNION
SELECT 6,'吉姆格林','在校' FROM dual UNION
SELECT 7,'杰克','在校' FROM dual UNION
SELECT 8,'Lili','退学' FROM dual;
--创建存储过程
CREATE OR REPLACE PROCEDURE update_stu_status AS
BEGIN
  UPDATE student s SET s.student_status = '在校';
  COMMIT;
END;
/  
--查询存储过程
SELECT * FROM User_Source s WHERE lower(s.name)='update_stu_status' AND s.TYPE='PROCEDURE';
SELECT * FROM student;
--调用
BEGIN
  update_stu_status;
END;
/

--创建带参的存储过程
CREATE SEQUENCE stu_seq;
ALTER TABLE student ADD age NUMBER;
ALTER TABLE student MODIFY student_status DEFAULT '在校';
CREATE OR REPLACE PROCEDURE p_insert_stu(p_name VARCHAR2, p_age NUMBER) AS
BEGIN
  DECLARE
    v_max_id NUMBER;
  BEGIN
    v_max_id:=1;
    -- p_age:=10; oracle会报错 入参不能修改
    IF p_age < 10 OR p_age > 30 THEN
      RETURN;
    END IF;
    IF p_name IS NULL OR LENGTH(p_name) = 0 THEN
      RETURN;
    END IF;
    SELECT MAX(s.student_id) INTO v_max_id FROM student s;
    INSERT INTO student
      (student_id, student_name, age)
    VALUES
      (v_max_id + 1, p_name, p_age);
  END;
END p_insert_stu;
/

BEGIN
   p_insert_stu('袁稼先',86);
   p_insert_stu('张无忌',28);
   p_insert_stu('张三丰',5);
END;
/
SELECT * FROM student;

ALTER TABLE student MODIFY student_status DEFAULT '在校';
CREATE OR REPLACE PROCEDURE p_insert_stu(p_name VARCHAR2, p_age NUMBER,p_total_1 OUT NUMBER,p_total_2 OUT NUMBER) AS
BEGIN
  DECLARE
    v_max_id NUMBER;
  BEGIN
    v_max_id:=1;
    -- p_age:=10; oracle会报错 入参不能修改
    SELECT COUNT(1) INTO p_total_1 FROM student;
    IF p_age < 10 OR p_age > 30 THEN
      RETURN;
    END IF;
    IF p_name IS NULL OR LENGTH(p_name) = 0 THEN
      RETURN;
    END IF;
    
    SELECT MAX(s.student_id) INTO v_max_id FROM student s;
    INSERT INTO student
      (student_id, student_name, age)
    VALUES
      (v_max_id + 1, p_name, p_age);
      SELECT COUNT(1) INTO p_total_2 FROM student;
  END;
END p_insert_stu;
/

DECLARE
  p_total_1 NUMBER;
  p_total_2 NUMBER;
BEGIN
  p_insert_stu('袁稼先', 86, p_total_1, p_total_2);
  dbms_output.put_line('原来的学生人数' || p_total_1);
  dbms_output.put_line('新的学生人数' || p_total_2);
  p_insert_stu('张无忌', 28, p_total_1, p_total_2);
  dbms_output.put_line('原来的学生人数' || p_total_1);
  dbms_output.put_line('新的学生人数' || p_total_2);
  p_insert_stu('张三丰', 5, p_total_1, p_total_2);
  dbms_output.put_line('原来的学生人数' || p_total_1);
  dbms_output.put_line('新的学生人数' || p_total_2);
END;
/

CREATE OR REPLACE PROCEDURE swap(v1 IN OUT NUMBER, v2 IN OUT NUMBER) AS
BEGIN
  v1 := v1 + v2;
  v2 := v1 - v2;
  v1 := v1 - v2;
END;
/

DECLARE
  v1 NUMBER := 5;
  v2 NUMBER := 7;
BEGIN
  dbms_output.put_line('交换之前的顺序为' || v1 || ',' || v2);
  swap(v1, v2);
  dbms_output.put_line('交换之后的顺序为' || v1 || ',' || v2);
END;
/


/*
调试存储过程
  单击存储过程右键->确保add debug infomation->test
  start bugger(f9)
  step over(ctr+O)平级调试
  step into 进入存储过程内部调试
  可以将某个变量加入add variable to watches,以观察变量变化
  直到调试结束

程序包package
  规范specification
  主体body
*/
--程序包规范编写
CREATE OR REPLACE PACKAGE pkg_student AS
  FUNCTION getname RETURN VARCHAR2;
  PROCEDURE update_stu_status;
  PROCEDURE p_insert_stu(p_name VARCHAR2, p_age NUMBER,p_total_1 OUT NUMBER,p_total_2 OUT NUMBER);
END pkg_student;

SELECT * FROM User_Source WHERE LOWER(NAME)='pkg_student';
--程序包主体编写
CREATE OR REPLACE PACKAGE BODY pkg_student AS
  FUNCTION getname RETURN VARCHAR2 AS
  BEGIN
    DECLARE
      CURSOR cur_stu IS
        SELECT s.student_name FROM student s;
      v_name   VARCHAR2(30);
      v_result VARCHAR2(300) := '';
    BEGIN
      OPEN cur_stu;
      FETCH cur_stu
        INTO v_name;
      WHILE cur_stu%FOUND LOOP
        v_result := v_result || v_name || ',';
        FETCH cur_stu
          INTO v_name;
      END LOOP;
      RETURN rtrim(v_result, ',');
      CLOSE cur_stu;
    END;
  END getname;

  PROCEDURE update_stu_status AS
  BEGIN
    UPDATE student s SET s.student_status = '在校';
    COMMIT;
  END update_stu_status;

  PROCEDURE p_insert_stu(p_name    VARCHAR2,
                         p_age     NUMBER,
                         p_total_1 OUT NUMBER,
                         p_total_2 OUT NUMBER) AS
  BEGIN
    DECLARE
      v_max_id NUMBER;
    BEGIN
      v_max_id := 1;
      SELECT COUNT(1) INTO p_total_1 FROM student;
      IF p_age < 10 OR p_age > 30 THEN
        RETURN;
      END IF;
      IF p_name IS NULL OR LENGTH(p_name) = 0 THEN
        RETURN;
      END IF;
    
      SELECT MAX(s.student_id) INTO v_max_id FROM student s;
      INSERT INTO student
        (student_id, student_name, age)
      VALUES
        (v_max_id + 1, p_name, p_age);
      SELECT COUNT(1) INTO p_total_2 FROM student;
    END;
  END p_insert_stu;
END pkg_student;

--程序包调用
SELECT pkg_student.getname FROM dual;
UPDATE student s SET s.student_status='退学';
SELECT * FROM student;
DECLARE
  v1 NUMBER;
  v2 NUMBER;
BEGIN
  pkg_student.update_stu_status;
  pkg_student.p_insert_stu('李冰冰', 28, v1, v2);
  dbms_output.put_line('之前的学生人数为' || v1);
  dbms_output.put_line('之后的学生人数为' || v2);
END;
/

CREATE OR REPLACE FUNCTION is_date(p_date VARCHAR2) RETURN VARCHAR2 AS
BEGIN
  DECLARE
    v_date DATE;
  BEGIN
    v_date := to_date(NVL(p_date, ''), 'yyyy-mm-dd hh24:mi:ss');
    RETURN 'Y';
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'N';
  END;
END is_date;
/
SELECT is_date('2016') FROM dual;
SELECT is_date('20160524') FROM dual;

/*
数据库的性能优化
  修改oracle数据库的启动参数
       SGA(System Global Area),系统全局区，是共享的内存结构。其存储的信息是数据库的公用信息。
                  共享池
                  缓冲区
                  大型池
                  java池
                  日志缓冲区
  增加索引
  sql语句优化
*/
--修改SGA
sqlplus sys/test1234@test as SYSDBA
--确认登陆用户
show parameters instance;
--查看sga
show sga;
--查看sga参数设置
show parameters SGA
SELECT * FROM v$sgastat;
--调整sga大小
alter system set sga_max_size=1024m scope=spfile;
alter system set sga_target=1024m scope=spfile;
--数据库关闭以后需要重启
shutdown IMMEDIATE
startup
--修改pga
show parameter pga

CREATE TABLE test_objects AS SELECT * FROM dba_objects;
SELECT COUNT(1) FROM test_objects;
/*
索引不宜使用的场景
在数据量较小的表
有着频敏更新的表
*/
SELECT * FROM test_objects t WHERE t.object_name='EMPLOYEES';
CREATE INDEX idx_obj ON test_objects(object_name);

/*
SQL语句的优化
1. 企业管理器 oem top SQL
2. sql语句的命中率
3.
   exists与in  通常exists比in效率高，但oralce进行了优化，实则两个语句一样
   not exists与not in, not in进行了全表扫描，not exists效率要高一些

   where条件的合理利用，当然是越早越好,典型的莫过于having子句。having子句执行顺序处于where子句之后。
   
   利用with子句利用查询
*/
--where条件的合理利用，当然是越早越好
SELECT * FROM salary;
SELECT e.employee_id, SUM(e.salary) AS total_salary
  FROM salary e
 GROUP BY e.employee_id
HAVING e.employee_id IN(1, 2, 3);

SELECT e.employee_id, SUM(e.salary) AS total_salary
  FROM salary e WHERE e.employee_id IN(1, 2, 3)
 GROUP BY e.employee_id;
--利用with子句利用查询
 WITH emp_avg_salary AS
  (SELECT e.employee_id, AVG(e.salary) avg_salary, e.department_id
     FROM hr.employees e
    GROUP BY e.employee_id, department_id)
 SELECT *
   FROM emp_avg_salary t
  WHERE t.avg_salary > (SELECT AVG(avg_salary) FROM emp_avg_salary);
  
/*
用户对数据的操作是复杂多变的，这些复杂的动作可能是一个逻辑整体。
当同属于一个逻辑整体应当作为一个事务进行处理，从而避免出现事务的不一致性

利用commit结束事务
利用rollback结束事务
事务属性和隔离级别
*/  
DROP TABLE warehouse;
CREATE TABLE warehouse(warehouse_id NUMBER,
warehouse_name VARCHAR2(30),
goods VARCHAR2(30),
stock NUMBER);
INSERT INTO warehouse
SELECT 1,'A库','衬衫',100 FROM dual UNION
SELECT 2,'B库','衬衫',225 FROM dual UNION
SELECT 3,'A库','长裤',200 FROM dual UNION
SELECT 4,'B库','长裤',160 FROM dual;
SELECT * FROM warehouse;

UPDATE warehouse w SET w.stock=w.stock-100 WHERE w.warehouse_id=1;
UPDATE warehouse w SET w.stock=w.stock+100 WHERE w.warehouse_id=2;
UPDATE warehouse w SET w.stock=w.stock+50 WHERE w.warehouse_id=3;
UPDATE warehouse w SET w.stock=w.stock-50 WHERE w.warehouse_id=4;
COMMIT;
SELECT * FROM warehouse;

UPDATE warehouse w SET w.stock=w.stock+100a WHERE w.warehouse_id=1;--这一句不能保证事务的一致性
UPDATE warehouse w SET w.stock=w.stock-100 WHERE w.warehouse_id=2;
UPDATE warehouse w SET w.stock=w.stock-50 WHERE w.warehouse_id=3;
UPDATE warehouse w SET w.stock=w.stock+50 WHERE w.warehouse_id=4;
COMMIT;
SELECT * FROM warehouse;
/*
oracle事务的属性和隔离级别
read only属性
read write属性  racle默认级别为read write
serializable隔离级别
read commited隔离级别 这是数据库默认的隔离级别

事务的处理原则
原子性  atomicity
     当事被提交时，所有数据修改都将被确认，当事务被回滚时，所有数据修改都将被忽略。不能出现部分提交部分忽略的情形。当然，具体的实现细节均由数据库实现。对用户来说，只需用commit/rollback命令来提交或回滚事务即可。
     
一致性  consistency
     事务一致性是指，在事务开始之前事务处于一致性状态，当事务结束后，数据库仍然处于一致性状态。也就是说，事务不能破坏数据库一致性。很多情怀下，事务内部对数据库操作有可能性破坏数据库一致性。此时的事务如果执行了commit动作，势必破坏数据库的一致性。那么正确做法以应该是以rollback动作结束事务。
     
隔离性  isolation
     一个事务在处理过程中，如果总是受到其它事务的影响，那么事务的执行总是毫无轨迹可循，数据库的最终结果也是随机的。各个事务对数据库的影响是独立的，那么，一个事务对于其它事务的数据修改，有可能产生１.脏读取dirty read 2.不可复读 3.影像读取
持久性  durablity
     持久性是指，事务一旦提交，对数据库的修改也将记录到永久介质中。当用户提交事务时，oracle数据库总是首先生成redo文件。redo文件记录了事务对数据库修改的细节，即使系统崩溃，oracle同样可以利用redo文件保证所有事务成功提交。
*/

--一般大数据产生报表，而这些数据又频繁更新时设置read only
SET TRANSACTION READ ONLY;
INSERT INTO warehouse w VALUES(5,'C库','毛衣',200);

--对于本事务中可见的，而别的事务的修改则不可见
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
INSERT INTO warehouse w VALUES(5,'C库','毛衣',200);
SELECT * FROM warehouse;

--事务的隔离性
ALTER TABLE warehouse ADD CONSTRAINTS pk_id PRIMARY KEY (warehouse_id);
--事务A 执行第一句后执行事务B，然后执行第二句会报错，尽管第三句用select查询没有出现
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
INSERT INTO warehouse w VALUES(5,'C库','毛衣',200);
SELECT * FROM warehouse;
--事务B
INSERT INTO warehouse w VALUES(5,'C库','毛衣',200);
COMMIT;
SELECT * FROM warehouse;

/*
并发与锁定
并发是指多线程同时访问和操作数据库。当多用户同一时刻访问相同的数据库资源时，将产生并发。并发极易破坏数据的一致性。锁定是处理并发的重要手段。也就是说，用户在修改某一资源前，必须首先获得资源的修改权。而这种修改权具有排他性。
死锁是指两个进程都尝试获得对方己获取的锁，从而导致双方相互等待。如果没有对应的处理措施，那么这种状态一直持续下去。

oracle中的悲观锁
       用for update来锁定
       SELECT * FROM student FOR UPDATE NOWAIT;
       SELECT * FROM student FOR UPDATE;
oracle中的乐观锁
       lock table student in share mode;
         
*/
--oracle中的悲观锁
--事务A,利用FOR UPDATE来创建一个锁定
SELECT * FROM student FOR UPDATE;
--事务B
SELECT * FROM student FOR UPDATE NOWAIT;
select * from v$lock;
SELECT *
   FROM user_objects o
  WHERE o.OBJECT_ID = (SELECT lc.OBJECT_ID
                         FROM v$locked_object lc
                        WHERE lc.SESSION_ID = 221);
                        
--
lock table student in share mode;
select * from v$lock;
 SELECT o.* FROM user_objects o,v$locked_object lc WHERE o.OBJECT_ID = lc.OBJECT_ID AND lc.SESSION_ID = 67;

--事务A,执行第一句后，执行事务B,然后执行第三不成功                     
lock table student in share mode;
update student s set s.age=20;
--事务B                     
lock table student in share mode;                    

/*
oracle在开发中的应用
1. 加载驱动
2. 建立连接
3. 发送命令
4. 处理返回结果
5. 关闭连接
java中利用oracle操作数据库
1. jdbc (java database connectivity standard)s
*/

sqlplus /nolog
connect / as sysdba
startup FORCE
sqlplus "/as sysdba"
shutdown immediate      --停止服务
startup                         -- 启动服务，观察启动时有无数据文件加载报错，并记住出错数据文件

select count(*) from v$process --当前的连接数
select value from v$parameter where name = 'processes' --数据库允许的最大连接数

--修改最大连接数:
alter system set processes = 300 scope = spfile;

--重启数据库:
shutdown immediate;
startup;

--查看当前有哪些用户正在使用数据
SELECT osuser, a.username,cpu_time/executions/1000000||'s', sql_fulltext,machine 
from v$session a, v$sqlarea b
where a.sql_address =b.address order by cpu_time/executions desc;

##ORA-12514 TNS 监听程序当前无法识别连接描述符中请求服务

考虑监听listener.ora    
监听配置文件listener.ora中可以不必指定监听的服务名（安装Oracle10g后也是没有指定的）。正常情况下一般只要数据库启动，客户端连接数据库也没有什么问题，但是有时重复启动关闭也会出现ORA-12514错误。     
既然listener.ora中没有指定监听，我们可以在listener.ora文件中指定监听的实例名，这样该问题应该可以连接。
