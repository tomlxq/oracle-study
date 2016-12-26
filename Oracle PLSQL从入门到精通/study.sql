--PL/SQL块结构
DECLARE --可选
BEGIN --必须
EXCEPTION --可选
END--必须

--最简单样式
BEGIN
  NULL;
END;
/
BEGIN
  dbms_output.put_line('Hello,world!');
END;

--oracle中的注释
/*
子程序名：outputVar
功能描述：输出字符串
参数：p_var用于传入输入字符串
创建人：罗小强
创建时间：2016-12-23
历史版本：v1.0
*/
CREATE OR REPLACE PROCEDURE outputVar(p_var VARCHAR2) IS
BEGIN
  dbms_output.put_line(p_var);--p_var用于传入输入字符串
  END;
/
BEGIN
  outputVar('hello,world!');
  END;
/  
  

--变量名规范
DECLARE
  VAR-b VARCHAR2(30); --变量名不能含-
  VAR&b VARCHAR2(30); --变量名不能含连字符&
BEGIN
  NULL;
END;
/

--定义记录类型
DECLARE
  TYPE Emp_Info_Type IS RECORD(
    empName VARCHAR2(30),
    empJob VARCHAR2(30),
    empSal  NUMBER);
  Emp_Info Emp_Info_Type;
BEGIN
  SELECT e.ename,e.job, e.sal INTO Emp_Info FROM scott.emp e WHERE e.empno = &empNo;
  dbms_output.put_line(Emp_Info.empName || '的职位为'||Emp_Info.empJob||' 薪水为' || Emp_Info.empSal);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      dbms_output.put_line('记录没有找到');
END;

--定义各类变量
/*
1. PL/SQL定义标量变量不是用 TYPE v_CountLoop IS BINARY_INTEGER,而是v_CountLoop　BINARY_INTEGER;
2. v_date DATE NOT NULL DEFAULT SYSDATE; 后面不是default system,而是default sysdate
*/
DECLARE
  v_name      VARCHAR2(30);
  v_date      DATE NOT NULL DEFAULT SYSDATE;
  v_CountLoop BINARY_INTEGER;
  TYPE t_cur IS REF CURSOR;
  TYPE Emp_Info_Type IS RECORD(
    empName VARCHAR2(30),
    empJob  VARCHAR2(30),
    empSal  NUMBER);
  Emp_info Emp_Info_Type;
  salRadio CONSTANT NUMBER := 0.10;
BEGIN
  NULL;
END;
/


CREATE OR REPLACE PACKAGE tom_utils AS
  PROCEDURE drop_table(t_name VARCHAR2);
  PROCEDURE drop_fk(t_name VARCHAR2,fk_name VARCHAR2);
END tom_utils;
/
CREATE OR REPLACE PACKAGE BODY tom_utils AS
  PROCEDURE drop_table(t_name VARCHAR2) AS
  BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE ' || t_name;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END drop_table;
  
  PROCEDURE drop_fk(t_name VARCHAR2,fk_name VARCHAR2) AS
  BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE '||t_name||' DROP CONSTRAINT ' || fk_name;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END drop_fk;
END tom_utils;
/

BEGIN
tom_utils.drop_fk('T_EMP','fk_emp');
tom_utils.drop_fk('T_DEPT','fk_dept');
tom_utils.drop_table('T_EMP');
tom_utils.drop_table('T_DEPT');
END;
/

--创建员工列表
CREATE TABLE t_emp(
                         --员工列表的字段
                         emp_id NUMBER NOT NULL,
                         emp_name VARCHAR2(30) NOT NULL,
                         --english_name VARCHAR2(30) NULL,
                         --alias_name VARCHAR2(30) NULL,
                         age           NUMBER DEFAULT 18,
                         hiredate      DATE DEFAULT SYSDATE,
                         dept_id NUMBER NULL,
                         --员工列表的主键
                         CONSTRAINT pk_t_emp PRIMARY KEY(emp_id)); 
--创建部门表
CREATE TABLE t_dept(dept_id NUMBER NOT NULL,
                      dept_name VARCHAR2(30) NOT NULL,
                      --dept_desc VARCHAR2(50) NULL,
                      dept_mgr_id NUMBER NOT NULL,
                      CONSTRAINT pk_t_dept PRIMARY KEY(dept_id));
--为员工表增加部门表的外键
ALTER TABLE t_emp ADD(
CONSTRAINT fk_emp
FOREIGN KEY(dept_id)
REFERENCES t_dept(dept_id));

ALTER TABLE t_dept ADD(
CONSTRAINT fk_dept
FOREIGN KEY(dept_mgr_id)
REFERENCES t_emp(emp_id)
);
--插入财务部记录
INSERT INTO t_emp VALUES(100,'罗小强',35,to_date('2016-05-24','yyyy-mm-dd'),NULL);
INSERT INTO t_dept VALUES(50,'财务部',100); 
INSERT INTO t_emp VALUES(101,'周星星',35,to_date('2016-05-24','yyyy-mm-dd'),50);
INSERT INTO t_emp VALUES(102,'达叔',35,to_date('2010-04-24','yyyy-mm-dd'),50);
--插入开发部记录
INSERT INTO t_emp VALUES(103,'紫霞',27,to_date('2005-05-24','yyyy-mm-dd'),NULL);
INSERT INTO t_dept VALUES(51,'开发部',103); 
INSERT INTO t_emp 
SELECT 104,'林涛',20,to_date('2014-06-01','yyyy-mm-dd'),51 FROM dual UNION
SELECT 105,'李雷',22,to_date('2012-08-09','yyyy-mm-dd'),51 FROM dual UNION
SELECT 106,'Polly',27,to_date('2011-05-24','yyyy-mm-dd'),51 FROM dual UNION
SELECT 107,'托尼',29,to_date('2009-02-02','yyyy-mm-dd'),51 FROM dual;
--插入销售部记录
INSERT INTO t_emp VALUES(108,'汪涵',29,to_date('2000-05-24','yyyy-mm-dd'),NULL);
INSERT INTO t_dept VALUES(52,'销售部',108); 
INSERT INTO t_emp 
SELECT 109,'杜海涛',20,to_date('2003-04-01','yyyy-mm-dd'),52 FROM dual UNION
SELECT 110,'陈红',45,to_date('2005-06-09','yyyy-mm-dd'),52 FROM dual UNION
SELECT 111,'张艺谋',64,to_date('2007-08-09','yyyy-mm-dd'),52 FROM dual UNION
SELECT 112,'李冰冰',34,to_date('2005-08-06','yyyy-mm-dd'),52 FROM dual;
COMMIT;

SELECT * FROM t_emp;
SELECT * FROM t_dept;
--set serveroutput on
--块中操作记录
DECLARE
  v_emp_id   NUMBER := 113;
  v_emp_name VARCHAR2(30) := '李英爱';
  v_age      NUMBER := 35;
  v_hiredate DATE := to_date('2008-08-06', 'yyyy-mm-dd');
  v_dept_id  NUMBER := 50;
BEGIN
  UPDATE t_emp emp
     SET emp.emp_name = v_emp_name,
         emp.age      = v_age,
         emp.hiredate = v_hiredate,
         emp.dept_id  = v_dept_id
   WHERE emp.emp_id = v_emp_id;
  IF SQL%NOTFOUND THEN
    INSERT INTO t_emp
    VALUES
      (v_emp_id, v_emp_name, v_age, v_hiredate, v_dept_id);
      dbms_output.put_line('插入员工记录成功!');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('插入员工记录失败!');
END;
/

--块打印与换行
BEGIN
  dbms_output.put_line('今天的时间是:' || SYSDATE);
  dbms_output.put('今天是:');
  dbms_output.put_line(to_char(SYSDATE, 'DAY'));
  dbms_output.put('现在的时间是:');
  dbms_output.put_line(to_char(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'));
END;
/

SELECT ROWID,t.* FROM scott.emp t;
SELECT t.* FROM scott.emp t,scott.dept d WHERE t.deptno=d.deptno AND t.sal>1000;

--块中定义输入，处理异常
DECLARE
  v_name VARCHAR2(30);
  v_sal  VARCHAR2(30);
BEGIN
  SELECT t.ename, t.sal
    INTO v_name, v_sal
    FROM scott.emp t
   WHERE t.empno = &empno;
  IF SQL%FOUND THEN
    dbms_output.put_line('员工编号为: '||&empno||' 名字为: '||v_name || ' 工资:' || v_sal); 
  END IF;
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('没有找到记录');
END;
/


--定义SQL DDL 语句  Data Definition Language
DECLARE
v_sql VARCHAR2(200):='create table scott.BOOK(id number not null,book_name varchar2(50))';
BEGIN
  EXECUTE IMMEDIATE v_sql;
  END;
/
SELECT * FROM scott.book;
DROP TABLE scott.book;

--动态语句
SELECT * FROM scott.emp e WHERE e.empno=&EmpNo;
UPDATE scott.emp e SET e.sal=e.sal*1.2 WHERE e.empno=&EmpNo;
DELETE FROM scott.emp e WHERE e.empno=&EmpNo;
ROLLBACK;

--在块中创建表，插入数据，查询数据
/*
错误的地方
1. 在动态语句的SQL中，不能用:=book_id 而是用=:book_id
2. 执行ＳＱＬ时， EXECUTE IMMEDIATE v_sql INTO v_id, v_name, v_price;后面要加using &1表示要输入的参数
3. 确保动态的sql里的语句是对的如DROP TABLE TABLE book，要写成DROP TABLE book
*/
DECLARE
  v_sql   VARCHAR2(300);
  v_id    NUMBER;
  v_name  VARCHAR2(30);
  v_price NUMBER;
BEGIN
  BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE book';
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
  END;
  v_sql := 'create table book(id number not null primary key,book_name varchar2(30),book_price number)';
  EXECUTE IMMEDIATE v_sql;
  v_sql := 'insert into book values(1,''九因真经'',82.5)';
  EXECUTE IMMEDIATE v_sql;
  v_sql := 'select * from book where id=:book_id';
  EXECUTE IMMEDIATE v_sql INTO v_id, v_name, v_price USING &1;
  dbms_output.put_line('书的id:' || v_id || ' 书的名字: ' || v_name || ' 书的单价:' ||
                       v_price);
END;
/

--异常处理
/*
1. WHEN DATA_NOT_FOUND THEN  是NO_DATA_FOUND
2. 不要画蛇添足　EXIT WHEN SQL%NOTFOUND; 它只能用于循环中
*/
DECLARE
  v_name VARCHAR2(30);
BEGIN
  SELECT e.ename INTO v_name FROM scott.emp e WHERE e.empno = &EmpNo;
  --EXIT WHEN SQL%NOTFOUND; 
  dbms_output.put_line(v_name);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    dbms_output.put_line('没有找到记录');
  WHEN OTHERS THEN
    dbms_output.put_line('处理其它的异常');
END;
/

--写个存储过程，根据编号输出名字
CREATE OR REPLACE PROCEDURE scott.get_ename(p_no IN NUMBER) IS
  v_name scott.emp.ename%TYPE;
BEGIN
  SELECT t.ename INTO v_name FROM scott.emp t WHERE t.empno = p_no;
  dbms_output.put_line('员工编号为: ' || p_no || ' 名字为: ' || v_name);
EXCEPTION
  WHEN no_data_found THEN
    dbms_output.put_line('没有找到记录');
  WHEN OTHERS THEN
    RAISE;
END get_ename;
/

BEGIN
  scott.get_ename(30);
  scott.get_ename(7369);
END;
/
SELECT DISTINCT e.job FROM scott.emp e;

--创建一个函数，返回加工资的幅度
--错误的地方：　1. else if=>elsif  2. return 类型后面是 AS 3. 没有declare
CREATE OR REPLACE FUNCTION GetAddSalaryRatio(p_job VARCHAR2) RETURN NUMBER AS
  v_ret NUMBER(7, 2);
BEGIN
  v_ret := 0;
  IF p_job = 'CLERK' THEN
    v_ret := 0.1;
  ELSIF p_job = 'SALESMAN' THEN
    v_ret := 0.12;
  ELSIF p_job = 'MANAGER' THEN
    v_ret := 0.15;
  END IF;
  RETURN v_ret;
END;

SELECT GetAddSalaryRatio('SALESMAN') FROM dual;

  --员工加工资幅度case版本
  --function 一定要有function   顶格的/，表示提交当前的代码
  CREATE OR REPLACE FUNCTION GetAddSalaryRatioCase(p_job VARCHAR2)
  RETURN NUMBER AS
  v_ret NUMBER(7, 2);
BEGIN
  v_ret := 0;
  CASE p_job
    WHEN 'CLERK' THEN
      v_ret := 0.1;
    WHEN 'SALESMAN' THEN
      v_ret := 0.12;
    WHEN 'MANAGER' THEN
      v_ret := 0.15;
    ELSE
      v_ret := 0;
  END CASE;
  RETURN v_ret;
END GetAddSalaryRatioCase;
/
BEGIN
  dbms_output.put_line(GetAddSalaryRatioCase('MANAGER'));
  END;
--创建一个存储过程，里面有带参的游标，如果工资增长幅度不为０，则更新该员工工资
--错误不知如何处理
SELECT * FROM scott.emp e;
CREATE OR REPLACE PROCEDURE UpdateEmpSal(p_empNo IN NUMBER) IS
  CURSOR v_cur(v_empNo NUMBER) IS
    SELECT * FROM scott.emp e WHERE e.empno = v_empNo;
  v_emp    scott.emp%ROWTYPE;
  v_newSal scott.emp.sal%TYPE;
BEGIN
  OPEN v_cur(p_empNo);
  FETCH v_cur
    INTO v_emp;
  v_newSal := GetAddSalaryRatio(v_emp.job);
  CLOSE v_cur;
  IF v_newSal <> 0 THEN
    UPDATE scott.emp e
       SET e.sal =
           (1 + v_newSal) * e.sal
     WHERE e.empno = p_empNo;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END UpdateEmpSal;

BEGIN
  UpdateEmpSal(7369);
  UpdateEmpSal(1);
END;

--块中的游标与索引表
/*错误的地方 
1. index by binary_integer   
2. 不是　for i in xxx, FOR i IN  1..empNameList.count 
3.  列表中取值不是empNameList[i] 而是empNameList(i)
*/
DECLARE
  TYPE Emp_Table IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
  empNameList Emp_Table;
  CURSOR v_cur IS
    SELECT e.ename FROM scott.emp e;
BEGIN
  OPEN v_cur;
  --从员工表中取出所有员工的名字
  FETCH v_cur BULK COLLECT
    INTO empNameList;
  CLOSE v_cur;
  FOR i IN 1 .. empNameList.count LOOP
    dbms_output.put_line('用户名为: ' || empNameList(i));
  END LOOP;
END;
/

--loop用法
/*
错误的地方
1. 游标里没有加FOR UPDATE;  如果加了FOR UPDATE;下面可以用
更新可以不用WHERE e.empno = v_EmpNo;　用where current of 游标
2. EXIT WHEN v_cur%NOTFOUND;  特别注意 游标%NOTFOUND
*/
DECLARE
  CURSOR v_cur IS
    SELECT e.empno, e.ename, e.sal, e.job FROM scott.emp e FOR UPDATE;
  v_EmpNo   NUMBER;
  v_EmpName VARCHAR2(30);
  v_EmpSal  NUMBER;
  v_EmpJob  VARCHAR2(30);
  v_radio   NUMBER := 0;
BEGIN
  OPEN v_cur;
  LOOP
    FETCH v_cur
      INTO v_EmpNo, v_EmpName, v_EmpSal, v_EmpJob;
    EXIT WHEN v_cur%NOTFOUND;
    v_radio := GetAddSalaryRatioCase(v_EmpJob);
    UPDATE scott.emp e
       SET e.sal = e.sal * (1 + v_radio)
     --WHERE e.empno = v_EmpNo;
     WHERE CURRENT OF v_cur;
    dbms_output.put_line('成功为' || v_EmpName || '加薪，薪水为' ||
                         v_EmpSal * (1 + v_radio));
  END LOOP;
  CLOSE v_cur;
END;


--for循环打印九九表
/*
错误的地方
1. RPAD　不够在右边填充空格
2.
制表符 chr(9) 
换行符 chr(10)
回车符 chr(13)
*/
DECLARE
  v_var1 NUMBER;
  v_var2 NUMBER;
BEGIN
  FOR v_var1 IN 1 .. 9 LOOP
    FOR v_var2 IN 1 .. v_var1 LOOP
      dbms_output.put(v_var1 || '*' || v_var2 || '=' ||
                      RPAD(v_var1 * v_var2, 2) || chr(9));
    END LOOP;
    dbms_output.put_line(' ');
  END LOOP;
END;
/

SELECT DISTINCT e.job FROM scott.emp e;
--分支结构
DECLARE
  v_clerk_radio    CONSTANT NUMBER := 0.1;
  v_salesman_radio CONSTANT NUMBER := 0.12;
  v_manager_radio  CONSTANT NUMBER := 0.1;
  v_job VARCHAR2(30);
BEGIN
  SELECT e.job INTO v_job FROM scott.emp e WHERE e.empno = &EmpNo;
  IF v_job = 'CLERK' THEN
    UPDATE scott.emp e
       SET e.sal = e.sal * (1 + v_clerk_radio)
     WHERE e.empno = &EmpNo;
  ELSIF v_job = 'SALESMAN' THEN
    UPDATE scott.emp e
       SET e.sal = e.sal * (1 + v_salesman_radio)
     WHERE e.empno = &EmpNo;
  ELSIF v_job = 'MANAGER' THEN
    UPDATE scott.emp e
       SET e.sal = e.sal * (1 + v_manager_radio)
     WHERE e.empno = &EmpNo;
  END IF;
  dbms_output.put_line('己成功为职员' || &EmpNo || '加薪了');
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    dbms_output.put_line('没有该记录');
END;

/*
错误的地方
1. 游标没有锁定　for update
2. 更新时不再使用员工编号，而是用游标来更新WHERE CURRENT OF v_cur;
*/
--循环结构
DECLARE
  c_clerk_radio    CONSTANT NUMBER := 0.10;
  c_salesman_radio CONSTANT NUMBER := 0.12;
  c_manager_radio  CONSTANT NUMBER := 0.15;
  CURSOR v_cur IS
    SELECT e.ename, e.sal, e.job FROM scott.emp e FOR UPDATE;
  v_name VARCHAR2(30);
  v_job  VARCHAR2(30);
  v_sal  NUMBER;
BEGIN
  OPEN v_cur;
  LOOP
    FETCH v_cur
      INTO v_name, v_sal, v_job;
    EXIT WHEN v_cur%NOTFOUND;
    IF v_job = 'CLERK' THEN
      UPDATE scott.emp e
         SET e.sal = e.sal * (1 + c_clerk_radio)
       WHERE CURRENT OF v_cur;
    ELSIF v_job = 'SALESMAN' THEN
      UPDATE scott.emp e
         SET e.sal = e.sal * (1 + c_salesman_radio)
       WHERE CURRENT OF v_cur;
    ELSIF v_job = 'MANAGER' THEN
      UPDATE scott.emp e
         SET e.sal = e.sal * (1 + c_manager_radio)
       WHERE CURRENT OF v_cur;
    END IF;
    dbms_output.put_line('己成功为员工' || v_name || '加薪了');
  END LOOP;
  CLOSE v_cur;
EXCEPTION
  WHEN no_data_found THEN
    dbms_output.put_line('没有找到员工信息');
END;

--面向对象编程
/*
错误的地方
1. AS OBJECT AS 后面没有名称只有(..)
2. 面面的FUNCTION addSal(sal NUMBER) RETURN NUMBER在前面要加member
3. CREATE OR REPLACE TYPE BODY emp_obj IS 不是is,是as 
4. FUNCTION addSal(sal NUMBER) RETURN NUMBER　的前面都要加 member
5. type里每个属性后面不能用;而是用,
6. type body里不能有()
7. 结尾要有end; 如 create or replace type body xxx as ... end;
*/
SELECT * FROM scott.emp e;
DROP TYPE emp_obj;
CREATE OR REPLACE TYPE emp_obj AS OBJECT
(
  EmpNo       NUMBER,
  EmpName     VARCHAR2(30),
  EmpJob      VARCHAR2(30),
  EmpMgr      VARCHAR2(30),
  EmpHireDate VARCHAR2(30),
  EmpSale     VARCHAR2(30),
  EmpComm     NUMBER,
  DeptNo      NUMBER,
  MEMBER FUNCTION addSal1(sal NUMBER, radio NUMBER) RETURN NUMBER,
  MEMBER PROCEDURE addSal(radio NUMBER)
)
;
CREATE OR REPLACE TYPE BODY emp_obj AS
  MEMBER FUNCTION addSal1(sal NUMBER, radio NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN sal * radio;
  END;
  MEMBER PROCEDURE addSal(radio NUMBER) AS
  BEGIN
    EmpSale := EmpSale * 1.1;
  END;
END;
--以emp_obj为类型创建表
DROP TABLE emp_obj_tab;
CREATE TABLE emp_obj_tab OF emp_obj;
SELECT * FROM emp_obj_tab;

--创建为员工加薪存储过程
/*
错误的地方
1. EXIT;必须在一个循环中才能使用
*/
CREATE OR REPLACE PROCEDURE AddEmpSalary(p_radio NUMBER, p_empno NUMBER) AS
BEGIN
  IF p_radio > 0 THEN
    UPDATE scott.emp e
       SET e.sal = e.sal * (1 + p_radio)
     WHERE e.empno = p_empno;
    dbms_output.put_line('成功为员工' || p_empno || '加薪了');
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    dbms_output.put_line('没有的找到员工记录');
END;

BEGIN
  AddEmpSalary(-5.6, 10);
  AddEmpSalary(1.1, 7369);
  AddEmpSalary(1.1, 11);
END;
/

--定义一个行触发器来记录工员工次的变化
/*
1. AFTER UPDATE ON sal OF scott.emp是 of sal on scott.emp
2. 不要使用OLD :sal，是:old.xxxx 特别注里new.xxx,old.xxx是　　after update of 表　on xxx里对应的字段
3. dbms_output.put_line(SQLERRM);是SQLERRM　不是 syserrm
*/

CREATE TABLE RaiseEmpSalLog(
empNo NUMBER,
empName VARCHAR2(30),
orginalSal NUMBER,
newSal NUMBER,
modifyDate DATE DEFAULT SYSDATE
);
CREATE OR REPLACE TRIGGER RaiseEmpSalTrigger
  AFTER UPDATE OF sal ON scott.emp
  FOR EACH ROW
DECLARE
  v_count NUMBER;
BEGIN
  SELECT COUNT(1)
    INTO v_count
    FROM RaiseEmpSalLog res
   WHERE res.empNo = :old.empno;
  IF v_count > 0 THEN
    UPDATE RaiseEmpSalLog res
       SET res.orginalsal = :old.sal, res.newSal = :new.sal,res.modifyDate = SYSDATE
     WHERE res.empNo = :old.empno;
  ELSE
    INSERT INTO RaiseEmpSalLog(empNo,empName,orginalSal,newSal)
    VALUES
      (:old.empno, :old.ename, :old.sal,:new.sal);
  END IF;
  EXCEPTION 
    WHEN OTHERS THEN
      dbms_output.put_line(SQLERRM);
END;
SELECT * FROM scott.emp;
UPDATE scott.emp e SET e.sal=e.sal*1.2 WHERE e.empno=7499;
UPDATE scott.emp e SET e.sal=e.sal*1.2 WHERE e.empno=1111;
SELECT * FROM RaiseEmpSalLog;
/*
 1. 不要用OTHERS v_radio := 2.0，是else
 case xx
   when xx then 
     ...
   else
     xxx
  end case;
2. CREATE OR REPLACE PACKAGE BODY EmpSalaryUtil AS　存储过程后是as
3.   FUNCTION getRadio(p_job VARCHAR2) RETURN NUMBER AS 函数后也是AS   
*/
--包规范定义
CREATE OR REPLACE PACKAGE EmpSalaryUtil AS
  PROCEDURE addEmpSalary(p_empno NUMBER, p_radio NUMBER);
  FUNCTION getRadio(p_job VARCHAR2) RETURN NUMBER;
  FUNCTION getRadioCase(p_job VARCHAR2) RETURN NUMBER;
END EmpSalaryUtil;
/
--包体定义
SELECT DISTINCT e.job FROM scott.emp e;
CREATE OR REPLACE PACKAGE BODY EmpSalaryUtil AS
  PROCEDURE addEmpSalary(p_empno NUMBER, p_radio NUMBER) AS
  BEGIN
    IF p_radio > 0 THEN
      UPDATE scott.emp e
         SET e.sal = e.sal * (1 + p_radio)
       WHERE e.empno = p_empno;
      dbms_output.put_line('成功为' || p_empno || '加薪了');
    END IF;
  END;
  FUNCTION getRadio(p_job VARCHAR2) RETURN NUMBER AS
    v_radio NUMBER(7, 2);
  BEGIN
    v_radio := 0;
    IF p_job = 'CLERK' THEN
      v_radio := 0.1;
    ELSIF p_job = 'SALESMAN' THEN
      v_radio := 0.12;
    ELSIF p_job = 'MANAGER' THEN
      v_radio := 0.15;
    END IF;
    RETURN v_radio;
  END;
  FUNCTION getRadioCase(p_job VARCHAR2) RETURN NUMBER AS
    v_radio NUMBER(7, 2) := 0;
  BEGIN
    CASE p_job
      WHEN 'CLERK' THEN
        v_radio := 0.1;
      WHEN 'SALESMAN' THEN
        v_radio := 0.12;
      WHEN 'MANAGER' THEN
        v_radio := 0.15;
      ELSE
        v_radio := 2.0;
    END CASE;
    RETURN v_radio;
  END;
END EmpSalaryUtil;
/
SELECT * FROM scott.emp e;
BEGIN
  EmpSalaryUtil.addEmpSalary(7499, 0.1);
  DBMS_OUTPUT.put_line(EmpSalaryUtil.getRadio('CLERK'));
  DBMS_OUTPUT.put_line(EmpSalaryUtil.getRadio('PRESIDENT'));
  DBMS_OUTPUT.put_line(EmpSalaryUtil.getRadio('MANAGER'));
  DBMS_OUTPUT.put_line(EmpSalaryUtil.getRadio('SALESMAN'));
  DBMS_OUTPUT.put_line(EmpSalaryUtil.getRadioCase('CLERK'));
  DBMS_OUTPUT.put_line(EmpSalaryUtil.getRadioCase('PRESIDENT'));
  DBMS_OUTPUT.put_line(EmpSalaryUtil.getRadioCase('MANAGER'));
  DBMS_OUTPUT.put_line(EmpSalaryUtil.getRadioCase('SALESMAN'));
END;
/
