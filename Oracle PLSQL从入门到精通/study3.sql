--��������
DECLARE
  v_ename    VARCHAR2(20);
  v_hiredate DATE NOT NULL := SYSDATE;
  v_empNo    NUMBER NOT NULL DEFAULT 7987;
BEGIN
  NULL;
END;
--������ֵ
DECLARE
  v_counter NUMBER;
BEGIN
  v_counter := 0;
  v_counter := v_counter + 1;
  dbms_output.put_line('������������Ϊ:' || v_counter);
END;
--���ָ�ֵ
DECLARE
  v_sal      NUMBER(7, 2);
  v_radio    NUMBER(7, 2) := 0.12;
  v_base_sal NUMBER(7, 2) := 1200.00;
BEGIN
  v_sal := v_base_sal * (1 + v_radio);
  dbms_output.put_line('Ա������Ϊ' || v_sal);
END;
--���ڸ�ֵ
DECLARE
  v_string    VARCHAR2(200);
  v_boolean   BOOLEAN;
  v_hire_date DATE;
BEGIN
  v_string    := 'hello,world';
  v_boolean   := TRUE;
  v_hire_date := SYSDATE;
  v_hire_date := to_date('2015-07-08', 'yyyy-mm-dd');
  v_hire_date := DATE '2015-06-07'; --ֱ�Ӿ�ֵ̬��ֵ
  dbms_output.put_line('Ա����ְ����Ϊ' || v_hire_date);
END;
/
--Explain plan��ť����ִ�мƻ���������ֱ�Ӱ�F5
--��F8����PL/SQL DeveloperĬ����ִ�иô��ڵ�����SQL��䣬��Ҫ����Ϊ������ڵ�����SQL��䣬��ִ�е�ǰSQL��䣻
--ִ�е���SQL��� ��ʹ�� PL/SQL Developer��SQL Windowʱ����F8����PL/SQL DeveloperĬ����ִ�иô��ڵ�����SQL��䣬��Ҫ����Ϊ������ڵ�����SQL��䣬��ִ�е�ǰSQL��䣻
--���÷�����PL/SQL Developer -->tools->Preferences-->Window types-->SQL Window �����ϡ�AutoSelect Statement�� ���ɡ�
SELECT * FROM scott.emp;

--%type��ֵ��%rowtype
DECLARE
  v_name    scott.emp.ename%TYPE;
  v_name1   v_name%TYPE;
  v_salary  scott.emp.sal%TYPE;
  v_salary1 v_salary%TYPE;
  v_emp     scott.emp%ROWTYPE;
BEGIN
  SELECT * INTO v_emp FROM scott.emp WHERE emp.empno = &empno;
  dbms_output.put_line('Ա��������Ϊ' || v_emp.ename || CHR(10) || 'Ա����нˮΪ' ||
                       v_emp.sal);
END;
/

SELECT TRIM(SYSDATE),MIN(SYSDATE) FROM dual;

--������
/*
1. ��Ҫ����is!!! SUBTYPE st_count IS INTEGER;
*/
DECLARE
  SUBTYPE st_count IS INTEGER;
  v_count st_count;
BEGIN
  SELECT COUNT(1) INTO v_count FROM scott.emp;
  dbms_output.put_line('����Ա��' || v_count);
END;
/

--ʱ�������
/*
����Ľ�ѵ:
1. ��WITH TIME ZONE;����with timezone
*/
DECLARE
  v_time1 TIMESTAMP;
  v_time2 TIMESTAMP WITH TIME ZONE;
BEGIN
  v_time1 := SYSDATE;
  v_time2 := SYSDATE;
  dbms_output.put_line(v_time1);
  dbms_output.put_line(v_time2);
END;
/
SELECT SESSIONTIMEZONE FROM dual;
SELECT * FROM v$timezone_names;

--�α�����
DECLARE
  CURSOR v_cur IS
    SELECT * FROM scott.emp;
  v_emp scott.emp%ROWTYPE;
BEGIN
  OPEN v_cur;
  LOOP
    FETCH v_cur
      INTO v_emp;
    EXIT WHEN v_cur%NOTFOUND;
    dbms_output.put_line('Ա��������' || v_emp.ename || CHR(10) || 'Ա���Ĺ���' ||
                         v_emp.sal);
  END LOOP;
EXCEPTION
  WHEN no_data_found THEN
    dbms_output.put_line('û���ҵ���¼');
  WHEN OTHERS THEN
    dbms_output.put_line(SQLERRM);
END;
  
--�����Ͳ���һ������
SELECT * FROM scott.emp;
/*
����Ľ�ѵ:
1. ORA-06502: PL/SQL: ���ֻ�ֵ���� :  �ַ���������̫С
v_emp.job      := '�������ʦ';  job VARCHAR2(9)
2. ��ֵһ��Ҫ��:=,��Ҫֻ��=
*/
DECLARE
  v_emp emp%ROWTYPE;
BEGIN
  v_emp.empno    := 9000;
  v_emp.ename    := '��Сǿ';
  v_emp.job      := 'manager';
  v_emp.mgr      := 7369;
  v_emp.hiredate := DATE '2016-05-24';
  v_emp.sal      := 6000;
  v_emp.deptno   := 20;
  INSERT INTO emp VALUES v_emp;
  EXCEPTION 
    WHEN OTHERS THEN
      dbms_output.put_line(SQLERRM);
END;
/
 --�����αꡡ
/*

1. system_refҪ��sys_refcursor
2.v_cur IS SELECT * FROM scott.emp; Ҫ�� OPEN  v_cur  FOR SELECT * FROM scott.emp;
3.RETURN v_cur��һ��Ҫ�ӷֺ�
4.FETCH v_cur INTO v_emp; ���Ƕ�v_emp.xxxȡ����ֵ���������α�v_cur
*/
CREATE OR REPLACE FUNCTION getEmpCurRef RETURN SYS_REFCURSOR AS
  v_cur SYS_REFCURSOR;
BEGIN
  OPEN v_cur FOR
    SELECT * FROM scott.emp;
  RETURN v_cur;
END;
/

DECLARE
  v_cur SYS_REFCURSOR;
  v_emp scott.emp%ROWTYPE;
BEGIN
  v_cur := getEmpCurRef;
  LOOP
    FETCH v_cur
      INTO v_emp;
    EXIT WHEN v_cur%NOTFOUND;
    dbms_output.put_line('Ա��������Ϊ' || v_emp.ename || CHR(10) || 'Ա����нˮΪ' ||
                         v_emp.sal);
  END LOOP;
END;

--rowid
SELECT rowidtochar(ROWID),e.* FROM scott.emp e;


  
