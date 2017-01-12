/*
ACID
����������Ҫ�����������ݲ�����һ���ԣ������������������������acid,��ԭ���ԣ�һ���ԣ������Ժͳ־���
ԭ���ԣ������������ԭ�Ӵ���λ���������ݵ��޸ģ�Ҫôȫ��ִ�У�Ҫôȫ����ִ�С�
һ���ԣ�������������ԣ�����ʹ���е����ݶ�����һ��״̬�������е����ݶ�Ҫ�������ģ���ȷ�����ݵ������ԡ�
�����ԣ������������ִ���ǻ������ŵģ�һ�����񲻿��ܿ���������������ʱ���м�ĳһʱ�̵����ݡ�
�־��ԣ�  һ�������ύ֮�����ݿ�ı仯�ͻᱻ���õı�����������ʹ�������ݿ�����Ļ�����������Ҳ����ˡ�
*/

DECLARE
   dept_no   NUMBER (2) := 70;
BEGIN
   --��ʼ����
   INSERT INTO dept 
        VALUES (dept_no, '�г���', '����');               --���벿�ż�¼
   INSERT INTO emp                                        --����Ա����¼
        VALUES (7997, '����', '������Ա', NULL, TRUNC (SYSDATE), 5000,300, dept_no);
   --�ύ����
   COMMIT;
END;

DELETE FROM emp WHERE deptno=70;
DELETE FROM dept WHERE deptno=70;
COMMIT;

SELECT * FROM dept;
SELECT * FROM emp;

--����ع� ORA-00001: Υ��ΨһԼ������ (SCOTT.PK_DEPT)
DECLARE
  v_deptno NUMBER(2) := 70;
BEGIN
  INSERT INTO scott.dept VALUES (v_deptno, '������', '����');
  INSERT INTO scott.dept VALUES (v_deptno, '��չ��', '����');
  INSERT INTO scott.emp
  VALUES
    (9003, '������', 'clerk', 7566, SYSDATE, 7500, NULL, 30);
EXCEPTION
  WHEN dup_val_on_index THEN
    dbms_output.put_line(SQLERRM);
    ROLLBACK;
END;

--����ع���
DECLARE
  v_deptno NUMBER(2) := 70;
BEGIN
  INSERT INTO scott.dept VALUES (v_deptno, '������', '����');
  SAVEPOINT a;
  INSERT INTO scott.emp
  VALUES
    (9003, '������', 'clerk', 7566, SYSDATE, 7500, NULL, 30);
  SAVEPOINT b;
  INSERT INTO scott.dept VALUES (v_deptno, '��չ��', '����');
  SAVEPOINT c;

EXCEPTION
  WHEN dup_val_on_index THEN
    dbms_output.put_line(SQLERRM);
    ROLLBACK TO b;
END;

SELECT * FROM dept;

DELETE FROM dept WHERE deptno=90;
COMMIT;

SELECT * FROM scott.emp;

DECLARE
  v_year1980 NUMBER(2);
  v_year1981 NUMBER(2);
  v_year1982 NUMBER(2);
BEGIN
  COMMIT;
  SET TRANSACTION READ ONLY NAME 'ͳ��80���3��ͳ����ְ����';
  SELECT COUNT(1)
    INTO v_year1980
    FROM scott.emp
   WHERE to_char(hiredate, 'yyyy') = '1980';
  SELECT COUNT(1)
    INTO v_year1981
    FROM scott.emp
   WHERE to_char(hiredate, 'yyyy') = '1981';
  SELECT COUNT(1)
    INTO v_year1982
    FROM scott.emp
   WHERE to_char(hiredate, 'yyyy') = '1982';
  COMMIT;
  dbms_output.put_line('1980����ְ����Ϊ��' || v_year1980);
  dbms_output.put_line('1981����ְ����Ϊ��' || v_year1981);
  dbms_output.put_line('1982����ְ����Ϊ��' || v_year1982);

END;


SELECT * FROM emp WHERE deptno=10 FOR UPDATE;
COMMIT;

SELECT * FROM emp WHERE deptno=10 FOR UPDATE NOWAIT;
COMMIT;
