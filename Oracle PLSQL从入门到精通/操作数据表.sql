/*�����¼*/
SELECT * FROM emp;
--ָ���в���
INSERT INTO emp
  (empno, ename, job, mgr, hiredate, sal, comm, deptno)
VALUES
  (7890,
   '����',
   '����',
   7566,
   TO_DATE('2001-08-15', 'YYYY-MM-DD'),
   8000,
   300,
   20);
--��ָ���У�������Ҫ����
INSERT INTO emp
VALUES
  (7891,
   '����',
   '����',
   7566,
   TO_DATE('2001-08-15', 'YYYY-MM-DD'),
   8000,
   300,
   20);
--ָ���в��룬����ֵʹ����Ĭ��
INSERT INTO emp (empno, ename, deptno) VALUES (7892, '�Ű�', 20);
SELECT * FROM emp WHERE empno = 7892;
--����ʱ�����'������''����
INSERT INTO emp (empno, ename, deptno) VALUES (7898, 'O''Malley', 20);

SELECT * FROM emp;
--����ʱ������null�����ֵ
INSERT INTO emp VALUES (7893, '����', NULL, NULL, NULL, NULL, NULL, 20);

INSERT INTO emp VALUES (7894, '��ʮ', '', NULL, '', NULL, NULL, 20);

INSERT INTO emp VALUES(7895, USER, NULL, NULL, TRUNC(SYSDATE), 3000, 200, 20);
SELECT * FROM emp WHERE empno = 7895;
--ָ������
DROP TABLE emp_copy;
CREATE TABLE emp_copy AS SELECT * FROM emp WHERE 1=2; 
INSERT INTO emp_copy
  SELECT * FROM emp WHERE deptno = 20;

SELECT * FROM emp;

INSERT INTO emp_copy
  SELECT * FROM emp WHERE deptno = 20;
--��������ѡ����������ƥ�����
INSERT INTO emp_copy
  (empno, ename, job, mgr, deptno)
  SELECT empno, ename, job, mgr, deptno FROM emp WHERE deptno = 30;
--�����������벻ͬ�ı�
SELECT DISTINCT(e.deptno) FROM emp e;
CREATE TABLE emp_10 AS SELECT * FROM emp WHERE 1<>1; 
CREATE TABLE emp_20 AS SELECT * FROM emp WHERE 1<>1; 
CREATE TABLE emp_30 AS SELECT * FROM emp WHERE 1<>1; 
CREATE TABLE emp_other_copy AS SELECT * FROM emp WHERE 1<>1; 

INSERT FIRST 
WHEN deptno = 10 THEN 
  INTO emp_10 
WHEN deptno = 20 THEN 
  INTO emp_20 
WHEN deptno = 30 THEN 
  INTO emp_30 
ELSE 
  INTO emp_other_copy
SELECT * FROM emp;

SELECT * FROM emp_10;  
SELECT * FROM emp_20;  
SELECT * FROM emp_30;  
SELECT * FROM emp_other_copy;   
--ָ������벻ͬ�ı�
TRUNCATE TABLE emp_10 ;
TRUNCATE TABLE emp_20 ;
TRUNCATE TABLE emp_30 ;
TRUNCATE TABLE emp_other_copy ;
INSERT FIRST WHEN deptno = 10 --������ű��Ϊ10
THEN INTO emp_10 --���뵽emp_dept_10��ʹ��VALUESָ���ֶ�
  (empno, ename, sal, deptno)
VALUES
  (empno, ename, sal, deptno) WHEN deptno = 20 --������ű��Ϊ20
THEN INTO emp_20 --���뵽emp_dept_20��ʹ��VALUESָ���ֶ�
  (empno, ename)
VALUES
  (empno, ename) WHEN deptno = 30 --������ű��Ϊ30
THEN INTO emp_30 --���뵽emp_dept_30��ʹ��VALUESָ���ֶ�
  (empno, ename, hiredate)
VALUES
  (empno, ename, hiredate) ELSE --������ű�ż���Ϊ10��20��30
INTO emp_other_copy --���뵽emp_copy��ʹ��VALUESָ���ֶ�
  (empno, ename, deptno)
VALUES
  (empno, ename, deptno)
  SELECT * FROM emp; --ָ�������Ӳ�ѯ
SELECT * FROM emp_10;



SELECT * FROM emp; 
/*���¼�¼*/
UPDATE emp SET sal=3000 WHERE empno=7369;
UPDATE emp SET sal=3000,comm=200,mgr=7566 WHERE empno=7369;
SELECT * FROM emp;
SELECT AVG(y.sal) FROM emp y WHERE y.deptno=20;
--����Ӳ�ѯ����
UPDATE emp x
   SET x.sal =
       (SELECT AVG(y.sal) FROM emp y WHERE y.deptno = x.deptno)
 WHERE x.empno = 7369;
 --����Ӳ�ѯ���¶���ֶ�
 UPDATE emp x
    SET (x.sal, x.comm) =
        (SELECT AVG(y.sal), MAX(y.comm) FROM emp y WHERE y.deptno = x.deptno)
  WHERE x.empno = 7369;
  
SELECT * FROM emp_history;
DROP TABLE emp_history;
CREATE TABLE emp_history AS
  SELECT * FROM emp;
UPDATE emp_history x
   SET (x.sal, x.comm) =
       (SELECT sal, comm FROM emp y WHERE y.empno = x.empno)
 WHERE x.empno = 7369;
SELECT * FROM emp_history;
--������Ӳ�ѯ����
UPDATE emp
   SET sal =
       (SELECT sal FROM emp WHERE empno = 7782)
 WHERE empno = 7369;
 
SELECT * FROM emp;

UPDATE (SELECT x.sal  sal,
               y.sal  sal_history,
               x.comm comm,
               y.comm comm_history
          FROM emp x, emp_history y
         WHERE x.empno = y.empno AND x.empno = 7369)
   SET sal_history = sal, comm_history = comm;
/*
��ʹ��implict update table ʱ����������һ����һ��Ҫ��ΨһԼ��������ᱨ��
����Oracle����ʹ��hints��\/*+ BYPASS_UJVC*\/ 
���ε���Ψһ�Եļ�顣
*/
UPDATE /*+bypass_ujvc*/ (SELECT x.sal  sal,
             y.sal  sal_history,
             x.comm comm,
             y.comm comm_history
        FROM emp x, emp_history y
       WHERE x.empno = y.empno AND x.empno = 7369)
   SET sal_history = sal, comm_history = comm;
   
   
DELETE FROM emp WHERE empno=7894 ;                  
INSERT INTO emp
VALUES(7894,'��ʮ','',DEFAULT,'',NULL,NULL,20);
SELECT * FROM emp_copy;
SELECT * FROM emp;
--merge���²����   
MERGE INTO emp_copy c --Ŀ���
USING emp e --Դ�������Ǳ���ͼ���Ӳ�ѯ
ON (c.empno = e.empno)
WHEN MATCHED THEN --��ƥ��ʱ������UPDATE����
  UPDATE
     SET c.ename    = e.ename,
         c.job      = e.job,
         c.mgr      = e.mgr,
         c.hiredate = e.hiredate,
         c.sal      = e.sal,
         c.comm     = e.comm,
         c.deptno   = e.deptno
WHEN NOT MATCHED THEN --����ƥ��ʱ������INSERT����
  INSERT
  VALUES
    (e.empno, e.ename, e.job, e.mgr, e.hiredate, e.sal, e.comm, e.deptno);

/*ɾ����¼*/
--����ɾ��
DELETE FROM emp WHERE empno = 7903;

DELETE FROM dept WHERE deptno = 20;

SELECT * FROM dept;
--������Ӳ�ѯɾ��
DELETE FROM emp
 WHERE deptno = (SELECT deptno FROM dept WHERE dname = '���۲�');

DELETE FROM emp_copy;
--����Ӳ�ѯɾ��
DELETE FROM emp x
 WHERE EXISTS (SELECT 1 FROM emp_copy WHERE empno = x.empno);
DELETE FROM emp x
 WHERE empno IN (SELECT empno FROM emp_copy WHERE empno = x.empno);
--�����ļ�¼�����ܻع�����
TRUNCATE TABLE dept;

ALTER TABLE dept ENABLE CONSTRAINT pk_dept;

ALTER TABLE emp DISABLE CONSTRAINT PK_EMP;

CREATE TABLE dept_copy AS
  SELECT * FROM dept;

TRUNCATE TABLE dept;

INSERT INTO dept
  SELECT * FROM dept_copy;
/*�ύ�ͻع���¼*/
/*ʹ������*/
--������ɾ������
DROP SEQUENCE invoice_seq;
CREATE SEQUENCE invoice_seq
INCREMENT BY 1
START WITH 1
MAXVALUE 99999
NOCYCLE NOCACHE;
--��user_objects��user_sequences��������
SELECT o.OBJECT_NAME, o.OBJECT_TYPE, o.OBJECT_ID
  FROM user_objects o
 WHERE o.OBJECT_NAME = 'INVOICE_SEQ';
 
SELECT sequence_name, min_value, max_value, increment_by, last_number
  FROM user_sequences;

SELECT invoice_seq.CURRVAL, invoice_seq.NEXTVAL FROM DUAL;

SELECT invoice_seq.CURRVAL FROM DUAL;

SELECT invoice_seq.CURRVAL, invoice_seq.NEXTVAL FROM DUAL;
--ʹ������
DROP TABLE invoice;
CREATE TABLE invoice
(
   invoice_id NUMBER PRIMARY KEY,                     --�Զ���ţ�Ψһ����Ϊ��
   vendor_id NUMBER NOT NULL,                                       --��Ӧ��ID
   invoice_number VARCHAR2(50)  NOT NULL,                           --��Ʊ���
   invoice_date DATE DEFAULT SYSDATE,                               --��Ʊ����
   invoice_total  NUMBER(9,2) NOT NULL,                             --��Ʊ����
   payment_total NUMBER(9,2)   DEFAULT 0                            --��������
);

INSERT INTO invoice
  (invoice_id, vendor_id, invoice_number, invoice_total)
VALUES
  (invoice_seq.NEXTVAL, 10, 'INV' || invoice_seq.CURRVAL, 100);

SELECT invoice_id, vendor_id, invoice_number, invoice_total FROM invoice;
  
--�޸����� 
ALTER SEQUENCE invoice_seq
INCREMENT BY 2;
ALTER SEQUENCE invoice_seq
              INCREMENT BY 2
              MAXVALUE 10
              NOCACHE
              NOCYCLE;                       

/*ͬ���*/
SELECT * FROM SCOTT.EMP;
SELECT * FROM emp;
CREATE PUBLIC SYNONYM tempemp FOR scott.emp;
SELECT * FROM tempemp;
DROP PUBLIC SYNONYM tempemp;

SELECT userenv('LANG') FROM DUAL;
