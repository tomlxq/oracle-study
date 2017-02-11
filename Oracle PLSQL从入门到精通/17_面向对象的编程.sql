SELECT * FROM scott.emp;
--��������ÿ����������Ժͷ��������̶����ö��ŷֿ��������͹���ǰ�涼Ҫ��member
CREATE OR REPLACE TYPE o_emp AS OBJECT
(
  empno    NUMBER(4),
  ename    VARCHAR2(30),
  job      VARCHAR2(30),
  mgr      NUMBER(4),
  hiredate DATE,
  sal      NUMBER(4),
  comm     NUMBER(4),
  deptno   NUMBER(4),
  MEMBER PROCEDURE change_job(p_empno NUMBER, p_job VARCHAR2),
  MEMBER PROCEDURE change_deptno(p_empno NUMBER, p_deptno NUMBER),
  MEMBER PROCEDURE change_sal(p_empno NUMBER, p_sal NUMBER),
  MEMBER FUNCTION get_job(p_empno NUMBER) RETURN VARCHAR2,
  MEMBER FUNCTION get_deptno(p_empno NUMBER) RETURN NUMBER,
  MEMBER FUNCTION get_sal(p_empno NUMBER) RETURN NUMBER
)
NOT FINAL;

CREATE OR REPLACE TYPE BODY o_emp AS
  MEMBER PROCEDURE change_job(p_empno NUMBER, p_job VARCHAR2) IS
  BEGIN
    UPDATE scott.emp SET job = p_job WHERE empno = p_empno;
  END;
  MEMBER PROCEDURE change_deptno(p_empno NUMBER, p_deptno NUMBER) IS
  BEGIN
    UPDATE scott.emp SET deptno = p_deptno WHERE empno = p_empno;
  END;
  MEMBER PROCEDURE change_sal(p_empno NUMBER, p_sal NUMBER) IS
  BEGIN
    UPDATE scott.emp SET sal = p_sal WHERE empno = p_empno;
  END;
  MEMBER FUNCTION get_job(p_empno NUMBER) RETURN VARCHAR2 IS
    v_job VARCHAR2(20);
  BEGIN
    SELECT job INTO v_job FROM scott.emp WHERE empno = p_empno AND ROWNUM=1;
    RETURN v_job;
  END;
  MEMBER FUNCTION get_deptno(p_empno NUMBER) RETURN NUMBER IS
    v_deptno VARCHAR2(20);
  BEGIN
    SELECT deptno INTO v_deptno FROM scott.emp WHERE empno = p_empno AND ROWNUM=1;
    RETURN v_deptno;
  END;
  MEMBER FUNCTION get_sal(p_empno NUMBER) RETURN NUMBER IS
    v_sal VARCHAR2(20);
  BEGIN
    SELECT sal INTO v_sal FROM scott.emp WHERE empno = p_empno AND ROWNUM=1;
    RETURN v_sal;
  END;
END;


DECLARE
  v_emp o_emp;
BEGIN
  v_emp := o_emp(90, 'tomLuo', 'salesman', 9003, SYSDATE, 8000, NULL, 20);
  dbms_output.put_line('ְԱ����:' || v_emp.get_job(7881));
  dbms_output.put_line('ְԱ����:' || v_emp.get_sal(7881));
  dbms_output.put_line('ְԱ���ű��:' || v_emp.get_deptno(7881));
END;
/
--self
CREATE OR REPLACE TYPE o_emp_sal AS OBJECT
(
  empno  NUMBER(4),
  ename  VARCHAR2(20),
  deptno NUMBER(4),
  sal    NUMBER,
  comm   NUMBER,
  MEMBER PROCEDURE change_deptno,
  MEMBER PROCEDURE change_sal,
  MEMBER PROCEDURE change_comm,
  MEMBER FUNCTION get_deptno RETURN NUMBER,
  MEMBER FUNCTION get_sal RETURN NUMBER,
  MEMBER FUNCTION get_comm RETURN NUMBER
)NOT FINAL;

CREATE OR REPLACE TYPE BODY o_emp_sal AS
  MEMBER PROCEDURE change_deptno IS
  BEGIN
    self.deptno := 20;
  END;
  MEMBER PROCEDURE change_sal IS
  BEGIN
    self.sal := self.sal * 1.1;
  END;
  MEMBER PROCEDURE change_comm IS
  BEGIN
    self.comm := self.comm * 1.1;
  END;
  MEMBER FUNCTION get_deptno RETURN NUMBER IS
  BEGIN
    RETURN self.deptno;
  END;
  MEMBER FUNCTION get_sal RETURN NUMBER IS
  BEGIN
    RETURN self.sal;
  END;
  MEMBER FUNCTION get_comm RETURN NUMBER IS
  BEGIN
    RETURN self.comm;
  END;
END;

DECLARE
  v_emp o_emp_sal;
BEGIN
  v_emp := o_emp_sal(90, 'tomLuo', 30, 8000, 200);
  v_emp.change_sal;
  v_emp.change_deptno;
  v_emp.change_comm;
  dbms_output.put_line('ְԱ���ű��:' || v_emp.get_deptno);
  dbms_output.put_line('ְԱ����:' || v_emp.get_sal);
  dbms_output.put_line('ְԱ����:' || v_emp.get_comm);
END;
/
--static��member
SELECT * FROM emp;
CREATE OR REPLACE TYPE o_emp_m AS OBJECT
(
  empno  NUMBER(4),
  ename  VARCHAR2(20),
  deptno NUMBER(4),
  sal    NUMBER,
  MEMBER PROCEDURE change_sal,
  MEMBER FUNCTION get_sal RETURN NUMBER,
  STATIC PROCEDURE change_sal(p_empno NUMBER, p_sal NUMBER),
  STATIC FUNCTION get_sal(p_empno NUMBER) RETURN NUMBER
)
NOT FINAL;
CREATE OR REPLACE TYPE BODY o_emp_m AS
  MEMBER PROCEDURE change_sal IS
  BEGIN
    self.sal := self.sal * 1.2;
  END;
  MEMBER FUNCTION get_sal RETURN NUMBER IS
  BEGIN
    RETURN self.sal;
  END;
  STATIC PROCEDURE change_sal(p_empno NUMBER, p_sal NUMBER) IS
  BEGIN
    UPDATE scott.emp SET sal = p_sal WHERE empno = p_empno;
  END;
  STATIC FUNCTION get_sal(p_empno NUMBER) RETURN NUMBER IS
    v_sal NUMBER;
  BEGIN
    SELECT sal INTO v_sal FROM scott.emp WHERE empno = p_empno AND ROWNUM=1;
    RETURN v_sal;
  END;
END;

DECLARE
  v_emp o_emp_m;
BEGIN
  v_emp := o_emp_m(90, 'tomLuo',  20,8000);
  v_emp.change_sal;
  dbms_output.put_line('ְԱ����:' || v_emp.get_sal);
  o_emp_m.change_sal(7881,900);
  dbms_output.put_line('ְԱ����:' || o_emp_m.get_sal(7881));
END;
/
--���캯�� 
--�ؼ���Ϊ constructor function ������(...) return self as result,ע��û��member

CREATE OR REPLACE TYPE o_emp_contr AS OBJECT
(
  ename VARCHAR2(30),
  sal   NUMBER(10, 2),
  CONSTRUCTOR FUNCTION o_emp_contr(p_ename VARCHAR2) RETURN SELF AS RESULT
)
INSTANTIABLE FINAL;
/
CREATE OR REPLACE TYPE BODY o_emp_contr AS
  CONSTRUCTOR FUNCTION o_emp_contr(p_ename VARCHAR2) RETURN SELF AS RESULT AS
  BEGIN
    SELF.ename := p_ename;
    SELF.sal   := 9000;
    RETURN;
  END;
END;
/

DECLARE
  v_emp o_emp_contr;
BEGIN
  v_emp := o_emp_contr('tomLuo');
  dbms_output.put_line('ְԱ����:' || v_emp.ename);
  dbms_output.put_line('ְԱ����:' || v_emp.sal);
  v_emp := o_emp_contr('tomLuo',12000);
  dbms_output.put_line('ְԱ����:' || v_emp.ename);
  dbms_output.put_line('ְԱ����:' || v_emp.sal);
END;
/
--���� map member function convert return real 
CREATE OR REPLACE TYPE o_emp_map AS OBJECT(
empno NUMBER,
sal NUMBER,
comm NUMBER,
deptno NUMBER,
MAP MEMBER FUNCTION CONVERT RETURN REAL
) NOT FINAL;
/
CREATE OR REPLACE TYPE BODY o_emp_map AS
  MAP MEMBER FUNCTION CONVERT RETURN REAL IS
  BEGIN
    RETURN sal + comm;
  END;
END;
/
CREATE TABLE emp_map OF o_emp_map;
SELECT * FROM emp_map;
INSERT INTO emp_map VALUES(1,7000,200,20);
INSERT INTO emp_map VALUES(2,5000,100,10);
INSERT INTO emp_map VALUES(3,8000,40,30);
INSERT INTO emp_map VALUES(4,3000,70,50);

SELECT VALUE(r) val,r.sal+r.comm FROM emp_map r ORDER BY 1;

DROP TABLE emp_map;
DROP TABLE emp_order;
--���� order member function xxx(r ����) return integer is 
CREATE OR REPLACE TYPE o_emp_order AS OBJECT
(
  empno  NUMBER,
  sal    NUMBER,
  comm   NUMBER,
  deptno NUMBER,
  ORDER MEMBER FUNCTION match(r o_emp_order) RETURN INTEGER
)
NOT FINAL;
/
CREATE OR REPLACE TYPE BODY o_emp_order AS
  ORDER MEMBER FUNCTION match(r o_emp_order) RETURN INTEGER IS
  BEGIN
    IF (self.sal + self.comm) > (r.sal + r.comm) THEN
      RETURN 1;
    ELSIF (self.sal + self.comm) < (r.sal + r.comm) THEN
      RETURN -1;
    ELSE
      RETURN 0;
    END IF;
  END;
END;
/
DECLARE
  v_emp_order1 o_emp_order := o_emp_order(1, 7000, 200, 20);
  v_emp_order2 o_emp_order := o_emp_order(2, 9000, 100, 10);
BEGIN
  IF v_emp_order1 > v_emp_order2 THEN
    dbms_output.put_line('Ա��1�Ĺ��ʼ���ɴ���Ա��2');
  ELSIF v_emp_order1 < v_emp_order2 THEN
    dbms_output.put_line('Ա��1�Ĺ��ʼ����С��Ա��2');
  ELSE
    dbms_output.put_line('Ա��1�Ĺ��ʼ���ɵ���Ա��2');
  END IF;
END;

--����employee_order���͵Ķ����
CREATE TABLE emp_order OF o_emp_order;
--�������в���Ա��н����Ϣ����
INSERT INTO emp_order VALUES(7123,3000,200,20);
INSERT INTO emp_order VALUES(7124,2000,800,20);
INSERT INTO emp_order VALUES(7125,5000,800,20);
INSERT INTO emp_order VALUES(7129,3000,400,20);
SELECT VALUE(r) val,r.sal+r.comm FROM emp_order r ORDER BY 1 DESC;

--����������Ϊ���̵��β�
CREATE OR REPLACE PROCEDURE change_sal(p_emp_order o_emp_order) IS
BEGIN
  IF p_emp_order IS NOT NULL THEN
    UPDATE scott.emp
       SET sal = p_emp_order.sal,comm= p_emp_order.comm
     WHERE empno = p_emp_order.empno;
  END IF;
END;
--����������Ϊ�����������������
CREATE OR REPLACE FUNCTION get_sal(p_emp_order IN OUT o_emp_order)
  RETURN NUMBER IS
  v_sal NUMBER;
BEGIN
  IF p_emp_order IS NOT NULL THEN
    SELECT (sal + nvl(comm,0)) INTO v_sal FROM scott.emp WHERE empno=p_emp_order.empno AND ROWNUM=1;
    RETURN  v_sal;
  END IF;
END;
SELECT * FROM scott.emp;

DECLARE
  v_emp_order o_emp_order;
BEGIN
  v_emp_order := o_emp_order(7881, 800, 20, 10);
  change_sal(v_emp_order);
  dbms_output.put_line('����Ϊ��'||get_sal(v_emp_order));
END;

DECLARE
   o_emp  o_emp_order;
BEGIN
   o_emp.empno:=7301;   --���󣺸ö���ʵ����û�б���ʼ���ͽ����˸�ֵ
END;

DECLARE
   o_emp   o_emp_order := 
              o_emp_order (NULL, NULL, NULL, NULL); --��ʼ����������
BEGIN
   o_emp.empno := 7301;                                --Ϊ�������͸�ֵ
   o_emp.sal := 5000;
   o_emp.comm := 300;
   o_emp.deptno := 20;
END;


--�����ַ�������͹淶
CREATE OR REPLACE TYPE address_type AS OBJECT
(
  street_addr1 VARCHAR2(25), --�ֵ���ַ1
  street_addr2 VARCHAR2(25), --�ֵ���ַ2
  city         VARCHAR2(30), --����
  state        VARCHAR2(20), --ʡ��
  zip_code     NUMBER, --��������
--��Ա���������ص�ַ�ַ���
  MEMBER FUNCTION toString RETURN VARCHAR2,
--MAP�����ṩ��ַ�ȽϺ���
  MAP MEMBER FUNCTION mapping_function RETURN VARCHAR2
);
/

--�����ַ���������壬ʵ�ֳ�Ա������MAP����
CREATE OR REPLACE TYPE BODY address_type
AS
   MEMBER FUNCTION tostring
      RETURN VARCHAR2                    --����ַ����ת��Ϊ�ַ���ʽ��ʾ
   IS
   BEGIN
      IF (street_addr2 IS NOT NULL)
      THEN
         RETURN    street_addr1
                || CHR (10)
                || street_addr2
                || CHR (10)
                || city
                || ','
                || state
                || ' '
                || zip_code;
      ELSE
         RETURN street_addr1 || CHR (10) || city || ',' || state || ' '
                || zip_code;
      END IF;
   END;
   MAP MEMBER FUNCTION mapping_function    --�����ַ����MAP������ʵ�֣�����VARCHAR2����
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN    TO_CHAR (NVL (zip_code, 0), 'fm00000')
             || LPAD (NVL (city, ''), 30)
             || LPAD (NVL (street_addr1, ''), 25)
             || LPAD (NVL (street_addr2, ''), 25);
   END;
END;
/
DECLARE 
v_addr1 address_type:=address_type('���԰15��1��','������','����','ɽ��',123456);
v_addr2 address_type:=address_type('���԰16��2��','���н�','��ɽ','�㶫',423527);
BEGIN
 dbms_output.put_line(v_addr1.tostring);
 dbms_output.put_line(v_addr2.mapping_function);
 END;
 
 --����һ������淶���ù淶�а���ORDER����
CREATE OR REPLACE TYPE employee_addr AS OBJECT (
   empno    NUMBER (4),
   sal      NUMBER (10, 2),
   comm     NUMBER (10, 2),
   deptno   NUMBER (4),
   addr     address_type,
 MEMBER FUNCTION get_emp_info RETURN VARCHAR2   
)
NOT FINAL; 
--������������壬ʵ��get_emp_info����
CREATE OR REPLACE TYPE BODY employee_addr
AS
   MEMBER FUNCTION get_emp_info
      RETURN VARCHAR2                    --����Ա������ϸ��Ϣ
   IS
   BEGIN
      RETURN 'Ա��'||SELF.empno||'�ĵ�ַΪ��'||SELF.addr.toString;
   END;
END;


DECLARE
   o_address address_type;
   o_emp employee_addr; 
BEGIN
   o_address:=address_type('����һ��','����','����','DG',523343);
   o_emp:=employee_addr(7369,5000,800,20,o_address); 
   DBMS_OUTPUT.put_line('Ա����ϢΪ'||o_emp.get_emp_info);
END;

CREATE OR REPLACE TYPE person_obj AS OBJECT (
   person_name        VARCHAR (20),   --��Ա����
   gender      VARCHAR2 (10),          --��Ա�Ա�
   birthdate   DATE,                  --��������
   address     VARCHAR2 (50),         --��ͥסַ
   MEMBER FUNCTION get_info
      RETURN VARCHAR2                 --����Ա����Ϣ
)
NOT FINAL;                            --��Ա������Ա��̳�
CREATE OR REPLACE TYPE BODY person_obj    --������
AS
   MEMBER FUNCTION get_info
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN '������' || person_name || ',��ͥסַ��' || address;
   END;
END;
--��������ʹ��UNDER����person_obj�м̳�
CREATE OR REPLACE TYPE employee_personobj UNDER person_obj
(
  empno NUMBER(6),
  sal   NUMBER(10, 2),
  job   VARCHAR2(10),
  MEMBER FUNCTION get_emp_info RETURN VARCHAR2,
  OVERRIDING MEMBER FUNCTION get_info RETURN VARCHAR2
);
CREATE OR REPLACE TYPE BODY employee_personobj AS
  MEMBER FUNCTION get_emp_info RETURN VARCHAR2 IS
  BEGIN
    --�ڶ����������п���ֱ�ӷ����ڸ������ж��������
    RETURN 'Ա����ţ�' || SELF.empno || ' Ա�����ƣ�' || SELF.person_name || ' ְλ��' || SELF.job;
  END;
  OVERRIDING MEMBER FUNCTION get_info RETURN VARCHAR2 IS --�������ط���
  BEGIN
    RETURN 'Ա����ţ�' || SELF.empno || ' Ա�����ƣ�' || SELF.person_name || ' ְλ��' || SELF.job;
  END;
END;

DECLARE
   o_emp employee_personobj;         --����Ա���������͵ı���
BEGIN
   --ʹ�ù��캯��ʵ����Ա������
   o_emp:=employee_personobj('��С��','F',
                             TO_DATE('1983-01-01','YYYY-MM-DD'),
                             '����',7981,5000,'Programmer');
   DBMS_OUTPUT.put_line(o_emp.get_info);          --������������Ա��Ϣ
   DBMS_OUTPUT.put_line(o_emp.get_emp_info);      --���Ա�������е�Ա����Ϣ
END;


CREATE TABLE emp_obj_table OF employee_personobj;


INSERT INTO emp_obj_table VALUES('��С��','F',
                             TO_DATE('1983-01-01','YYYY-MM-DD'),
                             '����',7981,5000,'Programmer');
                             
SELECT * FROM emp_obj_table;

CREATE TABLE emp_addr_table OF employee_addr;
INSERT INTO emp_addr_table
     VALUES (7369, 5000, 800, 20,
             address_type ('����һ��', '����', '����', 'DG', 523343));

SELECT * FROM emp_addr_table;

DECLARE
   o_emp employee_personobj;                   --����Ա���������͵ı���
BEGIN
   --ʹ�ù��캯��ʵ����Ա������
   o_emp:=employee_personobj('��С��','F',
                             TO_DATE('1983-01-01','YYYY-MM-DD'),
                             '����',7981,5000,'Programmer');
   INSERT INTO emp_obj_table VALUES(o_emp);    --���뵽�������                            
END; 

SELECT * FROM emp_obj_table;
INSERT INTO emp_obj_table VALUES (employee_personobj('��С��','F',
                             TO_DATE('1983-01-01','YYYY-MM-DD'),
                             '����',7981,5000,'Programmer'));
                             
                             
SELECT person_name,job FROM emp_obj_table;        

 SELECT VALUE(e) from emp_obj_table e;    
 DECLARE
    o_emp employee_personobj;   --����һ���������͵ı���
 BEGIN
    --ʹ��SELECT INTO��佫VALUE�������صĶ���ʵ�����뵽�������͵ı���
    SELECT VALUE(e) INTO o_emp FROM emp_obj_table e WHERE e.person_name='��С��' AND ROWNUM=1;
    --����������͵�����ֵ
    DBMS_OUTPUT.put_line(o_emp.person_name||'��ְλ�ǣ�'||o_emp.job);
 END; 
 
 INSERT INTO emp_obj_table VALUES (employee_personobj('��С��','F',
                             TO_DATE('1983-01-01','YYYY-MM-DD'),
                             '����',7981,5000,'Programmer'));
INSERT INTO emp_obj_table VALUES (employee_personobj('��С��','M',
                             TO_DATE('1983-01-01','YYYY-MM-DD'),
                             '��̩',7981,5000,'running'));   
                             
DECLARE
   o_emp   employee_personobj;     --����������͵ı���
   CURSOR all_emp
   IS
      SELECT VALUE (e) AS emp
        FROM emp_obj_table e;      --����һ���α꣬������ѯ��������
BEGIN
   FOR each_emp IN all_emp         --ʹ���α�FORѭ�������α�����
   LOOP
      o_emp := each_emp.emp;       --��ȡ�α��ѯ�Ķ���ʵ��
      --�������ʵ����Ϣ
      DBMS_OUTPUT.put_line (o_emp.person_name || ' ��ְλ�ǣ�' || o_emp.job);
   END LOOP;
END;
                             

 DECLARE
    o_emp REF employee_personobj;   --����REF���͵ı���
 BEGIN
    --ʹ��REF������ȡ�������͵Ķ���
    SELECT REF(e) INTO o_emp FROM emp_obj_table e WHERE e.person_name='��С��' AND ROWNUM=1;
 END;       
 UPDATE emp_obj_table empobj
   SET empobj.gender = 'M'
 WHERE empobj.person_name = '��С��';
 
 
 UPDATE emp_obj_table empobj
  SET empobj=employee_personobj('��С��','F',
                             TO_DATE('1983-01-01','YYYY-MM-DD'),
                             '��̩',7981,7000,'Testing')
  WHERE person_name='��С��';                            
  
  
  DECLARE
     empref REF employee_personobj;     
  BEGIN
     SELECT REF(empobj) INTO empref FROM emp_obj_table empobj WHERE e.person_name='��С��';
  END;
  
  SELECT REF(e2) FROM emp_obj_table e2;
--�������ϵ��emp��ƥ���еĶ�������
CREATE OR REPLACE TYPE emp_tbl_obj AS OBJECT (
empno    NUMBER (6),
ename    VARCHAR2(10),
job      VARCHAR2(18),
mgr      NUMBER(4),
hiredate DATE,
sal      NUMBER(7,2),
comm     NUMBER(7,2),
deptno   NUMBER(2),
MEMBER FUNCTION get_emp_info
      RETURN VARCHAR2
)
INSTANTIABLE NOT FINAL;
/
--�������������
CREATE OR REPLACE TYPE BODY emp_tbl_obj AS
   MEMBER FUNCTION get_emp_info  RETURN VARCHAR2 IS
   BEGIN
      --�ڶ����������п���ֱ�ӷ����ڸ������ж��������
      RETURN 'Ա����ţ�'||SELF.empno||' Ա�����ƣ�'||SELF.ename||' ְλ��'||SELF.job;
   END; 
END;
/
--����emp_view�����
CREATE VIEW emp_view
   OF emp_tbl_obj
   WITH OBJECT IDENTIFIER (empno)
AS
   SELECT e.empno, e.ename, e.job, e.mgr, e.hiredate, e.sal, e.comm, e.deptno
     FROM emp e;
/


DECLARE
  o_emp emp_tbl_obj;          --����������͵ı���
BEGIN
  --��ѯ��������
  SELECT VALUE(e) INTO o_emp FROM emp_view e WHERE empno=7369;
  --����������͵�����
  DBMS_OUTPUT.put_line('Ա��'||o_emp.ename||' ��н��Ϊ��'||o_emp.sal);
  DBMS_OUTPUT.put_line(o_emp.get_emp_info);  --���ö������͵ĳ�Ա����
END;  

/* Formatted on 2011/11/03 07:07 (Formatter Plus v4.8.8) */

CREATE TYPE address AS OBJECT (     --������ַ����
   street     VARCHAR2 (35),
   city       VARCHAR2 (15),
   state      CHAR (2),
   zip_code   INTEGER
);
CREATE TABLE addresses OF address;  --������ַ�����
CREATE TYPE person AS OBJECT (      --������Ա��������
   person_name     VARCHAR2 (15),
   birthday       DATE,
   home_address   REF address,      --ʹ��REF�ؼ��֣�ָ������Ϊָ����һ�������Ķ���
   phone_number   VARCHAR2 (15)
);
CREATE TABLE persons OF person;     --������Ա�����
--�����ַ
INSERT INTO addresses
     VALUES (address ('����', '����', 'GD', '52334'));
INSERT INTO addresses
     VALUES (address ('�Ƹ�', '����', 'GD', '52300'));
--����һ����Ա��ע�������home_address��������β���һ��ref address�ġ�
INSERT INTO persons
     VALUES (person ('��С��',
                     TO_DATE ('1983-01-01', 'YYYY-MM-DD'),
                     (SELECT REF (a)
                        FROM addresses a
                       WHERE street = '����'),
                     '16899188'
                    ));
--Ҳ����������Ĺ���������һ����Ա��¼

DECLARE
   addref   REF address;
BEGIN
   SELECT REF (a)
     INTO addref
     FROM addresses a
    WHERE street = '����';   --ʹ��SELECT INTO��ѯһ�����ö���
   --ʹ��INSERT�����persons���в������ö���
   INSERT INTO persons
        VALUES (person ('�����',
                        TO_DATE ('1983-01-01', 'yyyy-mm-dd'),
                        addref,
                        '16899188'
                       ));
END;

--��ѯĳ�˵ĵ�ַ��Ϣ
SELECT person_name, DEREF (home_address)
  FROM persons;
  
  
DECLARE
   addr address;
BEGIN
   SELECT DEREF(home_address) INTO addr FROM persons WHERE person_name='��С��';
   addr.street:='��һ';
   UPDATE address SET street=addr.street WHERE zip_code='523330';
END;
