/*
������
  DML������
    �д�����/��䴥����
  ���������
  ϵͳ�¼�������
    �û��¼�������/ϵͳ�¼�������
  create or replace trigger_name
  before/after/instead of [insert/update/delete..]
  referencing new as new_name old as old_name
  for each row
  when condition
  trigger_body
*/
--����һ�����¼�������
/*
BEFORE UPDATE ON scott.emp ����Ҫ��on �Ǹ���
WHEN (old.sal < new.sal)�����������Ҫ������
IF updating('sal') THEN  ������ֶ�Ҫ��'',�Ҳ�����scott.emp.sal     
*/
DROP TABLE emp_history;
CREATE TABLE emp_history AS SELECT * FROM scott.emp WHERE 1<>1; 
CREATE OR REPLACE TRIGGER update_emp_trigger
  BEFORE UPDATE ON scott.emp
  FOR EACH ROW
  WHEN (old.sal < new.sal)
DECLARE
  v_sal NUMBER;
BEGIN
  IF updating('sal') THEN
    v_sal:=:new.sal-:old.sal;
    DELETE FROM scott.emp_history h WHERE h.empno=:old.empno;
    INSERT INTO scott.emp_history VALUES(:old.empno,:old.ename,:old.job,:old.mgr,:old.hiredate,:old.sal,:old.comm,:old.deptno);
    UPDATE scott.emp_history SET sal=v_sal WHERE empno=:old.empno;
  END IF;
END;

UPDATE scott.emp SET sal=sal*0.9 WHERE deptno=30;
SELECT * FROM scott.emp_history;

--����һ��emp_log������emp����¼
CREATE TABLE emp_log AS SELECT * FROM scott.emp WHERE 1<>1;
ALTER TABLE emp_log ADD log_id NUMBER NOT NULL PRIMARY KEY;
ALTER TABLE emp_log ADD log_act VARCHAR2(10);
ALTER TABLE emp_log ADD log_date DATE DEFAULT SYSDATE;
DROP SEQUENCE emp_log_seq;
CREATE SEQUENCE emp_log_seq;
SELECT * FROM emp_log;
CREATE OR REPLACE TRIGGER save_emp_log_trigger
  BEFORE INSERT OR UPDATE OR DELETE ON scott.emp
  FOR EACH ROW
BEGIN
  IF inserting THEN
    INSERT INTO emp_log
      (log_id, log_act, empno, ename, job, mgr, hiredate, sal, comm)
    VALUES
      (emp_log_seq.nextval,
       'insert',
       :new.empno,
       :new.ename,
       :new.job,
       :new.mgr,
       :new.hiredate,
       :new.sal,
       :new.comm);
  
  END IF;
  IF updating THEN
    INSERT INTO emp_log
      (log_id, log_act, empno, ename, job, mgr, hiredate, sal, comm)
    VALUES
      (emp_log_seq.nextval,
       'update',
       :old.empno,
       :old.ename,
       :old.job,
       :old.mgr,
       :old.hiredate,
       :old.sal,
       :old.comm);
    INSERT INTO emp_log
      (log_id, log_act, empno, ename, job, mgr, hiredate, sal, comm)
    VALUES
      (emp_log_seq.nextval,
       'update',
       :new.empno,
       :new.ename,
       :new.job,
       :new.mgr,
       :new.hiredate,
       :new.sal,
       :new.comm);
  END IF;
  IF deleting THEN
    INSERT INTO emp_log
      (log_id, log_act, empno, ename, job, mgr, hiredate, sal, comm)
    VALUES
      (emp_log_seq.nextval,
       'delete',
       :old.empno,
       :old.ename,
       :old.job,
       :old.mgr,
       :old.hiredate,
       :old.sal,
       :old.comm);
  END IF;
END;
INSERT INTO scott.emp VALUES(9000,'ǿ��','clerk',7566,SYSDATE,15000,NULL,20);
UPDATE scott.emp SET sal=17000 WHERE empno=9000;
DELETE FROM scott.emp WHERE empno=9000;
SELECT * FROM emp_log;
--����һ����������
SELECT to_char(DATE '2017-01-14', 'DAY', 'NLS_DATE_LANGUAGE = American'),
       to_char(DATE '2017-01-15', 'DAY', 'NLS_DATE_LANGUAGE = American'),
       to_char(SYSDATE, 'HH24:MI')
  FROM dual;

CREATE OR REPLACE TRIGGER t_verify_empty_time
  BEFORE INSERT OR UPDATE OR DELETE ON scott.emp
BEGIN
  IF deleting THEN
    IF (to_char(SYSDATE, 'DAY', 'NLS_DATE_LANGUAGE = American') IN
       ('SATURDAY ', 'SUNDAY') OR
       to_char(SYSDATE, 'HH24:MI') NOT BETWEEN '8:30' AND '18:00') THEN
      raise_application_error(-20000, '�㲻���ڿ���ʱ��������ݿ⣡');
    END IF;
  END IF;
END;

DELETE FROM scott.emp;

--����������ͳ�Ʋ�������
CREATE TABLE audit_emp(
table_name VARCHAR2(100),
start_time DATE,
end_time DATE,
ins_count NUMBER DEFAULT 0,
upd_count NUMBER DEFAULT 0,
del_count NUMBER DEFAULT 0
);
CREATE OR REPLACE TRIGGER t_audit_emp
  AFTER INSERT OR UPDATE OR DELETE ON scott.emp
DECLARE
  v_count NUMBER := 0;
BEGIN
  SELECT COUNT(1) INTO v_count FROM audit_emp WHERE table_name = 'emp';
  IF v_count = 0 THEN
    INSERT INTO audit_emp
      (table_name, start_time, end_time)
    VALUES
      ('emp', SYSDATE, NULL);
  END IF;
  IF inserting THEN
    UPDATE audit_emp
       SET ins_count = ins_count + 1,end_time=SYSDATE
     WHERE table_name = 'emp';
  END IF;
  IF updating THEN
    UPDATE audit_emp
       SET upd_count = upd_count + 1,end_time=SYSDATE
     WHERE table_name = 'emp';
  END IF;
  IF deleting THEN
    UPDATE audit_emp
       SET del_count = del_count + 1,end_time=SYSDATE
     WHERE table_name = 'emp';
  END IF;
END;
DROP TRIGGER update_emp_trigger;
DROP TRIGGER t_verify_empty_time;
SELECT * FROM scott.emp;
DELETE FROM scott.emp WHERE empno=9005;
INSERT INTO scott.emp VALUES(9005,'kehan','clerk','7566',DATE'2017-02-14',8000,DEFAULT,30);
UPDATE scott.emp SET ename='����' WHERE empno=9005;
SELECT * FROM scott.audit_emp;
--referencing Ϊold new ȡ����
CREATE OR REPLACE TRIGGER update_emp_trigger
  BEFORE UPDATE ON scott.emp
  REFERENCING OLD AS o NEW AS n
  FOR EACH ROW
  WHEN (o.sal < n.sal)
DECLARE
  v_sal NUMBER;
BEGIN
  IF updating('sal') THEN
    v_sal:=:n.sal-:o.sal;
    DELETE FROM scott.emp_history h WHERE h.empno=:o.empno;
    INSERT INTO scott.emp_history VALUES(:o.empno,:o.ename,:o.job,:o.mgr,:o.hiredate,:o.sal,:o.comm,:o.deptno);
    UPDATE scott.emp_history SET sal=v_sal WHERE empno=:o.empno;
  END IF;
END;
TRUNCATE TABLE scott.emp_history;
UPDATE scott.emp SET sal=sal*1.2 WHERE deptno=30;
SELECT * FROM scott.emp_history;

DROP TABLE test_emp;
DROP TABLE emp_rec;
DROP SEQUENCE test_emp_seq;
CREATE TABLE test_emp(
emp_id NUMBER,
empno NUMBER,
ename VARCHAR2(20)
);
--new�����Ը�ֵ
CREATE TABLE emp_rec AS SELECT * FROM test_emp WHERE 1<>1;
CREATE SEQUENCE test_emp_seq;
CREATE OR REPLACE TRIGGER t_assign_test
  BEFORE INSERT ON test_emp
  FOR EACH ROW
DECLARE
  v_emp_rec emp_rec%ROWTYPE;
BEGIN
  SELECT test_emp_seq.nextval INTO :NEW.emp_id FROM dual;
  v_emp_rec.emp_id := :NEW.emp_id;
  v_emp_rec.empno  := :NEW.empno;
  v_emp_rec.ename  := :NEW.ename;
  --INSERT INTO emp_rec VALUES��v_emp_rec;�����ܹ���
  INSERT INTO emp_rec VALUES(v_emp_rec.emp_id,v_emp_rec.empno,v_emp_rec.ename);
END;
INSERT INTO test_emp(empno,ename) VALUES(1,'������');
SELECT * FROM test_emp;
SELECT * FROM emp_rec;

CREATE OR REPLACE TRIGGER t_emp_comm
   BEFORE UPDATE ON emp     --���������õı�����Լ������������ʹ����Ķ���
   FOR EACH ROW             --�м���Ĵ�����
   WHEN(NEW.comm>OLD.comm)    --����������
DECLARE
   v_comm   NUMBER;          --�����������
BEGIN
   IF UPDATING ('comm') THEN --ʹ������ν���ж��Ƿ���comm�б�����
      v_comm := :NEW.comm - :OLD.comm; --��¼���ʵĲ���
      DELETE FROM emp_history 
            WHERE empno = :OLD.empno;      --ɾ��emp_history�оɱ��¼
      INSERT INTO emp_history              --����в����µļ�¼
           VALUES (:OLD.empno, :OLD.ename, :OLD.job, :OLD.mgr, :OLD.hiredate,
                   :OLD.sal, :OLD.comm, :OLD.deptno);
      UPDATE emp_history                   --����н��ֵ
         SET comm = v_comm
       WHERE empno = :NEW.empno;
   END IF;
END;


CREATE OR REPLACE TRIGGER t_comm_sal
   BEFORE UPDATE ON emp     --���������õı�����Լ������������ʹ����Ķ���
   FOR EACH ROW             --�м���Ĵ�����
BEGIN
   CASE 
   WHEN UPDATING('comm') THEN          --����Ƕ�comm�н��и���     
      IF :NEW.comm<:OLD.comm THEN      --Ҫ���µ�commֵҪ���ھɵ�commֵ
         RAISE_APPLICATION_ERROR(-20001,'�µ�commֵ����С�ھɵ�commֵ');
      END IF;
   WHEN UPDATING('sal') THEN           --����Ƕ�sal�н��и���
      IF :NEW.sal<:OLD.sal THEN        --Ҫ���µ�salֵҪ���ھɵ�salֵ
         RAISE_APPLICATION_ERROR(-20001,'�µ�salֵ����С�ھɵ�salֵ'); 
      END IF;
   END CASE;        
END;

--����һ���������Զ����������ִ��˳��
CREATE TABLE trigger_data
(
   trigger_id  INT,
   tirgger_name VARCHAR2(100)
)
--������һ��������
CREATE OR REPLACE TRIGGER one_trigger
   BEFORE INSERT
   ON trigger_data
   FOR EACH ROW
BEGIN
   :NEW.trigger_id := :NEW.trigger_id + 1;
   DBMS_OUTPUT.put_line('������one_trigger');
END;
--�������1��������������ͬ������ͬ����ʱ���Ĵ�����
CREATE OR REPLACE TRIGGER two_trigger
   BEFORE INSERT
   ON trigger_data
   FOR EACH ROW
   FOLLOWS one_trigger          --�øô�������one_trigger���津��
BEGIN
   DBMS_OUTPUT.put_line('������two_trigger');
   IF :NEW.trigger_id > 1
   THEN
      :NEW.trigger_id := :NEW.trigger_id + 2;
   END IF;
END;
/*
ORA-04091: �� SCOTT.EMP �����˱仯, ������/�������ܶ���
ORA-06512: �� "SCOTT.T_EMP_MAXSAL", line 4
ORA-04088: ������ 'SCOTT.T_EMP_MAXSAL' ִ�й����г���
*/
CREATE OR REPLACE TRIGGER t_emp_maxsal
   BEFORE UPDATE OF sal
   ON scott.emp                       --��UPDATE������salֵ֮ǰ����
   FOR EACH ROW                 --�м���Ĵ�����
DECLARE
   v_maxsal   NUMBER;           --�������н��ֵ�ı���
BEGIN
   SELECT MAX(sal)            
     INTO v_maxsal
     FROM scott.emp;                  --��ȡemp�����н��ֵ
   UPDATE scott.emp
      SET sal = v_maxsal - 100  --����Ա��7369��н��ֵ
    WHERE empno = 7369;
END;

BEGIN
UPDATE emp SET sal=sal*1.12 WHERE deptno=20;
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line(SQLERRM);
END;


INSERT INTO trigger_data VALUES(1,'triggerdemo');
SELECT * FROM trigger_data;
TRUNCATE TABLE trigger_data;

SELECT referenced_name, referenced_type, dependency_type
  FROM user_dependencies
 WHERE NAME = 'TWO_TRIGGER' AND referenced_type = 'TRIGGER';
 
 
 CREATE OR REPLACE TRIGGER t_emp_comm
   BEFORE UPDATE ON emp     --���������õı�����Լ������������ʹ����Ķ���
   FOR EACH ROW             --�м���Ĵ�����
   WHEN(NEW.comm>OLD.comm)    --����������
DECLARE   
   v_comm   NUMBER;          --�����������
   PRAGMA AUTONOMOUS_TRANSACTION; --��������      
BEGIN
   IF UPDATING ('comm') THEN --ʹ������ν���ж��Ƿ���comm�б�����
      v_comm := :NEW.comm - :OLD.comm; --��¼���ʵĲ���
      DELETE FROM emp_history 
            WHERE empno = :OLD.empno;      --ɾ��emp_history�оɱ��¼
      INSERT INTO emp_history              --����в����µļ�¼
           VALUES (:OLD.empno, :OLD.ename, :OLD.job, :OLD.mgr, :OLD.hiredate,
                   :OLD.sal, :OLD.comm, :OLD.deptno);
      UPDATE emp_history                   --����н��ֵ
         SET comm = v_comm
       WHERE empno = :NEW.empno;
   END IF;
   COMMIT;                                 --�ύ������������
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK;                            --�����κ�����ع���������
END;

SELECT * FROM emp WHERE deptno=20;

--������ͼemp_dept��ͼ
CREATE OR REPLACE VIEW scott.emp_dept (empno,
                                       ename,
                                       job,
                                       mgr,
                                       hiredate,
                                       sal,
                                       comm,
                                       deptno,
                                       dname,
                                       loc
                                      )
AS
   SELECT emp.empno, emp.ename, emp.job, emp.mgr, emp.hiredate, emp.sal,
          emp.comm, emp.deptno, dept.dname, dept.loc
     FROM dept, emp
    WHERE ((dept.deptno = emp.deptno));
    
CREATE OR REPLACE TRIGGER t_dept_emp
   INSTEAD OF INSERT ON emp_dept      --����ͼemp_dept�ϴ���INSTEAD OF������
   REFERENCING NEW AS n               --ָ��ν�ʱ���
   FOR EACH ROW                       --�м�������
DECLARE
   v_counter   INT;                   --������ͳ�Ʊ���
BEGIN
   SELECT COUNT (*)
     INTO v_counter
     FROM dept
    WHERE deptno = :n.deptno;         --�ж���dept�����Ƿ������Ӧ�ļ�¼   
   IF v_counter = 0                   --��������ڸ�dept��¼
   THEN
      INSERT INTO dept VALUES (:n.deptno, :n.dname, :n.loc);   --��dept���в����µĲ��ż�¼
   END IF;
   SELECT COUNT (*)                   --�ж�emp�����Ƿ����Ա����¼
     INTO v_counter
     FROM emp
    WHERE empno = :n.empno;
   IF v_counter = 0                   --��������ڣ�����emp���в���Ա����¼
   THEN
      INSERT INTO emp
                  (empno, ename, job, mgr, hiredate, sal,
                   comm, deptno
                  )
           VALUES (:n.empno, :n.ename, :n.job, :n.mgr, :n.hiredate, :n.sal,
                   :n.comm, :n.deptno
                  );
   END IF;
END;

SELECT * FROM dept;

SELECT * FROM emp_dept;



INSERT INTO emp_dept
  (empno, ename, job, mgr, hiredate, sal, comm, deptno, dname, loc)
VALUES
  (8000,
   '��̫��',
   '��ְ',
   NULL,
   TRUNC(SYSDATE),
   5000,
   300,
   80,
   '����',
   '��ɽ');
SELECT * FROM dept;

SELECT * FROM emp_dept;
CREATE OR REPLACE TRIGGER t_dept_emp_update
   INSTEAD OF UPDATE ON emp_dept      --����ͼemp_dept�ϴ���INSTEAD OF������
   REFERENCING NEW AS n OLD AS o      --ָ��ν�ʱ���
   FOR EACH ROW                       --�м�������
DECLARE
   v_counter   INT;                   --������ͳ�Ʊ���
BEGIN
   SELECT COUNT (*)
     INTO v_counter
     FROM dept
    WHERE deptno = :o.deptno;           --�ж���dept�����Ƿ������Ӧ�ļ�¼   
   IF v_counter >0                      --������ڣ������dept��
   THEN
      UPDATE dept SET dname=:n.dname,loc=:n.loc WHERE deptno=:o.deptno;
   END IF;
   SELECT COUNT (*)                    --�ж�emp�����Ƿ����Ա����¼
     INTO v_counter
     FROM emp
    WHERE empno = :n.empno;
   IF v_counter > 0                    --������ڣ������emp��
   THEN
      UPDATE emp SET ename=:n.ename,job=:n.job,mgr=:n.mgr, hiredate=:n.hiredate,sal=:n.sal,
                   comm=:n.comm, deptno=:n.deptno WHERE empno=:o.empno;        
   END IF;
END; 


CREATE OR REPLACE TRIGGER t_dept_emp_delete
   INSTEAD OF DELETE ON emp_dept       --����ͼemp_dept�ϴ���INSTEAD OF������
   REFERENCING  OLD AS o               --ָ��ν�ʱ���
   FOR EACH ROW                        --�м�������
BEGIN
   DELETE FROM emp WHERE empno=:o.empno;        --ɾ��emp��
   DELETE FROM dept WHERE deptno=:o.deptno;     --ɾ��dept��
END; 


SELECT * FROM emp_dept WHERE empno=8000;

DELETE FROM emp_dept WHERE empno=8000;

CREATE OR REPLACE TRIGGER t_emp_dept
   INSTEAD OF UPDATE OR INSERT OR DELETE ON emp_dept   
   REFERENCING NEW AS n OLD AS o      --ָ��ν�ʱ���
   FOR EACH ROW                       --�м�������
DECLARE
   v_counter   INT;                   --������ͳ�Ʊ���
BEGIN
   SELECT COUNT (*)
     INTO v_counter
     FROM dept
    WHERE deptno = :o.deptno;           --�ж���dept�����Ƿ������Ӧ�ļ�¼   
   IF v_counter >0                      --������ڣ������dept��
   THEN
      CASE 
      WHEN UPDATING THEN
         UPDATE dept SET dname=:n.dname,loc=:n.loc WHERE deptno=:o.deptno;
      WHEN INSERTING THEN
         INSERT INTO dept VALUES (:n.deptno, :n.dname, :n.loc); 
      WHEN DELETING THEN
         DELETE FROM dept WHERE deptno=:o.deptno;     --ɾ��dept��      
      END CASE;
   END IF;
   SELECT COUNT (*)                    --�ж�emp�����Ƿ����Ա����¼
     INTO v_counter
     FROM emp
    WHERE empno = :n.empno;
   IF v_counter > 0                    --������ڣ������emp��
   THEN
      CASE 
      WHEN UPDATING THEN
         UPDATE emp SET ename=:n.ename,job=:n.job,mgr=:n.mgr, hiredate=:n.hiredate,sal=:n.sal,
                   comm=:n.comm, deptno=:n.deptno WHERE empno=:o.empno;    
      WHEN INSERTING THEN
         INSERT INTO emp
                  (empno, ename, job, mgr, hiredate, sal,
                   comm, deptno
                  )
           VALUES (:n.empno, :n.ename, :n.job, :n.mgr, :n.hiredate, :n.sal,
                   :n.comm, :n.deptno
                  );
      WHEN DELETING THEN
         DELETE FROM emp WHERE empno=:o.empno;   
      END CASE;       
   END IF;
END;  

SELECT * FROM emp;

--��������Ƕ�ױ�Ķ�������  MULTISET???
CREATE OR REPLACE TYPE emp_obj AS OBJECT(
   empno NUMBER(4),
   ename VARCHAR2(10),
   job VARCHAR2(10),
   mgr NUMBER(4),
   hiredate DATE,
   sal NUMBER(7,2),
   comm NUMBER(7,2),
   deptno NUMBER(2)
);
--����Ƕ�ױ�����
CREATE OR REPLACE TYPE emp_tab_type AS TABLE OF emp_obj;
--����Ƕ�ױ���ͼ��MULTISET������CASTһ��ʹ��
CREATE OR REPLACE VIEW dept_emp_view AS
   SELECT deptno,dname,loc,
   CAST(MULTISET(SELECT * FROM emp WHERE deptno=dept.deptno) AS emp_tab_type) emplst
   FROM dept;
   
SELECT * FROM dept_emp_view  where deptno=10;

--ORA-25015: ������Ƕ�ױ���ͼ����ִ�� DML
BEGIN
  INSERT INTO TABLE
    (SELECT emplst FROM dept_emp_view WHERE deptno = 10)
  VALUES
    (8003, '��ү', '����', NULL, SYSDATE, 5000, 500, 10);
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line(SQLERRM);
END;
CREATE OR REPLACE TRIGGER dept_emp_innerview
   INSTEAD OF INSERT
   ON NESTED TABLE emplst OF dept_emp_view                       --����Ƕ�ױ����������
BEGIN
   INSERT INTO emp                                             --�����ӱ��¼
               (deptno, empno, ename, job, mgr,
                hiredate, sal, comm
               )
        VALUES (:PARENT.deptno, :NEW.empno, :NEW.ename, :NEW.job, :NEW.mgr,
                :NEW.hiredate, :NEW.sal, :NEW.comm
               );
END;

--ϵͳ�¼�
DROP TABLE created_log;
CREATE TABLE created_log
(
    obj_owner VARCHAR2(30),   --������
    obj_name  VARCHAR2(30),   --��������
    obj_type  VARCHAR2(20),   --��������
    obj_user VARCHAR2(30),    --�����û�
    created_date DATE     --��������
);

CREATE OR REPLACE TRIGGER t_created_log
  AFTER CREATE ON scott.SCHEMA --��soctt�����´�������󴥷�
BEGIN
  --������־��¼
  INSERT INTO scott.created_log
    (obj_owner, obj_name, obj_type, obj_user, created_date)
  VALUES
    (SYS.dictionary_obj_owner,
     SYS.dictionary_obj_name,
     SYS.dictionary_obj_type,
     SYS.login_user,
     SYSDATE);
END;
DROP TABLE scott.t; 
CREATE TABLE scott.t(ID NUMBER);
SELECT * FROM scott.created_log;

--��DBA��ݵ�¼����������ĵ�¼��¼��
CREATE TABLE log_db_table
(
   username VARCHAR2(20),
   logon_time DATE,
   logoff_time DATE,
   address VARCHAR2(20) 
);
--��soctt��ݵ�¼����������ĵ�¼��¼��
CREATE TABLE log_user_table
(
   username VARCHAR2(20),
   logon_time DATE,
   logoff_time DATE,
   address VARCHAR2(20) 
);

--��DBA��ݵ�¼������DATABASE�����LOGON�¼�������
CREATE OR REPLACE TRIGGER t_db_logon
AFTER LOGON ON DATABASE
BEGIN
  INSERT INTO log_db_table(username,logon_time,address)
              VALUES(ora_login_user,SYSDATE,ora_client_ip_address);
END;
--��scott��ݵ�¼���������µ�SCHEMA�����LOGON�¼�������
CREATE OR REPLACE TRIGGER t_user_logon
AFTER LOGON ON SCHEMA
BEGIN
  INSERT INTO log_user_table(username,logon_time,address)
              VALUES(ora_login_user,SYSDATE,ora_client_ip_address);
END;

--��DBA��ݽ���ϵͳ��������ʱ��
CREATE TABLE event_table(
   sys_event VARCHAR2(30),
   event_time DATE
);

--��DBA���𴴽����µ�2��������
CREATE OR REPLACE TRIGGER t_startup
AFTER STARTUP ON DATABASE       --STARTUPֻ����AFTER
BEGIN
   INSERT INTO event_table VALUES(ora_sysevent,SYSDATE);
END;
/
CREATE OR REPLACE TRIGGER t_startup
BEFORE SHUTDOWN ON DATABASE       --SHUTDOWNֻ����BEFORE
BEGIN
   INSERT INTO event_table VALUES(ora_sysevent,SYSDATE);
END;
/

CREATE OR REPLACE TRIGGER preserve_app_cols
   AFTER ALTER ON SCHEMA
DECLARE
   --��ȡһ�����������е��α�
   CURSOR curs_get_columns (cp_owner VARCHAR2, cp_table VARCHAR2)
   IS
      SELECT column_name
        FROM all_tab_columns
       WHERE owner = cp_owner AND table_name = cp_table;
BEGIN
   -- �����ʹ�õ���ALTER TABLE����޸ı�
   IF ora_dict_obj_type = 'TABLE'
   THEN
      -- ѭ�����е�ÿһ��
      FOR v_column_rec IN curs_get_columns (
                             ora_dict_obj_owner,
                             ora_dict_obj_name
                          )
      LOOP
         --�жϵ�ǰ���������ڱ��޸�
         IF ORA_IS_ALTER_COLUMN (v_column_rec.column_name)
         THEN
            IF v_column_rec.column_name='EMPNO' THEN
               RAISE_APPLICATION_ERROR (
                  -20003,
                  '���ܶ�empno�ֶν����޸�'
               );
            END IF; 
         END IF; 
      END LOOP;
   END IF;
END;

ALTER TABLE scott.emp MODIFY(empno NUMBER(8));

--������־��¼��
CREATE TABLE servererror_log(
   error_time DATE,
   username  VARCHAR2(30),
   instance NUMBER,
   db_name VARCHAR2(50),
   error_stack VARCHAR2(2000)
);
--�������󴥷������ڳ������ݿ����ʱ������
CREATE OR REPLACE TRIGGER t_logerrors
   AFTER SERVERERROR ON DATABASE
BEGIN
   INSERT INTO servererror_log
        VALUES (SYSDATE, login_user, instance_num, database_name,
                DBMS_UTILITY.format_error_stack);
END;



--select privilege from dba_sys_privs where grantee='SCOTT' ;
