--定义包规范，包规范将被用于应用程序的接口部分，供外部调用
CREATE OR REPLACE PACKAGE emp_pkg AS
   --定义集合类型
   TYPE emp_tab IS TABLE OF emp%ROWTYPE INDEX BY BINARY_INTEGER;
   --在包规范中定义一个记录类型
   TYPE emprectyp IS RECORD(
      emp_no NUMBER,
      sal  NUMBER
   );
   --定义一个游标变量
   CURSOR desc_salary RETURN emprectyp;
   --定义雇佣员工的过程
   PROCEDURE hire_employee(p_empno NUMBER,p_ename VARCHAR2,p_job VARCHAR2,p_mgr NUMBER,p_sal NUMBER,
                        p_comm NUMBER,p_deptno NUMBER,p_hiredate DATE);
   --定义解雇员工的过程                        
   PROCEDURE fire_employee(p_emp_id NUMBER );
END emp_pkg;

--定义包体
CREATE OR REPLACE PACKAGE BODY emp_pkg
AS
   --定义游标变量的具体类型
   CURSOR desc_salary RETURN emprectyp IS
      SELECT empno, sal FROM emp ORDER BY sal DESC;
   --定义雇佣员工的具体实现
   PROCEDURE hire_employee(p_empno NUMBER,p_ename VARCHAR2,
                           p_job VARCHAR2,p_mgr NUMBER,p_sal NUMBER,
                           p_comm NUMBER,p_deptno NUMBER,p_hiredate DATE) IS
   BEGIN
      --向emp表中插入一条员工信息
      INSERT INTO emp VALUES(p_empno,p_ename,p_job,p_mgr,p_hiredate,p_sal,p_comm,p_deptno); 
   END;       
   --定义解雇员工的具体实现                 
   PROCEDURE fire_employee(p_emp_id NUMBER ) IS
   BEGIN
      --从emp表中删除员工信息
      DELETE FROM emp WHERE empno=p_emp_id;
   END;          
END emp_pkg;


--定义包规范，包规范将被用于应用程序的接口部分，供外部调用
CREATE OR REPLACE PACKAGE dept_pkg AS
   dept_count NUMBER:=1;
   --定义集合类型
   TYPE dept_tab IS TABLE OF dept%ROWTYPE INDEX BY BINARY_INTEGER;
   --在包规范中定义一个记录类型
   TYPE deptrectyp IS RECORD(
      dept_no NUMBER,
      dname  VARCHAR2(30),
      loc VARCHAR2(30)
   );
   CURSOR deptcur RETURN deptrectyp;       --定义一个游标变量
   e_nodept_assign EXCEPTION;              --定义一个异常
END dept_pkg;



DECLARE
   mydept dept_pkg.dept_tab;                           --定义包中的集合类型的变量     
BEGIN
   FOR deptrow IN (SELECT * FROM dept) LOOP            --使用游标FOR循环提取dept数据
     mydept(dept_pkg.dept_count):=deptrow;             --为集合类型赋值
     dept_pkg.dept_count:=dept_pkg.dept_count+1;       --递增包中的变量的值
   END LOOP;    
   FOR i IN 1..mydept.count LOOP                       --循环显示集合中的部门的部门名称
      DBMS_OUTPUT.put_line(mydept(i).dname);
   END LOOP;
   dept_pkg.dept_count:=1;                             --重置dept_pkg.dept_count的值。
EXCEPTION
   WHEN  dept_pkg.e_nodept_assign THEN
      DBMS_OUTPUT.put_line('没有找到员工记录');     --捕捉异常，如果有触发的话
END;

--定义包规范
CREATE OR REPLACE PACKAGE emp_action_pkg IS
   v_deptno NUMBER(3):=20;              --包公开的变量
   --定义一个增加新员工的过程
   PROCEDURE newdept (
       p_deptno   dept.deptno%TYPE,    --部门编号
       p_dname    dept.dname%TYPE,     --部门名称
       p_loc      dept.loc%TYPE        --位置
    );   
    --定义一个获取员工加薪数量的函数
    FUNCTION getraisedsalary (p_empno emp.empno%TYPE)
       RETURN NUMBER;    
END emp_action_pkg;

--定义包体
CREATE OR REPLACE PACKAGE BODY emp_action_pkg IS
  --公开，实现包规范中定义的newdept过程
  PROCEDURE newdept (
       p_deptno   dept.deptno%TYPE,    --部门编号
       p_dname    dept.dname%TYPE,     --部门名称
       p_loc      dept.loc%TYPE        --位置
    )
    AS
       v_deptcount   NUMBER;           --保存是否存在员工编号
       BEGIN
       SELECT COUNT (*) INTO v_deptcount FROM dept
        WHERE deptno = p_deptno;       --查询在dept表中是否存在部门编号
       IF v_deptcount > 0              --如果存在相同的员工记录
       THEN                            --抛出异常
          raise_application_error (-20002, '出现了相同的员工记录');
       END IF;
       INSERT INTO dept(deptno, dname, loc)  
            VALUES (p_deptno, p_dname, p_loc);--插入记录
    END newdept;
    --公开，实现包规范中定义的getraisedsalary函数
    FUNCTION getraisedsalary (p_empno emp.empno%TYPE)
       RETURN NUMBER
    IS
       v_job           emp.job%TYPE;            --职位变量
       v_sal           emp.sal%TYPE;            --薪资变量
       v_salaryratio   NUMBER (10, 2);          --调薪比率
    BEGIN
       --获取员工表中的薪资信息
       SELECT job, sal INTO v_job, v_sal FROM emp WHERE empno = p_empno;
       CASE v_job                               --根据不同的职位获取调薪比率
          WHEN '职员' THEN
             v_salaryratio := 1.09;
          WHEN '销售人员' THEN
             v_salaryratio := 1.11;
          WHEN '经理' THEN
             v_salaryratio := 1.18;
          ELSE
             v_salaryratio := 1;
       END CASE;
       IF v_salaryratio <> 1                    --如果有调薪的可能
       THEN
          RETURN ROUND(v_sal * v_salaryratio,2);         --返回调薪后的薪资
       ELSE
          RETURN v_sal;                         --否则不返回薪资
       END IF;
     EXCEPTION
          WHEN NO_DATA_FOUND THEN
             RETURN 0;                             --如果没找到原工记录，返回0
     END getraisedsalary;
    --私有，该函数在包规范中并不存在，只能在包体内被引用
    FUNCTION checkdeptno(p_deptno dept.deptno%TYPE) RETURN NUMBER
    AS
      v_counter NUMBER(2);
    BEGIN
       SELECT COUNT(*) INTO v_counter FROM dept WHERE deptno=p_deptno;
       RETURN v_counter; 
    END;           
END emp_action_pkg;      

--在该块中为v_deptno赋值为30，调用getraisedsalary函数
BEGIN
   emp_action_pkg.v_deptno:=30;                                  --为包规范变量赋值
   DBMS_OUTPUT.put_line(emp_action_pkg.getraisedsalary(7369));--调用包中的函数
END;

--在该块中为v_deptno赋值为50，并调用newdept过程
BEGIN
   emp_action_pkg.v_deptno:=50;
   emp_action_pkg.newdept(45,'采纳部','佛山');
END;
SELECT * FROM dept;

--在该块中输出v_deptno的值
BEGIN
   DBMS_OUTPUT.put_line(emp_action_pkg.v_deptno);
END;
DELETE FROM dept WHERE deptno=45;

--定义包规范
CREATE OR REPLACE PACKAGE emp_action_pkg IS
   PRAGMA SERIALLY_REUSABLE;            --指定编译提示
   v_deptno NUMBER(3):=20;              --包公开的变量
   --定义一个增加新员工的过程
   PROCEDURE newdept (
       p_deptno   dept.deptno%TYPE,    --部门编号
       p_dname    dept.dname%TYPE,     --部门名称
       p_loc      dept.loc%TYPE        --位置
    );   
    --定义一个获取员工加薪数量的函数
    FUNCTION getraisedsalary (p_empno emp.empno%TYPE)
       RETURN NUMBER;    
END emp_action_pkg;

--定义包体
CREATE OR REPLACE PACKAGE BODY emp_action_pkg IS
   PRAGMA SERIALLY_REUSABLE;            --指定编译提示
  --公开，实现包规范中定义的newdept过程
  PROCEDURE newdept (
       p_deptno   dept.deptno%TYPE,    --部门编号
       p_dname    dept.dname%TYPE,     --部门名称
       p_loc      dept.loc%TYPE        --位置
    )
    AS
       v_deptcount   NUMBER;           --保存是否存在员工编号
       BEGIN
       SELECT COUNT (*) INTO v_deptcount FROM dept
        WHERE deptno = p_deptno;       --查询在dept表中是否存在部门编号
       IF v_deptcount > 0              --如果存在相同的员工记录
       THEN                            --抛出异常
          raise_application_error (-20002, '出现了相同的员工记录');
       END IF;
       INSERT INTO dept(deptno, dname, loc)  
            VALUES (p_deptno, p_dname, p_loc);--插入记录
    END newdept;
    --公开，实现包规范中定义的getraisedsalary函数
    FUNCTION getraisedsalary (p_empno emp.empno%TYPE)
       RETURN NUMBER
    IS
       v_job           emp.job%TYPE;            --职位变量
       v_sal           emp.sal%TYPE;            --薪资变量
       v_salaryratio   NUMBER (10, 2);          --调薪比率
    BEGIN
       --获取员工表中的薪资信息
       SELECT job, sal INTO v_job, v_sal FROM emp WHERE empno = p_empno;
       CASE v_job                               --根据不同的职位获取调薪比率
          WHEN '职员' THEN
             v_salaryratio := 1.09;
          WHEN '销售人员' THEN
             v_salaryratio := 1.11;
          WHEN '经理' THEN
             v_salaryratio := 1.18;
          ELSE
             v_salaryratio := 1;
       END CASE;
       IF v_salaryratio <> 1                    --如果有调薪的可能
       THEN
          RETURN ROUND(v_sal * v_salaryratio,2);         --返回调薪后的薪资
       ELSE
          RETURN v_sal;                         --否则不返回薪资
       END IF;
     EXCEPTION
          WHEN NO_DATA_FOUND THEN
             RETURN 0;                             --如果没找到原工记录，返回0
     END getraisedsalary;
    --私有，该函数在包规范中并不存在，只能在包体内被引用
    FUNCTION checkdeptno(p_deptno dept.deptno%TYPE) RETURN NUMBER
    AS
      v_counter NUMBER(2);
    BEGIN
       SELECT COUNT(*) INTO v_counter FROM dept WHERE deptno=p_deptno;
       RETURN v_counter; 
    END;           
END emp_action_pkg;

ALTER PACKAGE emp_action_pkg COMPILE SPECIFICATION;--编译包规范
ALTER PACKAGE emp_action_pkg COMPILE BODY;--编译包体
ALTER PACKAGE emp_action_pkg COMPILE PACKAGE;--编译包规范和包体
--查看包是不是存在
SELECT o.OBJECT_TYPE, o.status, o.OBJECT_NAME
  FROM user_objects o
 WHERE o.OBJECT_TYPE IN ('PACKAGE', 'PACKAGE BODY')
 ORDER BY o.OBJECT_TYPE, o.status, o.OBJECT_NAME;
--查看包的源代码
SELECT   line, text
    FROM user_source
   WHERE NAME = 'EMP_ACTION_PKG' AND TYPE = 'PACKAGE'
ORDER BY line;
SELECT   line, text
    FROM user_source
   WHERE NAME = 'EMP_ACTION_PKG' AND TYPE = 'PACKAGE BODY'
ORDER BY line;

--包里的过程与函数的重载
--定义包规范
CREATE OR REPLACE PACKAGE emp_action_pkg_overload IS
   --定义一个增加新员工的过程
   PROCEDURE newdept (
       p_deptno   dept.deptno%TYPE,    --部门编号
       p_dname    dept.dname%TYPE,     --部门名称
       p_loc      dept.loc%TYPE        --位置
    );   
   --定义一个增加新员工的过程，重载过程
   PROCEDURE newdept (
       p_deptno   dept.deptno%TYPE,    --部门编号
       p_dname    dept.dname%TYPE     --部门名称
    );       
    --定义一个获取员工加薪数量的函数
    FUNCTION getraisedsalary (p_empno emp.empno%TYPE)
       RETURN NUMBER;
       
    --定义一个获取员工加薪数量的函数，重载函数
    FUNCTION getraisedsalary (p_ename emp.ename%TYPE)
       RETURN NUMBER;                  
END emp_action_pkg_overload;


--定义包体
CREATE OR REPLACE PACKAGE BODY emp_action_pkg_overload IS
  --公开，实现包规范中定义的newdept过程
  PROCEDURE newdept (
       p_deptno   dept.deptno%TYPE,    --部门编号
       p_dname    dept.dname%TYPE,     --部门名称
       p_loc      dept.loc%TYPE        --位置
    )
    AS
       v_deptcount   NUMBER;           --保存是否存在员工编号
       BEGIN
       SELECT COUNT (*) INTO v_deptcount FROM dept
        WHERE deptno = p_deptno;       --查询在dept表中是否存在部门编号
       IF v_deptcount > 0              --如果存在相同的员工记录
       THEN                            --抛出异常
          raise_application_error (-20002, '出现了相同的员工记录');
       END IF;
       INSERT INTO dept(deptno, dname, loc)  
            VALUES (p_deptno, p_dname, p_loc);--插入记录
    END newdept;
    
  PROCEDURE newdept (
       p_deptno   dept.deptno%TYPE,    --部门编号
       p_dname    dept.dname%TYPE     --部门名称
    )
    AS
       v_deptcount   NUMBER;           --保存是否存在员工编号
       BEGIN
       SELECT COUNT (*) INTO v_deptcount FROM dept
        WHERE deptno = p_deptno;       --查询在dept表中是否存在部门编号
       IF v_deptcount > 0              --如果存在相同的员工记录
       THEN                            --抛出异常
          raise_application_error (-20002, '出现了相同的员工记录');
       END IF;
       INSERT INTO dept(deptno, dname, loc)  
            VALUES (p_deptno, p_dname, '中国');--插入记录
    END newdept;    
    
    --公开，实现包规范中定义的getraisedsalary函数
    FUNCTION getraisedsalary (p_empno emp.empno%TYPE)
       RETURN NUMBER
    IS
       v_job           emp.job%TYPE;            --职位变量
       v_sal           emp.sal%TYPE;            --薪资变量
       v_salaryratio   NUMBER (10, 2);          --调薪比率
    BEGIN
       --获取员工表中的薪资信息
       SELECT job, sal INTO v_job, v_sal FROM emp WHERE empno = p_empno;
       CASE v_job                               --根据不同的职位获取调薪比率
          WHEN '职员' THEN
             v_salaryratio := 1.09;
          WHEN '销售人员' THEN
             v_salaryratio := 1.11;
          WHEN '经理' THEN
             v_salaryratio := 1.18;
          ELSE
             v_salaryratio := 1;
       END CASE;
       IF v_salaryratio <> 1                    --如果有调薪的可能
       THEN
          RETURN ROUND(v_sal * v_salaryratio,2);         --返回调薪后的薪资
       ELSE
          RETURN v_sal;                         --否则不返回薪资
       END IF;
     EXCEPTION
          WHEN NO_DATA_FOUND THEN
             RETURN 0;                             --如果没找到原工记录，返回0
     END getraisedsalary;
     
    --重载函数的实现
    FUNCTION getraisedsalary (p_ename emp.ename%TYPE)
       RETURN NUMBER
    IS
       v_job           emp.job%TYPE;            --职位变量
       v_sal           emp.sal%TYPE;            --薪资变量
       v_salaryratio   NUMBER (10, 2);          --调薪比率
    BEGIN
       --获取员工表中的薪资信息
       SELECT job, sal INTO v_job, v_sal FROM emp WHERE ename = p_ename AND ROWNUM=1;
       CASE v_job                               --根据不同的职位获取调薪比率
          WHEN '职员' THEN
             v_salaryratio := 1.09;
          WHEN '销售人员' THEN
             v_salaryratio := 1.11;
          WHEN '经理' THEN
             v_salaryratio := 1.18;
          ELSE
             v_salaryratio := 1;
       END CASE;
       IF v_salaryratio <> 1                    --如果有调薪的可能
       THEN
          RETURN ROUND(v_sal * v_salaryratio,2);         --返回调薪后的薪资
       ELSE
          RETURN v_sal;                         --否则不返回薪资
       END IF;
     EXCEPTION
          WHEN NO_DATA_FOUND THEN
             RETURN 0;                             --如果没找到原工记录，返回0
     END getraisedsalary;     
     
    --私有，该函数在包规范中并不存在，只能在包体内被引用
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
   emp_action_pkg_overload.newdept(43,'样品部','东京');          --重载过程使用示例
   emp_action_pkg_overload.newdept(44,'纸品部');
   v_sal:=emp_action_pkg_overload.getraisedsalary(7369);         --重载函数使用示例
   v_sal:=emp_action_pkg_overload.getraisedsalary('史密斯');
END;

--定义包头，在包头中定义要公开的成员
CREATE OR REPLACE PACKAGE InitTest IS
   TYPE emp_typ IS TABLE OF emp%ROWTYPE INDEX BY BINARY_INTEGER;
   CURSOR emp_cur RETURN emp%ROWTYPE;      --定义游标
   curr_time NUMBER;                       --当前秒数
   emp_tab emp_typ;                        --定义集合类型的变量
   --定义一个增加新员工的过程
   PROCEDURE newdept (
       p_deptno   dept.deptno%TYPE,    --部门编号
       p_dname    dept.dname%TYPE,     --部门名称
       p_loc      dept.loc%TYPE        --位置
    );   
    --定义一个获取员工加薪数量的函数
    FUNCTION getraisedsalary (p_empno emp.empno%TYPE)
       RETURN NUMBER;         
END InitTest;
--定义包体，在包体的初始化区域对包进行初始化
CREATE OR REPLACE PACKAGE BODY InitTest IS
   row_counter NUMBER:=1;
   CURSOR emp_cur RETURN emp%ROWTYPE IS
      SELECT * FROM emp ORDER BY sal DESC; --定义游标体         
    --定义一个增加新员工的过程
   PROCEDURE newdept (
       p_deptno   dept.deptno%TYPE,    --部门编号
       p_dname    dept.dname%TYPE,     --部门名称
       p_loc      dept.loc%TYPE        --位置
    ) AS
    BEGIN
       NULL;
    END newdept;
    --定义一个获取员工加薪数量的函数
    FUNCTION getraisedsalary (p_empno emp.empno%TYPE)
       RETURN NUMBER IS
    BEGIN
       NULL;
    END getraisedsalary;
BEGIN    
    --包初始化部分，定义包的代码
    SELECT TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS')) INTO curr_time FROM dual;
     FOR emp_row IN emp_cur LOOP
       emp_tab(row_counter):=emp_row;          --为集合赋值
       row_counter:=row_counter+1;
    END LOOP;   
EXCEPTION 
    WHEN OTHERS THEN 
       DBMS_OUTPUT.put_line('出现了异常');               
END InitTest;

DECLARE
   v_time NUMBER;
BEGIN
   v_time:=InitTest.curr_time;              --获取当前的时间秒数
   --输出索引表中的员工名称，以及当前的秒数。
  DBMS_OUTPUT.put_line(InitTest.emp_tab(1).ename||' '||v_time);
END;


--设置纯度级别
/*PRAGMA RESTRICT_REFERENCES WNPS/WNDS/WNPS/RNPS 理解不了*/
CREATE OR REPLACE PACKAGE purityTest IS
  TYPE emp_type IS TABLE OF scott.emp%ROWTYPE INDEX BY PLS_INTEGER;
  emp_tab emp_type;
  PROCEDURE insertDept(p_deptno scott.dept.deptno%TYPE,
                       p_dname  scott.dept.dname%TYPE,
                       p_loc    scott.dept.loc%TYPE);
  FUNCTION getEmpSal(p_empno scott.emp.empno%TYPE) RETURN NUMBER;
  --设置纯度级别
  PRAGMA RESTRICT_REFERENCES(insertDept, WNPS); --限制函数不能修改包变量，也不能给包变量赋值
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
      raise_application_error(-20000, '不能插入相同部门编号的记录');
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

SELECT empno 员工编号, purityTest.getEmpSal (empno) 调薪后, sal 调薪前,job
  FROM emp
 WHERE deptno = 20;
 
 GRANT EXECUTE ON scott.purityTest TO hr;     --为hr分配执行权限
DROP PACKAGE scott.purityTest;   --删除包

--定义包规范  
/*authid current_user 理解不了*/
CREATE OR REPLACE PACKAGE emp_action_pkg 
   AUTHID CURRENT_USER IS               --指定包中的过程为调用者权限   
   v_deptno NUMBER(3):=20;              --包公开的变量
   --定义一个增加新员工的过程
   PROCEDURE newdept (
       p_deptno   dept.deptno%TYPE,    --部门编号
       p_dname    dept.dname%TYPE,     --部门名称
       p_loc      dept.loc%TYPE        --位置
    );   
    --定义一个获取员工加薪数量的函数
    FUNCTION getraisedsalary (p_empno emp.empno%TYPE)
       RETURN NUMBER;    
END emp_action_pkg;


--定义包规范，包规范将被用于应用程序的接口部分，供外部调用
CREATE OR REPLACE PACKAGE emp_pkg AS
   --定义集合类型
   TYPE emp_tab IS TABLE OF emp%ROWTYPE INDEX BY BINARY_INTEGER;
   --在包规范中定义一个记录类型
   TYPE emprectyp IS RECORD(
      emp_no NUMBER,
      sal  NUMBER
   );
   --定义一个游标声明
   CURSOR desc_salary RETURN emprectyp;
   --定义一个游标，并具有游标体   
   CURSOR emp_cur(p_deptno IN dept.deptno%TYPE) IS
      SELECT * FROM emp WHERE deptno=p_deptno;   
   --定义雇佣员工的过程
   PROCEDURE hire_employee(p_empno NUMBER,p_ename VARCHAR2,p_job VARCHAR2,p_mgr NUMBER,p_sal NUMBER,
                        p_comm NUMBER,p_deptno NUMBER,p_hiredate DATE);
   --定义解雇员工的过程                        
   PROCEDURE fire_employee(p_emp_id NUMBER );
END emp_pkg;



--定义包体
CREATE OR REPLACE PACKAGE BODY emp_pkg
AS
   --定义游标变量的具体类型
   CURSOR desc_salary RETURN emprectyp IS
      SELECT empno, sal FROM emp ORDER BY sal DESC;
   --定义雇佣员工的具体实现
   PROCEDURE hire_employee(p_empno NUMBER,p_ename VARCHAR2,
                           p_job VARCHAR2,p_mgr NUMBER,p_sal NUMBER,
                           p_comm NUMBER,p_deptno NUMBER,p_hiredate DATE) IS
   BEGIN
      FOR emp_salrow IN desc_salary LOOP
        DBMS_OUTPUT.put_line(emp_salrow.emp_no||'： '||emp_salrow.sal); 
      END LOOP;
   END;       
   --定义解雇员工的具体实现                 
   PROCEDURE fire_employee(p_emp_id NUMBER ) IS
   BEGIN
      --从emp表中删除员工信息
      DELETE FROM emp WHERE empno=p_emp_id;
      FOR emp_row IN emp_cur(20) LOOP
        DBMS_OUTPUT.put_line(emp_row.empno||' '||emp_row.deptno);
      END LOOP;
   END;          
END emp_pkg;

SELECT object_type 对象类型, object_name 对象名称, status 状态
    FROM user_objects
    WHERE object_type IN ('PACKAGE', 'PACKAGE BODY')
    ORDER BY object_type, status, object_name;

--定义包规范，包规范将被用于应用程序的接口部分，供外部调用
CREATE OR REPLACE PACKAGE emp_pkg_dependency AS
   --定义雇佣员工的过程
   PROCEDURE hire_employee(p_empno NUMBER,p_ename VARCHAR2,p_job VARCHAR2,p_mgr NUMBER,p_sal NUMBER,
                        p_comm NUMBER,p_deptno NUMBER,p_hiredate DATE);
   --定义解雇员工的过程                        
   PROCEDURE fire_employee(p_emp_id NUMBER );
END emp_pkg_dependency;
--定义包体
CREATE OR REPLACE PACKAGE BODY emp_pkg_dependency
AS
   --定义雇佣员工的具体实现
   PROCEDURE hire_employee(p_empno NUMBER,p_ename VARCHAR2,
                           p_job VARCHAR2,p_mgr NUMBER,p_sal NUMBER,
                           p_comm NUMBER,p_deptno NUMBER,p_hiredate DATE) IS
   BEGIN
      --向emp表中插入一条员工信息
      INSERT INTO emp VALUES(p_empno,p_ename,p_job,
                             p_mgr,p_hiredate,
                             p_sal,p_comm,p_deptno); 
      INSERT INTO emp_history VALUES(p_empno,p_ename,p_job,
                                     p_mgr,p_hiredate,
                                     p_sal,p_comm,p_deptno);       
   END;       
   --定义解雇员工的具体实现                 
   PROCEDURE fire_employee(p_emp_id NUMBER ) IS
   BEGIN
      --从emp表中删除员工信息
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
  DBMS_OUTPUT.ENABLE; --开启DBMS_OUTPUT
  DBMS_OUTPUT.PUT_LINE('DBMS_OUTPUT主要用于输出信息，它包含：'); --写入并换行
  DBMS_OUTPUT.PUT('PUT_LINE'); --写入文本不换行
  DBMS_OUTPUT.PUT(',PUT_LINE');
  DBMS_OUTPUT.PUT(',PUTE');
  DBMS_OUTPUT.PUT(',NEW_LINE');
  DBMS_OUTPUT.PUT(',GET_LINE');
  DBMS_OUTPUT.PUT(',GET_LINES等过程');
  DBMS_OUTPUT.NEW_LINE; --在文本最后加上换行符
  DBMS_OUTPUT.GET_LINE(v_line1, v_status);
  DBMS_OUTPUT.GET_LINE(v_line2, v_status); --获取缓冲区中的数据行
  DBMS_OUTPUT.PUT_LINE(v_line1); --输出变量的值到缓冲区
  DBMS_OUTPUT.PUT_LINE(v_line2);
END;
/

DECLARE
  v_lines  DBMS_OUTPUT.CHARARR; --定义集合类型的变量
  v_status NUMBER;
BEGIN
  DBMS_OUTPUT.ENABLE; --开启DBMS_OUTPUT
  DBMS_OUTPUT.PUT_LINE('DBMS_OUTPUT主要用于输出信息，它包含：'); --写入并换行
  DBMS_OUTPUT.PUT('PUT_LINE'); --写入文本不换行
  DBMS_OUTPUT.PUT(',PUT_LINE');
  DBMS_OUTPUT.PUT(',PUTE');
  DBMS_OUTPUT.PUT(',NEW_LINE');
  DBMS_OUTPUT.PUT(',GET_LINE');
  DBMS_OUTPUT.PUT(',GET_LINES等过程');
  DBMS_OUTPUT.NEW_LINE; --在文本最后加上换行符     
  DBMS_OUTPUT.GET_LINES(v_lines, v_status); --获取缓冲区中所有的行
  FOR i IN 1 .. v_status LOOP
    DBMS_OUTPUT.PUT_LINE(v_lines(i)); --输出集合中所有的数据行
  END LOOP;
END;
/

--DBMS_PIPE是什么鬼

DECLARE
   v_ename emp.ename%TYPE;
   v_sal emp.sal%TYPE;
   v_rowid ROWID;
   v_empno emp.empno%TYPE:=&empno;
BEGIN
   SELECT rowid,ename,sal INTO v_rowid,v_rowid,v_sal FROM emp WHERE empno=v_empno;
   DBMS_PIPE.pack_message('员工编号：'||v_empno||' 员工名称：'||v_ename);
   DBMS_PIPE.pack_message('员工薪资：'||v_sal||' ROWID值：'||v_rowid);
END;
/


DECLARE 
   v_sendflag INT;                                          --发送标识变量
BEGIN
   v_sendflag:=DBMS_PIPE.send_message('PUBLIC_PIPE');    --向管道发送消息，如果管道不存在则创建管道
   IF v_sendflag=0 THEN
      DBMS_OUTPUT.PUT_LINE('消息成功发送到管道');        --如果消息成功发送，则提示成功消息
   END IF;
END;



DECLARE 
   v_receiveflag INT;                                              --接收标识变量
BEGIN
   v_receiveflag:=DBMS_PIPE.receive_message('PUBLIC_PIPE');    --从管道接收消息，如果管道不存在则创建管道
   IF v_receiveflag=0 THEN
      DBMS_OUTPUT.PUT_LINE('成功的从管道中获取消息');           --如果消息成功接收，则提示成功消息
   END IF;
END;


DECLARE
   v_message VARCHAR2(100);
BEGIN
   DBMS_PIPE.unpack_message(v_message); --将缓冲区的内容写入到变量
   DBMS_OUTPUT.PUT_LINE(message);       --显示缓冲区的内容
END;




--发送管道消息
CREATE OR REPLACE PROCEDURE send_pipe_message(pipename VARCHAR2,message VARCHAR2)
IS
   flag INT;
BEGIN
   flag:=DBMS_PIPE.create_pipe(pipename);           --创建管道
   if flag=0 THEN                                      --如果管道创建成功
      DBMS_PIPE.pack_message(message);              --将消息写到本地缓冲区
      flag:=DBMS_PIPE.send_message(pipename);       --将本地缓冲区中的消息发送到管道
   END IF;
END;
--从管道中接收消息
CREATE OR REPLACE PROCEDURE receive_pipe_message(pipename VARCHAR2,message VARCHAR2)
IS
   flag INT;
BEGIN
   falg:=DBMS_PIPE.receive_message(pipename);  --从管道中获取消息，保存到缓冲区
   IF flag=0 THEN
      DBMS_PIPE.unpack_message(message);       --从缓冲区读取消息
      flag:=DBMS_PIPE.remove_pipe(pipename);    --移除管道
   END IF;
END;



DECLARE
   v_alertname   VARCHAR2 (30)  := 'alert_demo';    --报警名称
   v_status      INTEGER;                           --等待状态
   v_msg         VARCHAR2 (200);                    --报警消息
BEGIN
    --注册报警，指定报警名为alert_demo
   DBMS_ALERT.REGISTER (v_alertname);
   --监听报警，等待报警发生
   DBMS_ALERT.waitone (v_alertname, v_msg, v_status);
   --如果不返回0，表示报警示败
   IF v_status != 0
   THEN
      DBMS_OUTPUT.put_line ('error');        --显示错误消息
   END IF;
   DBMS_OUTPUT.put_line (v_msg);             --显示报警消息
END;



DECLARE
   v_alertname   VARCHAR2 (30) := 'alert_demo';
BEGIN
    --向报警alert_demo发送报警信息
   DBMS_ALERT.signal (v_alertname, 'dbms_alert测试!');
   COMMIT;             --触发报警，如果是ROLLBACK，则不触发报警。
END;




DECLARE
   v_jobno   NUMBER;
BEGIN
   DBMS_JOB.submit
        (v_jobno,                             --作业编号
          --作业执行的过程
         'DBMS_DDL.analyze_object(''TABLE'',''SCOTT'',''EMP'',''COMPUTE'');',
         --下一次执行的日期         
         SYSDATE,
         --执行的时间间隔，表示24小时。
         'SYSDATE+1'
        );  
   DBMS_OUTPUT.put_line('获取的作业编号为：'||v_jobno);  --输出作业编号
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

