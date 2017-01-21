/*

DDL: create/alter/drop  
     数据定义语言（data definition language）   
DCL: grant/revoke
     数据控制语言（Data Control Language）
DML: insert/update/delete
     数据操作语言（Data Manipulation Language）
     
NDS本地动态sql语句     native dynamic sql
     execute immediate 执行ddl,dml,dcl
     游标open for fetch close
     批处理语句，bulk语句     
*/
--不可以这样写　'select count(1) INTO v_count from ' || table_name;
CREATE OR REPLACE FUNCTION get_tab_count(table_name VARCHAR2)
  RETURN PLS_INTEGER IS
  v_sql   VARCHAR2(32767);
  v_count NUMBER := 0;
BEGIN
  v_sql := 'select count(1) from ' || table_name;
  EXECUTE IMMEDIATE v_sql
    INTO v_count;
  RETURN v_count;
END;
/

SELECT get_tab_count('scott.emp') FROM dual;

--oracle不同系统之间时间转换（NLS_DATE_LANGUAGE）
SELECT TO_CHAR(SYSDATE,'DY') FROM DUAL;  
SELECT TO_CHAR(SYSDATE,'DAY','NLS_DATE_LANGUAGE = ''SIMPLIFIED CHINESE''') from dual;  
SELECT TO_CHAR(SYSDATE,'DAY','NLS_DATE_LANGUAGE = American') from dual;  
SELECT TO_CHAR(SYSDATE,'DAY','NLS_DATE_LANGUAGE = Korean') from dual;

--动态语句创建表
/* 
hiredate DATE not NOT null, 不要写两个not
CONSTRAINT pk_name_hiredate PRIMARY KEY(ename,hiredate)); 后面不要加;
*/
DROP TABLE test_emp;
DECLARE
  v_count NUMBER := 0;
BEGIN
  SELECT COUNT(1)
    INTO v_count
    FROM user_tables t
   WHERE t.TABLE_NAME = 'test_emp';
  IF v_count > 0 THEN
    dbms_output.put_line('表已存在');
  ELSE
    dbms_output.put_line('表不存在');
    EXECUTE IMMEDIATE 'CREATE TABLE test_emp(
      ename VARCHAR2(30) not null,
      hiredate DATE not null,
      status number(2),
      CONSTRAINT pk_name_hiredate PRIMARY KEY(ename,hiredate))';
  END IF;
END;
SELECT * FROM  test_emp;

--创建一个表，并动态的插入一条数据
--ORA-00911: 无效字符 DDL/DML都不能有分号在sql_statement变量中
DROP TABLE tmp;
DECLARE
  sql_statement VARCHAR2(100);
BEGIN
  sql_statement := 'create table tmp(id number,name varchar2(30))';
  EXECUTE IMMEDIATE sql_statement;
  sql_statement := 'insert into tmp values (1,''zhangshan'')';
  EXECUTE IMMEDIATE sql_statement;
  EXCEPTION 
    WHEN OTHERS THEN
      dbms_output.put_line(SQLERRM);
      ROLLBACK;
END;
/
SELECT * FROM tmp;

--执行block块
/*  EXECUTE IMMEDIATE ''TRUNCATE table tmp''; 不能直接写TRUNCATE table tmp;且后面不能分号*/
DECLARE
  v_block VARCHAR2(200);
BEGIN
  v_block := 'DECLARE
  i NUMBER:=10;
  BEGIN
  EXECUTE IMMEDIATE ''TRUNCATE table tmp'';
  FOR j IN 1..i LOOP
    INSERT INTO tmp VALUES(j,'' 李思思 '');
    END LOOP;
  END;';
  EXECUTE IMMEDIATE v_block;
  COMMIT;
END;

--带参数的动态语句
DELETE FROM scott.dept WHERE deptno=60;
DECLARE
  v_sql    VARCHAR2(200);
  v_deptno NUMBER := 60;
  v_dname   scott.dept.dname%TYPE := '开发部';
  v_loc  scott.dept.loc%TYPE := '新西兰';
  v_new_dname  v_dname%TYPE := '销售部';

BEGIN
  v_sql := 'INSERT INTO scott.dept VALUES(:1,:2,:3)';
  EXECUTE IMMEDIATE v_sql USING v_deptno, v_dname,v_loc;
  EXECUTE IMMEDIATE 'update scott.dept set dname=:1 where deptno=:2' USING v_new_dname, v_deptno;
  COMMIT;
END;
/
SELECT * FROM scott.dept ;
--注意嵌套表的.first和.last方法
DECLARE
  v_sql VARCHAR2(200);
  TYPE t_id IS TABLE OF INTEGER;
  TYPE t_name IS TABLE OF VARCHAR2(20);
  v_list_id   t_id := t_id(1, 2, 3, 4, 5, 6);
  v_list_name t_name := t_name('张三',
                               '李四',
                               '张飞',
                               '关羽',
                               '阿斗',
                               '刘备');

BEGIN

  EXECUTE IMMEDIATE 'create table emp_nane_tab(id number,name varchar2(20))';
  v_sql := 'insert into emp_nane_tab values(:1,:2)';
  FOR i IN v_list_id.first .. v_list_id.last LOOP
    EXECUTE IMMEDIATE v_sql
      USING v_list_id(i), v_list_name(i);
  END LOOP;
  COMMIT;
END;
/
SELECT * FROM emp_nane_tab;
--存储过程中使用动态sql
CREATE OR REPLACE PROCEDURE clear_tab_content(p_tab VARCHAR2) IS
  v_sql VARCHAR2(100);
BEGIN
  v_sql := 'truncate table ' || p_tab;
  EXECUTE IMMEDIATE v_sql;
END;
/
BEGIN
  clear_tab_content('emp_nane_tab');
END;
/
SELECT * FROM emp_nane_tab;
--绑定变量并返回员工工次 execute immediate (sql returning xxx into xxx) using ... returning into xxx
DROP TRIGGER t_emp_maxsal;
SELECT * FROM scott.emp WHERE empno=9003;
DECLARE
  v_empno   NUMBER := 9003;
  v_percent NUMBER(4, 2) := 0.12;
  v_sal     NUMBER;
  sql_stmt  VARCHAR2(200);
BEGIN
  sql_stmt := 'update scott.emp set sal=sal*(1+:percent) where empno=:empno returning sal into :salary';
  EXECUTE IMMEDIATE sql_stmt
    USING v_percent, v_empno
    RETURNING INTO v_sal;
  dbms_output.put_line('员工的新工资为：' || v_sal);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line(SQLERRM);
    ROLLBACK;
END;
/
SELECT * FROM scott.emp WHERE empno=9003;

DECLARE
   sql_stmt  VARCHAR2(100);           --保存动态SQL语句的变量
   v_deptno NUMBER(4) :=20;           --部门编号，用于绑定变量
   v_empno NUMBER(4):=7369;           --员工编号，用于绑定变量
   v_dname  VARCHAR2(20);             --部门名称，获取查询结果
   v_loc  VARCHAR2(20);               --部门位置，获取查询结果
   emp_row emp%ROWTYPE;               --保存结果的记录类型
BEGIN
   --查询dept表的动态SQL语句
   sql_stmt:='SELECT dname,loc FROM dept WHERE deptno=:deptno';
   --执行动态SQL语句并记录查询结果
   EXECUTE IMMEDIATE sql_stmt INTO v_dname,v_loc USING v_deptno ;
   --查询emp表的特定员工编号的记录
   sql_stmt:='SELECT * FROM emp WHERE empno=:empno';
   --将emp表中的特定行内容写入emp_row记录中
   EXECUTE IMMEDIATE sql_stmt INTO emp_row USING v_empno;
   DBMS_OUTPUT.put_line('查询的部门名称为：'||v_dname);
   DBMS_OUTPUT.put_line('查询的员工编号为：'||emp_row.ename);   
END;

CREATE OR REPLACE PROCEDURE create_dept(
deptno IN OUT NUMBER,             --IN OUT变量，用来获取或输出deptno值
dname IN VARCHAR2,                --部门名称
loc IN VARCHAR2                   --部门地址
)AS
BEGIN
  --如果deptno没有指定值
  IF deptno IS NULL THEN
     --从序列中取一个值
     SELECT deptno_seq.NEXTVAL INTO deptno FROM DUAL;
  END IF;
  --向dept表中插入记录
  INSERT INTO dept VALUES(deptno,dname,loc);
END;
/
CREATE SEQUENCE deptno_seq;
SELECT deptno_seq.NEXTVAL FROM dual;
--USING IN OUT xxx参数
DECLARE
   plsql_block   VARCHAR2 (500);
   v_deptno      NUMBER (2);
   v_dname       VARCHAR2 (14)  := '网络部';
   v_loc         VARCHAR2 (13)  := '也门';
BEGIN
   plsql_block := 'BEGIN create_dept(:a,:b,:c);END;';
   --在这里指定过程需要的IN OUT参数模式
   EXECUTE IMMEDIATE plsql_block
               USING IN OUT v_deptno, v_dname, v_loc;
   DBMS_OUTPUT.put_line ('新建部门的编号为：' || v_deptno);
END;

DECLARE
   TYPE emp_cur_type IS REF CURSOR;      --定义游标类型
   emp_cur emp_cur_type;                 --定义游标变量
   v_deptno NUMBER(4) := '&deptno';      --定义部门编号绑定变量
   v_empno NUMBER(4);                                         
   v_ename VARCHAR2(25);
BEGIN
   OPEN emp_cur FOR                  --打开动态游标
      'SELECT empno, ename FROM emp '||
      'WHERE deptno = :1'
   USING v_deptno;
   NULL;
END;

DECLARE
   TYPE emp_cur_type IS REF CURSOR;      --定义游标类型
   emp_cur emp_cur_type;                 --定义游标变量
   v_deptno NUMBER(4) := '&deptno';      --定义部门编号绑定变量
   v_empno NUMBER(4);                                         
   v_ename VARCHAR2(25);
BEGIN
   OPEN emp_cur FOR                       --打开动态游标
      'SELECT empno, ename FROM emp '||
      'WHERE deptno = :1'
   USING v_deptno;
   LOOP
      FETCH emp_cur INTO v_empno, v_ename; --循环提取游标数据  
      EXIT WHEN emp_cur%NOTFOUND;          --没有数据时退出循环
      DBMS_OUTPUT.PUT_LINE ('员工编号: '||v_empno);
      DBMS_OUTPUT.PUT_LINE ('员工名称:  '||v_ename);
   END LOOP;
END;
SELECT * FROM scott.emp;
DECLARE
  TYPE emp_cur_type IS REF CURSOR; --定义游标类型
  emp_cur  emp_cur_type; --定义游标变量
  v_deptno NUMBER(4) := '&deptno'; --定义部门编号绑定变量
  v_empno  NUMBER(4);
  v_ename  VARCHAR2(25);
BEGIN
  OPEN emp_cur FOR --打开动态游标
   'SELECT empno, ename FROM emp ' || 'WHERE deptno = :1'
    USING v_deptno;
  LOOP
    FETCH emp_cur
      INTO v_empno, v_ename; --循环提取游标数据  
    EXIT WHEN emp_cur%NOTFOUND; --没有数据时退出循环
    DBMS_OUTPUT.PUT_LINE('员工编号: ' || v_empno);
    DBMS_OUTPUT.PUT_LINE('员工名称:  ' || v_ename);
  END LOOP;
  CLOSE emp_cur; --关闭游标变量
EXCEPTION
  WHEN OTHERS THEN
    IF emp_cur%FOUND THEN
      --如果出现异常，游标变量未关闭
      CLOSE emp_cur; --关闭游标
    END IF;
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SUBSTR(SQLERRM, 1, 200));
END;

--注意索引表的.COUNT方法
/*
execute immediate 'dml语句 returning field1,field2 into :field1,:field2 ' 
using para1,para2.. returning bulk collect into xxx,xxx
*/
DECLARE
   --定义索引表类型，用来保存从DML语句中返回的结果
   TYPE ename_table_type IS TABLE OF VARCHAR2(25) INDEX BY BINARY_INTEGER;
   TYPE sal_table_type IS TABLE OF NUMBER(10,2) INDEX BY BINARY_INTEGER;   
   ename_tab ename_table_type;
   sal_tab sal_table_type;
   v_deptno NUMBER(4) :=20;                             --定义部门绑定变量
   v_percent NUMBER(4,2) := 0.12;                       --定义加薪比率绑定变量
   sql_stmt  VARCHAR2(500);                             --保存SQL语句的变量
BEGIN
   --定义更新emp表的sal字段值的动态SQL语句
   sql_stmt:='UPDATE emp SET sal=sal*(1+:percent) '
             ||' WHERE deptno=:deptno RETURNING ename,sal INTO :ename,:salary';
   EXECUTE IMMEDIATE sql_stmt USING v_percent, v_deptno
      RETURNING BULK COLLECT INTO ename_tab,sal_tab;   --使用RETURNING BULK COLLECT INTO子句获取返回值
   FOR i IN 1..ename_tab.COUNT LOOP                    --输出返回的结果值 
      DBMS_OUTPUT.put_line('员工'||ename_tab(i)||'调薪后的薪资：'||sal_tab(i));
   END LOOP;
END;

DECLARE
   TYPE ename_table_type IS TABLE OF VARCHAR2(20) INDEX BY BINARY_INTEGER;
   TYPE empno_table_type IS TABLE OF NUMBER(24) INDEX BY BINARY_INTEGER; 
   ename_tab ename_table_type;              --定义保存多行返回值的索引表
   empno_tab empno_table_type;  
   v_deptno NUMBER(4) := '&deptno';          --定义部门编号绑定变量
   sql_stmt VARCHAR2(500);
BEGIN
   --定义多行查询的SQL语句
   sql_stmt:='SELECT empno, ename FROM emp '||'WHERE deptno = :1';
   EXECUTE IMMEDIATE sql_stmt 
   BULK COLLECT INTO empno_tab,ename_tab               --批量插入到索引表
   USING v_deptno;   
   FOR i IN 1..ename_tab.COUNT LOOP                    --输出返回的结果值 
      DBMS_OUTPUT.put_line('员工编号'||empno_tab(i)
                                         ||'员工名称：'||ename_tab(i));
   END LOOP;          
END;
--引用游标实现动态语句
DECLARE
   TYPE ename_table_type IS TABLE OF VARCHAR2(20) INDEX BY BINARY_INTEGER;
   TYPE empno_table_type IS TABLE OF NUMBER(24) INDEX BY BINARY_INTEGER;
   TYPE emp_cur_type IS REF CURSOR;         --定义游标类型    
   ename_tab ename_table_type;              --定义保存多行返回值的索引表
   empno_tab empno_table_type;  
   emp_cur emp_cur_type;                    --定义游标变量
   v_deptno NUMBER(4) := '&deptno';         --定义部门编号绑定变量
BEGIN
   OPEN emp_cur FOR                         --打开动态游标
      'SELECT empno, ename FROM emp '||
      'WHERE deptno = :1'
   USING v_deptno;
   FETCH emp_cur BULK COLLECT INTO empno_tab, ename_tab; --批量提取游标数据  
   CLOSE emp_cur;                                        --关闭游标变量
   FOR i IN 1..ename_tab.COUNT LOOP                      --输出返回的结果值 
      DBMS_OUTPUT.put_line('员工编号'||empno_tab(i)
                                         ||'员工名称：'||ename_tab(i));
   END LOOP;       
END;

SELECT * FROM emp;


DECLARE
   --定义索引表类型，用来保存从DML语句中返回的结果
   TYPE ename_table_type IS TABLE OF VARCHAR2(25) INDEX BY BINARY_INTEGER;
   TYPE sal_table_type IS TABLE OF NUMBER(10,2) INDEX BY BINARY_INTEGER;   
   TYPE empno_table_type IS TABLE OF NUMBER(4);         --定义嵌套表类型，用于批量输入员工编号  
   ename_tab ename_table_type;
   sal_tab sal_table_type;
   empno_tab empno_table_type;
   v_deptno NUMBER(4) :=20;                             --定义部门绑定变量
   v_percent NUMBER(4,2) := 0.12;                       --定义加薪比率绑定变量
   sql_stmt  VARCHAR2(500);                             --保存SQL语句的变量
BEGIN
   empno_tab:=empno_table_type(7369,7499,7521,7566);    --初始化嵌套表
     --定义更新emp表的sal字段值的动态SQL语句
   sql_stmt:='UPDATE emp SET sal=sal*(1+:percent) '
             ||' WHERE empno=:empno RETURNING ename,sal INTO :ename,:salary';
   FORALL i IN 1..empno_tab.COUNT                        --使用FORALL语句批量输入参数
      EXECUTE IMMEDIATE sql_stmt USING v_percent, empno_tab(i)  --这里使用来自嵌套表的参数
      RETURNING BULK COLLECT INTO ename_tab,sal_tab;   --使用RETURNING BULK COLLECT INTO子句获取返回值
   FOR i IN 1..ename_tab.COUNT LOOP                    --输出返回的结果值 
      DBMS_OUTPUT.put_line('员工'||ename_tab(i)||'调薪后的薪资：'||sal_tab(i));
   END LOOP;
END;

DECLARE
   col_in     VARCHAR2(10):='sal';    --列名
   start_in   DATE;        --起始日期
   end_in     DATE;        --结束日期
   val_in     NUMBER;      --输入参数值
   plsql_str    VARCHAR2 (32767)
      :=    '
         BEGIN
             UPDATE emp SET '
             || col_in
             || ' = :val
            WHERE hiredate BETWEEN :lodate AND :hidate
            AND :val IS NOT NULL;
        END;
        '; --动态PLSQL语句
BEGIN
   --执行动态SQL语句，为重复的val_in传入多次作为绑定变量
   EXECUTE IMMEDIATE plsql_str
               USING val_in,start_in,end_in;
END;


--定义一个删除任何数据库对象的通用的过程
CREATE OR REPLACE PROCEDURE drop_obj (kind IN VARCHAR2, NAME IN VARCHAR2)
AUTHID CURRENT_USER       --定义调用者权限
AS
BEGIN
   EXECUTE IMMEDIATE 'DROP ' || kind || ' ' || NAME;
EXCEPTION
WHEN OTHERS THEN
   RAISE;   
END;
/
SELECT deptno_seq.nextval FROM dual;
BEGIN
  drop_obj('sequence', 'deptno_seq');
END;
/

DECLARE
   v_null   CHAR (1);                      --在运行时该变量自动被设置为NULL值
BEGIN
   EXECUTE IMMEDIATE 'UPDATE emp SET comm=:x'
               USING v_null;                                     --传入NULL值
END;

CREATE OR REPLACE PROCEDURE ddl_execution (ddl_string IN VARCHAR2)
   AUTHID CURRENT_USER IS            --使用调用者权限
BEGIN
   EXECUTE IMMEDIATE ddl_string;     --执行动态SQL语句
EXCEPTION
   WHEN OTHERS                       --捕捉错误  
   THEN
      DBMS_OUTPUT.PUT_LINE (      --显示错误消息
         '动态SQL语句错误：' || DBMS_UTILITY.FORMAT_ERROR_STACK);
      DBMS_OUTPUT.PUT_LINE (      --显示当前执行的SQL语句
         '   执行的SQL语句为： "' || ddl_string || '"');
      RAISE;
END ddl_execution;
/


CREATE TABLE emp_test(ID NUMBER);
EXEC ddl_execution('alter table emp_test add emp_sal number NULL');
SELECT * FROM emp_test;
