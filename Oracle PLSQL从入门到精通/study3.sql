--变量声明
DECLARE
  v_ename    VARCHAR2(20);
  v_hiredate DATE NOT NULL := SYSDATE;
  v_empNo    NUMBER NOT NULL DEFAULT 7987;
BEGIN
  NULL;
END;
--变量赋值
DECLARE
  v_counter NUMBER;
BEGIN
  v_counter := 0;
  v_counter := v_counter + 1;
  dbms_output.put_line('计数器的数字为:' || v_counter);
END;
--数字赋值
DECLARE
  v_sal      NUMBER(7, 2);
  v_radio    NUMBER(7, 2) := 0.12;
  v_base_sal NUMBER(7, 2) := 1200.00;
BEGIN
  v_sal := v_base_sal * (1 + v_radio);
  dbms_output.put_line('员工工资为' || v_sal);
END;
--日期赋值
DECLARE
  v_string    VARCHAR2(200);
  v_boolean   BOOLEAN;
  v_hire_date DATE;
BEGIN
  v_string    := 'hello,world';
  v_boolean   := TRUE;
  v_hire_date := SYSDATE;
  v_hire_date := to_date('2015-07-08', 'yyyy-mm-dd');
  v_hire_date := DATE '2015-06-07'; --直接静态值赋值
  dbms_output.put_line('员工入职日期为' || v_hire_date);
END;
/
--Explain plan按钮（即执行计划），或者直接按F5
--按F8键，PL/SQL Developer默认是执行该窗口的所有SQL语句，需要设置为鼠标所在的那条SQL语句，即执行当前SQL语句；
--执行单条SQL语句 在使用 PL/SQL Developer的SQL Window时，按F8键，PL/SQL Developer默认是执行该窗口的所有SQL语句，需要设置为鼠标所在的那条SQL语句，即执行当前SQL语句；
--设置方法：PL/SQL Developer -->tools->Preferences-->Window types-->SQL Window ，勾上“AutoSelect Statement” 即可。
SELECT * FROM scott.emp;

--%type赋值与%rowtype
DECLARE
  v_name    scott.emp.ename%TYPE;
  v_name1   v_name%TYPE;
  v_salary  scott.emp.sal%TYPE;
  v_salary1 v_salary%TYPE;
  v_emp     scott.emp%ROWTYPE;
BEGIN
  SELECT * INTO v_emp FROM scott.emp WHERE emp.empno = &empno;
  dbms_output.put_line('员工的名字为' || v_emp.ename || CHR(10) || '员工的薪水为' ||
                       v_emp.sal);
END;
/

SELECT TRIM(SYSDATE),MIN(SYSDATE) FROM dual;

--子类型
/*
1. 不要少了is!!! SUBTYPE st_count IS INTEGER;
*/
DECLARE
  SUBTYPE st_count IS INTEGER;
  v_count st_count;
BEGIN
  SELECT COUNT(1) INTO v_count FROM scott.emp;
  dbms_output.put_line('共有员工' || v_count);
END;
/

--时间戳变量
/*
错误的教训:
1. 是WITH TIME ZONE;不是with timezone
*/
DECLARE
  v_time1 TIMESTAMP;
  v_time2 TIMESTAMP WITH TIME ZONE;
BEGIN
  v_time1 := SYSDATE;
  v_time2 := SYSDATE;
  dbms_output.put_line(v_time1);
  dbms_output.put_line(v_time2);
END;
/
SELECT SESSIONTIMEZONE FROM dual;
SELECT * FROM v$timezone_names;

--游标类型
DECLARE
  CURSOR v_cur IS
    SELECT * FROM scott.emp;
  v_emp scott.emp%ROWTYPE;
BEGIN
  OPEN v_cur;
  LOOP
    FETCH v_cur
      INTO v_emp;
    EXIT WHEN v_cur%NOTFOUND;
    dbms_output.put_line('员工的名字' || v_emp.ename || CHR(10) || '员工的工资' ||
                         v_emp.sal);
  END LOOP;
EXCEPTION
  WHEN no_data_found THEN
    dbms_output.put_line('没有找到记录');
  WHEN OTHERS THEN
    dbms_output.put_line(SQLERRM);
END;
  
--列类型插入一条数据
SELECT * FROM scott.emp;
/*
错误的教训:
1. ORA-06502: PL/SQL: 数字或值错误 :  字符串缓冲区太小
v_emp.job      := '软件工程师';  job VARCHAR2(9)
2. 赋值一定要用:=,不要只用=
*/
DECLARE
  v_emp emp%ROWTYPE;
BEGIN
  v_emp.empno    := 9000;
  v_emp.ename    := '罗小强';
  v_emp.job      := 'manager';
  v_emp.mgr      := 7369;
  v_emp.hiredate := DATE '2016-05-24';
  v_emp.sal      := 6000;
  v_emp.deptno   := 20;
  INSERT INTO emp VALUES v_emp;
  EXCEPTION 
    WHEN OTHERS THEN
      dbms_output.put_line(SQLERRM);
END;
/
 --引用游标　
/*

1. system_ref要用sys_refcursor
2.v_cur IS SELECT * FROM scott.emp; 要用 OPEN  v_cur  FOR SELECT * FROM scott.emp;
3.RETURN v_cur后一定要加分号
4.FETCH v_cur INTO v_emp; 后是对v_emp.xxx取属性值，而不是游标v_cur
*/
CREATE OR REPLACE FUNCTION getEmpCurRef RETURN SYS_REFCURSOR AS
  v_cur SYS_REFCURSOR;
BEGIN
  OPEN v_cur FOR
    SELECT * FROM scott.emp;
  RETURN v_cur;
END;
/

DECLARE
  v_cur SYS_REFCURSOR;
  v_emp scott.emp%ROWTYPE;
BEGIN
  v_cur := getEmpCurRef;
  LOOP
    FETCH v_cur
      INTO v_emp;
    EXIT WHEN v_cur%NOTFOUND;
    dbms_output.put_line('员工的名字为' || v_emp.ename || CHR(10) || '员工的薪水为' ||
                         v_emp.sal);
  END LOOP;
END;

--rowid
SELECT rowidtochar(ROWID),e.* FROM scott.emp e;


  
