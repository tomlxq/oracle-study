SELECT * FROM emp;
DROP TABLE emp_copy;
CREATE TABLE emp_copy AS SELECT * FROM emp WHERE 1<>1;
--ʹ�ñ���������һ����¼
DECLARE
  v_empno    emp.empno%TYPE;
  v_ename    emp.ename%TYPE;
  v_job      emp.job%TYPE;
  v_mgr      emp.mgr%TYPE;
  v_hiredate emp.hiredate%TYPE;
  v_sal      emp.sal%TYPE;
  v_comm     emp.comm%TYPE;
  v_deptno   emp.deptno%TYPE;
BEGIN
  SELECT *
    INTO v_empno,
         v_ename,
         v_job,
         v_mgr,
         v_hiredate,
         v_sal,
         v_comm,
         v_deptno
    FROM emp e
   WHERE e.empno = 7891;
  dbms_output.put_line('�û�����' || v_ename);
  INSERT INTO emp_copy
  VALUES
    (v_empno, v_ename, v_job, v_mgr, v_hiredate, v_sal, v_comm, v_deptno);
    EXCEPTION 
      WHEN OTHERS THEN
      NULL;
END;
SELECT * FROM emp_copy;
--ʹ�ü�¼����������һ����¼
DECLARE
  TYPE t_emp IS RECORD(
    empno    emp.empno%TYPE,
    ename    emp.ename%TYPE,
    job      emp.job%TYPE,
    mgr      emp.mgr%TYPE,
    hiredate emp.hiredate%TYPE,
    sal      emp.sal%TYPE,
    comm     emp.comm%TYPE,
    deptno   emp.deptno%TYPE);
  v_emp_info t_emp;
BEGIN
  SELECT * INTO v_emp_info FROM emp e WHERE e.empno = 7891;
  dbms_output.put_line('�û�����' || v_emp_info.ename);
  INSERT INTO emp_copy VALUES v_emp_info;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;

--��¼�����͵ĳ�ʼֵ����ֵ
DECLARE
  TYPE t_emp IS RECORD(
    empno   NUMBER := 7902,
    ename    VARCHAR2(30),
    sal      NUMBER NOT NULL DEFAULT 0,
    hiredate DATE DEFAULT SYSDATE);
  v_emp t_emp;
BEGIN
  v_emp.empno   := 7788;
  v_emp.ename    := '��Сǿ';
  v_emp.sal      := 16000;
  v_emp.hiredate := to_date('2016-05-24', 'yyyy-mm-dd');
  --�����������empinfo��¼��ֵ
  DBMS_OUTPUT.PUT_LINE('Ա�����ƣ�' || v_emp.ename);
  DBMS_OUTPUT.PUT_LINE('Ա����ţ�' || v_emp.empno);
  DBMS_OUTPUT.PUT_LINE('��Ӷ���ڣ�' || TO_CHAR(v_emp.hiredate, 'YYYY-MM-DD'));
  DBMS_OUTPUT.PUT_LINE('Ա��н�ʣ�' || v_emp.sal);
END;

--��¼���͵�ֱ�Ӹ�ֵ�Լ������е����Ը�ֵ
DECLARE
   --�����¼����
   TYPE emp_rec IS RECORD (
      empno   NUMBER,
      ename   VARCHAR2 (20)
   );
   --������emp_rec������ͬ��Ա�ļ�¼����
   TYPE emp_rec_dept IS RECORD (
      empno   NUMBER,
      ename   VARCHAR2 (20)
   );
   --������¼���͵ı���
   emp_info1   emp_rec;
   emp_info2   emp_rec;
   emp_info3   emp_rec_dept;
   --����һ����Ƕ�������������¼��Ϣ
   PROCEDURE printrec (empinfo emp_rec)
   AS
   BEGIN
      DBMS_OUTPUT.put_line ('Ա����ţ�' || empinfo.empno);
      DBMS_OUTPUT.put_line ('Ա�����ƣ�' || empinfo.ename);
   END;
BEGIN
   emp_info1.empno := 7890;    --Ϊemp_info1��¼��ֵ
   emp_info1.ename := '�Ŵ�ǧ';
   DBMS_OUTPUT.put_line ('emp_info1����Ϣ���£�');
   printrec (emp_info1);      --��ӡ��ֵ���emp_info1��¼
   emp_info2 := emp_info1;    --��emp_info1��¼����ֱ�Ӹ���emp_info2
   DBMS_OUTPUT.put_line ('emp_info2����Ϣ���£�');
   printrec (emp_info2);      --��ӡ��ֵ���emp_info2�ļ�¼
   --emp_info3:=emp_info1;    --�������ִ��󣬲�ͬ��¼���͵ı��������໥��ֵ
END;

SELECT * FROM dept;
DECLARE
  TYPE t_detp IS RECORD(
    deptno NUMBER,
    dname  VARCHAR2(30),
    loc    VARCHAR2(100));
  v_dept1 t_detp;
  v_dept2 dept%ROWTYPE;
BEGIN
  SELECT * INTO v_dept2 FROM dept WHERE deptno = 10;
  v_dept1 := v_dept2;
  dbms_output.put_line(v_dept1.dname);
  SELECT * INTO v_dept1 FROM dept WHERE deptno = 10;
  dbms_output.put_line(v_dept1.dname);
END;
--��¼���Ͳ������ݿ�
DELETE FROM dept WHERE deptno IN (60,70);
DECLARE
  TYPE t_detp IS RECORD(
    deptno NUMBER,
    dname  VARCHAR2(30),
    loc    VARCHAR2(100));
  v_dept1 t_detp;
  v_dept2 dept%ROWTYPE;
BEGIN
  v_dept1.deptno := 60;
  v_dept1.dname  := '�ʼ첿';
  v_dept1.loc    := '�Ϻ��ֶ�';
  v_dept2.deptno := 70;
  v_dept2.dname  := '����';
  v_dept2.loc    := '�㶫��ɽ';
  INSERT INTO dept VALUES v_dept1;
  INSERT INTO dept VALUES v_dept2;
  --��¼����ɾ��
  DELETE FROM dept WHERE deptno= v_dept1.deptno;
  --��¼���͸���
  v_dept2.dname:='��Ʒ��';
  UPDATE dept SET ROW=v_dept2 WHERE deptno= v_dept2.deptno;
END;

--��¼���ͷ�����Ӱ����е���¼
SELECT * FROM dept;
DELETE FROM dept WHERE deptno=80;
DECLARE
  TYPE t_detp IS RECORD(
    deptno NUMBER,
    dname  VARCHAR2(30),
    loc    VARCHAR2(100));
  v_dept1 t_detp;
  v_dept2 dept%ROWTYPE;
BEGIN
  SELECT * INTO v_dept1 FROM dept WHERE deptno = 70;
  v_dept1.dname := '�ۺ����';
  UPDATE dept
     SET ROW = v_dept1
   WHERE deptno = v_dept1.deptno
  RETURNING deptno, dname, loc INTO v_dept2;
  dbms_output.put_line('���µĲ���Ϊ: ' || v_dept2.dname);

  v_dept1.deptno := 80;
  v_dept1.dname  := 'ά�޲�';
  INSERT INTO dept
  VALUES v_dept1
  RETURNING deptno, dname, loc INTO v_dept2;
  dbms_output.put_line('�����Ĳ���Ϊ: ' || v_dept2.dname);

  DELETE FROM dept
   WHERE deptno = v_dept1.deptno
  RETURNING deptno, dname, loc INTO v_dept2;
  dbms_output.put_line('ɾ���Ĳ���Ϊ: ' || v_dept2.dname);
END;

--��¼����Ƕ��
SELECT * FROM dept;
SELECT * FROM emp WHERE empno=7891;
DECLARE
  TYPE t_dept IS RECORD(
    deptno NUMBER,
    dname  VARCHAR2(30),
    loc    VARCHAR2(100));

  TYPE t_emp IS RECORD(
    empno    NUMBER,
    ename    VARCHAR2(30),
    job      VARCHAR2(30),
    mgr      NUMBER,
    hiredate DATE,
    sal      NUMBER,
    comm     NUMBER,
    deptinfo t_dept);
  v_dept t_dept;
  v_emp  t_emp;
BEGIN
  SELECT *
    INTO v_dept
    FROM dept
   WHERE deptno = (SELECT deptno FROM emp WHERE empno = 7891);
  v_emp.deptinfo := v_dept;
  SELECT e.empno, e.ename, e.job, e.mgr, e.hiredate, e.sal, e.comm
    INTO v_emp.empno,
         v_emp.ename,
         v_emp.job,
         v_emp.mgr,
         v_emp.hiredate,
         v_emp.sal,
         v_emp.comm
    FROM emp e
   WHERE e.empno = 7891;
  dbms_output.put_line('����Ϊ: ' || v_emp.deptinfo.dname || CHR(10) ||
                       '����Ϊ: ' || v_emp.ename);
END;

--��������
SELECT * FROM dept;
SELECT * FROM emp;
--��Ӷ������������
TYPE hiredate_idxt IS TABLE OF DATE INDEX BY PLS_INTEGER;
--���ű�ŵ���������
TYPE deptno_idxt IS TABLE OF dept.deptno%TYPE NOT NULL INDEX BY PLS_INTEGER;
--��¼���͵�������pl/sql��������ṹ����һ�����صĸ���
TYPE emp_idxt IS TABLE OF emp%ROWTYPE INDEX BY NATURAL;
--�ɲ������Ʊ�ʶ�Ĳ������Ƽ���
TYPE dname_idxt IS TABLE OF dept%ROWTYPE INDEX BY dept.dname%TYPE;
--���弯�ϵļ���
TYPE dname_idxt1 IS TABLE OF dname_idxt INDEX BY VARCHAR2(100);

--�������͸�ֵ
DECLARE
  TYPE test_idxt IS TABLE OF VARCHAR2(12) INDEX BY PLS_INTEGER;
  TYPE test_idxt1 IS TABLE OF NUMBER INDEX BY VARCHAR2(20);
  v_test  test_idxt;
  v_test1 test_idxt1;
BEGIN
  v_test(1) := 'ʷ̫��';
  v_test(40) := '����';
  v_test(80) := '����';
  v_test(-50) := '��׿';
  v_test(70) := '����';
  IF v_test.exists(-50) THEN
    dbms_output.put_line('����Ϊ: ' || v_test(-50));
  END IF;

  v_test1('ʷ̫��') := 1;
  v_test1('����') := 40;
  v_test1('����') := 80;
  v_test1('��׿') := -50;
  v_test1('����') := 70;
  IF v_test1.exists('����') THEN
    dbms_output.put_line('ѧ��Ϊ: ' || v_test1('����'));
  END IF;
END;

--��¼���͵���������dnameΪ����������
--forѭ�����ô򿪹ر��α�
DECLARE
  TYPE dept_idxt IS TABLE OF dept%ROWTYPE INDEX BY dept.dname%TYPE;
  v_dept dept_idxt;
  CURSOR dept_cur IS
    SELECT * FROM dept;
BEGIN
  FOR i IN dept_cur LOOP
    v_dept(i.dname) := i;
    dbms_output.put_line('����Ϊ: ' || v_dept(i.dname).dname);
  END LOOP;
END;

--Ƕ�ױ�
DECLARE
  TYPE dept_t IS TABLE OF dept%ROWTYPE;
  TYPE dname_t IS TABLE OF dept.dname%TYPE;
  TYPE deptno_t IS TABLE OF dept.deptno%TYPE;
  dname_info  dname_t := dname_t('����', '����');
  deptno_info deptno_t := deptno_t('78', '90');
BEGIN
  NULL;
END;

DECLARE
  TYPE deptno_t IS TABLE OF NUMBER;
  TYPE ename_t IS TABLE OF VARCHAR2(20);
  v_deptno deptno_t;
  v_ename  ename_t := ename_t('������', '���Բ�');
BEGIN
  dbms_output.put_line('����Ϊ' || v_ename(1));
  dbms_output.put_line('����Ϊ' || v_ename(2));
  --v_deptno.extend(5);
  v_deptno := deptno_t(NULL, NULL, NULL, NULL, NULL);
  FOR i IN 1 .. 5 LOOP
    v_deptno(i) := i * 10;
    dbms_output.put_line('���ű��Ϊ' || v_deptno(i));
  END LOOP;
  dbms_output.put_line('���Ÿ���Ϊ' || v_deptno.count);
END;

--Ƕ�ױ�����
CREATE TYPE dname_list_t IS TABLE OF VARCHAR(30);
/

CREATE TABLE emp_info(
empno NUMBER,
ename VARCHAR2(30),
dnamelist dname_list_t
) NESTED TABLE dnamelist STORE AS emp_info_table;
/
--Ƕ�ױ�Ĳ��������
DECLARE
  v_dname_list dname_list_t := dname_list_t('ѧͽ', 'ר��', '��ʦ');
BEGIN
  INSERT INTO emp_info VALUES (1, '��Сǿ', v_dname_list);
  INSERT INTO emp_info
  VALUES
    (2, '����', dname_list_t('����', '��������', '�Ĵ�����'));
  SELECT dnamelist INTO v_dname_list FROM emp_info WHERE empno = 1;
  v_dname_list(1) := '��ʦ��';
  v_dname_list(2) := '��ʦ��';
  v_dname_list(3) := '��ʦ��';
  UPDATE emp_info SET dnamelist = v_dname_list WHERE empno = 1;
  SELECT dnamelist INTO v_dname_list FROM emp_info WHERE empno = 1;
  dbms_output.put_line('���µĲ���' || v_dname_list(1));
END;
SELECT * FROM emp_info;


--�䳤����
DECLARE
   TYPE projectlist IS VARRAY (50) OF VARCHAR2 (16);        --������Ŀ�б�䳤����
   TYPE empno_type IS VARRAY (10) OF NUMBER (4);            --����Ա����ű䳤����
   --�����䳤�������͵ı�������ʹ�ù��캯�����г�ʼ��
   project_list   projectlist := projectlist ('��վ', 'ERP', 'CRM', 'CMS');
   empno_list     empno_type;                               --�����䳤�������͵ı���
BEGIN
   DBMS_OUTPUT.put_line (project_list (3));              --�����3��Ԫ�ص�ֵ
   project_list.EXTEND;                                     --��չ����5��Ԫ��
   project_list (5) := 'WORKFLOW';                          --Ϊ��5��Ԫ�ظ�ֵ
   empno_list :=                                            --����empno_list
      empno_type (7011, 7012, 7013, 7014, NULL, NULL, NULL, NULL, NULL, NULL);
   empno_list (9) := 8011;                                  --Ϊ��9��Ԫ�ظ���ֵ
   DBMS_OUTPUT.put_line (empno_list (9));                --�����9��Ԫ�ص�ֵ
END;

--����һ���䳤���������empname_varray_type�������洢Ա����Ϣ
CREATE OR REPLACE TYPE empname_varray_type IS VARRAY (20) OF VARCHAR2 (20);
/
CREATE TABLE dept_varray                  --�����������ݱ�
(
   deptno NUMBER(2),                      --���ű��    
   dname VARCHAR2(20),                    --��������
   emplist empname_varray_type            --����Ա���б�
);
DECLARE                                         --��������ʼ���䳤����
   emp_list   empname_varray_type                          
                := empname_varray_type ('ʷ��˹', '�ܿ�', '��ķ', '��ɳ', '��', 'ʷ̫��');
BEGIN
   INSERT INTO dept_varray
        VALUES (20, 'ά����', emp_list);        --����в���䳤��������
   INSERT INTO dept_varray                      --ֱ����INSERT����г�ʼ���䳤��������
        VALUES (30, '���ӹ�',
                empname_varray_type ('����', '����', '����', '����', '����', '����'));
   SELECT emplist
     INTO emp_list
     FROM dept_varray
    WHERE deptno = 20;                          --ʹ��SELECT���ӱ���ȡ���䳤��������
   emp_list (1) := '�ܿ���';                    --���±䳤�������ݵ�����
   UPDATE dept_varray
      SET emplist = emp_list
    WHERE deptno = 20;                          --ʹ��UPDATE�����±䳤��������
   DELETE FROM dept_varray
         WHERE deptno = 30;                     --ɾ����¼��ͬʱɾ���䳤��������
END;
SELECT * FROM dept_varray;

--�жϱ䳤����治����
DECLARE
   TYPE projectlist IS VARRAY (50) OF VARCHAR2 (16);   --������Ŀ�б�䳤����
   project_list   projectlist := projectlist ('��վ', 'ERP', 'CRM', 'CMS');
BEGIN
   IF project_list.EXISTS (5)                          --�ж�һ�������ڵ�Ԫ��ֵ
   THEN                                                --������ڣ������Ԫ��ֵ
      DBMS_OUTPUT.put_line ('Ԫ�ش��ڣ���ֵΪ��' || project_list (5));
   ELSE
      DBMS_OUTPUT.put_line ('Ԫ�ز�����');          --��������ڣ���ʾԪ�ز�����    
   END IF;
END;
--�䳤���ݸ�����Ϊ��Ч����
DECLARE
   TYPE emp_name_table IS TABLE OF VARCHAR2 (20);            --Ա������Ƕ�ױ�
   TYPE deptno_table IS TABLE OF NUMBER (2);                 --���ű��Ƕ�ױ�
   deptno_info     deptno_table;
   emp_name_info   emp_name_table := emp_name_table ('��С��', '��˹��');
BEGIN
   deptno_info:=deptno_table();                              --����һ���������κ�Ԫ�ص�Ƕ�ױ�
   deptno_info.EXTEND(5);                                    --��չ5��Ԫ��
   DBMS_OUTPUT.PUT_LINE('deptno_info��Ԫ�ظ���Ϊ��'||deptno_info.COUNT);
   DBMS_OUTPUT.PUT_LINE('emp_name_info��Ԫ�ظ���Ϊ��'||emp_name_info.COUNT);   
END;
--�䳤���������ֵ�����
DECLARE
   TYPE projectlist IS VARRAY (50) OF VARCHAR2 (16);   --������Ŀ�б�䳤����
   project_list   projectlist := projectlist ('��վ', 'ERP', 'CRM', 'CMS');
BEGIN
   DBMS_OUTPUT.put_line ('�䳤���������ֵΪ��' || project_list.LIMIT);
   project_list.EXTEND(8);
   DBMS_OUTPUT.put_line ('�䳤����ĵ�ǰ����Ϊ��' || project_list.COUNT);   
END;

--�䳤����ĵ�1��Ԫ�ص��±ꡢ���1��Ԫ�ص��±�
DECLARE
  TYPE projectlist IS VARRAY(50) OF VARCHAR2(16); --������Ŀ�б�䳤����
  project_list projectlist := projectlist('��վ', 'ERP', 'CRM', 'CMS');
BEGIN
  DBMS_OUTPUT.put_line('project_list�ĵ�1��Ԫ���±꣺' || project_list.FIRST); --�鿴��1��Ԫ�ص��±�
  project_list.EXTEND(8); --��չ8��Ԫ��
  DBMS_OUTPUT.put_line('project_list�����һ��Ԫ�ص��±꣺' || project_list.LAST); --�鿴���1��Ԫ�ص��±�
END;
--���������ú���next��prior
DECLARE
  TYPE idx_table IS TABLE OF VARCHAR(12) INDEX BY PLS_INTEGER; --��������������
  v_emp idx_table; --�������������
  i     PLS_INTEGER; --����ѭ�����Ʊ���
BEGIN
  v_emp(1) := 'ʷ��˹'; --�����Ϊ������ֵ
  v_emp(20) := '������';
  v_emp(40) := 'ʷ���';
  v_emp(-10) := '����';
  --��ȡ�����е�-10��Ԫ�ص���һ��ֵ
  DBMS_OUTPUT.put_line('��-10��Ԫ�ص���һ��ֵ��' || v_emp(v_emp.NEXT(-10)));
  --��ȡ�����е�40��Ԫ�ص���һ��ֵ
  DBMS_OUTPUT.put_line('��40��Ԫ�ص���һ��ֵ��' || v_emp(v_emp.PRIOR(40)));
  i := v_emp.FIRST; --��λ����1��Ԫ�ص��±�
  WHILE i IS NOT NULL --��ʼѭ��ֱ���±�ΪNULL
   LOOP
    --���Ԫ�ص�ֵ
    DBMS_OUTPUT.put_line('v_emp(' || i || ')=' || v_emp(i));
    i := v_emp.NEXT(i); --�����ƶ�ѭ��ָ�룬ָ����һ���±�
  END LOOP;
END;
--Ƕ�ױ����ú���DELETE\EXTEND\NEXT ��ȡ��һ���±�FIRST
DECLARE
  TYPE courselist IS TABLE OF VARCHAR2(10); --����Ƕ�ױ�
  --����γ�Ƕ�ױ����
  courses courselist;
  i       PLS_INTEGER;
BEGIN
  courses := courselist('����', '����', '��ѧ'); --��ʼ��Ԫ��
  courses.DELETE(3); --ɾ����3��Ԫ��
  courses.EXTEND; --׷��һ���µ�NULLԪ��
  courses(4) := 'Ӣ��';
  courses.EXTEND(5, 1); --�ѵ�1��Ԫ�ؿ���5����ӵ�ĩβ  
  i := courses.FIRST;
  WHILE i IS NOT NULL LOOP
    --ѭ����ʾ���ֵ
    DBMS_OUTPUT.PUT_LINE('courses(' || i || ')=' || courses(i));
    i := courses.NEXT(i);
  END LOOP;
END;

DECLARE
   TYPE courselist IS TABLE OF VARCHAR2 (10);                --����Ƕ�ױ�
   --����γ�Ƕ�ױ����
   courses   courselist;
   i PLS_INTEGER;
BEGIN
   courses := courselist ('����', '����', '��ѧ','����','��ѧ','����');--��ʼ��Ԫ��
   courses.TRIM(2);                                             --ɾ������ĩβ��2��Ԫ��
   DBMS_OUTPUT.PUT_LINE('��ǰ��Ԫ�ظ�����'||courses.COUNT);  --��ʾԪ�ظ���
   courses.EXTEND;                                             --��չ1��Ԫ��   
   courses(courses.COUNT):='����';                             --Ϊ���1��Ԫ�ظ�ֵ
   courses.TRIM;                                               --ɾ������ĩβ�����1��Ԫ�� 
   i:=courses.FIRST; 
   WHILE i IS NOT NULL LOOP                                  --ѭ����ʾ���ֵ
      DBMS_OUTPUT.PUT_LINE('courses('||i||')='||courses(i));
      i:=courses.NEXT(i);
   END LOOP;
END;

DECLARE
   TYPE courselist IS TABLE OF VARCHAR2 (10);                --����Ƕ�ױ�
   --����γ�Ƕ�ױ����
   courses   courselist;
   i PLS_INTEGER;
BEGIN
   courses := courselist ('����', '����', '��ѧ','����','��ѧ','����');--��ʼ��Ԫ��
   courses.DELETE(2);                                             --ɾ����2��Ԫ��
   DBMS_OUTPUT.PUT_LINE('��ǰ��Ԫ�ظ�����'||courses.COUNT);    --��ʾԪ�ظ���
   courses.EXTEND;                                                --��չ1��Ԫ��  
   DBMS_OUTPUT.PUT_LINE('��ǰ��Ԫ�ظ�����'||courses.COUNT);    --��ʾԪ�ظ���    
   courses(courses.LAST):='����';                                 --Ϊ���1��Ԫ�ظ�ֵ
   courses.DELETE(4,courses.COUNT);                               --ɾ������ĩβ�����1��Ԫ�� 
   i:=courses.FIRST; 
   WHILE i IS NOT NULL LOOP                                        --ѭ����ʾ���ֵ
      DBMS_OUTPUT.PUT_LINE('courses('||i||')='||courses(i));
      i:=courses.NEXT(i);
   END LOOP;
END;

DECLARE
   TYPE numlist IS TABLE OF NUMBER;
   nums numlist;          --һ���յ�Ƕ�ױ�
BEGIN
   nums(1):=1;        --δ�����ʹ�ñ�Ԫ�أ���������ORA-06531:����δ��ʼ�����ռ�
   nums:=numlist(1,2);--��ʼ��Ƕ�ױ�
   nums(NULL):=3;     --ʹ��NULL����������������ORA-06502:PL/SQL:���ֻ�ֵ����:NULL�������ֵ
   nums(0):=3;        --���ʲ����ڵ��±꣬��������ORA-06532:�±곬������
   nums(3):=3;        --�±곬�����Ԫ�ظ�������������ORA-06532:�±곬������
   nums.DELETE(1);    --ɾ����1��Ԫ��
   IF nums(1)=1 THEN
      NULL;
       --��Ϊ��1��Ԫ���ѱ�ɾ�����ٷ��ʽ�������ORA-01403: δ�ҵ��κ�����
   END IF;
END;

DECLARE
  TYPE dept_type IS VARRAY(20) OF NUMBER; --����Ƕ�ױ����  
  depts dept_type := dept_type(10, 30, 70); --ʵ����Ƕ�ױ�����3��Ԫ��
BEGIN
  FOR i IN depts.FIRST .. depts.LAST --ѭ��Ƕ�ױ�Ԫ�� 
   LOOP
    DELETE FROM emp WHERE deptno = depts(i); --��SQL���淢��SQL����ִ��SQL����
  END LOOP;
END;

DECLARE
  TYPE dept_type IS VARRAY(20) OF NUMBER; --����Ƕ�ױ����
  depts dept_type := dept_type(10, 30, 70); --ʵ����Ƕ�ױ�����3��Ԫ��   
BEGIN
  FORALL i IN depts.FIRST .. depts.LAST --ѭ��Ƕ�ױ�Ԫ��
    DELETE FROM emp WHERE deptno = depts(i); --��SQL���淢��SQL����ִ��SQL����
  FOR i IN 1 .. depts.COUNT LOOP
    DBMS_OUTPUT.put_line('���ű��' || depts(i) || '��ɾ��������Ӱ�����Ϊ��' ||
                         SQL%BULK_ROWCOUNT(i));
  END LOOP;
END;
--select .. bulk collect into .. from table
DECLARE
   TYPE numtab IS TABLE OF emp.empno%TYPE;     --Ա�����Ƕ�ױ�
   TYPE nametab IS TABLE OF emp.ename%TYPE;    --Ա������Ƕ�ױ�
   nums    numtab;                             --����Ƕ�ױ����������Ҫ��ʼ��        
   names   nametab;
BEGIN
   SELECT empno, ename
   BULK COLLECT INTO nums, names
     FROM emp;                                --��emp���в��Ա����ź����ƣ��������뵽����
   FOR i IN 1 .. nums.COUNT                   --ѭ����ʾ��������
   LOOP
      DBMS_OUTPUT.put ('num(' || i || ')=' || nums (i)||'   ');
      DBMS_OUTPUT.put_line ('names(' || i || ')=' || names (i));      
   END LOOP;
END;
