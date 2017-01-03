--create table
CREATE TABLE company_emp(
empNo NUMBER(4) PRIMARY KEY NOT NULL,
empName VARCHAR2(9 BYTE),
job VARCHAR2(10 BYTE),
sal NUMBER(7,2),
comm NUMBER(7,2),
hiredate DATE,
deptNo NUMBER(4),
mgr NUMBER(4)
);
--Ϊ�����ӻ�ɾ���ֶ�
ALTER TABLE company_emp ADD decription VARCHAR2(200) NULL;
ALTER TABLE company_emp DROP COLUMN decription; 
DROP TABLE company_emp;

--Ϊ��ָ��������Ĭ��ֵ���ǿ�Լ��
CREATE TABLE invoice(
invoice_id NUMBER PRIMARY KEY NOT NULL,
vendor_Id NUMBER NOT NULL,
invoice_number NUMBER NOT NULL,
invoice_date DATE DEFAULT SYSDATE,
invoice_total NUMBER NOT NULL,
invoice_Payment NUMBER DEFAULT 0
);

--ΪԼ��ָ������
DROP TABLE invoice;
CREATE TABLE invoice(
invoice_id NUMBER CONSTRAINT pk_invoice_id PRIMARY KEY NOT NULL,
vendor_Id NUMBER CONSTRAINT uk_vendor_id NOT NULL,
invoice_number NUMBER NOT NULL,
invoice_date DATE DEFAULT SYSDATE,
invoice_total NUMBER NOT NULL,
invoice_Payment NUMBER DEFAULT 0
);
--ΪԼ��ָ����������һ��д��
DROP TABLE invoice;
CREATE TABLE invoice(
invoice_id NUMBER  NOT NULL,
vendor_Id NUMBER NOT NULL,
invoice_number NUMBER NOT NULL,
invoice_date DATE DEFAULT SYSDATE,
invoice_total NUMBER NOT NULL,
invoice_Payment NUMBER DEFAULT 0,
CONSTRAINT pk_invoice_id PRIMARY KEY (invoice_id),
CONSTRAINT uk_vendor_id UNIQUE (vendor_Id)
);
--Ϊ��Ӧ��ָ��������Ψһ��
CREATE TABLE vendor(
vendor_id NUMBER,
vendor_name VARCHAR2(30),
CONSTRAINT pk_vendor_id PRIMARY KEY (vendor_id),
CONSTRAINT uk_vendor_name UNIQUE (vendor_name)
);

--ָ�����Լ��
/*
 ON DELETE CASCADE�����������ڶԹ�Ӧ�̱�ɾ��ʱ��������������ļ�¼Ҳ��ɾ��
*/
DROP TABLE invoice;
CREATE TABLE invoice(
invoice_id NUMBER,
vendor_id NUMBER,
invoice_date DATE DEFAULT SYSDATE,
invoice_total NUMBER NOT NULL,
invoice_payment NUMBER DEFAULT 0,
invoice_number NUMBER NOT NULL,
CONSTRAINT pk_invoice_id PRIMARY KEY (invoice_id),
CONSTRAINT uk_invoice_number UNIQUE (invoice_number),
CONSTRAINT fk_vender_id FOREIGN KEY (vendor_id) REFERENCES vendor(vendor_id) ON DELETE CASCADE
);

INSERT INTO vendor VALUES(1,'����');
INSERT INTO vendor VALUES(2,'�������');

INSERT INTO invoice(invoice_id,vendor_id,invoice_total,invoice_number) VALUES(1,1,50000,100000);
INSERT INTO invoice(invoice_id,vendor_id,invoice_total,invoice_number) VALUES(2,2,50000,100001);
DELETE FROM invoice WHERE invoice_id=2;
SELECT * FROM invoice;
SELECT * FROM vendor;
DELETE FROM vendor WHERE vendor_id=1;
DELETE FROM vendor WHERE vendor_id=2;
--Υ��Ψһ��Լ��
INSERT INTO invoice(invoice_id,vendor_id,invoice_total,invoice_number) VALUES(2,2,50000,100001);
--Υ�����Լ��
INSERT INTO invoice(invoice_id,vendor_id,invoice_total,invoice_number) VALUES(3,3,50000,100002);
--��������
CREATE TABLE invoice_bak AS SELECT * FROM invoice;
SELECT * FROM invoice_bak;
DROP TABLE invoice_bak;
CREATE TABLE invoice_bak AS SELECT * FROM invoice WHERE 1<>1;

--������ͼ
CREATE OR REPLACE VIEW view_emp_dept AS
SELECT e.empno,e.ename,e.job,e.sal,e.mgr,d.dname,d.loc FROM scott.emp e,scott.dept d WHERE e.deptno=d.deptno;
SELECT * FROM view_emp_dept;
--������ͼ�������¼
CREATE OR REPLACE VIEW view_emp_20 AS��
SELECT e.empno,e.ename,e.job,e.mgr,e.hiredate,e.sal,e.comm,e.deptno FROM scott.emp e WHERE e.deptno=20;
SELECT * FROM view_emp_20;
DELETE FROM scott.emp WHERE empno>=9000;
INSERT INTO view_emp_20(empno,ename,job,mgr,hiredate,sal,comm,deptno) VALUES(9002,'������','clerk',7566,SYSDATE,8000,NULL,30);
INSERT INTO view_emp_20(empno,ename,job,mgr,hiredate,sal,comm,deptno) VALUES(9003,'������','clerk',7566,SYSDATE,8000,NULL,20);
--������ͼwith read only,���޷������¼
DROP VIEW view_emp_20;
CREATE OR REPLACE VIEW view_emp_20 AS��
SELECT e.empno,e.ename,e.job,e.mgr,e.hiredate,e.sal,e.comm,e.deptno FROM scott.emp e WHERE e.deptno=20 WITH READ ONLY;
--��鴴������ͼ
SELECT object_name,status,object_type FROM user_objects WHERE object_name='VIEW_EMP_20';
--��Դ����ˣ����±༭��ͼ
SELECT * FROM emp;
ALTER TABLE emp MODIFY ename VARCHAR2(30);--�޸���
ALTER TABLE emp ADD grade NUMBER(2);--�����
ALTER TABLE emp DROP COLUMN grade;--ɾ����
ALTER VIEW view_emp_20 COMPILE;--���������仯���±�����ͼ

select * from v$version where rownum<2��
create table diy_os(id number,name varchar2(10));
alter table diy_os add constraint pk0 primary key(id);
select owner,constraint_name,table_name from user_constraints where constraint_name='PK0';
--����ͻ���ס������
show user;
alter user hr account unlock;
alter user hr identified by hr;
conn hr/hr@orcl;

CREATE TABLE temp_emp AS SELECT * FROM emp;
SELECT * FROM temp_emp;
--�����������
CREATE INDEX idx_emp_noname ON temp_emp(ename,empno);
CREATE INDEX idx_emp_job ON temp_emp(job);
--λ������
CREATE BITMAP INDEX idx_emp_job_bitmap ON temp_emp(ename);
--��������
CREATE INDEX idx_emp_name_fun ON temp_emp(UPPER(ename));
--������ѯ
SELECT i.OWNER,i.TABLE_NAME,i.INDEX_NAME,i.UNIQUENESS FROM All_Indexes i WHERE i.TABLE_OWNER='SCOTT' AND i.TABLE_NAME='TEMP_EMP';

--���Լ��
DROP TABLE total_invoice;
CREATE TABLE total_invoice(
invoice_id NUMBER NOT NULL PRIMARY KEY,
invoice_total NUMBER NOT NULL CHECK ( 0<invoice_total AND invoice_total<5000),
payment_total NUMBER DEFAULT 0 CHECK( 0<payment_total AND payment_total<10000)
);

INSERT INTO total_invoice VALUES(1,-1,20000);

DROP TABLE total_invoice;
CREATE TABLE total_invoice(
invoice_id NUMBER NOT NULL PRIMARY KEY,
invoice_total NUMBER(9,2) DEFAULT 0,
payment_total NUMBER(9,2) DEFAULT 0,
CONSTRAINT chk_total CHECK ( 0<invoice_total AND invoice_total<5000),
CONSTRAINT chk_payment_total CHECK ( 0<payment_total AND payment_total<20000)
);

INSERT INTO total_invoice VALUES(1,-1,20000);
--���������ļ��Լ��
DROP TABLE invoice_others;
CREATE TABLE invoice_others(
invoice_id NUMBER NOT NULL PRIMARY KEY,
invoice_name VARCHAR2(30),
invoice_total NUMBER(9,2) DEFAULT 0,
invoice_type NUMBER,
invoice_clerk VARCHAR2(30),
--����ֻ����1��1000֮��
CONSTRAINT chk_id CHECK(invoice_id BETWEEN 1 AND 1000),
--��Ʊ������ֻ��Ϊ��д
CONSTRAINT chk_invoice_name CHECK(invoice_name=UPPER(invoice_name)),
--��Ʊ������ֻ��Ϊ1����֮���ֵ
CONSTRAINT chk_type CHECK(invoice_type IN (1,2,3,4,5,6,7)),
--��Ʊ������ֻ��Ϊ1��5000
CONSTRAINT chk_invoice_total CHECK ( 0<invoice_total AND invoice_total<5000),
--��Ʊ�������߲���Ϊ��
CONSTRAINT chk_invoice_clerk CHECK (invoice_clerk IS NOT NULL)
);
INSERT INTO invoice_others VALUES(1,'TOM_INVOICE',500,1,'wang');
--��ѯ��INVOICE_OTHERS�����е�Լ��
SELECT c.OWNER, c.CONSTRAINT_NAME, c.TABLE_NAME, c.CONSTRAINT_TYPE,c.SEARCH_CONDITION,c.status
  FROM User_Constraints c
 WHERE c.TABLE_NAME = 'INVOICE_OTHERS';
--��ѯԼ��������Ϣ
SELECT * FROM User_Cons_Columns c WHERE c.TABLE_NAME='INVOICE_OTHERS';

SELECT a.status,a.table_name, a.constraint_name, a.search_condition, b.column_name,
       a.constraint_type
  FROM all_constraints a, all_cons_columns b
 WHERE a.table_name = UPPER ('INVOICE_OTHERS')
   AND a.table_name = b.table_name
   AND a.owner = b.owner
   AND a.constraint_name = b.constraint_name;
--�޸ģ����ӣ�ɾ��Լ��   
ALTER TABLE INVOICE_OTHERS DROP CONSTRAINT SYS_C0012028;
ALTER TABLE INVOICE_OTHERS ADD CONSTRAINT chk_name_len CHECK (length(invoice_name)<50);
ALTER TABLE INVOICE_OTHERS DROP CONSTRAINT chk_name_len;  
ALTER TABLE INVOICE_OTHERS MODIFY invoice_name VARCHAR2(100) CHECK (length(invoice_name)<50);

ALTER TABLE INVOICE_OTHERS DROP CONSTRAINT SYS_C0012034;  
ALTER TABLE INVOICE_OTHERS DROP CONSTRAINT CHK_ID;  
ALTER TABLE invoice_others ADD CONSTRAINT pk_id PRIMARY KEY(invoice_id);

--����Ψһ��Լ����DEFERRABLE�ؼ��֣���ǿһ�������õ�Ψһ��Լ��
ALTER TABLE INVOICE_OTHERS ADD CONSTRAINT uk_name UNIQUE (invoice_name) DEFERRABLE DISABLE;
SELECT * FROM INVOICE_OTHERS;
INSERT INTO INVOICE_OTHERS VALUES(2,'TOM-TEST2',700,2,'wang1');
ALTER TABLE invoice_others DROP CONSTRAINT uk_name;
ALTER TABLE invoice_others ADD CONSTRAINT chk_total_1 CHECK (0<invoice_total);
--����Լ��
ALTER TABLE invoice_others DISABLE CONSTRAINT CHK_INVOICE_TOTAL;
ALTER TABLE invoice_others DISABLE CONSTRAINT chk_total_1;
INSERT INTO INVOICE_OTHERS VALUES(4,'TOM-TEST2',-700,2,'wang');
--����Լ���������Ѵ��ڵļ�¼��������֤
ALTER TABLE invoice_others ENABLE NOVALIDATE CONSTRAINT chk_total_1;
--����Լ��ʱ����֤��������,���ܶԴ��н��ú�Լ�������Ľ��в��룬ɾ�����޸�
ALTER TABLE invoice_others DISABLE VALIDATE CONSTRAINT chk_total_1;
DELETE FROM invoice_others WHERE invoice_id=3;
--����һ��Լ�����ǽ�����
ALTER TABLE invoice_others ADD CONSTRAINT chk_total_2 CHECK (1<invoice_total) DISABLE;
ALTER TABLE invoice_others ENABLE novalidate CONSTRAINT chk_total_2;
INSERT INTO INVOICE_OTHERS VALUES(6,'TOM-TEST4',-700,2,'wang');

--�������Լ��
/*
����﷨ alter table [table_name] add constraint [name] foreign key (field) references other_table_name(field)
*/
SELECT * FROM INVOICE_OTHERS;
ALTER TABLE INVOICE_OTHERS ADD vendor_id NUMBER;
SELECT * FROM vendor;
ALTER TABLE INVOICE_OTHERS ADD CONSTRAINT fk_vendor_id FOREIGN KEY (vendor_id) REFERENCES vendor(vendor_id);
INSERT INTO INVOICE_OTHERS VALUES(7,'TOM-TEST5',800,2,'wang',2);
INSERT INTO INVOICE_OTHERS VALUES(7,'TOM-TEST5',800,2,'wang',3);
--���NOT NULLԼ��
ALTER TABLE vendor 
ADD CONSTRAINT vendor_vendor_name_nn CHECK (vendor_name IS NOT NULL);

SELECT a.status,a.table_name, a.constraint_name, a.search_condition, b.column_name,
       a.constraint_type
  FROM all_constraints a, all_cons_columns b
 WHERE a.table_name = UPPER ('VENDOR')
   AND a.table_name = b.table_name
   AND a.owner = b.owner
   AND a.constraint_name = b.constraint_name;
--ɾ��ʱ������ɾ�������������
DROP TABLE  VENDOR CASCADE CONSTRAINT;
SELECT * FROM INVOICE_OTHERS;
   
