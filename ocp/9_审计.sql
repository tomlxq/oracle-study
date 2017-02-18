/*
cd $ORACLE_BASE/admin/$ORACLE_SID/adump
cd /u01/app/oracle/admin/orcl/adump/
11G审计功能默认是打开的
show parameter audit_trail

TIPS: 
	1. ctrl+鼠标中键放大或缩小屏目
	2. 打开/取消 SecureCRT的右键复制功能
		在系统维护工作中，经常要在SecureCRT中使用复制黏贴功能，根据不同的需求，有人喜欢右键复制黏贴，有人不喜欢，笔者就不喜欢，而且是很不喜欢，因为实际工作中经常会不小心复制到一大堆不用的东西，还是使用ctrl+shift+v，来的安全，需要就复制，不需要就不复制。
		这里介绍开关位置，大家根据需要使用Options->Global Options->Terminal在右边选择或者取消
		“Copy on select”和“Paste on right button”的勾选即可打开或者关闭这个功能。

审计：
	语句审计
		audit create table by scott by access
	权限审计
		audit create table by scott by access
	模式对象审计
		audit select,insert,delete on scott.dept by access
	细粒度审计
		begin
			dbms_fga.add_policy(OBJECT_SCHEMA=>'scott',
			OBJECT_NAME=>'emp',
			POLICY_NAME=>'mypolicy1',
			AUDIT_CONDITION=>'sal<100',
			AUDIT_COLUMN=>'comm,sal',
			STATEMENT_TYPES => 'INSERT,UPDATE');
		end;
		/
--开启审计功能
alter system set audit_trail=db_extended scope=spfile;
--重启才能生效
SQL> shutdown immediate;
SQL> startup 
--1. 语句审计 
SQL> audit create table by scott by access;
SQL> create table t1 as select * from dept;
SQL> select username,to_char(timestamp,'MM/DD/YY HH24:MI') timestamp,obj_name,action_name,sql_text from dba_audit_trail where username='SCOTT';
SQL> select object_name,object_type,alt,del,ins,upd,sel from dba_obj_audit_opts;
--3.模式对象审计
SQL> audit select,insert,delete on scott.dept by access;  
SQL> insert into dept values(50,'book','xingjiang');
SQL> insert into dept values(60,'pen','bulage');
SQL> commit;
SQL> select * from dept;
--取消审计
SQL> noaudit select,insert,delete on scott.dept;

--4.细粒度审计
SQL> begin
  2  dbms_fga.add_policy(OBJECT_SCHEMA=>'scott',
  3  OBJECT_NAME=>'emp',
  4  POLICY_NAME=>'mypolicy1',
  5  AUDIT_CONDITION=>'sal<100',
  6  AUDIT_COLUMN=>'comm,sal',
  7  STATEMENT_TYPES => 'INSERT,UPDATE');
  8  end;
  9  /

SQL> insert into scott.emp values(800,'tomluo','CLERK',7839,date'2017-02-17',50,null,20);
SQL> commit;
SQL> update scott.emp set sal=50,comm=60 where empno=800;
SQL> commit;
SQL> select to_char(timestamp,'mm/dd/yy hh24:mi') timestamp,object_schema,object_name,policy_name,statement_type from dba_fga_audit_trail where db_user='SCOTT';

TIMESTAMP      OBJECT_SCHEMA   OBJECT_NAME     POLICY_NAM STATEME
-------------- --------------- --------------- ---------- -------
02/17/17 21:48 SCOTT           EMP             MYPOLICY1  INSERT
02/17/17 21:49 SCOTT           EMP             MYPOLICY1  UPDATE

ORA-01652: unable to extend temp segment by 128 in tablespace TEMPTBS2
SQL> select file_name,bytes/1024/1024 MB,autoextensible,tablespace_name from dba_temp_files;
SQL> create temporary tablespace TEMP01 TEMPFILE '/oradata/orcl/temptbs1.dbf' SIZE 50M REUSE AUTOEXTEND ON NEXT 640K MAXSIZE UNLIMITED; 
SQL> alter database default temporary tablespace TEMP01;
SQL> drop tablespace TEMPTBS2 including contents and datafiles; 


SQL> drop table t1;
ORA-55610: Invalid DDL statement on history-tracked table
SQL> !oerr ora 55610
SQL> alter table scott.t1 no flashback archive;

PLS-00306: wrong number or types of arguments in call to 'ADD_POLICY'
SQL> desc dbms_fga

*/