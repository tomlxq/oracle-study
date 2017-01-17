--������淶�����淶��������Ӧ�ó���Ľӿڲ��֣����ⲿ����
CREATE OR REPLACE PACKAGE emp_pkg AS
   --���弯������
   TYPE emp_tab IS TABLE OF emp%ROWTYPE INDEX BY BINARY_INTEGER;
   --�ڰ��淶�ж���һ����¼����
   TYPE emprectyp IS RECORD(
      emp_no NUMBER,
      sal  NUMBER
   );
   --����һ���α����
   CURSOR desc_salary RETURN emprectyp;
   --�����ӶԱ���Ĺ���
   PROCEDURE hire_employee(p_empno NUMBER,p_ename VARCHAR2,p_job VARCHAR2,p_mgr NUMBER,p_sal NUMBER,
                        p_comm NUMBER,p_deptno NUMBER,p_hiredate DATE);
   --������Ա���Ĺ���                        
   PROCEDURE fire_employee(p_emp_id NUMBER );
END emp_pkg;

--�������
CREATE OR REPLACE PACKAGE BODY emp_pkg
AS
   --�����α�����ľ�������
   CURSOR desc_salary RETURN emprectyp IS
      SELECT empno, sal FROM emp ORDER BY sal DESC;
   --�����ӶԱ���ľ���ʵ��
   PROCEDURE hire_employee(p_empno NUMBER,p_ename VARCHAR2,
                           p_job VARCHAR2,p_mgr NUMBER,p_sal NUMBER,
                           p_comm NUMBER,p_deptno NUMBER,p_hiredate DATE) IS
   BEGIN
      --��emp���в���һ��Ա����Ϣ
      INSERT INTO emp VALUES(p_empno,p_ename,p_job,p_mgr,p_hiredate,p_sal,p_comm,p_deptno); 
   END;       
   --������Ա���ľ���ʵ��                 
   PROCEDURE fire_employee(p_emp_id NUMBER ) IS
   BEGIN
      --��emp����ɾ��Ա����Ϣ
      DELETE FROM emp WHERE empno=p_emp_id;
   END;          
END emp_pkg;


--������淶�����淶��������Ӧ�ó���Ľӿڲ��֣����ⲿ����
CREATE OR REPLACE PACKAGE dept_pkg AS
   dept_count NUMBER:=1;
   --���弯������
   TYPE dept_tab IS TABLE OF dept%ROWTYPE INDEX BY BINARY_INTEGER;
   --�ڰ��淶�ж���һ����¼����
   TYPE deptrectyp IS RECORD(
      dept_no NUMBER,
      dname  VARCHAR2(30),
      loc VARCHAR2(30)
   );
   CURSOR deptcur RETURN deptrectyp;       --����һ���α����
   e_nodept_assign EXCEPTION;              --����һ���쳣
END dept_pkg;



DECLARE
   mydept dept_pkg.dept_tab;                           --������еļ������͵ı���     
BEGIN
   FOR deptrow IN (SELECT * FROM dept) LOOP            --ʹ���α�FORѭ����ȡdept����
     mydept(dept_pkg.dept_count):=deptrow;             --Ϊ�������͸�ֵ
     dept_pkg.dept_count:=dept_pkg.dept_count+1;       --�������еı�����ֵ
   END LOOP;    
   FOR i IN 1..mydept.count LOOP                       --ѭ����ʾ�����еĲ��ŵĲ�������
      DBMS_OUTPUT.put_line(mydept(i).dname);
   END LOOP;
   dept_pkg.dept_count:=1;                             --����dept_pkg.dept_count��ֵ��
EXCEPTION
   WHEN  dept_pkg.e_nodept_assign THEN
      DBMS_OUTPUT.put_line('û���ҵ�Ա����¼');     --��׽�쳣������д����Ļ�
END;

--������淶
CREATE OR REPLACE PACKAGE emp_action_pkg IS
   v_deptno NUMBER(3):=20;              --�������ı���
   --����һ��������Ա���Ĺ���
   PROCEDURE newdept (
       p_deptno   dept.deptno%TYPE,    --���ű��
       p_dname    dept.dname%TYPE,     --��������
       p_loc      dept.loc%TYPE        --λ��
    );   
    --����һ����ȡԱ����н�����ĺ���
    FUNCTION getraisedsalary (p_empno emp.empno%TYPE)
       RETURN NUMBER;    
END emp_action_pkg;

--�������
CREATE OR REPLACE PACKAGE BODY emp_action_pkg IS
  --������ʵ�ְ��淶�ж����newdept����
  PROCEDURE newdept (
       p_deptno   dept.deptno%TYPE,    --���ű��
       p_dname    dept.dname%TYPE,     --��������
       p_loc      dept.loc%TYPE        --λ��
    )
    AS
       v_deptcount   NUMBER;           --�����Ƿ����Ա�����
       BEGIN
       SELECT COUNT (*) INTO v_deptcount FROM dept
        WHERE deptno = p_deptno;       --��ѯ��dept�����Ƿ���ڲ��ű��
       IF v_deptcount > 0              --���������ͬ��Ա����¼
       THEN                            --�׳��쳣
          raise_application_error (-20002, '��������ͬ��Ա����¼');
       END IF;
       INSERT INTO dept(deptno, dname, loc)  
            VALUES (p_deptno, p_dname, p_loc);--�����¼
    END newdept;
    --������ʵ�ְ��淶�ж����getraisedsalary����
    FUNCTION getraisedsalary (p_empno emp.empno%TYPE)
       RETURN NUMBER
    IS
       v_job           emp.job%TYPE;            --ְλ����
       v_sal           emp.sal%TYPE;            --н�ʱ���
       v_salaryratio   NUMBER (10, 2);          --��н����
    BEGIN
       --��ȡԱ�����е�н����Ϣ
       SELECT job, sal INTO v_job, v_sal FROM emp WHERE empno = p_empno;
       CASE v_job                               --���ݲ�ͬ��ְλ��ȡ��н����
          WHEN 'ְԱ' THEN
             v_salaryratio := 1.09;
          WHEN '������Ա' THEN
             v_salaryratio := 1.11;
          WHEN '����' THEN
             v_salaryratio := 1.18;
          ELSE
             v_salaryratio := 1;
       END CASE;
       IF v_salaryratio <> 1                    --����е�н�Ŀ���
       THEN
          RETURN ROUND(v_sal * v_salaryratio,2);         --���ص�н���н��
       ELSE
          RETURN v_sal;                         --���򲻷���н��
       END IF;
     EXCEPTION
          WHEN NO_DATA_FOUND THEN
             RETURN 0;                             --���û�ҵ�ԭ����¼������0
     END getraisedsalary;
    --˽�У��ú����ڰ��淶�в������ڣ�ֻ���ڰ����ڱ�����
    FUNCTION checkdeptno(p_deptno dept.deptno%TYPE) RETURN NUMBER
    AS
      v_counter NUMBER(2);
    BEGIN
       SELECT COUNT(*) INTO v_counter FROM dept WHERE deptno=p_deptno;
       RETURN v_counter; 
    END;           
END emp_action_pkg;      

--�ڸÿ���Ϊv_deptno��ֵΪ30������getraisedsalary����
BEGIN
   emp_action_pkg.v_deptno:=30;                                  --Ϊ���淶������ֵ
   DBMS_OUTPUT.put_line(emp_action_pkg.getraisedsalary(7369));--���ð��еĺ���
END;

--�ڸÿ���Ϊv_deptno��ֵΪ50��������newdept����
BEGIN
   emp_action_pkg.v_deptno:=50;
   emp_action_pkg.newdept(45,'���ɲ�','��ɽ');
END;
SELECT * FROM dept;

--�ڸÿ������v_deptno��ֵ
BEGIN
   DBMS_OUTPUT.put_line(emp_action_pkg.v_deptno);
END;
DELETE FROM dept WHERE deptno=45;

--������淶
CREATE OR REPLACE PACKAGE emp_action_pkg IS
   PRAGMA SERIALLY_REUSABLE;            --ָ��������ʾ
   v_deptno NUMBER(3):=20;              --�������ı���
   --����һ��������Ա���Ĺ���
   PROCEDURE newdept (
       p_deptno   dept.deptno%TYPE,    --���ű��
       p_dname    dept.dname%TYPE,     --��������
       p_loc      dept.loc%TYPE        --λ��
    );   
    --����һ����ȡԱ����н�����ĺ���
    FUNCTION getraisedsalary (p_empno emp.empno%TYPE)
       RETURN NUMBER;    
END emp_action_pkg;

--�������
CREATE OR REPLACE PACKAGE BODY emp_action_pkg IS
   PRAGMA SERIALLY_REUSABLE;            --ָ��������ʾ
  --������ʵ�ְ��淶�ж����newdept����
  PROCEDURE newdept (
       p_deptno   dept.deptno%TYPE,    --���ű��
       p_dname    dept.dname%TYPE,     --��������
       p_loc      dept.loc%TYPE        --λ��
    )
    AS
       v_deptcount   NUMBER;           --�����Ƿ����Ա�����
       BEGIN
       SELECT COUNT (*) INTO v_deptcount FROM dept
        WHERE deptno = p_deptno;       --��ѯ��dept�����Ƿ���ڲ��ű��
       IF v_deptcount > 0              --���������ͬ��Ա����¼
       THEN                            --�׳��쳣
          raise_application_error (-20002, '��������ͬ��Ա����¼');
       END IF;
       INSERT INTO dept(deptno, dname, loc)  
            VALUES (p_deptno, p_dname, p_loc);--�����¼
    END newdept;
    --������ʵ�ְ��淶�ж����getraisedsalary����
    FUNCTION getraisedsalary (p_empno emp.empno%TYPE)
       RETURN NUMBER
    IS
       v_job           emp.job%TYPE;            --ְλ����
       v_sal           emp.sal%TYPE;            --н�ʱ���
       v_salaryratio   NUMBER (10, 2);          --��н����
    BEGIN
       --��ȡԱ�����е�н����Ϣ
       SELECT job, sal INTO v_job, v_sal FROM emp WHERE empno = p_empno;
       CASE v_job                               --���ݲ�ͬ��ְλ��ȡ��н����
          WHEN 'ְԱ' THEN
             v_salaryratio := 1.09;
          WHEN '������Ա' THEN
             v_salaryratio := 1.11;
          WHEN '����' THEN
             v_salaryratio := 1.18;
          ELSE
             v_salaryratio := 1;
       END CASE;
       IF v_salaryratio <> 1                    --����е�н�Ŀ���
       THEN
          RETURN ROUND(v_sal * v_salaryratio,2);         --���ص�н���н��
       ELSE
          RETURN v_sal;                         --���򲻷���н��
       END IF;
     EXCEPTION
          WHEN NO_DATA_FOUND THEN
             RETURN 0;                             --���û�ҵ�ԭ����¼������0
     END getraisedsalary;
    --˽�У��ú����ڰ��淶�в������ڣ�ֻ���ڰ����ڱ�����
    FUNCTION checkdeptno(p_deptno dept.deptno%TYPE) RETURN NUMBER
    AS
      v_counter NUMBER(2);
    BEGIN
       SELECT COUNT(*) INTO v_counter FROM dept WHERE deptno=p_deptno;
       RETURN v_counter; 
    END;           
END emp_action_pkg;

ALTER PACKAGE emp_action_pkg COMPILE SPECIFICATION;--������淶
ALTER PACKAGE emp_action_pkg COMPILE BODY;--�������
ALTER PACKAGE emp_action_pkg COMPILE PACKAGE;--������淶�Ͱ���
--�鿴���ǲ��Ǵ���
SELECT o.OBJECT_TYPE, o.status, o.OBJECT_NAME
  FROM user_objects o
 WHERE o.OBJECT_TYPE IN ('PACKAGE', 'PACKAGE BODY')
 ORDER BY o.OBJECT_TYPE, o.status, o.OBJECT_NAME;
--�鿴����Դ����
SELECT   line, text
    FROM user_source
   WHERE NAME = 'EMP_ACTION_PKG' AND TYPE = 'PACKAGE'
ORDER BY line;
SELECT   line, text
    FROM user_source
   WHERE NAME = 'EMP_ACTION_PKG' AND TYPE = 'PACKAGE BODY'
ORDER BY line;

--����Ĺ����뺯��������
--������淶
CREATE OR REPLACE PACKAGE emp_action_pkg_overload IS
   --����һ��������Ա���Ĺ���
   PROCEDURE newdept (
       p_deptno   dept.deptno%TYPE,    --���ű��
       p_dname    dept.dname%TYPE,     --��������
       p_loc      dept.loc%TYPE        --λ��
    );   
   --����һ��������Ա���Ĺ��̣����ع���
   PROCEDURE newdept (
       p_deptno   dept.deptno%TYPE,    --���ű��
       p_dname    dept.dname%TYPE     --��������
    );       
    --����һ����ȡԱ����н�����ĺ���
    FUNCTION getraisedsalary (p_empno emp.empno%TYPE)
       RETURN NUMBER;
       
    --����һ����ȡԱ����н�����ĺ��������غ���
    FUNCTION getraisedsalary (p_ename emp.ename%TYPE)
       RETURN NUMBER;                  
END emp_action_pkg_overload;


--�������
CREATE OR REPLACE PACKAGE BODY emp_action_pkg_overload IS
  --������ʵ�ְ��淶�ж����newdept����
  PROCEDURE newdept (
       p_deptno   dept.deptno%TYPE,    --���ű��
       p_dname    dept.dname%TYPE,     --��������
       p_loc      dept.loc%TYPE        --λ��
    )
    AS
       v_deptcount   NUMBER;           --�����Ƿ����Ա�����
       BEGIN
       SELECT COUNT (*) INTO v_deptcount FROM dept
        WHERE deptno = p_deptno;       --��ѯ��dept�����Ƿ���ڲ��ű��
       IF v_deptcount > 0              --���������ͬ��Ա����¼
       THEN                            --�׳��쳣
          raise_application_error (-20002, '��������ͬ��Ա����¼');
       END IF;
       INSERT INTO dept(deptno, dname, loc)  
            VALUES (p_deptno, p_dname, p_loc);--�����¼
    END newdept;
    
  PROCEDURE newdept (
       p_deptno   dept.deptno%TYPE,    --���ű��
       p_dname    dept.dname%TYPE     --��������
    )
    AS
       v_deptcount   NUMBER;           --�����Ƿ����Ա�����
       BEGIN
       SELECT COUNT (*) INTO v_deptcount FROM dept
        WHERE deptno = p_deptno;       --��ѯ��dept�����Ƿ���ڲ��ű��
       IF v_deptcount > 0              --���������ͬ��Ա����¼
       THEN                            --�׳��쳣
          raise_application_error (-20002, '��������ͬ��Ա����¼');
       END IF;
       INSERT INTO dept(deptno, dname, loc)  
            VALUES (p_deptno, p_dname, '�й�');--�����¼
    END newdept;    
    
    --������ʵ�ְ��淶�ж����getraisedsalary����
    FUNCTION getraisedsalary (p_empno emp.empno%TYPE)
       RETURN NUMBER
    IS
       v_job           emp.job%TYPE;            --ְλ����
       v_sal           emp.sal%TYPE;            --н�ʱ���
       v_salaryratio   NUMBER (10, 2);          --��н����
    BEGIN
       --��ȡԱ�����е�н����Ϣ
       SELECT job, sal INTO v_job, v_sal FROM emp WHERE empno = p_empno;
       CASE v_job                               --���ݲ�ͬ��ְλ��ȡ��н����
          WHEN 'ְԱ' THEN
             v_salaryratio := 1.09;
          WHEN '������Ա' THEN
             v_salaryratio := 1.11;
          WHEN '����' THEN
             v_salaryratio := 1.18;
          ELSE
             v_salaryratio := 1;
       END CASE;
       IF v_salaryratio <> 1                    --����е�н�Ŀ���
       THEN
          RETURN ROUND(v_sal * v_salaryratio,2);         --���ص�н���н��
       ELSE
          RETURN v_sal;                         --���򲻷���н��
       END IF;
     EXCEPTION
          WHEN NO_DATA_FOUND THEN
             RETURN 0;                             --���û�ҵ�ԭ����¼������0
     END getraisedsalary;
     
    --���غ�����ʵ��
    FUNCTION getraisedsalary (p_ename emp.ename%TYPE)
       RETURN NUMBER
    IS
       v_job           emp.job%TYPE;            --ְλ����
       v_sal           emp.sal%TYPE;            --н�ʱ���
       v_salaryratio   NUMBER (10, 2);          --��н����
    BEGIN
       --��ȡԱ�����е�н����Ϣ
       SELECT job, sal INTO v_job, v_sal FROM emp WHERE ename = p_ename AND ROWNUM=1;
       CASE v_job                               --���ݲ�ͬ��ְλ��ȡ��н����
          WHEN 'ְԱ' THEN
             v_salaryratio := 1.09;
          WHEN '������Ա' THEN
             v_salaryratio := 1.11;
          WHEN '����' THEN
             v_salaryratio := 1.18;
          ELSE
             v_salaryratio := 1;
       END CASE;
       IF v_salaryratio <> 1                    --����е�н�Ŀ���
       THEN
          RETURN ROUND(v_sal * v_salaryratio,2);         --���ص�н���н��
       ELSE
          RETURN v_sal;                         --���򲻷���н��
       END IF;
     EXCEPTION
          WHEN NO_DATA_FOUND THEN
             RETURN 0;                             --���û�ҵ�ԭ����¼������0
     END getraisedsalary;     
     
    --˽�У��ú����ڰ��淶�в������ڣ�ֻ���ڰ����ڱ�����
    FUNCTION checkdeptno(p_deptno dept.deptno%TYPE) RETURN NUMBER
    AS
      v_counter NUMBER(2);
    BEGIN
       SELECT COUNT(*) INTO v_counter FROM dept WHERE deptno=p_deptno;
       RETURN v_counter; 
    END;           
END emp_action_pkg_overload;   


DECLARE
   v_sal NUMBER(10,2);
BEGIN
   emp_action_pkg_overload.newdept(43,'��Ʒ��','����');          --���ع���ʹ��ʾ��
   emp_action_pkg_overload.newdept(44,'ֽƷ��');
   v_sal:=emp_action_pkg_overload.getraisedsalary(7369);         --���غ���ʹ��ʾ��
   v_sal:=emp_action_pkg_overload.getraisedsalary('ʷ��˹');
END;

--�����ͷ���ڰ�ͷ�ж���Ҫ�����ĳ�Ա
CREATE OR REPLACE PACKAGE InitTest IS
   TYPE emp_typ IS TABLE OF emp%ROWTYPE INDEX BY BINARY_INTEGER;
   CURSOR emp_cur RETURN emp%ROWTYPE;      --�����α�
   curr_time NUMBER;                       --��ǰ����
   emp_tab emp_typ;                        --���弯�����͵ı���
   --����һ��������Ա���Ĺ���
   PROCEDURE newdept (
       p_deptno   dept.deptno%TYPE,    --���ű��
       p_dname    dept.dname%TYPE,     --��������
       p_loc      dept.loc%TYPE        --λ��
    );   
    --����һ����ȡԱ����н�����ĺ���
    FUNCTION getraisedsalary (p_empno emp.empno%TYPE)
       RETURN NUMBER;         
END InitTest;
--������壬�ڰ���ĳ�ʼ������԰����г�ʼ��
CREATE OR REPLACE PACKAGE BODY InitTest IS
   row_counter NUMBER:=1;
   CURSOR emp_cur RETURN emp%ROWTYPE IS
      SELECT * FROM emp ORDER BY sal DESC; --�����α���         
    --����һ��������Ա���Ĺ���
   PROCEDURE newdept (
       p_deptno   dept.deptno%TYPE,    --���ű��
       p_dname    dept.dname%TYPE,     --��������
       p_loc      dept.loc%TYPE        --λ��
    ) AS
    BEGIN
       NULL;
    END newdept;
    --����һ����ȡԱ����н�����ĺ���
    FUNCTION getraisedsalary (p_empno emp.empno%TYPE)
       RETURN NUMBER IS
    BEGIN
       NULL;
    END getraisedsalary;
BEGIN    
    --����ʼ�����֣�������Ĵ���
    SELECT TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS')) INTO curr_time FROM dual;
     FOR emp_row IN emp_cur LOOP
       emp_tab(row_counter):=emp_row;          --Ϊ���ϸ�ֵ
       row_counter:=row_counter+1;
    END LOOP;   
EXCEPTION 
    WHEN OTHERS THEN 
       DBMS_OUTPUT.put_line('�������쳣');               
END InitTest;

DECLARE
   v_time NUMBER;
BEGIN
   v_time:=InitTest.curr_time;              --��ȡ��ǰ��ʱ������
   --����������е�Ա�����ƣ��Լ���ǰ��������
  DBMS_OUTPUT.put_line(InitTest.emp_tab(1).ename||' '||v_time);
END;


--���ô��ȼ���
/*PRAGMA RESTRICT_REFERENCES WNPS/WNDS/WNPS/RNPS ��ⲻ��*/
CREATE OR REPLACE PACKAGE purityTest IS
  TYPE emp_type IS TABLE OF scott.emp%ROWTYPE INDEX BY PLS_INTEGER;
  emp_tab emp_type;
  PROCEDURE insertDept(p_deptno scott.dept.deptno%TYPE,
                       p_dname  scott.dept.dname%TYPE,
                       p_loc    scott.dept.loc%TYPE);
  FUNCTION getEmpSal(p_empno scott.emp.empno%TYPE) RETURN NUMBER;
  --���ô��ȼ���
  PRAGMA RESTRICT_REFERENCES(insertDept, WNPS); --���ƺ��������޸İ�������Ҳ���ܸ���������ֵ
  PRAGMA RESTRICT_REFERENCES(getEmpSal, WNDS, WNPS, RNPS);
END purityTest;

sELECT DISTINCT job FROM scott.emp;
CREATE OR REPLACE PACKAGE BODY purityTest AS
  PROCEDURE insertDept(p_deptno scott.dept.deptno%TYPE,
                       p_dname  scott.dept.dname%TYPE,
                       p_loc    scott.dept.loc%TYPE) AS
    v_count NUMBER := 0;
  BEGIN
    SELECT COUNT(1) INTO v_count FROM scott.dept WHERE deptno = p_deptno;
    IF v_count > 0 THEN
      raise_application_error(-20000, '���ܲ�����ͬ���ű�ŵļ�¼');
    END IF;
    INSERT INTO scott.dept VALUES (p_deptno, p_dname, p_loc);
  END insertDept;

  FUNCTION getEmpSal(p_empno scott.emp.empno%TYPE) RETURN NUMBER AS
    v_job   scott.emp.job%TYPE;
    v_sal   scott.emp.sal%TYPE;
    v_radio NUMBER := 1;
  BEGIN
    SELECT job, sal INTO v_job, v_sal FROM scott.emp WHERE empno = p_empno AND ROWNUM=1;
    CASE v_job
      WHEN 'CLERK' THEN
        v_radio := 1.1;
      WHEN 'SALESMAN' THEN
        v_radio := 1.2;
      WHEN 'MANAGER' THEN
        v_radio := 1.5;
      ELSE
        v_radio := 1.0;
    END CASE;
    IF v_radio <> 1 THEN
      RETURN ROUND(v_sal * v_radio, 2);
    ELSE
      RETURN v_sal;
    END IF;
  END getEmpSal;
END purityTest;

SELECT empno Ա�����, purityTest.getEmpSal (empno) ��н��, sal ��нǰ,job
  FROM emp
 WHERE deptno = 20;
 
 GRANT EXECUTE ON scott.purityTest TO hr;     --Ϊhr����ִ��Ȩ��
DROP PACKAGE scott.purityTest;   --ɾ����

--������淶  
/*authid current_user ��ⲻ��*/
CREATE OR REPLACE PACKAGE emp_action_pkg 
   AUTHID CURRENT_USER IS               --ָ�����еĹ���Ϊ������Ȩ��   
   v_deptno NUMBER(3):=20;              --�������ı���
   --����һ��������Ա���Ĺ���
   PROCEDURE newdept (
       p_deptno   dept.deptno%TYPE,    --���ű��
       p_dname    dept.dname%TYPE,     --��������
       p_loc      dept.loc%TYPE        --λ��
    );   
    --����һ����ȡԱ����н�����ĺ���
    FUNCTION getraisedsalary (p_empno emp.empno%TYPE)
       RETURN NUMBER;    
END emp_action_pkg;


--������淶�����淶��������Ӧ�ó���Ľӿڲ��֣����ⲿ����
CREATE OR REPLACE PACKAGE emp_pkg AS
   --���弯������
   TYPE emp_tab IS TABLE OF emp%ROWTYPE INDEX BY BINARY_INTEGER;
   --�ڰ��淶�ж���һ����¼����
   TYPE emprectyp IS RECORD(
      emp_no NUMBER,
      sal  NUMBER
   );
   --����һ���α�����
   CURSOR desc_salary RETURN emprectyp;
   --����һ���α꣬�������α���   
   CURSOR emp_cur(p_deptno IN dept.deptno%TYPE) IS
      SELECT * FROM emp WHERE deptno=p_deptno;   
   --�����ӶԱ���Ĺ���
   PROCEDURE hire_employee(p_empno NUMBER,p_ename VARCHAR2,p_job VARCHAR2,p_mgr NUMBER,p_sal NUMBER,
                        p_comm NUMBER,p_deptno NUMBER,p_hiredate DATE);
   --������Ա���Ĺ���                        
   PROCEDURE fire_employee(p_emp_id NUMBER );
END emp_pkg;



--�������
CREATE OR REPLACE PACKAGE BODY emp_pkg
AS
   --�����α�����ľ�������
   CURSOR desc_salary RETURN emprectyp IS
      SELECT empno, sal FROM emp ORDER BY sal DESC;
   --�����ӶԱ���ľ���ʵ��
   PROCEDURE hire_employee(p_empno NUMBER,p_ename VARCHAR2,
                           p_job VARCHAR2,p_mgr NUMBER,p_sal NUMBER,
                           p_comm NUMBER,p_deptno NUMBER,p_hiredate DATE) IS
   BEGIN
      FOR emp_salrow IN desc_salary LOOP
        DBMS_OUTPUT.put_line(emp_salrow.emp_no||'�� '||emp_salrow.sal); 
      END LOOP;
   END;       
   --������Ա���ľ���ʵ��                 
   PROCEDURE fire_employee(p_emp_id NUMBER ) IS
   BEGIN
      --��emp����ɾ��Ա����Ϣ
      DELETE FROM emp WHERE empno=p_emp_id;
      FOR emp_row IN emp_cur(20) LOOP
        DBMS_OUTPUT.put_line(emp_row.empno||' '||emp_row.deptno);
      END LOOP;
   END;          
END emp_pkg;

SELECT object_type ��������, object_name ��������, status ״̬
    FROM user_objects
    WHERE object_type IN ('PACKAGE', 'PACKAGE BODY')
    ORDER BY object_type, status, object_name;

--������淶�����淶��������Ӧ�ó���Ľӿڲ��֣����ⲿ����
CREATE OR REPLACE PACKAGE emp_pkg_dependency AS
   --�����ӶԱ���Ĺ���
   PROCEDURE hire_employee(p_empno NUMBER,p_ename VARCHAR2,p_job VARCHAR2,p_mgr NUMBER,p_sal NUMBER,
                        p_comm NUMBER,p_deptno NUMBER,p_hiredate DATE);
   --������Ա���Ĺ���                        
   PROCEDURE fire_employee(p_emp_id NUMBER );
END emp_pkg_dependency;
--�������
CREATE OR REPLACE PACKAGE BODY emp_pkg_dependency
AS
   --�����ӶԱ���ľ���ʵ��
   PROCEDURE hire_employee(p_empno NUMBER,p_ename VARCHAR2,
                           p_job VARCHAR2,p_mgr NUMBER,p_sal NUMBER,
                           p_comm NUMBER,p_deptno NUMBER,p_hiredate DATE) IS
   BEGIN
      --��emp���в���һ��Ա����Ϣ
      INSERT INTO emp VALUES(p_empno,p_ename,p_job,
                             p_mgr,p_hiredate,
                             p_sal,p_comm,p_deptno); 
      INSERT INTO emp_history VALUES(p_empno,p_ename,p_job,
                                     p_mgr,p_hiredate,
                                     p_sal,p_comm,p_deptno);       
   END;       
   --������Ա���ľ���ʵ��                 
   PROCEDURE fire_employee(p_emp_id NUMBER ) IS
   BEGIN
      --��emp����ɾ��Ա����Ϣ
      DELETE FROM emp WHERE empno=p_emp_id;
   END;          
END emp_pkg_dependency;

SELECT object_name, object_type, status
  FROM user_objects
 WHERE object_name IN ('EMP_PKG_DEPENDENCY', 'EMP');
 
DROP TABLE emp_history;
CREATE TABLE emp_history AS SELECT * FROM emp;
SELECT * from user_dependencies WHERE REFERENCED_NAME='EMP_PKG_DEPENDENCY'

DECLARE
  v_line1  VARCHAR(200);
  v_line2  VARCHAR(200);
  v_status NUMBER;
BEGIN
  DBMS_OUTPUT.ENABLE; --����DBMS_OUTPUT
  DBMS_OUTPUT.PUT_LINE('DBMS_OUTPUT��Ҫ���������Ϣ����������'); --д�벢����
  DBMS_OUTPUT.PUT('PUT_LINE'); --д���ı�������
  DBMS_OUTPUT.PUT(',PUT_LINE');
  DBMS_OUTPUT.PUT(',PUTE');
  DBMS_OUTPUT.PUT(',NEW_LINE');
  DBMS_OUTPUT.PUT(',GET_LINE');
  DBMS_OUTPUT.PUT(',GET_LINES�ȹ���');
  DBMS_OUTPUT.NEW_LINE; --���ı������ϻ��з�
  DBMS_OUTPUT.GET_LINE(v_line1, v_status);
  DBMS_OUTPUT.GET_LINE(v_line2, v_status); --��ȡ�������е�������
  DBMS_OUTPUT.PUT_LINE(v_line1); --���������ֵ��������
  DBMS_OUTPUT.PUT_LINE(v_line2);
END;
/

DECLARE
  v_lines  DBMS_OUTPUT.CHARARR; --���弯�����͵ı���
  v_status NUMBER;
BEGIN
  DBMS_OUTPUT.ENABLE; --����DBMS_OUTPUT
  DBMS_OUTPUT.PUT_LINE('DBMS_OUTPUT��Ҫ���������Ϣ����������'); --д�벢����
  DBMS_OUTPUT.PUT('PUT_LINE'); --д���ı�������
  DBMS_OUTPUT.PUT(',PUT_LINE');
  DBMS_OUTPUT.PUT(',PUTE');
  DBMS_OUTPUT.PUT(',NEW_LINE');
  DBMS_OUTPUT.PUT(',GET_LINE');
  DBMS_OUTPUT.PUT(',GET_LINES�ȹ���');
  DBMS_OUTPUT.NEW_LINE; --���ı������ϻ��з�     
  DBMS_OUTPUT.GET_LINES(v_lines, v_status); --��ȡ�����������е���
  FOR i IN 1 .. v_status LOOP
    DBMS_OUTPUT.PUT_LINE(v_lines(i)); --������������е�������
  END LOOP;
END;
/

--DBMS_PIPE��ʲô��

DECLARE
   v_ename emp.ename%TYPE;
   v_sal emp.sal%TYPE;
   v_rowid ROWID;
   v_empno emp.empno%TYPE:=&empno;
BEGIN
   SELECT rowid,ename,sal INTO v_rowid,v_rowid,v_sal FROM emp WHERE empno=v_empno;
   DBMS_PIPE.pack_message('Ա����ţ�'||v_empno||' Ա�����ƣ�'||v_ename);
   DBMS_PIPE.pack_message('Ա��н�ʣ�'||v_sal||' ROWIDֵ��'||v_rowid);
END;
/


DECLARE 
   v_sendflag INT;                                          --���ͱ�ʶ����
BEGIN
   v_sendflag:=DBMS_PIPE.send_message('PUBLIC_PIPE');    --��ܵ�������Ϣ������ܵ��������򴴽��ܵ�
   IF v_sendflag=0 THEN
      DBMS_OUTPUT.PUT_LINE('��Ϣ�ɹ����͵��ܵ�');        --�����Ϣ�ɹ����ͣ�����ʾ�ɹ���Ϣ
   END IF;
END;



DECLARE 
   v_receiveflag INT;                                              --���ձ�ʶ����
BEGIN
   v_receiveflag:=DBMS_PIPE.receive_message('PUBLIC_PIPE');    --�ӹܵ�������Ϣ������ܵ��������򴴽��ܵ�
   IF v_receiveflag=0 THEN
      DBMS_OUTPUT.PUT_LINE('�ɹ��Ĵӹܵ��л�ȡ��Ϣ');           --�����Ϣ�ɹ����գ�����ʾ�ɹ���Ϣ
   END IF;
END;


DECLARE
   v_message VARCHAR2(100);
BEGIN
   DBMS_PIPE.unpack_message(v_message); --��������������д�뵽����
   DBMS_OUTPUT.PUT_LINE(message);       --��ʾ������������
END;




--���͹ܵ���Ϣ
CREATE OR REPLACE PROCEDURE send_pipe_message(pipename VARCHAR2,message VARCHAR2)
IS
   flag INT;
BEGIN
   flag:=DBMS_PIPE.create_pipe(pipename);           --�����ܵ�
   if flag=0 THEN                                      --����ܵ������ɹ�
      DBMS_PIPE.pack_message(message);              --����Ϣд�����ػ�����
      flag:=DBMS_PIPE.send_message(pipename);       --�����ػ������е���Ϣ���͵��ܵ�
   END IF;
END;
--�ӹܵ��н�����Ϣ
CREATE OR REPLACE PROCEDURE receive_pipe_message(pipename VARCHAR2,message VARCHAR2)
IS
   flag INT;
BEGIN
   falg:=DBMS_PIPE.receive_message(pipename);  --�ӹܵ��л�ȡ��Ϣ�����浽������
   IF flag=0 THEN
      DBMS_PIPE.unpack_message(message);       --�ӻ�������ȡ��Ϣ
      flag:=DBMS_PIPE.remove_pipe(pipename);    --�Ƴ��ܵ�
   END IF;
END;



DECLARE
   v_alertname   VARCHAR2 (30)  := 'alert_demo';    --��������
   v_status      INTEGER;                           --�ȴ�״̬
   v_msg         VARCHAR2 (200);                    --������Ϣ
BEGIN
    --ע�ᱨ����ָ��������Ϊalert_demo
   DBMS_ALERT.REGISTER (v_alertname);
   --�����������ȴ���������
   DBMS_ALERT.waitone (v_alertname, v_msg, v_status);
   --���������0����ʾ����ʾ��
   IF v_status != 0
   THEN
      DBMS_OUTPUT.put_line ('error');        --��ʾ������Ϣ
   END IF;
   DBMS_OUTPUT.put_line (v_msg);             --��ʾ������Ϣ
END;



DECLARE
   v_alertname   VARCHAR2 (30) := 'alert_demo';
BEGIN
    --�򱨾�alert_demo���ͱ�����Ϣ
   DBMS_ALERT.signal (v_alertname, 'dbms_alert����!');
   COMMIT;             --���������������ROLLBACK���򲻴���������
END;




DECLARE
   v_jobno   NUMBER;
BEGIN
   DBMS_JOB.submit
        (v_jobno,                             --��ҵ���
          --��ҵִ�еĹ���
         'DBMS_DDL.analyze_object(''TABLE'',''SCOTT'',''EMP'',''COMPUTE'');',
         --��һ��ִ�е�����         
         SYSDATE,
         --ִ�е�ʱ��������ʾ24Сʱ��
         'SYSDATE+1'
        );  
   DBMS_OUTPUT.put_line('��ȡ����ҵ���Ϊ��'||v_jobno);  --�����ҵ���
   COMMIT;
END;


SELECT job, next_date, next_sec, INTERVAL, what
  FROM user_jobs
 WHERE job = 22904
 
 
SELECT TO_DATE ('2011-10-15', 'YYYY-MM-DD')
  FROM DUAL;

EXEC DBMS_JOB.WHAT(22904,'emp_pkg_dependency.fire_employee(7369)'); 


function date_to_run_emp_job
return date
is
  mydate date;
begin
  if to_char(sysdate,'D') < 4 --Wednesday is the 4th day of the week in Oracle
  then
    mydate := trunc(sysdate,'W')+2+15/24 ; --Monday is the 1st day of week
  elsif to_char(sysdate,'D')=4 and sysdate < trunc(sysdate)+15/24 then
    --ie. it's Wednesday but it's before 3 pm
    mydate := trunc(sysdate,'W')+2+15/24 ;
  else
    mydate := trunc(sysdate,'W')+4+17/24 ; --Friday at 5 pm
  end if;  
  return mydate;
end;
/

