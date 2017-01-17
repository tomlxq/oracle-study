/*
触发器
  DML触发器
    行触发器/语句触发器
  替代触发器
  系统事件触发器
    用户事件触发器/系统事件触发器
  create or replace trigger_name
  before/after/instead of [insert/update/delete..]
  referencing new as new_name old as old_name
  for each row
  when condition
  trigger_body
*/
--定义一个行事件触发器
/*
BEFORE UPDATE ON scott.emp 后面要接on 那个表
WHEN (old.sal < new.sal)　后面的条件要加括号
IF updating('sal') THEN  里面的字段要加'',且不能用scott.emp.sal     
*/
DROP TABLE emp_history;
CREATE TABLE emp_history AS SELECT * FROM scott.emp WHERE 1<>1; 
CREATE OR REPLACE TRIGGER update_emp_trigger
  BEFORE UPDATE ON scott.emp
  FOR EACH ROW
  WHEN (old.sal < new.sal)
DECLARE
  v_sal NUMBER;
BEGIN
  IF updating('sal') THEN
    v_sal:=:new.sal-:old.sal;
    DELETE FROM scott.emp_history h WHERE h.empno=:old.empno;
    INSERT INTO scott.emp_history VALUES(:old.empno,:old.ename,:old.job,:old.mgr,:old.hiredate,:old.sal,:old.comm,:old.deptno);
    UPDATE scott.emp_history SET sal=v_sal WHERE empno=:old.empno;
  END IF;
END;

UPDATE scott.emp SET sal=sal*0.9 WHERE deptno=30;
SELECT * FROM scott.emp_history;

--创建一个emp_log表来对emp作记录
CREATE TABLE emp_log AS SELECT * FROM scott.emp WHERE 1<>1;
ALTER TABLE emp_log ADD log_id NUMBER NOT NULL PRIMARY KEY;
ALTER TABLE emp_log ADD log_act VARCHAR2(10);
ALTER TABLE emp_log ADD log_date DATE DEFAULT SYSDATE;
DROP SEQUENCE emp_log_seq;
CREATE SEQUENCE emp_log_seq;
SELECT * FROM emp_log;
CREATE OR REPLACE TRIGGER save_emp_log_trigger
  BEFORE INSERT OR UPDATE OR DELETE ON scott.emp
  FOR EACH ROW
BEGIN
  IF inserting THEN
    INSERT INTO emp_log
      (log_id, log_act, empno, ename, job, mgr, hiredate, sal, comm)
    VALUES
      (emp_log_seq.nextval,
       'insert',
       :new.empno,
       :new.ename,
       :new.job,
       :new.mgr,
       :new.hiredate,
       :new.sal,
       :new.comm);
  
  END IF;
  IF updating THEN
    INSERT INTO emp_log
      (log_id, log_act, empno, ename, job, mgr, hiredate, sal, comm)
    VALUES
      (emp_log_seq.nextval,
       'update',
       :old.empno,
       :old.ename,
       :old.job,
       :old.mgr,
       :old.hiredate,
       :old.sal,
       :old.comm);
    INSERT INTO emp_log
      (log_id, log_act, empno, ename, job, mgr, hiredate, sal, comm)
    VALUES
      (emp_log_seq.nextval,
       'update',
       :new.empno,
       :new.ename,
       :new.job,
       :new.mgr,
       :new.hiredate,
       :new.sal,
       :new.comm);
  END IF;
  IF deleting THEN
    INSERT INTO emp_log
      (log_id, log_act, empno, ename, job, mgr, hiredate, sal, comm)
    VALUES
      (emp_log_seq.nextval,
       'delete',
       :old.empno,
       :old.ename,
       :old.job,
       :old.mgr,
       :old.hiredate,
       :old.sal,
       :old.comm);
  END IF;
END;
INSERT INTO scott.emp VALUES(9000,'强哥','clerk',7566,SYSDATE,15000,NULL,20);
UPDATE scott.emp SET sal=17000 WHERE empno=9000;
DELETE FROM scott.emp WHERE empno=9000;
SELECT * FROM emp_log;
--创建一个表级触发器
SELECT to_char(DATE '2017-01-14', 'DAY', 'NLS_DATE_LANGUAGE = American'),
       to_char(DATE '2017-01-15', 'DAY', 'NLS_DATE_LANGUAGE = American'),
       to_char(SYSDATE, 'HH24:MI')
  FROM dual;

CREATE OR REPLACE TRIGGER t_verify_empty_time
  BEFORE INSERT OR UPDATE OR DELETE ON scott.emp
BEGIN
  IF deleting THEN
    IF (to_char(SYSDATE, 'DAY', 'NLS_DATE_LANGUAGE = American') IN
       ('SATURDAY ', 'SUNDAY') OR
       to_char(SYSDATE, 'HH24:MI') NOT BETWEEN '8:30' AND '18:00') THEN
      raise_application_error(-20000, '你不能在空闲时间操作数据库！');
    END IF;
  END IF;
END;

DELETE FROM scott.emp;

--表级触发器，统计操作次数
CREATE TABLE audit_emp(
table_name VARCHAR2(100),
start_time DATE,
end_time DATE,
ins_count NUMBER DEFAULT 0,
upd_count NUMBER DEFAULT 0,
del_count NUMBER DEFAULT 0
);
CREATE OR REPLACE TRIGGER t_audit_emp
  AFTER INSERT OR UPDATE OR DELETE ON scott.emp
DECLARE
  v_count NUMBER := 0;
BEGIN
  SELECT COUNT(1) INTO v_count FROM audit_emp WHERE table_name = 'emp';
  IF v_count = 0 THEN
    INSERT INTO audit_emp
      (table_name, start_time, end_time)
    VALUES
      ('emp', SYSDATE, NULL);
  END IF;
  IF inserting THEN
    UPDATE audit_emp
       SET ins_count = ins_count + 1,end_time=SYSDATE
     WHERE table_name = 'emp';
  END IF;
  IF updating THEN
    UPDATE audit_emp
       SET upd_count = upd_count + 1,end_time=SYSDATE
     WHERE table_name = 'emp';
  END IF;
  IF deleting THEN
    UPDATE audit_emp
       SET del_count = del_count + 1,end_time=SYSDATE
     WHERE table_name = 'emp';
  END IF;
END;
DROP TRIGGER update_emp_trigger;
DROP TRIGGER t_verify_empty_time;
SELECT * FROM scott.emp;
DELETE FROM scott.emp WHERE empno=9005;
INSERT INTO scott.emp VALUES(9005,'kehan','clerk','7566',DATE'2017-02-14',8000,DEFAULT,30);
UPDATE scott.emp SET ename='张三' WHERE empno=9005;
SELECT * FROM scott.audit_emp;
--referencing 为old new 取别名
CREATE OR REPLACE TRIGGER update_emp_trigger
  BEFORE UPDATE ON scott.emp
  REFERENCING OLD AS o NEW AS n
  FOR EACH ROW
  WHEN (o.sal < n.sal)
DECLARE
  v_sal NUMBER;
BEGIN
  IF updating('sal') THEN
    v_sal:=:n.sal-:o.sal;
    DELETE FROM scott.emp_history h WHERE h.empno=:o.empno;
    INSERT INTO scott.emp_history VALUES(:o.empno,:o.ename,:o.job,:o.mgr,:o.hiredate,:o.sal,:o.comm,:o.deptno);
    UPDATE scott.emp_history SET sal=v_sal WHERE empno=:o.empno;
  END IF;
END;
TRUNCATE TABLE scott.emp_history;
UPDATE scott.emp SET sal=sal*1.2 WHERE deptno=30;
SELECT * FROM scott.emp_history;

DROP TABLE test_emp;
DROP TABLE emp_rec;
DROP SEQUENCE test_emp_seq;
CREATE TABLE test_emp(
emp_id NUMBER,
empno NUMBER,
ename VARCHAR2(20)
);
--new的属性赋值
CREATE TABLE emp_rec AS SELECT * FROM test_emp WHERE 1<>1;
CREATE SEQUENCE test_emp_seq;
CREATE OR REPLACE TRIGGER t_assign_test
  BEFORE INSERT ON test_emp
  FOR EACH ROW
DECLARE
  v_emp_rec emp_rec%ROWTYPE;
BEGIN
  SELECT test_emp_seq.nextval INTO :NEW.emp_id FROM dual;
  v_emp_rec.emp_id := :NEW.emp_id;
  v_emp_rec.empno  := :NEW.empno;
  v_emp_rec.ename  := :NEW.ename;
  --INSERT INTO emp_rec VALUES　v_emp_rec;　不能工作
  INSERT INTO emp_rec VALUES(v_emp_rec.emp_id,v_emp_rec.empno,v_emp_rec.ename);
END;
INSERT INTO test_emp(empno,ename) VALUES(1,'特普良');
SELECT * FROM test_emp;
SELECT * FROM emp_rec;

CREATE OR REPLACE TRIGGER t_emp_comm
   BEFORE UPDATE ON emp     --触发器作用的表对象以及触发的条件和触发的动作
   FOR EACH ROW             --行级别的触发器
   WHEN(NEW.comm>OLD.comm)    --触发器条件
DECLARE
   v_comm   NUMBER;          --语句块的声明区
BEGIN
   IF UPDATING ('comm') THEN --使用条件谓词判断是否是comm列被更新
      v_comm := :NEW.comm - :OLD.comm; --记录工资的差异
      DELETE FROM emp_history 
            WHERE empno = :OLD.empno;      --删除emp_history中旧表记录
      INSERT INTO emp_history              --向表中插入新的记录
           VALUES (:OLD.empno, :OLD.ename, :OLD.job, :OLD.mgr, :OLD.hiredate,
                   :OLD.sal, :OLD.comm, :OLD.deptno);
      UPDATE emp_history                   --更新薪资值
         SET comm = v_comm
       WHERE empno = :NEW.empno;
   END IF;
END;


CREATE OR REPLACE TRIGGER t_comm_sal
   BEFORE UPDATE ON emp     --触发器作用的表对象以及触发的条件和触发的动作
   FOR EACH ROW             --行级别的触发器
BEGIN
   CASE 
   WHEN UPDATING('comm') THEN          --如果是对comm列进行更新     
      IF :NEW.comm<:OLD.comm THEN      --要求新的comm值要大于旧的comm值
         RAISE_APPLICATION_ERROR(-20001,'新的comm值不能小于旧的comm值');
      END IF;
   WHEN UPDATING('sal') THEN           --如果是对sal列进行更新
      IF :NEW.sal<:OLD.sal THEN        --要求新的sal值要大于旧的sal值
         RAISE_APPLICATION_ERROR(-20001,'新的sal值不能小于旧的sal值'); 
      END IF;
   END CASE;        
END;

--创建一个表来测试多个触发器的执行顺序
CREATE TABLE trigger_data
(
   trigger_id  INT,
   tirgger_name VARCHAR2(100)
)
--创建第一个触发器
CREATE OR REPLACE TRIGGER one_trigger
   BEFORE INSERT
   ON trigger_data
   FOR EACH ROW
BEGIN
   :NEW.trigger_id := :NEW.trigger_id + 1;
   DBMS_OUTPUT.put_line('触发了one_trigger');
END;
--创建与第1个触发器具有相同类型相同触发时机的触发器
CREATE OR REPLACE TRIGGER two_trigger
   BEFORE INSERT
   ON trigger_data
   FOR EACH ROW
   FOLLOWS one_trigger          --让该触发器在one_trigger后面触发
BEGIN
   DBMS_OUTPUT.put_line('触发了two_trigger');
   IF :NEW.trigger_id > 1
   THEN
      :NEW.trigger_id := :NEW.trigger_id + 2;
   END IF;
END;
/*
ORA-04091: 表 SCOTT.EMP 发生了变化, 触发器/函数不能读它
ORA-06512: 在 "SCOTT.T_EMP_MAXSAL", line 4
ORA-04088: 触发器 'SCOTT.T_EMP_MAXSAL' 执行过程中出错
*/
CREATE OR REPLACE TRIGGER t_emp_maxsal
   BEFORE UPDATE OF sal
   ON scott.emp                       --在UPDATE语句更新sal值之前触发
   FOR EACH ROW                 --行级别的触发器
DECLARE
   v_maxsal   NUMBER;           --保存最大薪资值的变量
BEGIN
   SELECT MAX(sal)            
     INTO v_maxsal
     FROM scott.emp;                  --获取emp表最大薪资值
   UPDATE scott.emp
      SET sal = v_maxsal - 100  --更新员工7369的薪资值
    WHERE empno = 7369;
END;

BEGIN
UPDATE emp SET sal=sal*1.12 WHERE deptno=20;
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line(SQLERRM);
END;


INSERT INTO trigger_data VALUES(1,'triggerdemo');
SELECT * FROM trigger_data;
TRUNCATE TABLE trigger_data;

SELECT referenced_name, referenced_type, dependency_type
  FROM user_dependencies
 WHERE NAME = 'TWO_TRIGGER' AND referenced_type = 'TRIGGER';
 
 
 CREATE OR REPLACE TRIGGER t_emp_comm
   BEFORE UPDATE ON emp     --触发器作用的表对象以及触发的条件和触发的动作
   FOR EACH ROW             --行级别的触发器
   WHEN(NEW.comm>OLD.comm)    --触发器条件
DECLARE   
   v_comm   NUMBER;          --语句块的声明区
   PRAGMA AUTONOMOUS_TRANSACTION; --自治事务      
BEGIN
   IF UPDATING ('comm') THEN --使用条件谓词判断是否是comm列被更新
      v_comm := :NEW.comm - :OLD.comm; --记录工资的差异
      DELETE FROM emp_history 
            WHERE empno = :OLD.empno;      --删除emp_history中旧表记录
      INSERT INTO emp_history              --向表中插入新的记录
           VALUES (:OLD.empno, :OLD.ename, :OLD.job, :OLD.mgr, :OLD.hiredate,
                   :OLD.sal, :OLD.comm, :OLD.deptno);
      UPDATE emp_history                   --更新薪资值
         SET comm = v_comm
       WHERE empno = :NEW.empno;
   END IF;
   COMMIT;                                 --提交结束自治事务
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK;                            --发生任何异外回滚自治事务
END;

SELECT * FROM emp WHERE deptno=20;

--创建视图emp_dept视图
CREATE OR REPLACE VIEW scott.emp_dept (empno,
                                       ename,
                                       job,
                                       mgr,
                                       hiredate,
                                       sal,
                                       comm,
                                       deptno,
                                       dname,
                                       loc
                                      )
AS
   SELECT emp.empno, emp.ename, emp.job, emp.mgr, emp.hiredate, emp.sal,
          emp.comm, emp.deptno, dept.dname, dept.loc
     FROM dept, emp
    WHERE ((dept.deptno = emp.deptno));
    
CREATE OR REPLACE TRIGGER t_dept_emp
   INSTEAD OF INSERT ON emp_dept      --在视图emp_dept上创建INSTEAD OF触发器
   REFERENCING NEW AS n               --指定谓词别名
   FOR EACH ROW                       --行级触发器
DECLARE
   v_counter   INT;                   --计数器统计变量
BEGIN
   SELECT COUNT (*)
     INTO v_counter
     FROM dept
    WHERE deptno = :n.deptno;         --判断在dept表中是否存在相应的记录   
   IF v_counter = 0                   --如果不存在该dept记录
   THEN
      INSERT INTO dept VALUES (:n.deptno, :n.dname, :n.loc);   --向dept表中插入新的部门记录
   END IF;
   SELECT COUNT (*)                   --判断emp表中是否存在员工记录
     INTO v_counter
     FROM emp
    WHERE empno = :n.empno;
   IF v_counter = 0                   --如果不存在，则向emp表中插入员工记录
   THEN
      INSERT INTO emp
                  (empno, ename, job, mgr, hiredate, sal,
                   comm, deptno
                  )
           VALUES (:n.empno, :n.ename, :n.job, :n.mgr, :n.hiredate, :n.sal,
                   :n.comm, :n.deptno
                  );
   END IF;
END;

SELECT * FROM dept;

SELECT * FROM emp_dept;



INSERT INTO emp_dept
  (empno, ename, job, mgr, hiredate, sal, comm, deptno, dname, loc)
VALUES
  (8000,
   '龙太郎',
   '神职',
   NULL,
   TRUNC(SYSDATE),
   5000,
   300,
   80,
   '神庙',
   '龙山');
SELECT * FROM dept;

SELECT * FROM emp_dept;
CREATE OR REPLACE TRIGGER t_dept_emp_update
   INSTEAD OF UPDATE ON emp_dept      --在视图emp_dept上创建INSTEAD OF触发器
   REFERENCING NEW AS n OLD AS o      --指定谓词别名
   FOR EACH ROW                       --行级触发器
DECLARE
   v_counter   INT;                   --计数器统计变量
BEGIN
   SELECT COUNT (*)
     INTO v_counter
     FROM dept
    WHERE deptno = :o.deptno;           --判断在dept表中是否存在相应的记录   
   IF v_counter >0                      --如果存在，则更新dept表
   THEN
      UPDATE dept SET dname=:n.dname,loc=:n.loc WHERE deptno=:o.deptno;
   END IF;
   SELECT COUNT (*)                    --判断emp表中是否存在员工记录
     INTO v_counter
     FROM emp
    WHERE empno = :n.empno;
   IF v_counter > 0                    --如果存在，则更新emp表
   THEN
      UPDATE emp SET ename=:n.ename,job=:n.job,mgr=:n.mgr, hiredate=:n.hiredate,sal=:n.sal,
                   comm=:n.comm, deptno=:n.deptno WHERE empno=:o.empno;        
   END IF;
END; 


CREATE OR REPLACE TRIGGER t_dept_emp_delete
   INSTEAD OF DELETE ON emp_dept       --在视图emp_dept上创建INSTEAD OF触发器
   REFERENCING  OLD AS o               --指定谓词别名
   FOR EACH ROW                        --行级触发器
BEGIN
   DELETE FROM emp WHERE empno=:o.empno;        --删除emp表
   DELETE FROM dept WHERE deptno=:o.deptno;     --删除dept表
END; 


SELECT * FROM emp_dept WHERE empno=8000;

DELETE FROM emp_dept WHERE empno=8000;

CREATE OR REPLACE TRIGGER t_emp_dept
   INSTEAD OF UPDATE OR INSERT OR DELETE ON emp_dept   
   REFERENCING NEW AS n OLD AS o      --指定谓词别名
   FOR EACH ROW                       --行级触发器
DECLARE
   v_counter   INT;                   --计数器统计变量
BEGIN
   SELECT COUNT (*)
     INTO v_counter
     FROM dept
    WHERE deptno = :o.deptno;           --判断在dept表中是否存在相应的记录   
   IF v_counter >0                      --如果存在，则更新dept表
   THEN
      CASE 
      WHEN UPDATING THEN
         UPDATE dept SET dname=:n.dname,loc=:n.loc WHERE deptno=:o.deptno;
      WHEN INSERTING THEN
         INSERT INTO dept VALUES (:n.deptno, :n.dname, :n.loc); 
      WHEN DELETING THEN
         DELETE FROM dept WHERE deptno=:o.deptno;     --删除dept表      
      END CASE;
   END IF;
   SELECT COUNT (*)                    --判断emp表中是否存在员工记录
     INTO v_counter
     FROM emp
    WHERE empno = :n.empno;
   IF v_counter > 0                    --如果存在，则更新emp表
   THEN
      CASE 
      WHEN UPDATING THEN
         UPDATE emp SET ename=:n.ename,job=:n.job,mgr=:n.mgr, hiredate=:n.hiredate,sal=:n.sal,
                   comm=:n.comm, deptno=:n.deptno WHERE empno=:o.empno;    
      WHEN INSERTING THEN
         INSERT INTO emp
                  (empno, ename, job, mgr, hiredate, sal,
                   comm, deptno
                  )
           VALUES (:n.empno, :n.ename, :n.job, :n.mgr, :n.hiredate, :n.sal,
                   :n.comm, :n.deptno
                  );
      WHEN DELETING THEN
         DELETE FROM emp WHERE empno=:o.empno;   
      END CASE;       
   END IF;
END;  

SELECT * FROM emp;

--创建用于嵌套表的对象类型  MULTISET???
CREATE OR REPLACE TYPE emp_obj AS OBJECT(
   empno NUMBER(4),
   ename VARCHAR2(10),
   job VARCHAR2(10),
   mgr NUMBER(4),
   hiredate DATE,
   sal NUMBER(7,2),
   comm NUMBER(7,2),
   deptno NUMBER(2)
);
--创建嵌套表类型
CREATE OR REPLACE TYPE emp_tab_type AS TABLE OF emp_obj;
--创建嵌套表视图，MULTISET必须与CAST一起使用
CREATE OR REPLACE VIEW dept_emp_view AS
   SELECT deptno,dname,loc,
   CAST(MULTISET(SELECT * FROM emp WHERE deptno=dept.deptno) AS emp_tab_type) emplst
   FROM dept;
   
SELECT * FROM dept_emp_view  where deptno=10;

--ORA-25015: 不能在嵌套表视图列中执行 DML
BEGIN
  INSERT INTO TABLE
    (SELECT emplst FROM dept_emp_view WHERE deptno = 10)
  VALUES
    (8003, '四爷', '皇上', NULL, SYSDATE, 5000, 500, 10);
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line(SQLERRM);
END;
CREATE OR REPLACE TRIGGER dept_emp_innerview
   INSTEAD OF INSERT
   ON NESTED TABLE emplst OF dept_emp_view                       --创建嵌套表替代触发器
BEGIN
   INSERT INTO emp                                             --插入子表记录
               (deptno, empno, ename, job, mgr,
                hiredate, sal, comm
               )
        VALUES (:PARENT.deptno, :NEW.empno, :NEW.ename, :NEW.job, :NEW.mgr,
                :NEW.hiredate, :NEW.sal, :NEW.comm
               );
END;

--系统事件
DROP TABLE created_log;
CREATE TABLE created_log
(
    obj_owner VARCHAR2(30),   --所有者
    obj_name  VARCHAR2(30),   --对象名称
    obj_type  VARCHAR2(20),   --对象类型
    obj_user VARCHAR2(30),    --创建用户
    created_date DATE     --创建日期
);

CREATE OR REPLACE TRIGGER t_created_log
  AFTER CREATE ON scott.SCHEMA --在soctt方案下创建对象后触发
BEGIN
  --插入日志记录
  INSERT INTO scott.created_log
    (obj_owner, obj_name, obj_type, obj_user, created_date)
  VALUES
    (SYS.dictionary_obj_owner,
     SYS.dictionary_obj_name,
     SYS.dictionary_obj_type,
     SYS.login_user,
     SYSDATE);
END;
DROP TABLE scott.t; 
CREATE TABLE scott.t(ID NUMBER);
SELECT * FROM scott.created_log;

--以DBA身份登录，创建下面的登录记录表
CREATE TABLE log_db_table
(
   username VARCHAR2(20),
   logon_time DATE,
   logoff_time DATE,
   address VARCHAR2(20) 
);
--以soctt身份登录，创建下面的登录记录表
CREATE TABLE log_user_table
(
   username VARCHAR2(20),
   logon_time DATE,
   logoff_time DATE,
   address VARCHAR2(20) 
);

--以DBA身份登录，创建DATABASE级别的LOGON事件触发器
CREATE OR REPLACE TRIGGER t_db_logon
AFTER LOGON ON DATABASE
BEGIN
  INSERT INTO log_db_table(username,logon_time,address)
              VALUES(ora_login_user,SYSDATE,ora_client_ip_address);
END;
--以scott身份登录，创建如下的SCHEMA级别的LOGON事件触发器
CREATE OR REPLACE TRIGGER t_user_logon
AFTER LOGON ON SCHEMA
BEGIN
  INSERT INTO log_user_table(username,logon_time,address)
              VALUES(ora_login_user,SYSDATE,ora_client_ip_address);
END;

--以DBA身份进入系统，创建临时表
CREATE TABLE event_table(
   sys_event VARCHAR2(30),
   event_time DATE
);

--在DBA级别创建如下的2个触发器
CREATE OR REPLACE TRIGGER t_startup
AFTER STARTUP ON DATABASE       --STARTUP只能是AFTER
BEGIN
   INSERT INTO event_table VALUES(ora_sysevent,SYSDATE);
END;
/
CREATE OR REPLACE TRIGGER t_startup
BEFORE SHUTDOWN ON DATABASE       --SHUTDOWN只能是BEFORE
BEGIN
   INSERT INTO event_table VALUES(ora_sysevent,SYSDATE);
END;
/

CREATE OR REPLACE TRIGGER preserve_app_cols
   AFTER ALTER ON SCHEMA
DECLARE
   --获取一个表中所有列的游标
   CURSOR curs_get_columns (cp_owner VARCHAR2, cp_table VARCHAR2)
   IS
      SELECT column_name
        FROM all_tab_columns
       WHERE owner = cp_owner AND table_name = cp_table;
BEGIN
   -- 如果正使用的是ALTER TABLE语句修改表
   IF ora_dict_obj_type = 'TABLE'
   THEN
      -- 循环表中的每一列
      FOR v_column_rec IN curs_get_columns (
                             ora_dict_obj_owner,
                             ora_dict_obj_name
                          )
      LOOP
         --判断当前的列名正在被修改
         IF ORA_IS_ALTER_COLUMN (v_column_rec.column_name)
         THEN
            IF v_column_rec.column_name='EMPNO' THEN
               RAISE_APPLICATION_ERROR (
                  -20003,
                  '不能对empno字段进行修改'
               );
            END IF; 
         END IF; 
      END LOOP;
   END IF;
END;

ALTER TABLE scott.emp MODIFY(empno NUMBER(8));

--错误日志记录表
CREATE TABLE servererror_log(
   error_time DATE,
   username  VARCHAR2(30),
   instance NUMBER,
   db_name VARCHAR2(50),
   error_stack VARCHAR2(2000)
);
--创建错误触发器，在出现数据库错误时触发。
CREATE OR REPLACE TRIGGER t_logerrors
   AFTER SERVERERROR ON DATABASE
BEGIN
   INSERT INTO servererror_log
        VALUES (SYSDATE, login_user, instance_num, database_name,
                DBMS_UTILITY.format_error_stack);
END;



--select privilege from dba_sys_privs where grantee='SCOTT' ;
