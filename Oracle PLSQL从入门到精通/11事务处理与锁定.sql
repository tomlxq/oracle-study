/*
ACID
由于事务处理要求事务内数据操作的一致性，因此事务处理必须满足事务处理的acid,即原子性，一致性，隔离性和持久性
原子性：　事务必须是原子处理单位，对于数据的修改，要么全部执行，要么全部不执行。
一致性：　事务在完成性，必须使所有的数据都保持一致状态，即所有的数据都要发生更改，以确保数据的完整性。
隔离性：　２个事务的执行是互不干扰的，一个事务不可能看到其它事务运行时，中间某一时刻的数据。
持久性：  一旦事务被提交之后，数据库的变化就会被永久的保留下来，即使运行数据库软件的机器后来崩溃也是如此。
*/

DECLARE
   dept_no   NUMBER (2) := 70;
BEGIN
   --开始事务
   INSERT INTO dept 
        VALUES (dept_no, '市场部', '北京');               --插入部门记录
   INSERT INTO emp                                        --插入员工记录
        VALUES (7997, '威尔', '销售人员', NULL, TRUNC (SYSDATE), 5000,300, dept_no);
   --提交事务
   COMMIT;
END;

DELETE FROM emp WHERE deptno=70;
DELETE FROM dept WHERE deptno=70;
COMMIT;

SELECT * FROM dept;
SELECT * FROM emp;

--事务回滚 ORA-00001: 违反唯一约束条件 (SCOTT.PK_DEPT)
DECLARE
  v_deptno NUMBER(2) := 70;
BEGIN
  INSERT INTO scott.dept VALUES (v_deptno, '开发部', '深圳');
  INSERT INTO scott.dept VALUES (v_deptno, '扩展部', '广州');
  INSERT INTO scott.emp
  VALUES
    (9003, '韩妹妹', 'clerk', 7566, SYSDATE, 7500, NULL, 30);
EXCEPTION
  WHEN dup_val_on_index THEN
    dbms_output.put_line(SQLERRM);
    ROLLBACK;
END;

--事务回滚点
DECLARE
  v_deptno NUMBER(2) := 70;
BEGIN
  INSERT INTO scott.dept VALUES (v_deptno, '开发部', '深圳');
  SAVEPOINT a;
  INSERT INTO scott.emp
  VALUES
    (9003, '韩妹妹', 'clerk', 7566, SYSDATE, 7500, NULL, 30);
  SAVEPOINT b;
  INSERT INTO scott.dept VALUES (v_deptno, '扩展部', '广州');
  SAVEPOINT c;

EXCEPTION
  WHEN dup_val_on_index THEN
    dbms_output.put_line(SQLERRM);
    ROLLBACK TO b;
END;

SELECT * FROM dept;

DELETE FROM dept WHERE deptno=90;
COMMIT;

SELECT * FROM scott.emp;

DECLARE
  v_year1980 NUMBER(2);
  v_year1981 NUMBER(2);
  v_year1982 NUMBER(2);
BEGIN
  COMMIT;
  SET TRANSACTION READ ONLY NAME '统计80后的3年统计入职人数';
  SELECT COUNT(1)
    INTO v_year1980
    FROM scott.emp
   WHERE to_char(hiredate, 'yyyy') = '1980';
  SELECT COUNT(1)
    INTO v_year1981
    FROM scott.emp
   WHERE to_char(hiredate, 'yyyy') = '1981';
  SELECT COUNT(1)
    INTO v_year1982
    FROM scott.emp
   WHERE to_char(hiredate, 'yyyy') = '1982';
  COMMIT;
  dbms_output.put_line('1980年入职人数为：' || v_year1980);
  dbms_output.put_line('1981年入职人数为：' || v_year1981);
  dbms_output.put_line('1982年入职人数为：' || v_year1982);

END;


SELECT * FROM emp WHERE deptno=10 FOR UPDATE;
COMMIT;

SELECT * FROM emp WHERE deptno=10 FOR UPDATE NOWAIT;
COMMIT;
