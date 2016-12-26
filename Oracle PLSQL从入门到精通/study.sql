--PL/SQL��ṹ
DECLARE --��ѡ
BEGIN --����
EXCEPTION --��ѡ
END--����

--�����ʽ
BEGIN
  NULL;
END;
/
BEGIN
  dbms_output.put_line('Hello,world!');
END;

--oracle�е�ע��
/*
�ӳ�������outputVar
��������������ַ���
������p_var���ڴ��������ַ���
�����ˣ���Сǿ
����ʱ�䣺2016-12-23
��ʷ�汾��v1.0
*/
CREATE OR REPLACE PROCEDURE outputVar(p_var VARCHAR2) IS
BEGIN
  dbms_output.put_line(p_var);--p_var���ڴ��������ַ���
  END;
/
BEGIN
  outputVar('hello,world!');
  END;
/  
  

--�������淶
DECLARE
  VAR-b VARCHAR2(30); --���������ܺ�-
  VAR&b VARCHAR2(30); --���������ܺ����ַ�&
BEGIN
  NULL;
END;
/

--�����¼����
DECLARE
  TYPE Emp_Info_Type IS RECORD(
    empName VARCHAR2(30),
    empJob VARCHAR2(30),
    empSal  NUMBER);
  Emp_Info Emp_Info_Type;
BEGIN
  SELECT e.ename,e.job, e.sal INTO Emp_Info FROM scott.emp e WHERE e.empno = &empNo;
  dbms_output.put_line(Emp_Info.empName || '��ְλΪ'||Emp_Info.empJob||' нˮΪ' || Emp_Info.empSal);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      dbms_output.put_line('��¼û���ҵ�');
END;

--����������
/*
1. PL/SQL����������������� TYPE v_CountLoop IS BINARY_INTEGER,����v_CountLoop��BINARY_INTEGER;
2. v_date DATE NOT NULL DEFAULT SYSDATE; ���治��default system,����default sysdate
*/
DECLARE
  v_name      VARCHAR2(30);
  v_date      DATE NOT NULL DEFAULT SYSDATE;
  v_CountLoop BINARY_INTEGER;
  TYPE t_cur IS REF CURSOR;
  TYPE Emp_Info_Type IS RECORD(
    empName VARCHAR2(30),
    empJob  VARCHAR2(30),
    empSal  NUMBER);
  Emp_info Emp_Info_Type;
  salRadio CONSTANT NUMBER := 0.10;
BEGIN
  NULL;
END;
/


CREATE OR REPLACE PACKAGE tom_utils AS
  PROCEDURE drop_table(t_name VARCHAR2);
  PROCEDURE drop_fk(t_name VARCHAR2,fk_name VARCHAR2);
END tom_utils;
/
CREATE OR REPLACE PACKAGE BODY tom_utils AS
  PROCEDURE drop_table(t_name VARCHAR2) AS
  BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE ' || t_name;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END drop_table;
  
  PROCEDURE drop_fk(t_name VARCHAR2,fk_name VARCHAR2) AS
  BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE '||t_name||' DROP CONSTRAINT ' || fk_name;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END drop_fk;
END tom_utils;
/

BEGIN
tom_utils.drop_fk('T_EMP','fk_emp');
tom_utils.drop_fk('T_DEPT','fk_dept');
tom_utils.drop_table('T_EMP');
tom_utils.drop_table('T_DEPT');
END;
/

--����Ա���б�
CREATE TABLE t_emp(
                         --Ա���б���ֶ�
                         emp_id NUMBER NOT NULL,
                         emp_name VARCHAR2(30) NOT NULL,
                         --english_name VARCHAR2(30) NULL,
                         --alias_name VARCHAR2(30) NULL,
                         age           NUMBER DEFAULT 18,
                         hiredate      DATE DEFAULT SYSDATE,
                         dept_id NUMBER NULL,
                         --Ա���б������
                         CONSTRAINT pk_t_emp PRIMARY KEY(emp_id)); 
--�������ű�
CREATE TABLE t_dept(dept_id NUMBER NOT NULL,
                      dept_name VARCHAR2(30) NOT NULL,
                      --dept_desc VARCHAR2(50) NULL,
                      dept_mgr_id NUMBER NOT NULL,
                      CONSTRAINT pk_t_dept PRIMARY KEY(dept_id));
--ΪԱ�������Ӳ��ű�����
ALTER TABLE t_emp ADD(
CONSTRAINT fk_emp
FOREIGN KEY(dept_id)
REFERENCES t_dept(dept_id));

ALTER TABLE t_dept ADD(
CONSTRAINT fk_dept
FOREIGN KEY(dept_mgr_id)
REFERENCES t_emp(emp_id)
);
--������񲿼�¼
INSERT INTO t_emp VALUES(100,'��Сǿ',35,to_date('2016-05-24','yyyy-mm-dd'),NULL);
INSERT INTO t_dept VALUES(50,'����',100); 
INSERT INTO t_emp VALUES(101,'������',35,to_date('2016-05-24','yyyy-mm-dd'),50);
INSERT INTO t_emp VALUES(102,'����',35,to_date('2010-04-24','yyyy-mm-dd'),50);
--���뿪������¼
INSERT INTO t_emp VALUES(103,'��ϼ',27,to_date('2005-05-24','yyyy-mm-dd'),NULL);
INSERT INTO t_dept VALUES(51,'������',103); 
INSERT INTO t_emp 
SELECT 104,'����',20,to_date('2014-06-01','yyyy-mm-dd'),51 FROM dual UNION
SELECT 105,'����',22,to_date('2012-08-09','yyyy-mm-dd'),51 FROM dual UNION
SELECT 106,'Polly',27,to_date('2011-05-24','yyyy-mm-dd'),51 FROM dual UNION
SELECT 107,'����',29,to_date('2009-02-02','yyyy-mm-dd'),51 FROM dual;
--�������۲���¼
INSERT INTO t_emp VALUES(108,'����',29,to_date('2000-05-24','yyyy-mm-dd'),NULL);
INSERT INTO t_dept VALUES(52,'���۲�',108); 
INSERT INTO t_emp 
SELECT 109,'�ź���',20,to_date('2003-04-01','yyyy-mm-dd'),52 FROM dual UNION
SELECT 110,'�º�',45,to_date('2005-06-09','yyyy-mm-dd'),52 FROM dual UNION
SELECT 111,'����ı',64,to_date('2007-08-09','yyyy-mm-dd'),52 FROM dual UNION
SELECT 112,'�����',34,to_date('2005-08-06','yyyy-mm-dd'),52 FROM dual;
COMMIT;

SELECT * FROM t_emp;
SELECT * FROM t_dept;
--set serveroutput on
--���в�����¼
DECLARE
  v_emp_id   NUMBER := 113;
  v_emp_name VARCHAR2(30) := '��Ӣ��';
  v_age      NUMBER := 35;
  v_hiredate DATE := to_date('2008-08-06', 'yyyy-mm-dd');
  v_dept_id  NUMBER := 50;
BEGIN
  UPDATE t_emp emp
     SET emp.emp_name = v_emp_name,
         emp.age      = v_age,
         emp.hiredate = v_hiredate,
         emp.dept_id  = v_dept_id
   WHERE emp.emp_id = v_emp_id;
  IF SQL%NOTFOUND THEN
    INSERT INTO t_emp
    VALUES
      (v_emp_id, v_emp_name, v_age, v_hiredate, v_dept_id);
      dbms_output.put_line('����Ա����¼�ɹ�!');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('����Ա����¼ʧ��!');
END;
/

--���ӡ�뻻��
BEGIN
  dbms_output.put_line('�����ʱ����:' || SYSDATE);
  dbms_output.put('������:');
  dbms_output.put_line(to_char(SYSDATE, 'DAY'));
  dbms_output.put('���ڵ�ʱ����:');
  dbms_output.put_line(to_char(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'));
END;
/

SELECT ROWID,t.* FROM scott.emp t;
SELECT t.* FROM scott.emp t,scott.dept d WHERE t.deptno=d.deptno AND t.sal>1000;

--���ж������룬�����쳣
DECLARE
  v_name VARCHAR2(30);
  v_sal  VARCHAR2(30);
BEGIN
  SELECT t.ename, t.sal
    INTO v_name, v_sal
    FROM scott.emp t
   WHERE t.empno = &empno;
  IF SQL%FOUND THEN
    dbms_output.put_line('Ա�����Ϊ: '||&empno||' ����Ϊ: '||v_name || ' ����:' || v_sal); 
  END IF;
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('û���ҵ���¼');
END;
/


--����SQL DDL ���  Data Definition Language
DECLARE
v_sql VARCHAR2(200):='create table scott.BOOK(id number not null,book_name varchar2(50))';
BEGIN
  EXECUTE IMMEDIATE v_sql;
  END;
/
SELECT * FROM scott.book;
DROP TABLE scott.book;

--��̬���
SELECT * FROM scott.emp e WHERE e.empno=&EmpNo;
UPDATE scott.emp e SET e.sal=e.sal*1.2 WHERE e.empno=&EmpNo;
DELETE FROM scott.emp e WHERE e.empno=&EmpNo;
ROLLBACK;

--�ڿ��д������������ݣ���ѯ����
/*
����ĵط�
1. �ڶ�̬����SQL�У�������:=book_id ������=:book_id
2. ִ�Уӣѣ�ʱ�� EXECUTE IMMEDIATE v_sql INTO v_id, v_name, v_price;����Ҫ��using &1��ʾҪ����Ĳ���
3. ȷ����̬��sql�������ǶԵ���DROP TABLE TABLE book��Ҫд��DROP TABLE book
*/
DECLARE
  v_sql   VARCHAR2(300);
  v_id    NUMBER;
  v_name  VARCHAR2(30);
  v_price NUMBER;
BEGIN
  BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE book';
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
  END;
  v_sql := 'create table book(id number not null primary key,book_name varchar2(30),book_price number)';
  EXECUTE IMMEDIATE v_sql;
  v_sql := 'insert into book values(1,''�����澭'',82.5)';
  EXECUTE IMMEDIATE v_sql;
  v_sql := 'select * from book where id=:book_id';
  EXECUTE IMMEDIATE v_sql INTO v_id, v_name, v_price USING &1;
  dbms_output.put_line('���id:' || v_id || ' �������: ' || v_name || ' ��ĵ���:' ||
                       v_price);
END;
/

--�쳣����
/*
1. WHEN DATA_NOT_FOUND THEN  ��NO_DATA_FOUND
2. ��Ҫ�������㡡EXIT WHEN SQL%NOTFOUND; ��ֻ������ѭ����
*/
DECLARE
  v_name VARCHAR2(30);
BEGIN
  SELECT e.ename INTO v_name FROM scott.emp e WHERE e.empno = &EmpNo;
  --EXIT WHEN SQL%NOTFOUND; 
  dbms_output.put_line(v_name);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    dbms_output.put_line('û���ҵ���¼');
  WHEN OTHERS THEN
    dbms_output.put_line('�����������쳣');
END;
/

--д���洢���̣����ݱ���������
CREATE OR REPLACE PROCEDURE scott.get_ename(p_no IN NUMBER) IS
  v_name scott.emp.ename%TYPE;
BEGIN
  SELECT t.ename INTO v_name FROM scott.emp t WHERE t.empno = p_no;
  dbms_output.put_line('Ա�����Ϊ: ' || p_no || ' ����Ϊ: ' || v_name);
EXCEPTION
  WHEN no_data_found THEN
    dbms_output.put_line('û���ҵ���¼');
  WHEN OTHERS THEN
    RAISE;
END get_ename;
/

BEGIN
  scott.get_ename(30);
  scott.get_ename(7369);
END;
/
SELECT DISTINCT e.job FROM scott.emp e;

--����һ�����������ؼӹ��ʵķ���
--����ĵط�����1. else if=>elsif  2. return ���ͺ����� AS 3. û��declare
CREATE OR REPLACE FUNCTION GetAddSalaryRatio(p_job VARCHAR2) RETURN NUMBER AS
  v_ret NUMBER(7, 2);
BEGIN
  v_ret := 0;
  IF p_job = 'CLERK' THEN
    v_ret := 0.1;
  ELSIF p_job = 'SALESMAN' THEN
    v_ret := 0.12;
  ELSIF p_job = 'MANAGER' THEN
    v_ret := 0.15;
  END IF;
  RETURN v_ret;
END;

SELECT GetAddSalaryRatio('SALESMAN') FROM dual;

  --Ա���ӹ��ʷ���case�汾
  --function һ��Ҫ��function   �����/����ʾ�ύ��ǰ�Ĵ���
  CREATE OR REPLACE FUNCTION GetAddSalaryRatioCase(p_job VARCHAR2)
  RETURN NUMBER AS
  v_ret NUMBER(7, 2);
BEGIN
  v_ret := 0;
  CASE p_job
    WHEN 'CLERK' THEN
      v_ret := 0.1;
    WHEN 'SALESMAN' THEN
      v_ret := 0.12;
    WHEN 'MANAGER' THEN
      v_ret := 0.15;
    ELSE
      v_ret := 0;
  END CASE;
  RETURN v_ret;
END GetAddSalaryRatioCase;
/
BEGIN
  dbms_output.put_line(GetAddSalaryRatioCase('MANAGER'));
  END;
--����һ���洢���̣������д��ε��α꣬��������������Ȳ�Ϊ��������¸�Ա������
--����֪��δ���
SELECT * FROM scott.emp e;
CREATE OR REPLACE PROCEDURE UpdateEmpSal(p_empNo IN NUMBER) IS
  CURSOR v_cur(v_empNo NUMBER) IS
    SELECT * FROM scott.emp e WHERE e.empno = v_empNo;
  v_emp    scott.emp%ROWTYPE;
  v_newSal scott.emp.sal%TYPE;
BEGIN
  OPEN v_cur(p_empNo);
  FETCH v_cur
    INTO v_emp;
  v_newSal := GetAddSalaryRatio(v_emp.job);
  CLOSE v_cur;
  IF v_newSal <> 0 THEN
    UPDATE scott.emp e
       SET e.sal =
           (1 + v_newSal) * e.sal
     WHERE e.empno = p_empNo;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END UpdateEmpSal;

BEGIN
  UpdateEmpSal(7369);
  UpdateEmpSal(1);
END;

--���е��α���������
/*����ĵط� 
1. index by binary_integer   
2. ���ǡ�for i in xxx, FOR i IN  1..empNameList.count 
3.  �б���ȡֵ����empNameList[i] ����empNameList(i)
*/
DECLARE
  TYPE Emp_Table IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
  empNameList Emp_Table;
  CURSOR v_cur IS
    SELECT e.ename FROM scott.emp e;
BEGIN
  OPEN v_cur;
  --��Ա������ȡ������Ա��������
  FETCH v_cur BULK COLLECT
    INTO empNameList;
  CLOSE v_cur;
  FOR i IN 1 .. empNameList.count LOOP
    dbms_output.put_line('�û���Ϊ: ' || empNameList(i));
  END LOOP;
END;
/

--loop�÷�
/*
����ĵط�
1. �α���û�м�FOR UPDATE;  �������FOR UPDATE;���������
���¿��Բ���WHERE e.empno = v_EmpNo;����where current of �α�
2. EXIT WHEN v_cur%NOTFOUND;  �ر�ע�� �α�%NOTFOUND
*/
DECLARE
  CURSOR v_cur IS
    SELECT e.empno, e.ename, e.sal, e.job FROM scott.emp e FOR UPDATE;
  v_EmpNo   NUMBER;
  v_EmpName VARCHAR2(30);
  v_EmpSal  NUMBER;
  v_EmpJob  VARCHAR2(30);
  v_radio   NUMBER := 0;
BEGIN
  OPEN v_cur;
  LOOP
    FETCH v_cur
      INTO v_EmpNo, v_EmpName, v_EmpSal, v_EmpJob;
    EXIT WHEN v_cur%NOTFOUND;
    v_radio := GetAddSalaryRatioCase(v_EmpJob);
    UPDATE scott.emp e
       SET e.sal = e.sal * (1 + v_radio)
     --WHERE e.empno = v_EmpNo;
     WHERE CURRENT OF v_cur;
    dbms_output.put_line('�ɹ�Ϊ' || v_EmpName || '��н��нˮΪ' ||
                         v_EmpSal * (1 + v_radio));
  END LOOP;
  CLOSE v_cur;
END;


--forѭ����ӡ�žű�
/*
����ĵط�
1. RPAD���������ұ����ո�
2.
�Ʊ�� chr(9) 
���з� chr(10)
�س��� chr(13)
*/
DECLARE
  v_var1 NUMBER;
  v_var2 NUMBER;
BEGIN
  FOR v_var1 IN 1 .. 9 LOOP
    FOR v_var2 IN 1 .. v_var1 LOOP
      dbms_output.put(v_var1 || '*' || v_var2 || '=' ||
                      RPAD(v_var1 * v_var2, 2) || chr(9));
    END LOOP;
    dbms_output.put_line(' ');
  END LOOP;
END;
/

SELECT DISTINCT e.job FROM scott.emp e;
--��֧�ṹ
DECLARE
  v_clerk_radio    CONSTANT NUMBER := 0.1;
  v_salesman_radio CONSTANT NUMBER := 0.12;
  v_manager_radio  CONSTANT NUMBER := 0.1;
  v_job VARCHAR2(30);
BEGIN
  SELECT e.job INTO v_job FROM scott.emp e WHERE e.empno = &EmpNo;
  IF v_job = 'CLERK' THEN
    UPDATE scott.emp e
       SET e.sal = e.sal * (1 + v_clerk_radio)
     WHERE e.empno = &EmpNo;
  ELSIF v_job = 'SALESMAN' THEN
    UPDATE scott.emp e
       SET e.sal = e.sal * (1 + v_salesman_radio)
     WHERE e.empno = &EmpNo;
  ELSIF v_job = 'MANAGER' THEN
    UPDATE scott.emp e
       SET e.sal = e.sal * (1 + v_manager_radio)
     WHERE e.empno = &EmpNo;
  END IF;
  dbms_output.put_line('���ɹ�ΪְԱ' || &EmpNo || '��н��');
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    dbms_output.put_line('û�иü�¼');
END;

/*
����ĵط�
1. �α�û��������for update
2. ����ʱ����ʹ��Ա����ţ��������α�������WHERE CURRENT OF v_cur;
*/
--ѭ���ṹ
DECLARE
  c_clerk_radio    CONSTANT NUMBER := 0.10;
  c_salesman_radio CONSTANT NUMBER := 0.12;
  c_manager_radio  CONSTANT NUMBER := 0.15;
  CURSOR v_cur IS
    SELECT e.ename, e.sal, e.job FROM scott.emp e FOR UPDATE;
  v_name VARCHAR2(30);
  v_job  VARCHAR2(30);
  v_sal  NUMBER;
BEGIN
  OPEN v_cur;
  LOOP
    FETCH v_cur
      INTO v_name, v_sal, v_job;
    EXIT WHEN v_cur%NOTFOUND;
    IF v_job = 'CLERK' THEN
      UPDATE scott.emp e
         SET e.sal = e.sal * (1 + c_clerk_radio)
       WHERE CURRENT OF v_cur;
    ELSIF v_job = 'SALESMAN' THEN
      UPDATE scott.emp e
         SET e.sal = e.sal * (1 + c_salesman_radio)
       WHERE CURRENT OF v_cur;
    ELSIF v_job = 'MANAGER' THEN
      UPDATE scott.emp e
         SET e.sal = e.sal * (1 + c_manager_radio)
       WHERE CURRENT OF v_cur;
    END IF;
    dbms_output.put_line('���ɹ�ΪԱ��' || v_name || '��н��');
  END LOOP;
  CLOSE v_cur;
EXCEPTION
  WHEN no_data_found THEN
    dbms_output.put_line('û���ҵ�Ա����Ϣ');
END;

--���������
/*
����ĵط�
1. AS OBJECT AS ����û������ֻ��(..)
2. �����FUNCTION addSal(sal NUMBER) RETURN NUMBER��ǰ��Ҫ��member
3. CREATE OR REPLACE TYPE BODY emp_obj IS ����is,��as 
4. FUNCTION addSal(sal NUMBER) RETURN NUMBER����ǰ�涼Ҫ�� member
5. type��ÿ�����Ժ��治����;������,
6. type body�ﲻ����()
7. ��βҪ��end; �� create or replace type body xxx as ... end;
*/
SELECT * FROM scott.emp e;
DROP TYPE emp_obj;
CREATE OR REPLACE TYPE emp_obj AS OBJECT
(
  EmpNo       NUMBER,
  EmpName     VARCHAR2(30),
  EmpJob      VARCHAR2(30),
  EmpMgr      VARCHAR2(30),
  EmpHireDate VARCHAR2(30),
  EmpSale     VARCHAR2(30),
  EmpComm     NUMBER,
  DeptNo      NUMBER,
  MEMBER FUNCTION addSal1(sal NUMBER, radio NUMBER) RETURN NUMBER,
  MEMBER PROCEDURE addSal(radio NUMBER)
)
;
CREATE OR REPLACE TYPE BODY emp_obj AS
  MEMBER FUNCTION addSal1(sal NUMBER, radio NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN sal * radio;
  END;
  MEMBER PROCEDURE addSal(radio NUMBER) AS
  BEGIN
    EmpSale := EmpSale * 1.1;
  END;
END;
--��emp_objΪ���ʹ�����
DROP TABLE emp_obj_tab;
CREATE TABLE emp_obj_tab OF emp_obj;
SELECT * FROM emp_obj_tab;

--����ΪԱ����н�洢����
/*
����ĵط�
1. EXIT;������һ��ѭ���в���ʹ��
*/
CREATE OR REPLACE PROCEDURE AddEmpSalary(p_radio NUMBER, p_empno NUMBER) AS
BEGIN
  IF p_radio > 0 THEN
    UPDATE scott.emp e
       SET e.sal = e.sal * (1 + p_radio)
     WHERE e.empno = p_empno;
    dbms_output.put_line('�ɹ�ΪԱ��' || p_empno || '��н��');
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    dbms_output.put_line('û�е��ҵ�Ա����¼');
END;

BEGIN
  AddEmpSalary(-5.6, 10);
  AddEmpSalary(1.1, 7369);
  AddEmpSalary(1.1, 11);
END;
/

--����һ���д���������¼��Ա���εı仯
/*
1. AFTER UPDATE ON sal OF scott.emp�� of sal on scott.emp
2. ��Ҫʹ��OLD :sal����:old.xxxx �ر�ע��new.xxx,old.xxx�ǡ���after update of ��on xxx���Ӧ���ֶ�
3. dbms_output.put_line(SQLERRM);��SQLERRM������ syserrm
*/

CREATE TABLE RaiseEmpSalLog(
empNo NUMBER,
empName VARCHAR2(30),
orginalSal NUMBER,
newSal NUMBER,
modifyDate DATE DEFAULT SYSDATE
);
CREATE OR REPLACE TRIGGER RaiseEmpSalTrigger
  AFTER UPDATE OF sal ON scott.emp
  FOR EACH ROW
DECLARE
  v_count NUMBER;
BEGIN
  SELECT COUNT(1)
    INTO v_count
    FROM RaiseEmpSalLog res
   WHERE res.empNo = :old.empno;
  IF v_count > 0 THEN
    UPDATE RaiseEmpSalLog res
       SET res.orginalsal = :old.sal, res.newSal = :new.sal,res.modifyDate = SYSDATE
     WHERE res.empNo = :old.empno;
  ELSE
    INSERT INTO RaiseEmpSalLog(empNo,empName,orginalSal,newSal)
    VALUES
      (:old.empno, :old.ename, :old.sal,:new.sal);
  END IF;
  EXCEPTION 
    WHEN OTHERS THEN
      dbms_output.put_line(SQLERRM);
END;
SELECT * FROM scott.emp;
UPDATE scott.emp e SET e.sal=e.sal*1.2 WHERE e.empno=7499;
UPDATE scott.emp e SET e.sal=e.sal*1.2 WHERE e.empno=1111;
SELECT * FROM RaiseEmpSalLog;
/*
 1. ��Ҫ��OTHERS v_radio := 2.0����else
 case xx
   when xx then 
     ...
   else
     xxx
  end case;
2. CREATE OR REPLACE PACKAGE BODY EmpSalaryUtil AS���洢���̺���as
3.   FUNCTION getRadio(p_job VARCHAR2) RETURN NUMBER AS ������Ҳ��AS   
*/
--���淶����
CREATE OR REPLACE PACKAGE EmpSalaryUtil AS
  PROCEDURE addEmpSalary(p_empno NUMBER, p_radio NUMBER);
  FUNCTION getRadio(p_job VARCHAR2) RETURN NUMBER;
  FUNCTION getRadioCase(p_job VARCHAR2) RETURN NUMBER;
END EmpSalaryUtil;
/
--���嶨��
SELECT DISTINCT e.job FROM scott.emp e;
CREATE OR REPLACE PACKAGE BODY EmpSalaryUtil AS
  PROCEDURE addEmpSalary(p_empno NUMBER, p_radio NUMBER) AS
  BEGIN
    IF p_radio > 0 THEN
      UPDATE scott.emp e
         SET e.sal = e.sal * (1 + p_radio)
       WHERE e.empno = p_empno;
      dbms_output.put_line('�ɹ�Ϊ' || p_empno || '��н��');
    END IF;
  END;
  FUNCTION getRadio(p_job VARCHAR2) RETURN NUMBER AS
    v_radio NUMBER(7, 2);
  BEGIN
    v_radio := 0;
    IF p_job = 'CLERK' THEN
      v_radio := 0.1;
    ELSIF p_job = 'SALESMAN' THEN
      v_radio := 0.12;
    ELSIF p_job = 'MANAGER' THEN
      v_radio := 0.15;
    END IF;
    RETURN v_radio;
  END;
  FUNCTION getRadioCase(p_job VARCHAR2) RETURN NUMBER AS
    v_radio NUMBER(7, 2) := 0;
  BEGIN
    CASE p_job
      WHEN 'CLERK' THEN
        v_radio := 0.1;
      WHEN 'SALESMAN' THEN
        v_radio := 0.12;
      WHEN 'MANAGER' THEN
        v_radio := 0.15;
      ELSE
        v_radio := 2.0;
    END CASE;
    RETURN v_radio;
  END;
END EmpSalaryUtil;
/
SELECT * FROM scott.emp e;
BEGIN
  EmpSalaryUtil.addEmpSalary(7499, 0.1);
  DBMS_OUTPUT.put_line(EmpSalaryUtil.getRadio('CLERK'));
  DBMS_OUTPUT.put_line(EmpSalaryUtil.getRadio('PRESIDENT'));
  DBMS_OUTPUT.put_line(EmpSalaryUtil.getRadio('MANAGER'));
  DBMS_OUTPUT.put_line(EmpSalaryUtil.getRadio('SALESMAN'));
  DBMS_OUTPUT.put_line(EmpSalaryUtil.getRadioCase('CLERK'));
  DBMS_OUTPUT.put_line(EmpSalaryUtil.getRadioCase('PRESIDENT'));
  DBMS_OUTPUT.put_line(EmpSalaryUtil.getRadioCase('MANAGER'));
  DBMS_OUTPUT.put_line(EmpSalaryUtil.getRadioCase('SALESMAN'));
END;
/
