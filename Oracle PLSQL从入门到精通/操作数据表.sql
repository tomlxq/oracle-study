/*插入记录*/
SELECT * FROM emp;
--指定列插入
INSERT INTO emp
  (empno, ename, job, mgr, hiredate, sal, comm, deptno)
VALUES
  (7890,
   '刘七',
   '副理',
   7566,
   TO_DATE('2001-08-15', 'YYYY-MM-DD'),
   8000,
   300,
   20);
--不指定列，所有列要插入
INSERT INTO emp
VALUES
  (7891,
   '刘七',
   '副理',
   7566,
   TO_DATE('2001-08-15', 'YYYY-MM-DD'),
   8000,
   300,
   20);
--指定列插入，其它值使用用默认
INSERT INTO emp (empno, ename, deptno) VALUES (7892, '张八', 20);
SELECT * FROM emp WHERE empno = 7892;
--插入时如果有'，则用''代替
INSERT INTO emp (empno, ename, deptno) VALUES (7898, 'O''Malley', 20);

SELECT * FROM emp;
--插入时，可用null代替空值
INSERT INTO emp VALUES (7893, '霍九', NULL, NULL, NULL, NULL, NULL, 20);

INSERT INTO emp VALUES (7894, '霍十', '', NULL, '', NULL, NULL, 20);

INSERT INTO emp VALUES(7895, USER, NULL, NULL, TRUNC(SYSDATE), 3000, 200, 20);
SELECT * FROM emp WHERE empno = 7895;
--指量插入
DROP TABLE emp_copy;
CREATE TABLE emp_copy AS SELECT * FROM emp WHERE 1=2; 
INSERT INTO emp_copy
  SELECT * FROM emp WHERE deptno = 20;

SELECT * FROM emp;

INSERT INTO emp_copy
  SELECT * FROM emp WHERE deptno = 20;
--根据条件选择结果集插入匹配的列
INSERT INTO emp_copy
  (empno, ename, job, mgr, deptno)
  SELECT empno, ename, job, mgr, deptno FROM emp WHERE deptno = 30;
--根据条件插入不同的表
SELECT DISTINCT(e.deptno) FROM emp e;
CREATE TABLE emp_10 AS SELECT * FROM emp WHERE 1<>1; 
CREATE TABLE emp_20 AS SELECT * FROM emp WHERE 1<>1; 
CREATE TABLE emp_30 AS SELECT * FROM emp WHERE 1<>1; 
CREATE TABLE emp_other_copy AS SELECT * FROM emp WHERE 1<>1; 

INSERT FIRST 
WHEN deptno = 10 THEN 
  INTO emp_10 
WHEN deptno = 20 THEN 
  INTO emp_20 
WHEN deptno = 30 THEN 
  INTO emp_30 
ELSE 
  INTO emp_other_copy
SELECT * FROM emp;

SELECT * FROM emp_10;  
SELECT * FROM emp_20;  
SELECT * FROM emp_30;  
SELECT * FROM emp_other_copy;   
--指定域插入不同的表
TRUNCATE TABLE emp_10 ;
TRUNCATE TABLE emp_20 ;
TRUNCATE TABLE emp_30 ;
TRUNCATE TABLE emp_other_copy ;
INSERT FIRST WHEN deptno = 10 --如果部门编号为10
THEN INTO emp_10 --插入到emp_dept_10，使用VALUES指定字段
  (empno, ename, sal, deptno)
VALUES
  (empno, ename, sal, deptno) WHEN deptno = 20 --如果部门编号为20
THEN INTO emp_20 --插入到emp_dept_20，使用VALUES指定字段
  (empno, ename)
VALUES
  (empno, ename) WHEN deptno = 30 --如果部门编号为30
THEN INTO emp_30 --插入到emp_dept_30，使用VALUES指定字段
  (empno, ename, hiredate)
VALUES
  (empno, ename, hiredate) ELSE --如果部门编号即不为10、20或30
INTO emp_other_copy --插入到emp_copy，使用VALUES指定字段
  (empno, ename, deptno)
VALUES
  (empno, ename, deptno)
  SELECT * FROM emp; --指定插入子查询
SELECT * FROM emp_10;



SELECT * FROM emp; 
/*更新记录*/
UPDATE emp SET sal=3000 WHERE empno=7369;
UPDATE emp SET sal=3000,comm=200,mgr=7566 WHERE empno=7369;
SELECT * FROM emp;
SELECT AVG(y.sal) FROM emp y WHERE y.deptno=20;
--相关子查询更新
UPDATE emp x
   SET x.sal =
       (SELECT AVG(y.sal) FROM emp y WHERE y.deptno = x.deptno)
 WHERE x.empno = 7369;
 --相关子查询更新多个字段
 UPDATE emp x
    SET (x.sal, x.comm) =
        (SELECT AVG(y.sal), MAX(y.comm) FROM emp y WHERE y.deptno = x.deptno)
  WHERE x.empno = 7369;
  
SELECT * FROM emp_history;
DROP TABLE emp_history;
CREATE TABLE emp_history AS
  SELECT * FROM emp;
UPDATE emp_history x
   SET (x.sal, x.comm) =
       (SELECT sal, comm FROM emp y WHERE y.empno = x.empno)
 WHERE x.empno = 7369;
SELECT * FROM emp_history;
--不相关子查询更新
UPDATE emp
   SET sal =
       (SELECT sal FROM emp WHERE empno = 7782)
 WHERE empno = 7369;
 
SELECT * FROM emp;

UPDATE (SELECT x.sal  sal,
               y.sal  sal_history,
               x.comm comm,
               y.comm comm_history
          FROM emp x, emp_history y
         WHERE x.empno = y.empno AND x.empno = 7369)
   SET sal_history = sal, comm_history = comm;
/*
在使用implict update table 时，发现其中一个表一定要有唯一约束，否则会报错！
但是Oracle可以使用hints：\/*+ BYPASS_UJVC*\/ 
屏蔽掉队唯一性的检查。
*/
UPDATE /*+bypass_ujvc*/ (SELECT x.sal  sal,
             y.sal  sal_history,
             x.comm comm,
             y.comm comm_history
        FROM emp x, emp_history y
       WHERE x.empno = y.empno AND x.empno = 7369)
   SET sal_history = sal, comm_history = comm;
   
   
DELETE FROM emp WHERE empno=7894 ;                  
INSERT INTO emp
VALUES(7894,'霍十','',DEFAULT,'',NULL,NULL,20);
SELECT * FROM emp_copy;
SELECT * FROM emp;
--merge更新插入表   
MERGE INTO emp_copy c --目标表
USING emp e --源表，可以是表、视图或子查询
ON (c.empno = e.empno)
WHEN MATCHED THEN --当匹配时，进行UPDATE操作
  UPDATE
     SET c.ename    = e.ename,
         c.job      = e.job,
         c.mgr      = e.mgr,
         c.hiredate = e.hiredate,
         c.sal      = e.sal,
         c.comm     = e.comm,
         c.deptno   = e.deptno
WHEN NOT MATCHED THEN --当不匹配时，进行INSERT操作
  INSERT
  VALUES
    (e.empno, e.ename, e.job, e.mgr, e.hiredate, e.sal, e.comm, e.deptno);

/*删除记录*/
--单表删除
DELETE FROM emp WHERE empno = 7903;

DELETE FROM dept WHERE deptno = 20;

SELECT * FROM dept;
--不相关子查询删除
DELETE FROM emp
 WHERE deptno = (SELECT deptno FROM dept WHERE dname = '销售部');

DELETE FROM emp_copy;
--相关子查询删除
DELETE FROM emp x
 WHERE EXISTS (SELECT 1 FROM emp_copy WHERE empno = x.empno);
DELETE FROM emp x
 WHERE empno IN (SELECT empno FROM emp_copy WHERE empno = x.empno);
--清除表的记录，不能回滚事务
TRUNCATE TABLE dept;

ALTER TABLE dept ENABLE CONSTRAINT pk_dept;

ALTER TABLE emp DISABLE CONSTRAINT PK_EMP;

CREATE TABLE dept_copy AS
  SELECT * FROM dept;

TRUNCATE TABLE dept;

INSERT INTO dept
  SELECT * FROM dept_copy;
/*提交和回滚记录*/
/*使用序列*/
--创建与删除序列
DROP SEQUENCE invoice_seq;
CREATE SEQUENCE invoice_seq
INCREMENT BY 1
START WITH 1
MAXVALUE 99999
NOCYCLE NOCACHE;
--在user_objects和user_sequences查找序列
SELECT o.OBJECT_NAME, o.OBJECT_TYPE, o.OBJECT_ID
  FROM user_objects o
 WHERE o.OBJECT_NAME = 'INVOICE_SEQ';
 
SELECT sequence_name, min_value, max_value, increment_by, last_number
  FROM user_sequences;

SELECT invoice_seq.CURRVAL, invoice_seq.NEXTVAL FROM DUAL;

SELECT invoice_seq.CURRVAL FROM DUAL;

SELECT invoice_seq.CURRVAL, invoice_seq.NEXTVAL FROM DUAL;
--使用序列
DROP TABLE invoice;
CREATE TABLE invoice
(
   invoice_id NUMBER PRIMARY KEY,                     --自动编号，唯一，不为空
   vendor_id NUMBER NOT NULL,                                       --供应商ID
   invoice_number VARCHAR2(50)  NOT NULL,                           --发票编号
   invoice_date DATE DEFAULT SYSDATE,                               --发票日期
   invoice_total  NUMBER(9,2) NOT NULL,                             --发票总数
   payment_total NUMBER(9,2)   DEFAULT 0                            --付款总数
);

INSERT INTO invoice
  (invoice_id, vendor_id, invoice_number, invoice_total)
VALUES
  (invoice_seq.NEXTVAL, 10, 'INV' || invoice_seq.CURRVAL, 100);

SELECT invoice_id, vendor_id, invoice_number, invoice_total FROM invoice;
  
--修改序列 
ALTER SEQUENCE invoice_seq
INCREMENT BY 2;
ALTER SEQUENCE invoice_seq
              INCREMENT BY 2
              MAXVALUE 10
              NOCACHE
              NOCYCLE;                       

/*同义词*/
SELECT * FROM SCOTT.EMP;
SELECT * FROM emp;
CREATE PUBLIC SYNONYM tempemp FOR scott.emp;
SELECT * FROM tempemp;
DROP PUBLIC SYNONYM tempemp;

SELECT userenv('LANG') FROM DUAL;
