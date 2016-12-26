/*
��������

���ݿ����
��table
Լ�� contraint
��ͼ��view
���� index
ͬ��� synonym
�洢���̡�procedure
������function
�� package
������ trigger

���ݿⰲȫ
�û� user
���� schema
Ȩ�� privilege
��ɫ role
��quota

���ݿ��ļ���洢
�����ļ� datafile
��ռ� tablespace
�ؼ��ļ���control file
������־�ļ� redo log
��ʼ�������ļ���pfile sfile

���ݿ��������
���ݿ�����db_name
ʵ������instance_name
������ service_name
�����ַ�����ip:port/tnsname����ip:(description...)
����������tnsname
������ listener

DBA����
��������һ��
��˼������ think before you act!  ���������
rm��Σ�յ�
�����ƶ��淶
*/
--dbc���ݿ���������
sqlplus sys/orcl@orcl as sysdba
shutdown immediate
conn sys/orcl as sysdba
startup 

show parameter sga
show parameter pga

--������ռ�
create tablespace test datafile 'F:\test.dbf' size 20m;
--��ռ�����
alter tablespace test rename to test1��
--�鿴��ռ�
select * from v$datafile;
--������
create table student(id number, name varchar2(20)) tablespace test_data;
--�鿴���ǲ��Ǵ����ɹ�
select table_name,tablespace_name from user_tables where lower(table_name)='student';
--������
alter table student add(age number);
--�鿴��ṹ
desc student;
--ɾ������ص�Լ��(��ʱ����ĳЩԼ�����ڣ��޷�ɾ�������統ǰ�������������������������ᵼ�±��޷��ɹ�ɾ��������cascade constraintsѡ�����ͬʱ��Լ��ɾ��)
drop table student cascade constraints;
--�����
select * from dual;--�����û�ʹ��ͬ���
select * from sys.dual;
--���ü�����net manager,����������
--F:\server\Oracle\product\11.2.0\dbhome_1\NETWORK\ADMIN\listener.ora
lsnrctl start listener orcl;
--�鿴����
--F:\server\Oracle\product\11.2.0\dbhome_1\NETWORK\ADMIN\tnsnames.ora
--�������������
desc user_tab_cols;

--��ͨ��ѯ
SELECT  emp.first_name FROM hr.employees emp;
--ָ����������
SELECT emp.first_name,
       emp.salary,
       ROUND((trunc(SYSDATE) - TRUNC(emp.hire_date)) / 365) AS ��Ӷ����
  FROM hr.employees emp
 WHERE ROUND((trunc(SYSDATE) - TRUNC(emp.hire_date)) / 365) > 10;
--Ψһ�Բ�ѯdistinct,ֻ��Խ��������������
SELECT DISTINCT emp.first_name,emp.last_name,dept.department_name FROM hr.departments dept,hr.employees emp WHERE dept.department_id=emp.department_id;
--group by�����Ӿ�
SELECT emp.department_id,round(AVG(emp.salary),2) avg_salary FROM hr.employees emp GROUP BY emp.department_id;
--�����Ӿ�having
SELECT dept.department_name AS ��������, SUM(emp.salary) AS �ܹ���
  FROM hr.employees emp
  JOIN hr.departments dept
    ON emp.department_id = dept.department_id
 GROUP BY dept.department_name
HAVING SUM(emp.salary) > 100000;
--����order by��asc����desc����,������յĽ������������
SELECT c.country_name FROM hr.countries c ORDER BY c.country_name ASC;
--order by��group byͬʱ����ʱ��oracle����group by,Ȼ����order by
--order by��distinctͬʱʹ��ʱ��������order by���У����������select�ı��ʽ��
SELECT DISTINCT emp.first_name FROM hr.employees emp ORDER BY emp.first_name,emp.last_name;--�������

/*
�Ӳ�ѯ��ָ�ڲ�ѯ������ڲ�Ƕ���ѯ���Ի���ٽ��Ľ����
����Ӳ�ѯ�е�����Դ�븸��ѯ�е����ݿ���Խ������������oracle����ת��Ϊ���ᣬ�ٽ��в�ѯ�������Ƚ����Ӳ�ѯ���ٽ��и���ѯ
*/
--��ѯ�����е��Ӳ�ѯ
SELECT *
  FROM hr.employees emp
 WHERE emp.department_id IN
       (SELECT dept.department_id FROM hr.departments dept);
--��������е��Ӳ�ѯ
CREATE TABLE temp_user_obj AS SELECT * FROM User_Objects WHERE 1<>1;     --user_objects������ǰ�û����еĶ�����Ϣ��1<>1������ѯ������ԶΪ�٣��ѳ����Ľ��Ϊ�գ�ֻ������ͬ�ı�ṹ 
SELECT * FROM temp_user_obj;
--��������е��Ӳ�ѯ���൱����������
TRUNCATE TABLE temp_user_obj;
INSERT INTO temp_user_obj SELECT * FROM User_Objects uo WHERE uo.object_type='TABLE' AND ROWNUM<10;

/*
���ϲ�ѯ���Զ����ѯ��������м��ϲ���, union,union all, intersect,minus
*/
--union������������ϲ���ȥ��
CREATE TABLE stu1(ID NUMBER,NAME VARCHAR2(30));
CREATE TABLE stu2 AS SELECT * FROM stu1 WHERE 1<>1;
INSERT INTO stu1 SELECT 1,'��Сǿ' FROM dual UNION SELECT 2,'����' FROM dual UNION SELECT 3,'��ǿ��'��FROM dual;
INSERT INTO stu2 SELECT 4,'����־' FROM dual UNION SELECT 2,'����' FROM dual UNION SELECT 3,'��ǿ��'��FROM dual;

SELECT * FROM stu1 UNION SELECT * FROM stu2;
--union all������������ϲ�����ȥ��
SELECT * FROM stu1 UNION ALL SELECT * FROM stu2;
--insertsect�󽻼���������������ж����ڵļ�¼ɸѡ����
SELECT * FROM stu1 INTERSECT SELECT * FROM stu2;
--minus����ڵ�һ��������д��ڣ��ڵڶ��������в����ڵļ�¼ɸѡ����
SELECT * FROM stu1 MINUS SELECT * FROM stu2;

/*
���ӣ��ڴ��������£����õ�����Դ�����ж�������Ӽ�����ָ���������Դ֮�����Ϲ�ϵ��
Ĭ�ϵ�����¶������Դ֮��ʹ�õ��ǵѿ������ķ�ʽ���������������ⷽʽ����Щ���ⷽʽ�ֲ��˵ѿ����Ĳ��㡣
��������ָ������������Դ������ƽ�ȵĵ�λ���������Ӳ�ͬ��
������������һ������ԴΪ������������һ������Դ�����������ƥ�䣬��ʹ������ƥ�䣬��������Դ�е��������ǳ����ڽ�����С�
*/
--��Ȼ����natural join������˼�壬�������û�ָ���κ�������ֻ��ָ�������ӵ���������Դ��ǿ��ʹ��������Ĺ�������Ϊ��Ѱ����������Ҫ�󹫹��е�ֵ������ȡ�
SELECT * FROM hr.employees NATURAL JOIN hr.departments;
--������inner joinͻ������Ȼ���ӵ����ƣ����������к���������
SELECT emp.first_name,emp.last_name,dept.department_name FROM hr.employees emp INNER JOIN hr.departments dept ON emp.department_id=dept.department_id;
--�����ӣ��������ӣ��������ӣ�ȫ����
DROP TABLE stu;
CREATE TABLE stu(ID NUMBER,NAME VARCHAR2(30),school_id NUMBER);
INSERT INTO stu SELECT 1,'����'��1 FROM dual UNION SELECT 2,'����'��2 FROM dual UNION SELECT 3,'��������'��3 FROM dual UNION SELECT 4,'������'��5 FROM dual;
DROP TABLE school;
CREATE TABLE school(school_id NUMBER,NAME VARCHAR2(30));
INSERT INTO school SELECT 1,'�廪' FROM dual UNION SELECT 2,'����' FROM dual UNION SELECT 3,'�Ͽ�' FROM dual UNION SELECT 4,'���' FROM dual UNION SELECT 6,'����' FROM dual;
SELECT * FROM stu;
SELECT * FROM school;

SELECT * FROM stu st LEFT OUTER JOIN school sc ON st.school_id=sc.school_id;--�����ӣ�����ߵļ�¼ȫ��Ҫ���֣������ұߵ��ܲ���ƥ����
SELECT * FROM stu st RIGHT OUTER JOIN school sc ON st.school_id=sc.school_id;--�����ӣ����ұߵļ�¼ȫ��Ҫ���֣�������ߵ��ܲ���ƥ����
SELECT * FROM stu st FULL OUTER JOIN school sc ON st.school_id=sc.school_id;
--����д��
SELECT * FROM stu st , school sc WHERE st.school_id=sc.school_id(+);
SELECT * FROM stu st , school sc WHERE st.school_id(+)=sc.school_id;

/*
��λ���ѯ
��ϵ�����ݿ��У�ͬһ�����ݱ��еļ�¼������ͬ���У���ˣ���ͬ�ļ�¼֮�������ƽ�й�ϵ��
���ǣ���ʱ�򣬸���¼֮��Ҳ���ܴ��Ÿ��ӹ�ϵ������Щ���ӹ�ϵ��Ϊ����ʱ�����ǿ��Խ��������е����ݿ�����״�ṹ����������״�ṹ���ݵĲ�ѯ����Ϊ��λ���ѯ
*/
CREATE TABLE market(ID NUMBER,NAME VARCHAR2(30),parent_id NUMBER);
INSERT INTO market 
SELECT 1,'ȫ��',0 FROM dual UNION 
SELECT 2,'����',1 FROM dual UNION 
SELECT 3,'����',1 FROM dual UNION 
SELECT 4,'��������',1 FROM dual UNION 
SELECT 5,'ŷ��',1 FROM dual UNION
SELECT 6,'����',1 FROM dual UNION 
SELECT 7,'�й�',2 FROM dual UNION 
SELECT 8,'����',2 FROM dual UNION 
SELECT 9,'����',2 FROM dual UNION 
SELECT 10,'���',7 FROM dual UNION 
SELECT 11,'����',7 FROM dual UNION 
SELECT 12,'����',7 FROM dual;
SELECT ID,lpad(' ',2*(level-1))||NAME AS NAME,parent_id,LEVEL FROM market START WITH NAME='����' CONNECT BY PRIOR ID=parent_id ORDER BY LEVEL;--prior�ŵ�����λ�þ����Զ����²���Ҷ�ӿ�
SELECT ID,lpad(' ',2*(level-1))||NAME AS NAME,parent_id,LEVEL FROM market START WITH NAME='���' CONNECT BY id= PRIOR parent_id ORDER BY LEVEL;--prior�ŵ�����λ�þ����Ե����ϲ��Ҹ����
/*��λ���ѯ����غ���
sys_connect_by_path()��������λ���ѯ������ĳ����¼Ϊ��㣬����connect by��ָ���������ݹ��ý�����ϣ����˺������Զ����絽��ǰ֮��¼֮��Ľ�������оۺϲ�����
*/
SELECT ID,sys_connect_by_path(NAME,'/') AS NAME,parent_id,LEVEL FROM market START WITH NAME='����' CONNECT BY PRIOR ID=parent_id ORDER BY LEVEL;

--С����: COPY������ͨ��Objects->TABLES->������չ�����Ҽ�->Columns->copy comma separated
--�ֶ��޸ļ�¼
SELECT * FROM stu FOR UPDATE;--FOR UPDATE�������ݲ��޸�

/*
Oracle��������:
�ַ��� character:��
  �̶����� char(n)��n���Ϊ2000,�����ÿո���䡡
  �ɱ䳤���ַ������� varchar(n) n���Ϊ4000 
  oracle�ڹ�ҵ��׼֮�⣬�Զ������ͣ����Ի��oracle�������Եı�֤ varchar2(n) n���Ϊ4000 
��ֵ�� number 
    number[(precision,[scale])]  1<=precision<=38 -84<=scale<=127
������ date 
    date,timestamp
������� lob 
*/
CREATE TABLE test_char(NAME CHAR(2001));
CREATE TABLE test_varchar(NAME VARCHAR(4001));
CREATE TABLE test_varchar2(NAME VARCHAR2(4001));

CREATE TABLE test_c(f_char CHAR(2000),f_varchar VARCHAR(4000),f_varchar2 VARCHAR2(4000));
INSERT INTO test_c VALUES('000','000','000');
SELECT LENGTH(f_char),LENGTH(f_varchar),LENGTH(f_varchar2) FROM test_c;
--�ַ�������
SELECT LPAD('1',4,'*'),RPAD('1',4,'*') FROM dual;
SELECT LPAD(' ',4,'*')||'luo' FROM dual UNION ALL SELECT RPAD(' ',4,'*')||'luo' FROM dual;
SELECT UPPER('LuoXiaoQiang'),LOWER('LuoXiaoQiang'),initcap('hello, world') FROM dual;
SELECT SUBSTR('hello, world',1,5),SUBSTR('hello, world',2,5) FROM dual;
SELECT INSTR('hello, world','hello'),INSTR('hello, world','world'),INSTR('hello, world,world...','world',1,2) FROM dual;
SELECT LTRIM('  lxq'),RTRIM('lxq   '),TRIM('   lxq ') FROM dual;
SELECT CONCAT('hello',', oracle'), 'hello'||', oracle' FROM dual;
--translate��һ���ַ���ÿ���ַ��ڵڶ��ַ����е�λ�ã��ڵ������ַ������ҵ����滻
SELECT TRANSLATE('hello','+h-*e&^l%$o#@!','abcdefghijklmnopqrstuvwxyz') FROM dual;
--��ֵ����Ҳ���ؿ�ֵ
SELECT LENGTH(''),LENGTH(NULL) FROM dual;


CREATE TABLE test_num(num1 NUMBER(5,2),num2 NUMBER(2,5),num3 NUMBER(5,-2));
INSERT INTO test_num(num1) VALUES(12345);--����ʧ��,���������ܱ�ʾ��λ��
INSERT INTO test_num(num1) VALUES(123);
INSERT INTO test_num(num2) VALUES(0.000123);
INSERT INTO test_num(num3) VALUES(12345);
SELECT * FROM test_num;
SELECT ABS(-123.0099),ABS(8.99) FROM dual;
SELECT ROUND(-123.0099),ROUND(8.99),ROUND(-123.0099,2),ROUND(8.981235,3) FROM dual;
SELECT CEIL(-123.0099),CEIL(8.99) FROM dual;
SELECT FLOOR(-123.0099),FLOOR(8.99) FROM dual;
SELECT MOD(-123.0099,2),MOD(8.99,2) FROM dual;
SELECT SIGN(-123.0099),SIGN(8.99) FROM dual;--�ж����ֵ�����
SELECT SQRT(4),POWER(4,3) FROM dual;
SELECT TRUNC(3.789,2),ROUND(3.789,2),SYSDATE,TRUNC(SYSDATE),TRUNC(SYSDATE)-1 FROM dual;
--��asciiת��Ϊ�ַ�
SELECT CHR(65),'ddd'||CHR(13)||'eee','ddd'||CHR(10)||'eee',CHR(14) FROM dual;
SELECT to_char('0.98','9.99'),to_char('0.98','0.00') FROM dual;
SELECT to_char(68,'xxx') FROM dual;

--����
SELECT SYSDATE,
       add_months(SYSDATE, 1),
       add_months(SYSDATE, -1),
       add_months(to_date('2016-12-30', 'yyyy-mm-dd'), -1)
  FROM dual;
--�ض����������µ����һ��  
SELECT last_day(SYSDATE),
       last_day(to_date('2016-12-30', 'yyyy-mm-dd'))
  FROM dual;
--���������������������  
SELECT months_between(SYSDATE, to_date('2016-5-30', 'yyyy-mm-dd')),
       months_between(to_date('2016-5-30', 'yyyy-mm-dd'), SYSDATE)
  FROM dual;
--�����ض�����֮�������
/*�����������������ʶΪ1,��һ��ʶΪ2....������ʶΪ7
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
--���ص�ǰ�Ựʱ���ĵ�ǰ����
SELECT SESSIONTIMEZONE,
       to_char(current_date, 'yyyy-mm-dd hh:mi:ss'),
       to_char(current_date, 'yyyy-mm-dd hh24:mi:ss')
  FROM dual;
--���ص�ǰ�Ựʱ���ĵ�ǰʱ���
SELECT SESSIONTIMEZONE,current_timestamp FROM dual;
--extract�������ڵ�ĳ����
SELECT EXTRACT(YEAR FROM SYSDATE),
       EXTRACT(MONTH FROM SYSDATE),
       EXTRACT(DAY FROM SYSDATE)
  FROM dual;
--����������Ի��ĳ�ȡʱ����ĺ���
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



--�ۺϺ���
SELECT MAX(emp.salary), MIN(emp.salary), AVG(emp.salary), SUM(emp.salary)
  FROM hr.employees emp;
--ͳ�ƺ���
SELECT COUNT(*), COUNT(emp.employee_id), COUNT(1) FROM hr.employees emp
--��ֵ�ж�decode()
SELECT emp.first_name||' '||emp.last_name AS ����,
       ROUND(months_between(SYSDATE, emp.hire_date) / 12) AS ��������,
       decode(sign(months_between(SYSDATE, emp.hire_date) / 12 - 15),
              1,
              '��Ŀ����',
              decode(sign(months_between(SYSDATE, emp.hire_date) / 12 - 10),
                     1,
                     '�߼�����ʦ',
                     'һ�����Ա')) AS ����
  FROM hr.employees emp;
--Ϊ��ֵ���¸�ֵnvl()
SELECT st.name, NVL(sc.name, '����') AS ѧУ
  FROM stu st
  LEFT JOIN school sc
    ON st.school_id = sc.school_id;
--��������к�rownum ��Ҫ���ڷ�ҳ�統ǰҳΪ2,ÿҳ��ʾ10����¼����ʾ��ΧΪ11~20
--rownum��������order by֮ǰ�ͼ���������ֵ
SELECT *
  FROM (SELECT t.*, ROWNUM rn
          FROM (SELECT * FROM hr.employees) t
         WHERE ROWNUM < 10 * 2 + 1)
 WHERE rn > 10 * (2 - 1);
--ǿ��ת����������cast()
--CAST()�������Խ����������͵�ת����
--CAST()�����Ĳ����������֣�Դֵ��Ŀ���������ͣ��м���AS�ؼ��ַָ���
create table cast_salary AS 
select cast(empno as varchar2(100)) empno,
cast(sal as varchar2(100)) sal, 
cast(job as varchar2(100)) job,
cast(comm as varchar2(100)) comm, 
ename 
from scott.emp;

--oracle��������+-*/
--oracle�߼�����> >= < <= = <> != not and or
--��λ���� ��λ�롡��λ�� ��λ��� bitand()
SELECT BITAND(7,5) FROM dual;--��λ��
SELECT 7+5-BITAND(7,5) FROM dual; --��λ��
SELECT 7+5-BITAND(7,5)��BITAND(7,5) FROM dual; --��λ���
/*
7=111 
5=101
---------
 =101 ��Ӧλ��Ϊ1��Ϊ1������Ϊ0
 
7=111 
5=101
---------
 =111 ��Ӧλ���κ�λΪ1������Ϊ0
 
7=111 
5=101
---------
 =010 ��Ӧλ��ͬΪ1������Ϊ0 
*/

/*
oracle�е�������ʽ
between��Χ����
in���ϳ�Ա����
likeģ��ƥ�� 
 %ƥ�������ַ�
 _ƥ�䵥���ַ�
 ԭ���ַ�
is null��ֵ�ж�
exists�������ж�
all,some,any������ʽ
*/
--oracle�е�������ʽ-between��Χ����
SELECT * FROM hr.employees emp WHERE emp.salary BETWEEN 10000 AND 20000;
--oracle�е�������ʽ-in���ϳ�Ա����
SELECT * FROM hr.employees emp WHERE emp.department_id IN (SELECT department_id FROM hr.departments);
--oracle�е�������ʽ-likeģ��ƥ�� 
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
--ģ����ѯ�������ַ���ת��
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
--oracle�е�������ʽ-is null��ֵ�ж� 
SELECT * FROM stu st,school sc WHERE st.school_id=sc.school_id(+) AND sc.name IS NOT NULL;
SELECT * FROM stu st,school sc WHERE st.school_id=sc.school_id(+) AND sc.name IS  NULL;
--oracle�е�������ʽ-exists�������ж�
SELECT * FROM stu st WHERE EXISTS (SELECT NULL FROM school sc WHERE sc.school_id=st.school_id);
SELECT * FROM stu st WHERE NOT EXISTS (SELECT NULL FROM school sc WHERE sc.school_id=st.school_id);
--ANY������ʽ
SELECT * FROM stu st WHERE st.school_id IN (SELECT sc.school_id FROM school sc);  
SELECT * FROM stu st WHERE st.school_id =ANY(SELECT sc.school_id FROM school sc);
--ALL������ʽ
SELECT * FROM hr.employees emp WHERE emp.salary>(SELECT MAX(salary) FROM hr.employees WHERE department_id='60');
SELECT * FROM hr.employees emp WHERE emp.salary> ALL (SELECT salary FROM hr.employees WHERE department_id='60');
--some��ʾ�κ�һ����û��
SELECT * FROM stu st WHERE st.school_id=SOME(SELECT sc.school_id FROM school sc);

/*
���ں���Ϊÿ����¼��һ�����ڣ�ʵ��ÿ��������һ�����ϡ������Щ������һЩ������Ҫ�õ�����������
���Դ��ں����ͷ����������ǳɶԳ��֡�
���з���������
       �ۺϺ��� max(),min(),sum(),avg()
       �������� rank() ������Ծ��,dense_rank() ��������Ծ��,row_number() ֱ�ӷ����к�,����������Ӧ�Ĵ��ں�������ָ���������order by�Ӿ�
over ָ�����ڣ�����ͨ��order by��ָ������,������ͬorder by����ģ�����ͬһ���ڣ�������ָ�ӵ�һ����¼�����һ����¼
*/
--��������rank(),������Ծ��,������Ų�����
SELECT emp.first_name,
       emp.salary,
       rank() OVER(ORDER BY emp.salary) position  --������׼Ϊ����
  FROM hr.employees emp;
--�������� dense_rank(),��������Ծ��,�����������
SELECT emp.first_name,
       emp.salary,
       dense_rank() OVER(ORDER BY emp.salary) position  --������׼Ϊ����
  FROM hr.employees emp;
--�������� row_number() ֱ�ӷ����к�
SELECT emp.first_name,
       emp.salary,
       row_number() OVER(ORDER BY emp.salary) position  --������׼Ϊ����
  FROM hr.employees emp;
 
--�������� partition ������ͬ��ֵ��Ϊͬһ����
SELECT emp.first_name,
       emp.department_id,
       emp.salary,
       dense_rank() OVER(PARTITION BY emp.department_id ORDER BY emp.salary) position  --������׼Ϊ����
  FROM hr.employees emp; 
/*
�����Ӿ�
����ÿ����¼,һ��ʹ���˴��ں��������ж�Ӧ�Ĵ��ڼ�¼�ļ��ϡ���ʹ�ô����Ӿ䣬���Խ�һ�����ƴ����Ӿ�ķ�Χ��
  ����rows�Ӿ��������
  ����rang�Ӿ��������
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
--���÷�������
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
--��ҳ����  
  SELECT t.*
    FROM (SELECT t.*, ROWNUM rn
            FROM (SELECT * FROM hr.employees) t
           WHERE ROWNUM <= 20) t
   WHERE t.rn > 10;
/*
oracle�е��������
�������     if else
�������     case when
ѭ�����     ���������
ѭ�����     whileѭ��
ѭ�����     forѭ��

*/
--edit
--set serveroutput on
--/
--ѭ�����     ���������
DECLARE
  v_work_year NUMBER;
BEGIN
  SELECT round(avg(months_between(SYSDATE, emp.hire_date) / 12))
    INTO v_work_year
    FROM hr.employees emp;
  IF v_work_year > 5 THEN
    dbms_output.put_line(v_work_year || '��ƽ���������޼�����5��!');
  ELSE
    dbms_output.put_line(v_work_year || '��ƽ����������û�г���5��!');
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
    dbms_output.put_line(v_name || '�Ĺ���Ϊ: ' || v_sal);
    v_num := v_num + 1;
  END LOOP;
END;
/
--ѭ�����     whileѭ��
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
    dbms_output.put_line(v_name || '�Ĺ���Ϊ: ' || v_sal);
    v_num := v_num + 1;
  END LOOP;
END;
/
--ѭ�����     forѭ��
DECLARE
  v_name VARCHAR2(30);
  v_sal  VARCHAR2(30);
BEGIN
  FOR v_num IN 100..105 LOOP
    SELECT emp.first_name, emp.salary
      INTO v_name, v_sal
      FROM hr.employees emp
     WHERE emp.employee_id = v_num;
    dbms_output.put_line(v_name || '�Ĺ���Ϊ: ' || v_sal);
  END LOOP;
END;
/
--�α���ѭ���е�ʹ��
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
    dbms_output.put_line(v_name || '�Ĺ���Ϊ: ' || v_sal);
    FETCH emp_cur
      INTO v_name, v_sal;
  END LOOP;
  CLOSE emp_cur;
END;
/

/*
��ͼ���û������������ͨ��һ��������ͼ����ͼ������ռ�����ݿ����Ĵ洢�ռ䣬��ֻ�洢���塣
��ϵ��ͼ
��Ƕ��ͼ ��Ƕ��ͼ�������贴�����������ݿ���󣬶�ֻ�Ƿ�װ��ѯ����˻��Լ���ݿ���Դ��ͬʱ��������ά���ɱ���
������Ƕ��ͼ�����пɸ����ԣ���˵�Ԥ�ڽ��ڶദ���õ�ͬһ��ѯ����ʱ������Ӧ��ʹ�ù�ϵ��ͼ��
��Ƕ��ͼ�ڲ��ѯΪ�Ӳ�ѯ������ѯΪ����ѯ��

������ͼ
oracle���Զ���������ͣ������ݶ�����������������ʵ����������ͼ����ͨ�������֧����ʵ�ֵġ�

�ﻯ��ͼ
�ﻯ��ͼ��oracle 8i�ų��ֵĸ���ڸ���İ汾�У�����Ϊ����snapshot,��������ͼ��ͬ���ﻯ��ͼ�Ǵ洢���ݣ����
��ռ�ÿռ䡣

�ô�:����װ��ѯ(���������ݱ���������)�����İ�ȫ�Կ���(��ͬ����Ա������ͬ���ֶ�)
*/
--��ϵ��ͼ
DROP VIEW vm_emp;
CREATE OR REPLACE VIEW vm_emp AS 
SELECT emp.employee_id,emp.first_name,emp.last_name,job.job_title,emp.salary FROM hr.employees emp,hr.jobs job WHERE emp.job_id=job.job_id;

SELECT * FROM vm_emp;

UPDATE vm_emp v SET v.job_title='Ů״Ԫ'��WHERE v.employee_id=206;
INSERT INTO vm_emp (employee_id,first_name,last_name,job_title,salary) VALUES(1,'luo','xiaoqiang','��״Ԫ',100000);
DELETE FROM vm_emp v WHERE v.employee_id=206;
--��Ƕ��ͼ  ��ù����������ٵ�����Ա��
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
  dbms_output.put_line(e.employee_name||'��ְλ��'||e.employee_position);
END;

--����������ͼ
CREATE OR REPLACE VIEW ov_employee OF employee WITH OBJECT OID(employee_id) AS
SELECT employee_id,employee_name,employee_position FROM o_employees;

SELECT * FROM ov_employee;
--�ö�����ͼ������ɾ�Ĳ�
INSERT INTO ov_employee VALUES (2, 'lintao', '�㷨����ʦ');
SELECT t.*,ROWNUM FROM ov_employee t FOR UPDATE;
INSERT INTO ov_employee SELECT 3, 'hanmeimei', '�ܹ�ʦ' FROM dual UNION  SELECT 4, 'polly', '��Ŀ����' FROM dual;
UPDATE ov_employee SET employee_position='�������ʦ' WHERE employee_id=1;
DELETE FROM ov_employee WHERE employee_id=1;

--�ﻯ��ͼ
SELECT COUNT(*) FROM tmp_user_objects;
CREATE MATERIALIZED VIEW mv_employee_count AS 
SELECT t.department_id,COUNT(*) 
FROM hr.employees t 
GROUP BY t.department_id;

SELECT * FROM mv_employee_count;--f5�鿴ִ�мƻ�

DROP MATERIALIZED VIEW mv_employee_count;
--�����ﻯ��ͼʱ�����ӳټ��صĲ���
CREATE MATERIALIZED VIEW mv_employee_count BUILD DEFERRED AS 
SELECT t.department_id,COUNT(*) 
FROM hr.employees t 
GROUP BY t.department_id;

--��������ִ��
EXEC dbms_mview.refresh('mv_employee_count');

--ʹ�ﻯ��ͼ֧�ֲ�ѯ��д
ALTER MATERIALIZED VIEW mv_employee_count ENABLE QUERY REWRITE;
--�ٴΰ�f5�鿴ִ�мƻ����Կ����ɱ����ﻯ��ͼ��ѯһ��
SELECT * FROM mv_employee_count;

/*
Լ��
Լ�����ڱ�֤���ݿ������ݵ������ԺͿɿ���
���ݱ����ʱ�����ݱ�һ��Ҫ������bcnf��ʽ����Ҫ��������һ����ѡ�루�ɿ���Ψһ��Լ������������һ����ѡ���ֱ�ѡΪ���롣�����������Կ������ݱ��������
oracle����ҪԼ��������
����Լ��(��ҵ���޹�)
���Լ��(��ҵ����ص�Ψһ��Լ������Ϊ����Լ�������油��)
Ψһ��Լ��
���Լ��
Ĭ��ֵԼ��
�ǿ�Լ��
*/

DROP TABLE employees;
CREATE TABLE employees(
  employee_id NUMBER,
  employee_name VARCHAR2(30),
  employee_job VARCHAR2(30),
  employee_age NUMBER
);
--����Լ��
ALTER TABLE employees ADD CONSTRAINT pk_employee_id PRIMARY KEY(employee_id);

INSERT INTO employees SELECT 1,'����','�߼�����ʦ',25 FROM dual UNION  
SELECT 2,'Polly','�߼�����ʦ',25 FROM dual UNION
SELECT 3,'������','�߼�����ʦ',29 FROM dual UNION
SELECT 4,'����','�߼�����ʦ',27 FROM dual UNION
SELECT 5,'Uncle Wang','�߼�����ʦ',28 FROM dual UNION
SELECT 6,'��ķ����','��������',32 FROM dual UNION
SELECT 7,'�ܿ�','���Թ���ʦ',32 FROM dual UNION
SELECT 8,'Lili','��Ŀ����ʦ',38 FROM dual;
SELECT * FROM employees;
--����Υ��������Լ��
INSERT INTO employees(employee_id,employee_name,employee_job,employee_age) VALUES(8,'����'��'���Թ���ʦ',32);
--�鿴�������
SELECT * FROM User_Constraints;
SELECT * FROM User_Cons_Columns;
--���á���������
ALTER TABLE employees DISABLE PRIMARY KEY;
ALTER TABLE employees ENABLE PRIMARY KEY;
--����������
ALTER TABLE employees RENAME CONSTRAINT pk_employee_id TO pk_empl_id;
ALTER TABLE employees DROP PRIMARY KEY;
--�鿴�������
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
INSERT INTO customer SELECT 1,'����','13590785440','��ɽ·' FROM dual UNION  
SELECT 2,'Polly','13590785441','���' FROM dual UNION
SELECT 3,'������','13590785442','���·' FROM dual UNION
SELECT 4,'����','13590785443','���Ŷ�·' FROM dual UNION
SELECT 5,'Uncle Wang','13590785444','�޺���ҵ��' FROM dual UNION
SELECT 6,'��ķ����','13590785445','����' FROM dual UNION
SELECT 7,'�ܿ�','13590785446','�޺�����' FROM dual UNION
SELECT 8,'Lili','13590785447','�������ȳ�' FROM dual;

INSERT INTO purchase_order SELECT 1,'T��',1200,1 FROM dual UNION  
SELECT 2,'��ȹ',1500,2 FROM dual;
SELECT * FROM customer;
SELECT * FROM purchase_order;
--���ܲ��룬��Ϊû������ͻ�
INSERT INTO purchase_order VALUES(1,'����',1600,9);
DELETE FROM customer WHERE customer_id=1;
--ALTER TABLE customer ADD PRIMARY KEY (customer_id);
ALTER TABLE customer ADD CONSTRAINT pk_cu_id PRIMARY KEY (customer_id);
ALTER TABLE purchase_order
ADD CONSTRAINT fk_customer_order
FOREIGN KEY(customer_id) REFERENCES customer(customer_id);

SELECT * FROM User_Constraints WHERE LOWER(table_name)='purchase_order';

--����ɾ������������,�ӳ�У��
ALTER TABLE purchase_order DROP CONSTRAINT fk_customer_order;
ALTER TABLE purchase_order ADD CONSTRAINT fk_customer_order FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
ON DELETE CASCADE
DEFERRABLE INITIALLY DEFERRED;
--���������ͬʱ��Ҫ���´ӱ�()
UPDATE customer SET customer_id=9 WHERE customer_id=1;
UPDATE purchase_order SET customer_id=9 WHERE customer_id=1;
--ɾ�������ͬʱ��Ѹ���Ҳɾ��
DELETE FROM customer WHERE customer_id=9;
--Ψһ��Լ��
ALTER TABLE customer ADD CONSTRAINT uk_cu_name UNIQUE(customer_name);
INSERT INTO customer VALUES( 8,'Lili','13590785447','�������ȳ�');
--�����Լ��
DROP TABLE student_score;
CREATE TABLE student_score(
  student_id NUMBER,
  student_name VARCHAR2(20),
  subject VARCHAR2(20),
  score NUMBER
);
INSERT INTO student_score SELECT 1,'����','��ѧ',100 FROM dual UNION  
SELECT 2,'Polly','����',95 FROM dual UNION
SELECT 3,'������','��ѧ',86.5 FROM dual UNION
SELECT 4,'����','Ӣ��',78 FROM dual UNION
SELECT 5,'Uncle Wang','����',99 FROM dual UNION
SELECT 6,'��ķ����','����',78 FROM dual UNION
SELECT 7,'�ܿ�','����',89 FROM dual UNION
SELECT 8,'Lili','����',96 FROM dual;
SELECT * FROM student_score;
ALTER TABLE student_score ADD CONSTRAINT chk_score CHECK(score>=0 AND score<=100);
SELECT * FROM User_Constraints WHERE lower(table_name)='student_score';
INSERT INTO student_score VALUES(9,'Lili','�����ԭ��',190);
ALTER TABLE student_score ADD CONSTRAINT chk_subject CHECK(subject IN ('��ѧ','����','��ѧ','Ӣ��','����','����'));
INSERT INTO student_score VALUES(9,'Lili','����',23);

ALTER TABLE student_score DROP CONSTRAINT chk_score;
ALTER TABLE student_score DROP CONSTRAINT chk_subject;
ALTER TABLE student_score ADD CONSTRAINT chk_subject_score CHECK(subject IN ('��ѧ','����','��ѧ','Ӣ��','����','����') AND score>=0 AND score<=100);

--Ĭ��ֵԼ��
DROP TABLE contract;
CREATE TABLE contract(
  contract_id NUMBER,
  contract_name VARCHAR2(20),
  start_date DATE,
  end_date DATE,
  status VARCHAR2(5)
);
INSERT INTO contract SELECT 1,'�Ͷ���ͬ',to_date('2016-01-02','yyyy-mm-dd'),to_date('2016-02-02','yyyy-mm-dd'),'CXL' FROM dual UNION  
SELECT 2,'������ͬ',to_date('2016-02-05','yyyy-mm-dd'),NULL,'ACT' FROM dual UNION
SELECT 3,'���޺�ͬ',to_date('2016-03-02','yyyy-mm-dd'),NULL,'ACT' FROM dual UNION
SELECT 4,'�а���ͬ',to_date('2016-04-02','yyyy-mm-dd'),NULL,'ACT' FROM dual;
SELECT * FROM contract;
ALTER TABLE contract MODIFY status DEFAULT 'ACT';
SELECT * FROM user_tab_cols WHERE lower(table_name)='contract' AND lower(column_name)='status';
INSERT INTO contract(contract_id,contract_name,start_date) VALUES(5,'�а���ͬ',to_date('2016-04-02','yyyy-mm-dd'));
ALTER TABLE contract MODIFY start_date DEFAULT SYSDATE;
INSERT INTO contract(contract_id,contract_name) VALUES(6,'�ְ���ͬ');
--ɾ��Ĭ��ֵ
ALTER TABLE contract MODIFY(start_date DEFAULT NULL,end_date DEFAULT NULL);
INSERT INTO contract(contract_id,contract_name) VALUES(8,'�ְ���ͬ');
--�ǿ�Լ��
DROP TABLE debit;
CREATE TABLE debit(
  debit_id NUMBER,
  debit_name VARCHAR2(20),
  debit_amount NUMBER
);
INSERT INTO debit SELECT 1,'����',100 FROM dual UNION  
SELECT 2,'Polly',95 FROM dual UNION
SELECT 3,'������',86.5 FROM dual; 
SELECT * FROM debit;
ALTER TABLE debit MODIFY debit_name NOT NULL;
INSERT INTO debit(debit_id,debit_amount) VALUES(4,150);
--ɾ���ǿ�Լ��
ALTER TABLE debit MODIFY(debit_name NULL);

/*
�α�
��ʾ�α�
��ʽ�α�:ʹ��oracleԤ�������ΪSQL����ʽ�α��ʹ��cursor for loop������ѭ������ʽ�α�
��̬�α�:ǿ�����α���������α�

�α�����
cursor cu_�α� is select ....
��������
v_field ����
v_field ��.��%type
v_row  ��%rowtype
ʹ���α�
open cu_�α�
fetch cu_�α� into v_����
close cu_�α�

�α�����
found/not found/rowcount/isopen

��̬�α�
type �α����͡�is ref cursor
return ��¼����
*/
--��ʾ�α�
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
    dbms_output.put_line(v_id||'��' || v_name || ',������' || v_age);
    FETCH cu_employee
      INTO v_id, v_name, v_age;
  END LOOP;
  CLOSE cu_employee;
END;
/

--��ʽ�α�
DECLARE
  v_age NUMBER;
BEGIN
  SELECT t.employee_age
    INTO v_age
    FROM employees t
   WHERE t.employee_id = 1;
  IF SQL%ISOPEN THEN
    dbms_output.put_line('�α����');
  ELSE
    dbms_output.put_line('�α�û�д�');
  END IF;
  dbms_output.put_line('����ļ�¼��Ϊ' || SQL%ROWCOUNT);
END;
/

DECLARE
BEGIN
  UPDATE employees t SET t.employee_age=15
   WHERE t.employee_id = 1;
  IF SQL%ISOPEN THEN
    dbms_output.put_line('�α����');
  ELSE
    dbms_output.put_line('�α�û�д�');
  END IF;
  dbms_output.put_line('����ļ�¼��Ϊ' || SQL%ROWCOUNT);
END;
/

BEGIN
  FOR emp IN (SELECT * FROM employees) LOOP
    dbms_output.put_line(emp.employee_name || '��������' || emp.employee_age);
  END LOOP;
END;
/
--��̬�αꡡǿ�����α�
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
   WHERE employee_job = '��������';
  IF v_count > 0 THEN
    OPEN cu_emp FOR
      SELECT * FROM employees WHERE employee_job = '��������';
  ELSE
    OPEN cu_emp FOR
      SELECT * FROM employees;
  END IF;
  FETCH cu_emp
    INTO v_emp;
  WHILE cu_emp%FOUND LOOP
    dbms_output.put_line(v_emp.employee_name || '��������' ||
                         v_emp.employee_age || ' ְλ��' ||
                         v_emp.employee_job);
    FETCH cu_emp
      INTO v_emp;
  END LOOP;
END;
/

--��̬�α� �������α�
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
   WHERE employee_job = '��������';
  IF v_count = 0 THEN
    OPEN cu_emp FOR
      SELECT * FROM employees WHERE employee_job = '��������';
    FETCH cu_emp
      INTO v_emp;
    WHILE cu_emp%FOUND LOOP
      dbms_output.put_line(v_emp.employee_name || '��������' ||
                           v_emp.employee_age || ' ְλ��' ||
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
      dbms_output.put_line(v_cust.customer_name || '�ĵ绰��' ||
                           v_cust.customer_phone || ' ��ַ��' ||
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
    
ʹ��merge into  ��Ϊ�˸���ƥ������on(condition)����stu1 �����ݸ��ºϲ�stu2�����ݡ�
merge into ���ڲ������ǽ�stu1 ��ÿһ����¼��stu2��ÿһ����¼�Ա�ƥ�䣬
ƥ�䵽���������ļ�¼�ͻ�����޸ģ�
ƥ�䲻���Ļ��ͻ�insert��
���stu1��ƥ���������ظ�ֵ�Ļ����ȵ��ڶ����ظ�����ֵƥ���ʱ�򣬾ͻὫ��һ�ε�update���ֵ��һ��update,
����˵�ϲ����stu2�лᶪʧ��stu1�еļ�¼������
�����¼��ʧ�Ļ�������ϲ���������ڣ�����
�������ʹ��merge intoҪע�⣺Դ��ƥ�����в������ظ�ֵ�������޷�ƥ��
*/
DROP TABLE stu1;
DROP TABLE stu2;
CREATE TABLE stu1(stu_id NUMBER,stu_name VARCHAR2(30));
INSERT INTO stu1 SELECT 1,'����' FROM dual UNION  
SELECT 2,'Polly' FROM dual UNION
SELECT 3,'������' FROM dual UNION
SELECT 4,'����' FROM dual UNION
SELECT 5,'Uncle Wang' FROM dual UNION
SELECT 6,'��ķ����' FROM dual UNION
SELECT 7,'�ܿ�' FROM dual UNION
SELECT 8,'Lili' FROM dual;
CREATE TABLE stu2 AS SELECT * FROM stu1 WHERE 1<>1;

SELECT * FROM stu1;
SELECT * FROM stu2;
--ORA-30926: �޷���Դ���л��һ���ȶ�����,����Դ���ظ�����
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
--Դ���ظ���Ŀ����ظ��᲻�������  
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
--ORA-30926: �޷���Դ���л��һ���ȶ����У�����dual���ظ�����
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
--����취:�����ڹ��������ϴ����������ߴ���unique index������һ������취���ǽ�ֵ��ȵ��кϲ���һ��������

--����merge����һ���¼�¼
DELETE FROM stu2 t WHERE t.stu_id=1;
MERGE INTO stu2 T1
USING (SELECT 1 AS stu_id,'Polly' AS stu_name FROM dual) T2
ON ( T1.stu_id=T2.stu_id)
WHEN MATCHED THEN
    UPDATE SET T1.stu_name = T2.stu_name
WHEN NOT MATCHED THEN 
    INSERT (stu_id,stu_name) VALUES(T2.stu_id,T2.stu_name);
MERGE INTO stu2 T1
--����merge����һ���¼�¼
MERGE INTO stu2 T1
USING (SELECT 1 AS stu_id,'TianTian' AS stu_name FROM dual) T2
ON ( T1.stu_id=T2.stu_id)
WHEN MATCHED THEN
    UPDATE SET T1.stu_name = T2.stu_name
WHEN NOT MATCHED THEN 
    INSERT (stu_id,stu_name) VALUES(T2.stu_id,T2.stu_name);    
--Դ������2���ظ����ݣ���Ŀ�����û��ƥ����У��᲻���д��� 
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
--Դ������3���ظ����ݣ���Ŀ�����û��ƥ����У��᲻���д��� 
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
--merge�����ñ���û���ݵĽ���취
DELETE FROM stu1;
DELETE FROM stu2;
INSERT INTO stu2 VALUES(1,'liliwang');
INSERT INTO stu2 VALUES(2,'jackluo');
--������䲻��
MERGE INTO stu2
USING stu1
ON (stu1.stu_id=stu2.stu_id)
WHEN MATCHED THEN
 UPDATE SET stu2.stu_name='lilei'
WHEN NOT MATCHED THEN 
  INSERT VALUES(3,'lilei'); 
--�����Բ��� 
MERGE INTO stu2
USING (SELECT count(*) cnt FROM stu1) t
ON (t.cnt<>0)
WHEN MATCHED THEN
 UPDATE SET stu2.stu_name='lilei'
WHEN NOT MATCHED THEN 
  INSERT VALUES(3,'lilei'); 
SELECT * FROM stu1;
SELECT * FROM stu2;  
--����ɾ��  delete�Ӿ��where���������
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
������:

��䴥����
create trigger ���������� on ���ö���
before/after ��������
as ����������

�д�����
instead of������
ϵͳ���û�������
*/

--��䴥����
DROP TABLE t_user;
CREATE TABLE t_user(user_id NUMBER,user_name VARCHAR2(30),role_name VARCHAR2(30));
SELECT * FROM t_user;
DROP TRIGGER tr_insert_user;
CREATE OR REPLACE TRIGGER tr_user
  BEFORE INSERT OR UPDATE ON t_user
BEGIN
  dbms_output.put_line('��ǰ�û�' || USER);
  IF USER != 'SYSTEM' THEN
    raise_application_error(-20001, 'Ȩ�޲��㣬���ܴ���������û�!');
  END IF;
END;

--������ν�� inserting,updating,deleting
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
--�д�����
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
���������ִ��˳�� �ߣ��� �������������м������� 
�缶����ͬ������ʱ����Ĵ��������ڽ���Ĵ�����
*/
INSERT INTO t_user(user_name,role_name) VALUES('zhanglan','admin');
INSERT INTO t_user(user_name,role_name) VALUES('lishi','admin');
INSERT INTO t_user(user_name) VALUES('jack');
SELECT * FROM t_user;

--������ָ����������
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

--instead of ������
/*
instead of�������Ĵ�����������update,insert��delete
���ÿһ�ֶ�����ÿ�����ݣ�instead of����������ִ��һ��
instead of������ʵ����һ���д���������������ʾ����Ϊfor each row
instead of�����������ֱ������ԭ�������ݣ������ܸ���Щ���õ�ֵ 
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
--ORA-01732: ����ͼ�����ݲ��ݲ����Ƿ�
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
--�û��¼���ϵͳ�¼�������
/*
DML  data manipulation language ���ݲ�������
ϵͳ�¼���ָ���ݿ⼶��Ķ������������¼������ݿ����������ݿ�رգ�ϵͳ����ȡ�
�û��¼��Ƕ����û���ִ�еı����ͼ��DML�������Եġ�
��Ҫ��:create/truncate/drop/alter/commit/rollback���¼�
*/
--ϵͳ�¼��������Լ�¼ϵͳ������ʱ��
CREATE TABLE db_log(username VARCHAR2(30),act VARCHAR2(30),act_date DATE);
CREATE OR REPLACE TRIGGER tr_db_log
  AFTER startup ON DATABASE
BEGIN
  INSERT INTO db_log VALUES (USER, 'startup', SYSDATE);
END;
--�û��¼�
CREATE OR REPLACE TRIGGER tr_table_truncate
AFTER TRUNCATE
ON system.schema
BEGIN
  INSERT INTO db_log VALUES(USER,ora_dict_obj_name||' truncated',SYSDATE);
  END;
CREATE TABLE temp(ID NUMBER);
TRUNCATE TABLE temp;
SELECT * FROM db_log;
--�������Ľ���������
ALTER TRIGGER tr_table_truncate DISABLE;
TRUNCATE TABLE temp;
ALTER TRIGGER tr_table_truncate ENABLE;
--�����ݿ��в鿴����������Ϣ
SELECT * FROM user_triggers WHERE lower(trigger_name)='tr_table_truncate';
SELECT * FROM User_Objects WHERE lower(object_name)='tr_table_truncate' AND object_type='TRIGGER';
--�������ļ���
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
--����
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

--�û���Ȩ�ޣ���ɫ
SELECT u.username,u.account_status,u.default_tablespace FROM Dba_Users u;
--�����û�
CREATE USER lxq IDENTIFIED BY lxq;
SELECT u.username,u.account_status,u.default_tablespace FROM Dba_Users u WHERE u.username='LXQ';
/*
ģʽschema���û��ĸ������������ڶ���Ĵ��ڶ����ڡ�
һ���û������ݿ�������ӵ�е����ж���ļ��ϼ�Ϊ���û���ģʽ��
��Щ�������������������ͼ���洢���̡�
sys�Ľ�ɫΪsysdba�����ݿ����Ա
system�Ľ�ɫsysoper,���ݿ����Ա��Ȩ��Ȩ����sys�û���
*/
ALTER USER scott ACCOUNT LOCK;
ALTER USER scott ACCOUNT UNLOCK;
ALTER USER scott IDENTIFIED BY scott;
--ϵͳȨ��
SELECT NAME FROM System_Privilege_Map;
SELECT * FROM dba_sys_privs p WHERE p.GRANTEE='LXQ';
GRANT CREATE SESSION TO lxq;
GRANT CREATE TABLE TO lxq;
ALTER USER lxq QUOTA 20m ON USERS;
DROP TABLE TEST;
CREATE TABLE TEST(ID NUMBER);
--�ջ�Ȩ��
REVOKE CREATE TABLE FROM lxq;
/*
����Ȩ����ָ�û��ڼ����ڶ����ϵ�Ȩ�ޡ���ЩȨ����Ҫ�������¼��֣�
select: �����ڲ�ѯ����ͼ������
insert: ������ͼ�в����µļ�¼
update: ���±��е�����
delete: ɾ�����е�����
execute: �������洢���̡�������ȵĵ��ú�ִ��
index: Ϊ��������
references: Ϊ�������
alter: �޸ı�����е�����
*/
SELECT * FROM system.employees;
GRANT SELECT ON system.employees TO lxq;
/*
DBA ���ݿ����Ա��ɫ
connect
resource
*/
--������ɫ����Ȩ
CREATE ROLE employee_role;
GRANT SELECT,UPDATE,DELETE,INSERT ON system.Employees TO employee_role;
GRANT employee_role TO lxq;
INSERT INTO system.employees VALUES(9,'����˧','ǰ�˹���ʦ',36);
UPDATE system.employees t SET t.employee_age=32 WHERE t.employee_id=9;
DELETE FROM system.employees t  WHERE t.employee_id=9;
--�鿴����Ľ�ɫ��Ϣ
SELECT * FROM session_roles;
ALTER USER lxq DEFAULT ROLES NONE;
SET ROLE employee_role;

SELECT * FROM dba_sys_privs p WHERE p.GRANTEE IN('CONNECT','RESOURCE');

--�Զ��庯�� 
CREATE OR REPLACE FUNCTION getHello RETURN VARCHAR AS
BEGIN
  RETURN 'Hello,world';
END getHello;
/
--�鿴�Զ��庯��
SELECT s.name,s.TYPE,s.text FROM user_source s WHERE lower(s.name)=lower('getHello');
SELECT * FROM User_Objects o WHERE lower(o.OBJECT_NAME)=lower('getHello') 
AND lower(o.OBJECT_TYPE)=lower('function');
--�����Զ��庯��
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

--ȷ���Ժ���
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
--ͨ������ʵ����ת��
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

--�洢����
create table student(student_id number, student_name varchar2(20),student_status varchar2(20));
INSERT INTO student SELECT 1,'����','��У' FROM dual UNION  
SELECT 2,'Polly','��У' FROM dual UNION
SELECT 3,'������','��У' FROM dual UNION
SELECT 4,'����','��У' FROM dual UNION
SELECT 5,'Uncle Wang','��У' FROM dual UNION
SELECT 6,'��ķ����','��У' FROM dual UNION
SELECT 7,'�ܿ�','��У' FROM dual UNION
SELECT 8,'Lili','��ѧ' FROM dual;
--�����洢����
CREATE OR REPLACE PROCEDURE update_stu_status AS
BEGIN
  UPDATE student s SET s.student_status = '��У';
  COMMIT;
END;
/  
--��ѯ�洢����
SELECT * FROM User_Source s WHERE lower(s.name)='update_stu_status' AND s.TYPE='PROCEDURE';
SELECT * FROM student;
--����
BEGIN
  update_stu_status;
END;
/

--�������εĴ洢����
CREATE SEQUENCE stu_seq;
ALTER TABLE student ADD age NUMBER;
ALTER TABLE student MODIFY student_status DEFAULT '��У';
CREATE OR REPLACE PROCEDURE p_insert_stu(p_name VARCHAR2, p_age NUMBER) AS
BEGIN
  DECLARE
    v_max_id NUMBER;
  BEGIN
    v_max_id:=1;
    -- p_age:=10; oracle�ᱨ�� ��β����޸�
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
   p_insert_stu('Ԭ����',86);
   p_insert_stu('���޼�',28);
   p_insert_stu('������',5);
END;
/
SELECT * FROM student;

ALTER TABLE student MODIFY student_status DEFAULT '��У';
CREATE OR REPLACE PROCEDURE p_insert_stu(p_name VARCHAR2, p_age NUMBER,p_total_1 OUT NUMBER,p_total_2 OUT NUMBER) AS
BEGIN
  DECLARE
    v_max_id NUMBER;
  BEGIN
    v_max_id:=1;
    -- p_age:=10; oracle�ᱨ�� ��β����޸�
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
  p_insert_stu('Ԭ����', 86, p_total_1, p_total_2);
  dbms_output.put_line('ԭ����ѧ������' || p_total_1);
  dbms_output.put_line('�µ�ѧ������' || p_total_2);
  p_insert_stu('���޼�', 28, p_total_1, p_total_2);
  dbms_output.put_line('ԭ����ѧ������' || p_total_1);
  dbms_output.put_line('�µ�ѧ������' || p_total_2);
  p_insert_stu('������', 5, p_total_1, p_total_2);
  dbms_output.put_line('ԭ����ѧ������' || p_total_1);
  dbms_output.put_line('�µ�ѧ������' || p_total_2);
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
  dbms_output.put_line('����֮ǰ��˳��Ϊ' || v1 || ',' || v2);
  swap(v1, v2);
  dbms_output.put_line('����֮���˳��Ϊ' || v1 || ',' || v2);
END;
/


/*
���Դ洢����
  �����洢�����Ҽ�->ȷ��add debug infomation->test
  start bugger(f9)
  step over(ctr+O)ƽ������
  step into ����洢�����ڲ�����
  ���Խ�ĳ����������add variable to watches,�Թ۲�����仯
  ֱ�����Խ���

�����package
  �淶specification
  ����body
*/
--������淶��д
CREATE OR REPLACE PACKAGE pkg_student AS
  FUNCTION getname RETURN VARCHAR2;
  PROCEDURE update_stu_status;
  PROCEDURE p_insert_stu(p_name VARCHAR2, p_age NUMBER,p_total_1 OUT NUMBER,p_total_2 OUT NUMBER);
END pkg_student;

SELECT * FROM User_Source WHERE LOWER(NAME)='pkg_student';
--����������д
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
    UPDATE student s SET s.student_status = '��У';
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

--���������
SELECT pkg_student.getname FROM dual;
UPDATE student s SET s.student_status='��ѧ';
SELECT * FROM student;
DECLARE
  v1 NUMBER;
  v2 NUMBER;
BEGIN
  pkg_student.update_stu_status;
  pkg_student.p_insert_stu('�����', 28, v1, v2);
  dbms_output.put_line('֮ǰ��ѧ������Ϊ' || v1);
  dbms_output.put_line('֮���ѧ������Ϊ' || v2);
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
���ݿ�������Ż�
  �޸�oracle���ݿ����������
       SGA(System Global Area),ϵͳȫ�������ǹ�����ڴ�ṹ����洢����Ϣ�����ݿ�Ĺ�����Ϣ��
                  �����
                  ������
                  ���ͳ�
                  java��
                  ��־������
  ��������
  sql����Ż�
*/
--�޸�SGA
sqlplus sys/test1234@test as SYSDBA
--ȷ�ϵ�½�û�
show parameters instance;
--�鿴sga
show sga;
--�鿴sga��������
show parameters SGA
SELECT * FROM v$sgastat;
--����sga��С
alter system set sga_max_size=1024m scope=spfile;
alter system set sga_target=1024m scope=spfile;
--���ݿ�ر��Ժ���Ҫ����
shutdown IMMEDIATE
startup
--�޸�pga
show parameter pga

CREATE TABLE test_objects AS SELECT * FROM dba_objects;
SELECT COUNT(1) FROM test_objects;
/*
��������ʹ�õĳ���
����������С�ı�
����Ƶ�����µı�
*/
SELECT * FROM test_objects t WHERE t.object_name='EMPLOYEES';
CREATE INDEX idx_obj ON test_objects(object_name);

/*
SQL�����Ż�
1. ��ҵ������ oem top SQL
2. sql����������
3.
   exists��in  ͨ��exists��inЧ�ʸߣ���oralce�������Ż���ʵ���������һ��
   not exists��not in, not in������ȫ��ɨ�裬not existsЧ��Ҫ��һЩ

   where�����ĺ������ã���Ȼ��Խ��Խ��,���͵�Ī����having�Ӿ䡣having�Ӿ�ִ��˳����where�Ӿ�֮��
   
   ����with�Ӿ����ò�ѯ
*/
--where�����ĺ������ã���Ȼ��Խ��Խ��
SELECT * FROM salary;
SELECT e.employee_id, SUM(e.salary) AS total_salary
  FROM salary e
 GROUP BY e.employee_id
HAVING e.employee_id IN(1, 2, 3);

SELECT e.employee_id, SUM(e.salary) AS total_salary
  FROM salary e WHERE e.employee_id IN(1, 2, 3)
 GROUP BY e.employee_id;
--����with�Ӿ����ò�ѯ
 WITH emp_avg_salary AS
  (SELECT e.employee_id, AVG(e.salary) avg_salary, e.department_id
     FROM hr.employees e
    GROUP BY e.employee_id, department_id)
 SELECT *
   FROM emp_avg_salary t
  WHERE t.avg_salary > (SELECT AVG(avg_salary) FROM emp_avg_salary);
  
/*
�û������ݵĲ����Ǹ��Ӷ��ģ���Щ���ӵĶ���������һ���߼����塣
��ͬ����һ���߼�����Ӧ����Ϊһ��������д����Ӷ������������Ĳ�һ����

����commit��������
����rollback��������
�������Ժ͸��뼶��
*/  
DROP TABLE warehouse;
CREATE TABLE warehouse(warehouse_id NUMBER,
warehouse_name VARCHAR2(30),
goods VARCHAR2(30),
stock NUMBER);
INSERT INTO warehouse
SELECT 1,'A��','����',100 FROM dual UNION
SELECT 2,'B��','����',225 FROM dual UNION
SELECT 3,'A��','����',200 FROM dual UNION
SELECT 4,'B��','����',160 FROM dual;
SELECT * FROM warehouse;

UPDATE warehouse w SET w.stock=w.stock-100 WHERE w.warehouse_id=1;
UPDATE warehouse w SET w.stock=w.stock+100 WHERE w.warehouse_id=2;
UPDATE warehouse w SET w.stock=w.stock+50 WHERE w.warehouse_id=3;
UPDATE warehouse w SET w.stock=w.stock-50 WHERE w.warehouse_id=4;
COMMIT;
SELECT * FROM warehouse;

UPDATE warehouse w SET w.stock=w.stock+100a WHERE w.warehouse_id=1;--��һ�䲻�ܱ�֤�����һ����
UPDATE warehouse w SET w.stock=w.stock-100 WHERE w.warehouse_id=2;
UPDATE warehouse w SET w.stock=w.stock-50 WHERE w.warehouse_id=3;
UPDATE warehouse w SET w.stock=w.stock+50 WHERE w.warehouse_id=4;
COMMIT;
SELECT * FROM warehouse;
/*
oracle��������Ժ͸��뼶��
read only����
read write����  racleĬ�ϼ���Ϊread write
serializable���뼶��
read commited���뼶�� �������ݿ�Ĭ�ϵĸ��뼶��

����Ĵ���ԭ��
ԭ����  atomicity
     ���±��ύʱ�����������޸Ķ�����ȷ�ϣ������񱻻ع�ʱ�����������޸Ķ��������ԡ����ܳ��ֲ����ύ���ֺ��Ե����Ρ���Ȼ�������ʵ��ϸ�ھ������ݿ�ʵ�֡����û���˵��ֻ����commit/rollback�������ύ��ع����񼴿ɡ�
     
һ����  consistency
     ����һ������ָ��������ʼ֮ǰ������һ����״̬����������������ݿ���Ȼ����һ����״̬��Ҳ����˵���������ƻ����ݿ�һ���ԡ��ܶ��黳�£������ڲ������ݿ�����п������ƻ����ݿ�һ���ԡ���ʱ���������ִ����commit�������Ʊ��ƻ����ݿ��һ���ԡ���ô��ȷ������Ӧ������rollback������������
     
������  isolation
     һ�������ڴ�������У���������ܵ����������Ӱ�죬��ô�����ִ�����Ǻ��޹켣��ѭ�����ݿ�����ս��Ҳ������ġ�������������ݿ��Ӱ���Ƕ����ģ���ô��һ�����������������������޸ģ��п��ܲ�����.���ȡdirty read 2.���ɸ��� 3.Ӱ���ȡ
�־���  durablity
     �־�����ָ������һ���ύ�������ݿ���޸�Ҳ����¼�����ý����С����û��ύ����ʱ��oracle���ݿ�������������redo�ļ���redo�ļ���¼����������ݿ��޸ĵ�ϸ�ڣ���ʹϵͳ������oracleͬ����������redo�ļ���֤��������ɹ��ύ��
*/

--һ������ݲ�����������Щ������Ƶ������ʱ����read only
SET TRANSACTION READ ONLY;
INSERT INTO warehouse w VALUES(5,'C��','ë��',200);

--���ڱ������пɼ��ģ������������޸��򲻿ɼ�
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
INSERT INTO warehouse w VALUES(5,'C��','ë��',200);
SELECT * FROM warehouse;

--����ĸ�����
ALTER TABLE warehouse ADD CONSTRAINTS pk_id PRIMARY KEY (warehouse_id);
--����A ִ�е�һ���ִ������B��Ȼ��ִ�еڶ���ᱨ�����ܵ�������select��ѯû�г���
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
INSERT INTO warehouse w VALUES(5,'C��','ë��',200);
SELECT * FROM warehouse;
--����B
INSERT INTO warehouse w VALUES(5,'C��','ë��',200);
COMMIT;
SELECT * FROM warehouse;

/*
����������
������ָ���߳�ͬʱ���ʺͲ������ݿ⡣�����û�ͬһʱ�̷�����ͬ�����ݿ���Դʱ�����������������������ƻ����ݵ�һ���ԡ������Ǵ���������Ҫ�ֶΡ�Ҳ����˵���û����޸�ĳһ��Դǰ���������Ȼ����Դ���޸�Ȩ���������޸�Ȩ���������ԡ�
������ָ�������̶����Ի�öԷ�����ȡ�������Ӷ�����˫���໥�ȴ������û�ж�Ӧ�Ĵ����ʩ����ô����״̬һֱ������ȥ��

oracle�еı�����
       ��for update������
       SELECT * FROM student FOR UPDATE NOWAIT;
       SELECT * FROM student FOR UPDATE;
oracle�е��ֹ���
       lock table student in share mode;
         
*/
--oracle�еı�����
--����A,����FOR UPDATE������һ������
SELECT * FROM student FOR UPDATE;
--����B
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

--����A,ִ�е�һ���ִ������B,Ȼ��ִ�е������ɹ�                     
lock table student in share mode;
update student s set s.age=20;
--����B                     
lock table student in share mode;                    

/*
oracle�ڿ����е�Ӧ��
1. ��������
2. ��������
3. ��������
4. �����ؽ��
5. �ر�����
java������oracle�������ݿ�
1. jdbc (java database connectivity standard)s
*/

sqlplus /nolog
connect / as sysdba
startup FORCE
sqlplus "/as sysdba"
shutdown immediate      --ֹͣ����
startup                         -- �������񣬹۲�����ʱ���������ļ����ر�������ס���������ļ�

select count(*) from v$process --��ǰ��������
select value from v$parameter where name = 'processes' --���ݿ���������������

--�޸����������:
alter system set processes = 300 scope = spfile;

--�������ݿ�:
shutdown immediate;
startup;

--�鿴��ǰ����Щ�û�����ʹ������
SELECT osuser, a.username,cpu_time/executions/1000000||'s', sql_fulltext,machine 
from v$session a, v$sqlarea b
where a.sql_address =b.address order by cpu_time/executions desc;

##ORA-12514 TNS ��������ǰ�޷�ʶ���������������������

���Ǽ���listener.ora    
���������ļ�listener.ora�п��Բ���ָ�������ķ���������װOracle10g��Ҳ��û��ָ���ģ������������һ��ֻҪ���ݿ��������ͻ����������ݿ�Ҳû��ʲô���⣬������ʱ�ظ������ر�Ҳ�����ORA-12514����     
��Ȼlistener.ora��û��ָ�����������ǿ�����listener.ora�ļ���ָ��������ʵ����������������Ӧ�ÿ������ӡ�
