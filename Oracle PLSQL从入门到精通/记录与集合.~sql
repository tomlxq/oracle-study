SELECT * FROM emp;
DROP TABLE emp_copy;
CREATE TABLE emp_copy AS SELECT * FROM emp WHERE 1<>1;
--使用变量来插入一条记录
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
  dbms_output.put_line('用户名：' || v_ename);
  INSERT INTO emp_copy
  VALUES
    (v_empno, v_ename, v_job, v_mgr, v_hiredate, v_sal, v_comm, v_deptno);
    EXCEPTION 
      WHEN OTHERS THEN
      NULL;
END;
SELECT * FROM emp_copy;
--使用记录类型来插入一条记录
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
  dbms_output.put_line('用户名：' || v_emp_info.ename);
  INSERT INTO emp_copy VALUES v_emp_info;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;

--记录的类型的初始值及赋值
DECLARE
  TYPE t_emp IS RECORD(
    empno   NUMBER := 7902,
    ename    VARCHAR2(30),
    sal      NUMBER NOT NULL DEFAULT 0,
    hiredate DATE DEFAULT SYSDATE);
  v_emp t_emp;
BEGIN
  v_emp.empno   := 7788;
  v_emp.ename    := '罗小强';
  v_emp.sal      := 16000;
  v_emp.hiredate := to_date('2016-05-24', 'yyyy-mm-dd');
  --下面的语句输出empinfo记录的值
  DBMS_OUTPUT.PUT_LINE('员工名称：' || v_emp.ename);
  DBMS_OUTPUT.PUT_LINE('员工编号：' || v_emp.empno);
  DBMS_OUTPUT.PUT_LINE('雇佣日期：' || TO_CHAR(v_emp.hiredate, 'YYYY-MM-DD'));
  DBMS_OUTPUT.PUT_LINE('员工薪资：' || v_emp.sal);
END;

--记录类型的直接赋值以及对其中的属性赋值
DECLARE
   --定义记录类型
   TYPE emp_rec IS RECORD (
      empno   NUMBER,
      ename   VARCHAR2 (20)
   );
   --定义与emp_rec具有相同成员的记录类型
   TYPE emp_rec_dept IS RECORD (
      empno   NUMBER,
      ename   VARCHAR2 (20)
   );
   --声明记录类型的变量
   emp_info1   emp_rec;
   emp_info2   emp_rec;
   emp_info3   emp_rec_dept;
   --定义一个内嵌过程用来输出记录信息
   PROCEDURE printrec (empinfo emp_rec)
   AS
   BEGIN
      DBMS_OUTPUT.put_line ('员工编号：' || empinfo.empno);
      DBMS_OUTPUT.put_line ('员工名称：' || empinfo.ename);
   END;
BEGIN
   emp_info1.empno := 7890;    --为emp_info1记录赋值
   emp_info1.ename := '张大千';
   DBMS_OUTPUT.put_line ('emp_info1的信息如下：');
   printrec (emp_info1);      --打印赋值后的emp_info1记录
   emp_info2 := emp_info1;    --将emp_info1记录变量直接赋给emp_info2
   DBMS_OUTPUT.put_line ('emp_info2的信息如下：');
   printrec (emp_info2);      --打印赋值后的emp_info2的记录
   --emp_info3:=emp_info1;    --此语句出现错误，不同记录类型的变量不能相互赋值
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
--记录类型插入数据库
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
  v_dept1.dname  := '质检部';
  v_dept1.loc    := '上海浦东';
  v_dept2.deptno := 70;
  v_dept2.dname  := '财务部';
  v_dept2.loc    := '广东中山';
  INSERT INTO dept VALUES v_dept1;
  INSERT INTO dept VALUES v_dept2;
  --记录类型删除
  DELETE FROM dept WHERE deptno= v_dept1.deptno;
  --记录类型更新
  v_dept2.dname:='产品部';
  UPDATE dept SET ROW=v_dept2 WHERE deptno= v_dept2.deptno;
END;

--记录类型返回受影响的行到记录
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
  v_dept1.dname := '售后服务';
  UPDATE dept
     SET ROW = v_dept1
   WHERE deptno = v_dept1.deptno
  RETURNING deptno, dname, loc INTO v_dept2;
  dbms_output.put_line('更新的部门为: ' || v_dept2.dname);

  v_dept1.deptno := 80;
  v_dept1.dname  := '维修部';
  INSERT INTO dept
  VALUES v_dept1
  RETURNING deptno, dname, loc INTO v_dept2;
  dbms_output.put_line('新增的部门为: ' || v_dept2.dname);

  DELETE FROM dept
   WHERE deptno = v_dept1.deptno
  RETURNING deptno, dname, loc INTO v_dept2;
  dbms_output.put_line('删除的部门为: ' || v_dept2.dname);
END;

--记录类型嵌套
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
  dbms_output.put_line('部门为: ' || v_emp.deptinfo.dname || CHR(10) ||
                       '名字为: ' || v_emp.ename);
END;

--索引表集合
SELECT * FROM dept;
SELECT * FROM emp;
--雇佣日期索引表集合
TYPE hiredate_idxt IS TABLE OF DATE INDEX BY PLS_INTEGER;
--部门编号的索引表集合
TYPE deptno_idxt IS TABLE OF dept.deptno%TYPE NOT NULL INDEX BY PLS_INTEGER;
--记录类型的索引表，pl/sql允许这个结构创建一个本地的副本
TYPE emp_idxt IS TABLE OF emp%ROWTYPE INDEX BY NATURAL;
--由部门名称标识的部门名称集合
TYPE dname_idxt IS TABLE OF dept%ROWTYPE INDEX BY dept.dname%TYPE;
--定义集合的集合
TYPE dname_idxt1 IS TABLE OF dname_idxt INDEX BY VARCHAR2(100);

--集合类型赋值
DECLARE
  TYPE test_idxt IS TABLE OF VARCHAR2(12) INDEX BY PLS_INTEGER;
  TYPE test_idxt1 IS TABLE OF NUMBER INDEX BY VARCHAR2(20);
  v_test  test_idxt;
  v_test1 test_idxt1;
BEGIN
  v_test(1) := '史太龙';
  v_test(40) := '阿妈';
  v_test(80) := '刘备';
  v_test(-50) := '董卓';
  v_test(70) := '李磊';
  IF v_test.exists(-50) THEN
    dbms_output.put_line('名字为: ' || v_test(-50));
  END IF;

  v_test1('史太龙') := 1;
  v_test1('阿妈') := 40;
  v_test1('刘备') := 80;
  v_test1('董卓') := -50;
  v_test1('李磊') := 70;
  IF v_test1.exists('李磊') THEN
    dbms_output.put_line('学号为: ' || v_test1('李磊'));
  END IF;
END;

--记录类型的索引表，以dname为索引键类型
--for循环不用打开关闭游标
DECLARE
  TYPE dept_idxt IS TABLE OF dept%ROWTYPE INDEX BY dept.dname%TYPE;
  v_dept dept_idxt;
  CURSOR dept_cur IS
    SELECT * FROM dept;
BEGIN
  FOR i IN dept_cur LOOP
    v_dept(i.dname) := i;
    dbms_output.put_line('名字为: ' || v_dept(i.dname).dname);
  END LOOP;
END;

--嵌套表
DECLARE
  TYPE dept_t IS TABLE OF dept%ROWTYPE;
  TYPE dname_t IS TABLE OF dept.dname%TYPE;
  TYPE deptno_t IS TABLE OF dept.deptno%TYPE;
  dname_info  dname_t := dname_t('娱乐', '金融');
  deptno_info deptno_t := deptno_t('78', '90');
BEGIN
  NULL;
END;

DECLARE
  TYPE deptno_t IS TABLE OF NUMBER;
  TYPE ename_t IS TABLE OF VARCHAR2(20);
  v_deptno deptno_t;
  v_ename  ename_t := ename_t('开发部', '测试部');
BEGIN
  dbms_output.put_line('部门为' || v_ename(1));
  dbms_output.put_line('部门为' || v_ename(2));
  --v_deptno.extend(5);
  v_deptno := deptno_t(NULL, NULL, NULL, NULL, NULL);
  FOR i IN 1 .. 5 LOOP
    v_deptno(i) := i * 10;
    dbms_output.put_line('部门编号为' || v_deptno(i));
  END LOOP;
  dbms_output.put_line('部门个数为' || v_deptno.count);
END;

--嵌套表类型
CREATE TYPE dname_list_t IS TABLE OF VARCHAR(30);
/

CREATE TABLE emp_info(
empno NUMBER,
ename VARCHAR2(30),
dnamelist dname_list_t
) NESTED TABLE dnamelist STORE AS emp_info_table;
/
--嵌套表的插入与更新
DECLARE
  v_dname_list dname_list_t := dname_list_t('学徒', '专家', '大师');
BEGIN
  INSERT INTO emp_info VALUES (1, '罗小强', v_dname_list);
  INSERT INTO emp_info
  VALUES
    (2, '汪涵', dname_list_t('央视', '湖南卫视', '四川电视'));
  SELECT dnamelist INTO v_dname_list FROM emp_info WHERE empno = 1;
  v_dname_list(1) := '大师兄';
  v_dname_list(2) := '二师兄';
  v_dname_list(3) := '三师兄';
  UPDATE emp_info SET dnamelist = v_dname_list WHERE empno = 1;
  SELECT dnamelist INTO v_dname_list FROM emp_info WHERE empno = 1;
  dbms_output.put_line('更新的部门' || v_dname_list(1));
END;
SELECT * FROM emp_info;


--变长数组
DECLARE
   TYPE projectlist IS VARRAY (50) OF VARCHAR2 (16);        --定义项目列表变长数组
   TYPE empno_type IS VARRAY (10) OF NUMBER (4);            --定义员工编号变长数组
   --声明变长数组类型的变量，并使用构造函数进行初始化
   project_list   projectlist := projectlist ('网站', 'ERP', 'CRM', 'CMS');
   empno_list     empno_type;                               --声明变长数组类型的变量
BEGIN
   DBMS_OUTPUT.put_line (project_list (3));              --输出第3个元素的值
   project_list.EXTEND;                                     --扩展到第5个元素
   project_list (5) := 'WORKFLOW';                          --为第5个元素赋值
   empno_list :=                                            --构造empno_list
      empno_type (7011, 7012, 7013, 7014, NULL, NULL, NULL, NULL, NULL, NULL);
   empno_list (9) := 8011;                                  --为第9个元素赋初值
   DBMS_OUTPUT.put_line (empno_list (9));                --输出第9个元素的值
END;

--创建一个变长数组的类型empname_varray_type，用来存储员工信息
CREATE OR REPLACE TYPE empname_varray_type IS VARRAY (20) OF VARCHAR2 (20);
/
CREATE TABLE dept_varray                  --创建部门数据表
(
   deptno NUMBER(2),                      --部门编号    
   dname VARCHAR2(20),                    --部门名称
   emplist empname_varray_type            --部门员工列表
);
DECLARE                                         --声明并初始化变长数组
   emp_list   empname_varray_type                          
                := empname_varray_type ('史密斯', '杰克', '汤姆', '丽沙', '简', '史太龙');
BEGIN
   INSERT INTO dept_varray
        VALUES (20, '维修组', emp_list);        --向表中插入变长数组数据
   INSERT INTO dept_varray                      --直接在INSERT语句中初始化变长数组数据
        VALUES (30, '机加工',
                empname_varray_type ('张三', '刘七', '赵五', '阿四', '阿五', '阿六'));
   SELECT emplist
     INTO emp_list
     FROM dept_varray
    WHERE deptno = 20;                          --使用SELECT语句从表中取出变长数组数据
   emp_list (1) := '杰克张';                    --更新变长数组数据的内容
   UPDATE dept_varray
      SET emplist = emp_list
    WHERE deptno = 20;                          --使用UPDATE语句更新变长数组数据
   DELETE FROM dept_varray
         WHERE deptno = 30;                     --删除记录并同时删除变长数组数据
END;
SELECT * FROM dept_varray;

--判断变长数组存不在在
DECLARE
   TYPE projectlist IS VARRAY (50) OF VARCHAR2 (16);   --定义项目列表变长数组
   project_list   projectlist := projectlist ('网站', 'ERP', 'CRM', 'CMS');
BEGIN
   IF project_list.EXISTS (5)                          --判断一个不存在的元素值
   THEN                                                --如果存在，则输出元素值
      DBMS_OUTPUT.put_line ('元素存在，其值为：' || project_list (5));
   ELSE
      DBMS_OUTPUT.put_line ('元素不存在');          --如果不存在，显示元素不存在    
   END IF;
END;
--变长数据个数，为有效个数
DECLARE
   TYPE emp_name_table IS TABLE OF VARCHAR2 (20);            --员工名称嵌套表
   TYPE deptno_table IS TABLE OF NUMBER (2);                 --部门编号嵌套表
   deptno_info     deptno_table;
   emp_name_info   emp_name_table := emp_name_table ('张小三', '李斯特');
BEGIN
   deptno_info:=deptno_table();                              --构造一个不包含任何元素的嵌套表
   deptno_info.EXTEND(5);                                    --扩展5个元素
   DBMS_OUTPUT.PUT_LINE('deptno_info的元素个数为：'||deptno_info.COUNT);
   DBMS_OUTPUT.PUT_LINE('emp_name_info的元素个数为：'||emp_name_info.COUNT);   
END;
--变长数组的上限值与个数
DECLARE
   TYPE projectlist IS VARRAY (50) OF VARCHAR2 (16);   --定义项目列表变长数组
   project_list   projectlist := projectlist ('网站', 'ERP', 'CRM', 'CMS');
BEGIN
   DBMS_OUTPUT.put_line ('变长数组的上限值为：' || project_list.LIMIT);
   project_list.EXTEND(8);
   DBMS_OUTPUT.put_line ('变长数组的当前个数为：' || project_list.COUNT);   
END;

--变长数组的第1个元素的下标、最后1个元素的下标
DECLARE
  TYPE projectlist IS VARRAY(50) OF VARCHAR2(16); --定义项目列表变长数组
  project_list projectlist := projectlist('网站', 'ERP', 'CRM', 'CMS');
BEGIN
  DBMS_OUTPUT.put_line('project_list的第1个元素下标：' || project_list.FIRST); --查看第1个元素的下标
  project_list.EXTEND(8); --扩展8个元素
  DBMS_OUTPUT.put_line('project_list的最后一个元素的下标：' || project_list.LAST); --查看最后1个元素的下标
END;
--索引表内置函数next、prior
DECLARE
  TYPE idx_table IS TABLE OF VARCHAR(12) INDEX BY PLS_INTEGER; --定义索引表类型
  v_emp idx_table; --定义索引表变量
  i     PLS_INTEGER; --定义循环控制变量
BEGIN
  v_emp(1) := '史密斯'; --随机的为索引表赋值
  v_emp(20) := '克拉克';
  v_emp(40) := '史瑞克';
  v_emp(-10) := '杰瑞';
  --获取集合中第-10个元素的下一个值
  DBMS_OUTPUT.put_line('第-10个元素的下一个值：' || v_emp(v_emp.NEXT(-10)));
  --获取集合中第40个元素的上一个值
  DBMS_OUTPUT.put_line('第40个元素的上一个值：' || v_emp(v_emp.PRIOR(40)));
  i := v_emp.FIRST; --定位到第1个元素的下标
  WHILE i IS NOT NULL --开始循环直到下标为NULL
   LOOP
    --输出元素的值
    DBMS_OUTPUT.put_line('v_emp(' || i || ')=' || v_emp(i));
    i := v_emp.NEXT(i); --向下移动循环指针，指向下一个下标
  END LOOP;
END;
--嵌套表内置函数DELETE\EXTEND\NEXT 获取第一个下标FIRST
DECLARE
  TYPE courselist IS TABLE OF VARCHAR2(10); --定义嵌套表
  --定义课程嵌套表变量
  courses courselist;
  i       PLS_INTEGER;
BEGIN
  courses := courselist('生物', '物理', '化学'); --初始化元素
  courses.DELETE(3); --删除第3个元素
  courses.EXTEND; --追加一个新的NULL元素
  courses(4) := '英语';
  courses.EXTEND(5, 1); --把第1个元素拷贝5份添加到末尾  
  i := courses.FIRST;
  WHILE i IS NOT NULL LOOP
    --循环显示结果值
    DBMS_OUTPUT.PUT_LINE('courses(' || i || ')=' || courses(i));
    i := courses.NEXT(i);
  END LOOP;
END;

DECLARE
   TYPE courselist IS TABLE OF VARCHAR2 (10);                --定义嵌套表
   --定义课程嵌套表变量
   courses   courselist;
   i PLS_INTEGER;
BEGIN
   courses := courselist ('生物', '物理', '化学','音乐','数学','地理');--初始化元素
   courses.TRIM(2);                                             --删除集合末尾的2个元素
   DBMS_OUTPUT.PUT_LINE('当前的元素个数：'||courses.COUNT);  --显示元素个数
   courses.EXTEND;                                             --扩展1个元素   
   courses(courses.COUNT):='语文';                             --为最后1个元素赋值
   courses.TRIM;                                               --删除集合末尾的最后1个元素 
   i:=courses.FIRST; 
   WHILE i IS NOT NULL LOOP                                  --循环显示结果值
      DBMS_OUTPUT.PUT_LINE('courses('||i||')='||courses(i));
      i:=courses.NEXT(i);
   END LOOP;
END;

DECLARE
   TYPE courselist IS TABLE OF VARCHAR2 (10);                --定义嵌套表
   --定义课程嵌套表变量
   courses   courselist;
   i PLS_INTEGER;
BEGIN
   courses := courselist ('生物', '物理', '化学','音乐','数学','地理');--初始化元素
   courses.DELETE(2);                                             --删除第2个元素
   DBMS_OUTPUT.PUT_LINE('当前的元素个数：'||courses.COUNT);    --显示元素个数
   courses.EXTEND;                                                --扩展1个元素  
   DBMS_OUTPUT.PUT_LINE('当前的元素个数：'||courses.COUNT);    --显示元素个数    
   courses(courses.LAST):='语文';                                 --为最后1个元素赋值
   courses.DELETE(4,courses.COUNT);                               --删除集合末尾的最后1个元素 
   i:=courses.FIRST; 
   WHILE i IS NOT NULL LOOP                                        --循环显示结果值
      DBMS_OUTPUT.PUT_LINE('courses('||i||')='||courses(i));
      i:=courses.NEXT(i);
   END LOOP;
END;

DECLARE
   TYPE numlist IS TABLE OF NUMBER;
   nums numlist;          --一个空的嵌套表
BEGIN
   nums(1):=1;        --未构造就使用表元素，将触发：ORA-06531:引用未初始化的收集
   nums:=numlist(1,2);--初始化嵌套表
   nums(NULL):=3;     --使用NULL索引键，将触发：ORA-06502:PL/SQL:数字或值错误:NULL索引表键值
   nums(0):=3;        --访问不存在的下标，将触发：ORA-06532:下标超出限制
   nums(3):=3;        --下标超过最大元素个数，将触发：ORA-06532:下标超出限制
   nums.DELETE(1);    --删除第1个元素
   IF nums(1)=1 THEN
      NULL;
       --因为第1个元素已被删除，再访问将触发：ORA-01403: 未找到任何数据
   END IF;
END;

DECLARE
  TYPE dept_type IS VARRAY(20) OF NUMBER; --定义嵌套表变量  
  depts dept_type := dept_type(10, 30, 70); --实例化嵌套表，分配3个元素
BEGIN
  FOR i IN depts.FIRST .. depts.LAST --循环嵌套表元素 
   LOOP
    DELETE FROM emp WHERE deptno = depts(i); --向SQL引擎发送SQL命令执行SQL操作
  END LOOP;
END;

DECLARE
  TYPE dept_type IS VARRAY(20) OF NUMBER; --定义嵌套表变量
  depts dept_type := dept_type(10, 30, 70); --实例化嵌套表，分配3个元素   
BEGIN
  FORALL i IN depts.FIRST .. depts.LAST --循环嵌套表元素
    DELETE FROM emp WHERE deptno = depts(i); --向SQL引擎发送SQL命令执行SQL操作
  FOR i IN 1 .. depts.COUNT LOOP
    DBMS_OUTPUT.put_line('部门编号' || depts(i) || '的删除操作受影响的行为：' ||
                         SQL%BULK_ROWCOUNT(i));
  END LOOP;
END;
--select .. bulk collect into .. from table
DECLARE
   TYPE numtab IS TABLE OF emp.empno%TYPE;     --员工编号嵌套表
   TYPE nametab IS TABLE OF emp.ename%TYPE;    --员工名称嵌套表
   nums    numtab;                             --定义嵌套表变量，不需要初始化        
   names   nametab;
BEGIN
   SELECT empno, ename
   BULK COLLECT INTO nums, names
     FROM emp;                                --从emp表中查出员工编号和名称，批量插入到集合
   FOR i IN 1 .. nums.COUNT                   --循环显示集合内容
   LOOP
      DBMS_OUTPUT.put ('num(' || i || ')=' || nums (i)||'   ');
      DBMS_OUTPUT.put_line ('names(' || i || ')=' || names (i));      
   END LOOP;
END;
