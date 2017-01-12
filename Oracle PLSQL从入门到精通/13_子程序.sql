CREATE OR REPLACE PROCEDURE insertDept(p_deptno IN NUMBER:=55,
                                       p_dname  IN VARCHAR2,
                                       p_loc    IN VARCHAR2) AS
  v_count NUMBER := 0;
BEGIN
  SELECT COUNT(1) INTO v_count FROM scott.dept d WHERE d.deptno = p_deptno;
  IF v_count > 0 THEN
    raise_application_error(-20000, '不能插入相同部门编号的记录');
  END IF;
  INSERT INTO scott.dept VALUES (p_deptno, p_dname, p_loc);
END;
/
SELECT  * FROM scott.dept;

BEGIN
  insertDept(80, '广告部', '纽约');
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line(SQLERRM);
END;
--判断存储过程是不是存储
SELECT * FROM user_objects o WHERE o.OBJECT_TYPE='PROCEDURE' AND o.OBJECT_NAME='INSERTDEPT';


CREATE OR REPLACE PROCEDURE insertDept(p_deptno IN NUMBER,
                                       p_dname  IN VARCHAR2,
                                       p_loc    IN VARCHAR2) AS
  v_count NUMBER := 0;
  err_dup_deptno EXCEPTION;
BEGIN
  SELECT COUNT(1) INTO v_count FROM scott.dept d WHERE d.deptno = p_deptno;
  IF v_count > 0 THEN
    RAISE err_dup_deptno;
    
  END IF;
  INSERT INTO scott.dept VALUES (p_deptno, p_dname, p_loc);
  
  EXCEPTION 
    WHEN err_dup_deptno THEN
      raise_application_error(-20000, '不能插入相同部门编号的记录');
END;

SHOW ERRORS;

--获得调薪后的工资
DELETE FROM scott.emp WHERE empno=9006;
SELECT * FROM scott.emp
CREATE OR REPLACE FUNCTION getRaiseSal(p_empno NUMBER) RETURN NUMBER IS
  v_job   scott.emp.job%TYPE;
  v_sal   scott.emp.sal%TYPE;
  v_radio NUMBER(10, 2) := 1;
BEGIN
  SELECT e.job, e.sal
    INTO v_job, v_sal
    FROM scott.emp e
   WHERE e.empno = p_empno;
  CASE v_job
    WHEN 'clerk' THEN
      v_radio := 1.1;
    WHEN 'SALESMAN' THEN
      v_radio := 1.2;
    WHEN 'MANAGER' THEN
      v_radio := 1.5;
    ELSE
      v_radio := 1;
  END CASE;
  IF v_radio <> 1 THEN
    RETURN ROUND(v_sal * v_radio, 2);
  ELSE
    RETURN v_sal;
  END IF;
EXCEPTION
  WHEN no_data_found THEN
    dbms_output.put_line('没有找到员工记录');
    RETURN NULL;
END;
/

SELECT getRaiseSal(10) FROM dual;
SELECT getRaiseSal(7369) FROM dual;

SELECT * FROM scott.emp WHERE sal<3000;
CREATE OR REPLACE PROCEDURE raiseSal(p_empno NUMBER) IS
  v_job scott.emp.job%TYPE;
  v_sal scott.emp.sal%TYPE;
BEGIN
  SELECT e.job, e.sal
    INTO v_job, v_sal
    FROM scott.emp e
   WHERE e.empno = p_empno;
  IF v_job <> 'CLERK' THEN
    dbms_output.put_line(v_job);
    RETURN;
  END IF;
  IF v_sal > 3000 THEN
    dbms_output.put_line(v_sal);
    RETURN;
  END IF;
  UPDATE scott.emp e SET e.sal = e.sal * 1.1 WHERE e.empno = p_empno;
EXCEPTION
  WHEN no_data_found THEN
    dbms_output.put_line('没有找到员工记录');
END;
/

BEGIN
raiseSal(7698);
raiseSal(7876);
END;
/

SELECT object_name, created, last_ddl_time, status
  FROM user_objects
 WHERE object_type IN ('FUNCTION','PROCEDURE') AND object_name='RAISESAL';
 SELECT   line, text
    FROM user_source
   WHERE NAME = 'RAISESAL'
ORDER BY line;
SELECT   line, POSITION, text
    FROM user_errors
   WHERE NAME = 'RAISESAL'
ORDER BY SEQUENCE;

DROP FUNCTION getRaiseSal ;
DROP PROCEDURE RAISESAL;
--in/out参数
CREATE OR REPLACE PROCEDURE raiseSal(p_empno NUMBER,p_sal OUT NUMBER) IS
  v_job scott.emp.job%TYPE;
  v_sal scott.emp.sal%TYPE;
BEGIN
  SELECT e.job, e.sal
    INTO v_job, v_sal
    FROM scott.emp e
   WHERE e.empno = p_empno;
  IF v_job <> 'CLERK' THEN
    dbms_output.put_line(v_job);
    RETURN;
  END IF;
  IF v_sal > 3000 THEN
    dbms_output.put_line(v_sal);
    RETURN;
  END IF;
  p_sal:=v_sal * 1.1;
  UPDATE scott.emp e SET e.sal = p_sal WHERE e.empno = p_empno;
EXCEPTION
  WHEN no_data_found THEN
    dbms_output.put_line('没有找到员工记录');
END;
/

DECLARE
v_sal NUMBER:=0;
BEGIN
raiseSal(7698,v_sal);
 dbms_output.put_line(v_sal);
raiseSal(7876,v_sal);
 dbms_output.put_line(v_sal);
END;
/


CREATE OR REPLACE PROCEDURE calcRaisedSalary(
         p_job IN VARCHAR2,
         p_salary IN OUT NUMBER                         --定义输入输出参数
)
AS
  v_sal NUMBER(10,2);                               --保存调整后的薪资值
BEGIN
  if p_job='职员' THEN                              --根据不同的job进行薪资的调整
     v_sal:=p_salary*1.12;
  ELSIF p_job='销售人员' THEN
     v_sal:=p_salary*1.18;
  ELSIF p_job='经理' THEN
     v_sal:=p_salary*1.19;
  ELSE
     v_sal:=p_salary;
  END IF;
  p_salary:=v_sal;                                   --将调整后的结果赋给输入输出参数
END calcRaisedSalary;



DECLARE
   v_sal NUMBER(10,2);                 --薪资变量
   v_job VARCHAR2(10);                 --职位变量
BEGIN
   SELECT sal,job INTO v_sal,v_job FROM emp WHERE empno=7369; --获取薪资和职位信息
   calcRaisedSalary(v_job,v_sal);                             --计算调薪
   DBMS_OUTPUT.put_line('计算后的调整薪水为：'||v_sal);    --获取调薪后的结果
END;   

CREATE OR REPLACE PROCEDURE calcRaisedSalaryWithTYPE(
         p_job IN emp.job%TYPE,
         p_salary IN OUT emp.sal%TYPE               --定义输入输出参数
)
AS
  v_sal NUMBER(10,2);                               --保存调整后的薪资值
BEGIN
  if p_job='职员' THEN                              --根据不同的job进行薪资的调整
     v_sal:=p_salary*1.12;
  ELSIF p_job='销售人员' THEN
     v_sal:=p_salary*1.18;
  ELSIF p_job='经理' THEN
     v_sal:=p_salary*1.19;
  ELSE
     v_sal:=p_salary;
  END IF;
  p_salary:=v_sal;                                   --将调整后的结果赋给输入输出参数
END calcRaisedSalaryWithTYPE;

--下面第一种和第三都不能用，因为要和emp.sal%TYPE精度一样，而且值也不能超过它的精度
DECLARE
   v_sal NUMBER(7,2);                 --薪资变量
   v_job VARCHAR2(10);                 --职位变量
BEGIN
   v_sal:=123294.45;
   v_job:='职员';
   calcRaisedSalaryWithTYPE(v_job,v_sal);                             --计算调薪
   DBMS_OUTPUT.put_line('计算后的调整薪水为：'||v_sal);    --获取调薪后的结果
EXCEPTION 
   WHEN OTHERS THEN
      DBMS_OUTPUT.put_line(SQLCODE||' '||SQLERRM);   
END; 

DECLARE
   v_sal NUMBER(8,2);                 --薪资变量
   v_job VARCHAR2(10);                 --职位变量
BEGIN
   v_sal:=123294.45;
   v_job:='职员';
   calcRaisedSalaryWithTYPE(p_job=>v_job,p_salary=>v_sal);                             --计算调薪
   DBMS_OUTPUT.put_line('计算后的调整薪水为：'||v_sal);    --获取调薪后的结果
EXCEPTION 
   WHEN OTHERS THEN
      DBMS_OUTPUT.put_line(SQLCODE||' '||SQLERRM);   
END;   


DECLARE
   v_sal NUMBER(7,2);                 --薪资变量
   v_job VARCHAR2(10);                 --职位变量
BEGIN
   v_sal:=1224.45;
   v_job:='职员';
   calcRaisedSalaryWithTYPE(p_salary=>v_sal,p_job=>v_job);                             --计算调薪
   DBMS_OUTPUT.put_line('计算后的调整薪水为：'||v_sal);    --获取调薪后的结果
EXCEPTION 
   WHEN OTHERS THEN
      DBMS_OUTPUT.put_line(SQLCODE||' '||SQLERRM);   
END;  
