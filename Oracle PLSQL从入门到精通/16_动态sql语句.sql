/*

DDL: create/alter/drop  
     ���ݶ������ԣ�data definition language��   
DCL: grant/revoke
     ���ݿ������ԣ�Data Control Language��
DML: insert/update/delete
     ���ݲ������ԣ�Data Manipulation Language��
     
NDS���ض�̬sql���     native dynamic sql
     execute immediate ִ��ddl,dml,dcl
     �α�open for fetch close
     ��������䣬bulk���     
*/
--����������д��'select count(1) INTO v_count from ' || table_name;
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

--oracle��ͬϵͳ֮��ʱ��ת����NLS_DATE_LANGUAGE��
SELECT TO_CHAR(SYSDATE,'DY') FROM DUAL;  
SELECT TO_CHAR(SYSDATE,'DAY','NLS_DATE_LANGUAGE = ''SIMPLIFIED CHINESE''') from dual;  
SELECT TO_CHAR(SYSDATE,'DAY','NLS_DATE_LANGUAGE = American') from dual;  
SELECT TO_CHAR(SYSDATE,'DAY','NLS_DATE_LANGUAGE = Korean') from dual;

--��̬��䴴����
/* 
hiredate DATE not NOT null, ��Ҫд����not
CONSTRAINT pk_name_hiredate PRIMARY KEY(ename,hiredate)); ���治Ҫ��;
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
    dbms_output.put_line('���Ѵ���');
  ELSE
    dbms_output.put_line('������');
    EXECUTE IMMEDIATE 'CREATE TABLE test_emp(
      ename VARCHAR2(30) not null,
      hiredate DATE not null,
      status number(2),
      CONSTRAINT pk_name_hiredate PRIMARY KEY(ename,hiredate))';
  END IF;
END;
SELECT * FROM  test_emp;

--����һ��������̬�Ĳ���һ������
--ORA-00911: ��Ч�ַ� DDL/DML�������зֺ���sql_statement������
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

--ִ��block��
/*  EXECUTE IMMEDIATE ''TRUNCATE table tmp''; ����ֱ��дTRUNCATE table tmp;�Һ��治�ֺܷ�*/
DECLARE
  v_block VARCHAR2(200);
BEGIN
  v_block := 'DECLARE
  i NUMBER:=10;
  BEGIN
  EXECUTE IMMEDIATE ''TRUNCATE table tmp'';
  FOR j IN 1..i LOOP
    INSERT INTO tmp VALUES(j,'' ��˼˼ '');
    END LOOP;
  END;';
  EXECUTE IMMEDIATE v_block;
  COMMIT;
END;

--�������Ķ�̬���
DELETE FROM scott.dept WHERE deptno=60;
DECLARE
  v_sql    VARCHAR2(200);
  v_deptno NUMBER := 60;
  v_dname   scott.dept.dname%TYPE := '������';
  v_loc  scott.dept.loc%TYPE := '������';
  v_new_dname  v_dname%TYPE := '���۲�';

BEGIN
  v_sql := 'INSERT INTO scott.dept VALUES(:1,:2,:3)';
  EXECUTE IMMEDIATE v_sql USING v_deptno, v_dname,v_loc;
  EXECUTE IMMEDIATE 'update scott.dept set dname=:1 where deptno=:2' USING v_new_dname, v_deptno;
  COMMIT;
END;
/
SELECT * FROM scott.dept ;
--ע��Ƕ�ױ��.first��.last����
DECLARE
  v_sql VARCHAR2(200);
  TYPE t_id IS TABLE OF INTEGER;
  TYPE t_name IS TABLE OF VARCHAR2(20);
  v_list_id   t_id := t_id(1, 2, 3, 4, 5, 6);
  v_list_name t_name := t_name('����',
                               '����',
                               '�ŷ�',
                               '����',
                               '����',
                               '����');

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
--�洢������ʹ�ö�̬sql
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
--�󶨱���������Ա������ execute immediate (sql returning xxx into xxx) using ... returning into xxx
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
  dbms_output.put_line('Ա�����¹���Ϊ��' || v_sal);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line(SQLERRM);
    ROLLBACK;
END;
/
SELECT * FROM scott.emp WHERE empno=9003;

DECLARE
   sql_stmt  VARCHAR2(100);           --���涯̬SQL���ı���
   v_deptno NUMBER(4) :=20;           --���ű�ţ����ڰ󶨱���
   v_empno NUMBER(4):=7369;           --Ա����ţ����ڰ󶨱���
   v_dname  VARCHAR2(20);             --�������ƣ���ȡ��ѯ���
   v_loc  VARCHAR2(20);               --����λ�ã���ȡ��ѯ���
   emp_row emp%ROWTYPE;               --�������ļ�¼����
BEGIN
   --��ѯdept��Ķ�̬SQL���
   sql_stmt:='SELECT dname,loc FROM dept WHERE deptno=:deptno';
   --ִ�ж�̬SQL��䲢��¼��ѯ���
   EXECUTE IMMEDIATE sql_stmt INTO v_dname,v_loc USING v_deptno ;
   --��ѯemp����ض�Ա����ŵļ�¼
   sql_stmt:='SELECT * FROM emp WHERE empno=:empno';
   --��emp���е��ض�������д��emp_row��¼��
   EXECUTE IMMEDIATE sql_stmt INTO emp_row USING v_empno;
   DBMS_OUTPUT.put_line('��ѯ�Ĳ�������Ϊ��'||v_dname);
   DBMS_OUTPUT.put_line('��ѯ��Ա�����Ϊ��'||emp_row.ename);   
END;

CREATE OR REPLACE PROCEDURE create_dept(
deptno IN OUT NUMBER,             --IN OUT������������ȡ�����deptnoֵ
dname IN VARCHAR2,                --��������
loc IN VARCHAR2                   --���ŵ�ַ
)AS
BEGIN
  --���deptnoû��ָ��ֵ
  IF deptno IS NULL THEN
     --��������ȡһ��ֵ
     SELECT deptno_seq.NEXTVAL INTO deptno FROM DUAL;
  END IF;
  --��dept���в����¼
  INSERT INTO dept VALUES(deptno,dname,loc);
END;
/
CREATE SEQUENCE deptno_seq;
SELECT deptno_seq.NEXTVAL FROM dual;
--USING IN OUT xxx����
DECLARE
   plsql_block   VARCHAR2 (500);
   v_deptno      NUMBER (2);
   v_dname       VARCHAR2 (14)  := '���粿';
   v_loc         VARCHAR2 (13)  := 'Ҳ��';
BEGIN
   plsql_block := 'BEGIN create_dept(:a,:b,:c);END;';
   --������ָ��������Ҫ��IN OUT����ģʽ
   EXECUTE IMMEDIATE plsql_block
               USING IN OUT v_deptno, v_dname, v_loc;
   DBMS_OUTPUT.put_line ('�½����ŵı��Ϊ��' || v_deptno);
END;

DECLARE
   TYPE emp_cur_type IS REF CURSOR;      --�����α�����
   emp_cur emp_cur_type;                 --�����α����
   v_deptno NUMBER(4) := '&deptno';      --���岿�ű�Ű󶨱���
   v_empno NUMBER(4);                                         
   v_ename VARCHAR2(25);
BEGIN
   OPEN emp_cur FOR                  --�򿪶�̬�α�
      'SELECT empno, ename FROM emp '||
      'WHERE deptno = :1'
   USING v_deptno;
   NULL;
END;

DECLARE
   TYPE emp_cur_type IS REF CURSOR;      --�����α�����
   emp_cur emp_cur_type;                 --�����α����
   v_deptno NUMBER(4) := '&deptno';      --���岿�ű�Ű󶨱���
   v_empno NUMBER(4);                                         
   v_ename VARCHAR2(25);
BEGIN
   OPEN emp_cur FOR                       --�򿪶�̬�α�
      'SELECT empno, ename FROM emp '||
      'WHERE deptno = :1'
   USING v_deptno;
   LOOP
      FETCH emp_cur INTO v_empno, v_ename; --ѭ����ȡ�α�����  
      EXIT WHEN emp_cur%NOTFOUND;          --û������ʱ�˳�ѭ��
      DBMS_OUTPUT.PUT_LINE ('Ա�����: '||v_empno);
      DBMS_OUTPUT.PUT_LINE ('Ա������:  '||v_ename);
   END LOOP;
END;
SELECT * FROM scott.emp;
DECLARE
  TYPE emp_cur_type IS REF CURSOR; --�����α�����
  emp_cur  emp_cur_type; --�����α����
  v_deptno NUMBER(4) := '&deptno'; --���岿�ű�Ű󶨱���
  v_empno  NUMBER(4);
  v_ename  VARCHAR2(25);
BEGIN
  OPEN emp_cur FOR --�򿪶�̬�α�
   'SELECT empno, ename FROM emp ' || 'WHERE deptno = :1'
    USING v_deptno;
  LOOP
    FETCH emp_cur
      INTO v_empno, v_ename; --ѭ����ȡ�α�����  
    EXIT WHEN emp_cur%NOTFOUND; --û������ʱ�˳�ѭ��
    DBMS_OUTPUT.PUT_LINE('Ա�����: ' || v_empno);
    DBMS_OUTPUT.PUT_LINE('Ա������:  ' || v_ename);
  END LOOP;
  CLOSE emp_cur; --�ر��α����
EXCEPTION
  WHEN OTHERS THEN
    IF emp_cur%FOUND THEN
      --��������쳣���α����δ�ر�
      CLOSE emp_cur; --�ر��α�
    END IF;
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SUBSTR(SQLERRM, 1, 200));
END;

--ע���������.COUNT����
/*
execute immediate 'dml��� returning field1,field2 into :field1,:field2 ' 
using para1,para2.. returning bulk collect into xxx,xxx
*/
DECLARE
   --�������������ͣ����������DML����з��صĽ��
   TYPE ename_table_type IS TABLE OF VARCHAR2(25) INDEX BY BINARY_INTEGER;
   TYPE sal_table_type IS TABLE OF NUMBER(10,2) INDEX BY BINARY_INTEGER;   
   ename_tab ename_table_type;
   sal_tab sal_table_type;
   v_deptno NUMBER(4) :=20;                             --���岿�Ű󶨱���
   v_percent NUMBER(4,2) := 0.12;                       --�����н���ʰ󶨱���
   sql_stmt  VARCHAR2(500);                             --����SQL���ı���
BEGIN
   --�������emp���sal�ֶ�ֵ�Ķ�̬SQL���
   sql_stmt:='UPDATE emp SET sal=sal*(1+:percent) '
             ||' WHERE deptno=:deptno RETURNING ename,sal INTO :ename,:salary';
   EXECUTE IMMEDIATE sql_stmt USING v_percent, v_deptno
      RETURNING BULK COLLECT INTO ename_tab,sal_tab;   --ʹ��RETURNING BULK COLLECT INTO�Ӿ��ȡ����ֵ
   FOR i IN 1..ename_tab.COUNT LOOP                    --������صĽ��ֵ 
      DBMS_OUTPUT.put_line('Ա��'||ename_tab(i)||'��н���н�ʣ�'||sal_tab(i));
   END LOOP;
END;

DECLARE
   TYPE ename_table_type IS TABLE OF VARCHAR2(20) INDEX BY BINARY_INTEGER;
   TYPE empno_table_type IS TABLE OF NUMBER(24) INDEX BY BINARY_INTEGER; 
   ename_tab ename_table_type;              --���屣����з���ֵ��������
   empno_tab empno_table_type;  
   v_deptno NUMBER(4) := '&deptno';          --���岿�ű�Ű󶨱���
   sql_stmt VARCHAR2(500);
BEGIN
   --������в�ѯ��SQL���
   sql_stmt:='SELECT empno, ename FROM emp '||'WHERE deptno = :1';
   EXECUTE IMMEDIATE sql_stmt 
   BULK COLLECT INTO empno_tab,ename_tab               --�������뵽������
   USING v_deptno;   
   FOR i IN 1..ename_tab.COUNT LOOP                    --������صĽ��ֵ 
      DBMS_OUTPUT.put_line('Ա�����'||empno_tab(i)
                                         ||'Ա�����ƣ�'||ename_tab(i));
   END LOOP;          
END;
--�����α�ʵ�ֶ�̬���
DECLARE
   TYPE ename_table_type IS TABLE OF VARCHAR2(20) INDEX BY BINARY_INTEGER;
   TYPE empno_table_type IS TABLE OF NUMBER(24) INDEX BY BINARY_INTEGER;
   TYPE emp_cur_type IS REF CURSOR;         --�����α�����    
   ename_tab ename_table_type;              --���屣����з���ֵ��������
   empno_tab empno_table_type;  
   emp_cur emp_cur_type;                    --�����α����
   v_deptno NUMBER(4) := '&deptno';         --���岿�ű�Ű󶨱���
BEGIN
   OPEN emp_cur FOR                         --�򿪶�̬�α�
      'SELECT empno, ename FROM emp '||
      'WHERE deptno = :1'
   USING v_deptno;
   FETCH emp_cur BULK COLLECT INTO empno_tab, ename_tab; --������ȡ�α�����  
   CLOSE emp_cur;                                        --�ر��α����
   FOR i IN 1..ename_tab.COUNT LOOP                      --������صĽ��ֵ 
      DBMS_OUTPUT.put_line('Ա�����'||empno_tab(i)
                                         ||'Ա�����ƣ�'||ename_tab(i));
   END LOOP;       
END;

SELECT * FROM emp;


DECLARE
   --�������������ͣ����������DML����з��صĽ��
   TYPE ename_table_type IS TABLE OF VARCHAR2(25) INDEX BY BINARY_INTEGER;
   TYPE sal_table_type IS TABLE OF NUMBER(10,2) INDEX BY BINARY_INTEGER;   
   TYPE empno_table_type IS TABLE OF NUMBER(4);         --����Ƕ�ױ����ͣ�������������Ա�����  
   ename_tab ename_table_type;
   sal_tab sal_table_type;
   empno_tab empno_table_type;
   v_deptno NUMBER(4) :=20;                             --���岿�Ű󶨱���
   v_percent NUMBER(4,2) := 0.12;                       --�����н���ʰ󶨱���
   sql_stmt  VARCHAR2(500);                             --����SQL���ı���
BEGIN
   empno_tab:=empno_table_type(7369,7499,7521,7566);    --��ʼ��Ƕ�ױ�
     --�������emp���sal�ֶ�ֵ�Ķ�̬SQL���
   sql_stmt:='UPDATE emp SET sal=sal*(1+:percent) '
             ||' WHERE empno=:empno RETURNING ename,sal INTO :ename,:salary';
   FORALL i IN 1..empno_tab.COUNT                        --ʹ��FORALL��������������
      EXECUTE IMMEDIATE sql_stmt USING v_percent, empno_tab(i)  --����ʹ������Ƕ�ױ�Ĳ���
      RETURNING BULK COLLECT INTO ename_tab,sal_tab;   --ʹ��RETURNING BULK COLLECT INTO�Ӿ��ȡ����ֵ
   FOR i IN 1..ename_tab.COUNT LOOP                    --������صĽ��ֵ 
      DBMS_OUTPUT.put_line('Ա��'||ename_tab(i)||'��н���н�ʣ�'||sal_tab(i));
   END LOOP;
END;

DECLARE
   col_in     VARCHAR2(10):='sal';    --����
   start_in   DATE;        --��ʼ����
   end_in     DATE;        --��������
   val_in     NUMBER;      --�������ֵ
   plsql_str    VARCHAR2 (32767)
      :=    '
         BEGIN
             UPDATE emp SET '
             || col_in
             || ' = :val
            WHERE hiredate BETWEEN :lodate AND :hidate
            AND :val IS NOT NULL;
        END;
        '; --��̬PLSQL���
BEGIN
   --ִ�ж�̬SQL��䣬Ϊ�ظ���val_in��������Ϊ�󶨱���
   EXECUTE IMMEDIATE plsql_str
               USING val_in,start_in,end_in;
END;


--����һ��ɾ���κ����ݿ�����ͨ�õĹ���
CREATE OR REPLACE PROCEDURE drop_obj (kind IN VARCHAR2, NAME IN VARCHAR2)
AUTHID CURRENT_USER       --���������Ȩ��
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
   v_null   CHAR (1);                      --������ʱ�ñ����Զ�������ΪNULLֵ
BEGIN
   EXECUTE IMMEDIATE 'UPDATE emp SET comm=:x'
               USING v_null;                                     --����NULLֵ
END;

CREATE OR REPLACE PROCEDURE ddl_execution (ddl_string IN VARCHAR2)
   AUTHID CURRENT_USER IS            --ʹ�õ�����Ȩ��
BEGIN
   EXECUTE IMMEDIATE ddl_string;     --ִ�ж�̬SQL���
EXCEPTION
   WHEN OTHERS                       --��׽����  
   THEN
      DBMS_OUTPUT.PUT_LINE (      --��ʾ������Ϣ
         '��̬SQL������' || DBMS_UTILITY.FORMAT_ERROR_STACK);
      DBMS_OUTPUT.PUT_LINE (      --��ʾ��ǰִ�е�SQL���
         '   ִ�е�SQL���Ϊ�� "' || ddl_string || '"');
      RAISE;
END ddl_execution;
/


CREATE TABLE emp_test(ID NUMBER);
EXEC ddl_execution('alter table emp_test add emp_sal number NULL');
SELECT * FROM emp_test;
