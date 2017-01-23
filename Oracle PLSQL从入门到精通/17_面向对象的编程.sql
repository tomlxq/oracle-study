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
