SELECT * FROM scott.emp;
--对象内型每个里面的属性和方法、过程都是用逗号分开，方法和过程前面都要加member
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
  dbms_output.put_line('职员工种:' || v_emp.get_job(7881));
  dbms_output.put_line('职员工资:' || v_emp.get_sal(7881));
  dbms_output.put_line('职员部门编号:' || v_emp.get_deptno(7881));
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
  dbms_output.put_line('职员部门编号:' || v_emp.get_deptno);
  dbms_output.put_line('职员工资:' || v_emp.get_sal);
  dbms_output.put_line('职员补贴:' || v_emp.get_comm);
END;
/
--static、member
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
  dbms_output.put_line('职员工资:' || v_emp.get_sal);
  o_emp_m.change_sal(7881,900);
  dbms_output.put_line('职员工资:' || o_emp_m.get_sal(7881));
END;
/
--构造函数 
--关键字为 constructor function 类型名(...) return self as result,注意没有member

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
  dbms_output.put_line('职员名字:' || v_emp.ename);
  dbms_output.put_line('职员工资:' || v_emp.sal);
  v_emp := o_emp_contr('tomLuo',12000);
  dbms_output.put_line('职员名字:' || v_emp.ename);
  dbms_output.put_line('职员工资:' || v_emp.sal);
END;
/
--排序 map member function convert return real 
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
--排序 order member function xxx(r 类型) return integer is 
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
    dbms_output.put_line('员工1的工资加提成大于员工2');
  ELSIF v_emp_order1 < v_emp_order2 THEN
    dbms_output.put_line('员工1的工资加提成小于员工2');
  ELSE
    dbms_output.put_line('员工1的工资加提成等于员工2');
  END IF;
END;

--创建employee_order类型的对象表
CREATE TABLE emp_order OF o_emp_order;
--向对象表中插入员工薪资信息对象。
INSERT INTO emp_order VALUES(7123,3000,200,20);
INSERT INTO emp_order VALUES(7124,2000,800,20);
INSERT INTO emp_order VALUES(7125,5000,800,20);
INSERT INTO emp_order VALUES(7129,3000,400,20);
SELECT VALUE(r) val,r.sal+r.comm FROM emp_order r ORDER BY 1 DESC;

--对象类型作为过程的形参
CREATE OR REPLACE PROCEDURE change_sal(p_emp_order o_emp_order) IS
BEGIN
  IF p_emp_order IS NOT NULL THEN
    UPDATE scott.emp
       SET sal = p_emp_order.sal,comm= p_emp_order.comm
     WHERE empno = p_emp_order.empno;
  END IF;
END;
--对象类型作为函数的输入输出参数
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
  dbms_output.put_line('工资为：'||get_sal(v_emp_order));
END;

DECLARE
   o_emp  o_emp_order;
BEGIN
   o_emp.empno:=7301;   --错误：该对象实例还没有被初始化就进行了赋值
END;

DECLARE
   o_emp   o_emp_order := 
              o_emp_order (NULL, NULL, NULL, NULL); --初始化对象类型
BEGIN
   o_emp.empno := 7301;                                --为对象类型赋值
   o_emp.sal := 5000;
   o_emp.comm := 300;
   o_emp.deptno := 20;
END;


--定义地址对象类型规范
CREATE OR REPLACE TYPE address_type AS OBJECT
(
  street_addr1 VARCHAR2(25), --街道地址1
  street_addr2 VARCHAR2(25), --街道地址2
  city         VARCHAR2(30), --城市
  state        VARCHAR2(20), --省份
  zip_code     NUMBER, --邮政编码
--成员方法，返回地址字符串
  MEMBER FUNCTION toString RETURN VARCHAR2,
--MAP方法提供地址比较函数
  MAP MEMBER FUNCTION mapping_function RETURN VARCHAR2
);
/

--定义地址对象类型体，实现成员方法与MAP函数
CREATE OR REPLACE TYPE BODY address_type
AS
   MEMBER FUNCTION tostring
      RETURN VARCHAR2                    --将地址属性转换为字符形式显示
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
   MAP MEMBER FUNCTION mapping_function    --定义地址对象MAP函数的实现，返回VARCHAR2类型
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
v_addr1 address_type:=address_type('软件园15栋1号','新明街','西安','山东',123456);
v_addr2 address_type:=address_type('软件园16栋2号','步行街','中山','广东',423527);
BEGIN
 dbms_output.put_line(v_addr1.tostring);
 dbms_output.put_line(v_addr2.mapping_function);
 END;
 
 --定义一个对象规范，该规范中包含ORDER方法
CREATE OR REPLACE TYPE employee_addr AS OBJECT (
   empno    NUMBER (4),
   sal      NUMBER (10, 2),
   comm     NUMBER (10, 2),
   deptno   NUMBER (4),
   addr     address_type,
 MEMBER FUNCTION get_emp_info RETURN VARCHAR2   
)
NOT FINAL; 
--定义对象类型体，实现get_emp_info方法
CREATE OR REPLACE TYPE BODY employee_addr
AS
   MEMBER FUNCTION get_emp_info
      RETURN VARCHAR2                    --返回员工的详细信息
   IS
   BEGIN
      RETURN '员工'||SELF.empno||'的地址为：'||SELF.addr.toString;
   END;
END;


DECLARE
   o_address address_type;
   o_emp employee_addr; 
BEGIN
   o_address:=address_type('玉兰一街','二巷','深圳','DG',523343);
   o_emp:=employee_addr(7369,5000,800,20,o_address); 
   DBMS_OUTPUT.put_line('员工信息为'||o_emp.get_emp_info);
END;

CREATE OR REPLACE TYPE person_obj AS OBJECT (
   person_name        VARCHAR (20),   --人员姓名
   gender      VARCHAR2 (10),          --人员性别
   birthdate   DATE,                  --出生日期
   address     VARCHAR2 (50),         --家庭住址
   MEMBER FUNCTION get_info
      RETURN VARCHAR2                 --返回员工信息
)
NOT FINAL;                            --人员对象可以被继承
CREATE OR REPLACE TYPE BODY person_obj    --对象体
AS
   MEMBER FUNCTION get_info
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN '姓名：' || person_name || ',家庭住址：' || address;
   END;
END;
--对象类型使用UNDER语句从person_obj中继承
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
    --在对象类型体中可以直接访问在父对象中定义的属性
    RETURN '员工编号：' || SELF.empno || ' 员工名称：' || SELF.person_name || ' 职位：' || SELF.job;
  END;
  OVERRIDING MEMBER FUNCTION get_info RETURN VARCHAR2 IS --定义重载方法
  BEGIN
    RETURN '员工编号：' || SELF.empno || ' 员工名称：' || SELF.person_name || ' 职位：' || SELF.job;
  END;
END;

DECLARE
   o_emp employee_personobj;         --定义员工对象类型的变量
BEGIN
   --使用构造函数实例化员工对象
   o_emp:=employee_personobj('张小五','F',
                             TO_DATE('1983-01-01','YYYY-MM-DD'),
                             '中信',7981,5000,'Programmer');
   DBMS_OUTPUT.put_line(o_emp.get_info);          --输出父对象的人员信息
   DBMS_OUTPUT.put_line(o_emp.get_emp_info);      --输出员工对象中的员工信息
END;


CREATE TABLE emp_obj_table OF employee_personobj;


INSERT INTO emp_obj_table VALUES('张小五','F',
                             TO_DATE('1983-01-01','YYYY-MM-DD'),
                             '中信',7981,5000,'Programmer');
                             
SELECT * FROM emp_obj_table;

CREATE TABLE emp_addr_table OF employee_addr;
INSERT INTO emp_addr_table
     VALUES (7369, 5000, 800, 20,
             address_type ('玉兰一街', '二巷', '深圳', 'DG', 523343));

SELECT * FROM emp_addr_table;

DECLARE
   o_emp employee_personobj;                   --定义员工对象类型的变量
BEGIN
   --使用构造函数实例化员工对象
   o_emp:=employee_personobj('张小五','F',
                             TO_DATE('1983-01-01','YYYY-MM-DD'),
                             '中信',7981,5000,'Programmer');
   INSERT INTO emp_obj_table VALUES(o_emp);    --插入到对象表中                            
END; 

SELECT * FROM emp_obj_table;
INSERT INTO emp_obj_table VALUES (employee_personobj('张小五','F',
                             TO_DATE('1983-01-01','YYYY-MM-DD'),
                             '中信',7981,5000,'Programmer'));
                             
                             
SELECT person_name,job FROM emp_obj_table;        

 SELECT VALUE(e) from emp_obj_table e;    
 DECLARE
    o_emp employee_personobj;   --定义一个对象类型的变量
 BEGIN
    --使用SELECT INTO语句将VALUE函数返回的对象实例插入到对象类型的变量
    SELECT VALUE(e) INTO o_emp FROM emp_obj_table e WHERE e.person_name='张小五' AND ROWNUM=1;
    --输出对象类型的属性值
    DBMS_OUTPUT.put_line(o_emp.person_name||'的职位是：'||o_emp.job);
 END; 
 
 INSERT INTO emp_obj_table VALUES (employee_personobj('张小五','F',
                             TO_DATE('1983-01-01','YYYY-MM-DD'),
                             '中信',7981,5000,'Programmer'));
INSERT INTO emp_obj_table VALUES (employee_personobj('刘小艳','M',
                             TO_DATE('1983-01-01','YYYY-MM-DD'),
                             '中泰',7981,5000,'running'));   
                             
DECLARE
   o_emp   employee_personobj;     --定义对象类型的变量
   CURSOR all_emp
   IS
      SELECT VALUE (e) AS emp
        FROM emp_obj_table e;      --定义一个游标，用来查询多行数据
BEGIN
   FOR each_emp IN all_emp         --使用游标FOR循环检索游标数据
   LOOP
      o_emp := each_emp.emp;       --获取游标查询的对象实例
      --输出对象实例信息
      DBMS_OUTPUT.put_line (o_emp.person_name || ' 的职位是：' || o_emp.job);
   END LOOP;
END;
                             

 DECLARE
    o_emp REF employee_personobj;   --定义REF类型的变量
 BEGIN
    --使用REF函数获取引用类型的对象
    SELECT REF(e) INTO o_emp FROM emp_obj_table e WHERE e.person_name='张小五' AND ROWNUM=1;
 END;       
 UPDATE emp_obj_table empobj
   SET empobj.gender = 'M'
 WHERE empobj.person_name = '张小五';
 
 
 UPDATE emp_obj_table empobj
  SET empobj=employee_personobj('李小七','F',
                             TO_DATE('1983-01-01','YYYY-MM-DD'),
                             '众泰',7981,7000,'Testing')
  WHERE person_name='张小五';                            
  
  
  DECLARE
     empref REF employee_personobj;     
  BEGIN
     SELECT REF(empobj) INTO empref FROM emp_obj_table empobj WHERE e.person_name='刘小艳';
  END;
  
  SELECT REF(e2) FROM emp_obj_table e2;
--定义与关系表emp相匹配列的对象类型
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
--定义对象类型体
CREATE OR REPLACE TYPE BODY emp_tbl_obj AS
   MEMBER FUNCTION get_emp_info  RETURN VARCHAR2 IS
   BEGIN
      --在对象类型体中可以直接访问在父对象中定义的属性
      RETURN '员工编号：'||SELF.empno||' 员工名称：'||SELF.ename||' 职位：'||SELF.job;
   END; 
END;
/
--创建emp_view对象表
CREATE VIEW emp_view
   OF emp_tbl_obj
   WITH OBJECT IDENTIFIER (empno)
AS
   SELECT e.empno, e.ename, e.job, e.mgr, e.hiredate, e.sal, e.comm, e.deptno
     FROM emp e;
/


DECLARE
  o_emp emp_tbl_obj;          --定义对象类型的变量
BEGIN
  --查询对象类型
  SELECT VALUE(e) INTO o_emp FROM emp_view e WHERE empno=7369;
  --输出对象类型的属性
  DBMS_OUTPUT.put_line('员工'||o_emp.ename||' 的薪资为：'||o_emp.sal);
  DBMS_OUTPUT.put_line(o_emp.get_emp_info);  --调用对象类型的成员方法
END;  

/* Formatted on 2011/11/03 07:07 (Formatter Plus v4.8.8) */

CREATE TYPE address AS OBJECT (     --创建地址类型
   street     VARCHAR2 (35),
   city       VARCHAR2 (15),
   state      CHAR (2),
   zip_code   INTEGER
);
CREATE TABLE addresses OF address;  --创建地址对象表
CREATE TYPE person AS OBJECT (      --创建人员对象类型
   person_name     VARCHAR2 (15),
   birthday       DATE,
   home_address   REF address,      --使用REF关键字，指定属性为指向另一个对象表的对象
   phone_number   VARCHAR2 (15)
);
CREATE TABLE persons OF person;     --创建人员对象表
--插入地址
INSERT INTO addresses
     VALUES (address ('玉兰', '深圳', 'GD', '52334'));
INSERT INTO addresses
     VALUES (address ('黄甫', '广州', 'GD', '52300'));
--插入一个人员，注意这里的home_address部分是如何插入一个ref address的。
INSERT INTO persons
     VALUES (person ('王小五',
                     TO_DATE ('1983-01-01', 'YYYY-MM-DD'),
                     (SELECT REF (a)
                        FROM addresses a
                       WHERE street = '玉兰'),
                     '16899188'
                    ));
--也可以用下面的过程来插入一个人员记录

DECLARE
   addref   REF address;
BEGIN
   SELECT REF (a)
     INTO addref
     FROM addresses a
    WHERE street = '玉兰';   --使用SELECT INTO查询一个引用对象
   --使用INSERT语句向persons表中插入引用对象
   INSERT INTO persons
        VALUES (person ('五大狼',
                        TO_DATE ('1983-01-01', 'yyyy-mm-dd'),
                        addref,
                        '16899188'
                       ));
END;

--查询某人的地址信息
SELECT person_name, DEREF (home_address)
  FROM persons;
  
  
DECLARE
   addr address;
BEGIN
   SELECT DEREF(home_address) INTO addr FROM persons WHERE person_name='王小五';
   addr.street:='五一';
   UPDATE address SET street=addr.street WHERE zip_code='523330';
END;
