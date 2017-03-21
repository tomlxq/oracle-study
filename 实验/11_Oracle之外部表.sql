Oracle 之外部表
使用CREATE TABLE 语句的ORGANIZATION EXTENERAL 子句来创建外部表。外部表不分配任何盘区，因为仅仅是在数据字典中创建元数据。
注：在外部表上不能执行DML 操作
--（一）Oracle_loader 驱动程序
SQL> create or replace directory dir as '/home/oracle/data';
[oracle@oracle ~]$ cat /home/oracle/data/stu.dat 
000001,ALICE
000002,JACK
000003,DAVID
000004,MIKE
000005,KEVIN

SQL> create table stu
  2  (id number,name varchar(10))
  3  organization external
  4  (type oracle_loader
  5  default directory dir
  6  access parameters
  7  (
  8  records delimited by newline
  9  badfile dir:'exp.bad'
 10  logfile dir:'emp.log'
 11  fields terminated by ','
 12  missing field values are null
 13  (id,name))
 14  location ('stu.dat'))
 15  reject limit unlimited;

Table created.

SQL> select * from stu;

        ID NAME
---------- ----------
         1 ALICE
         2 JACK
         3 DAVID
         4 MIKE
         5 KEVIN
		 
--（二）Oracle_datapump 驱动程序
SQL> create table ext_emp 
  2  organization external
  3   (
  4     type oracle_datapump
  5     default directory dir
  6     location('emp.dat')
  7     )
  8    as select empno,ename,dname from emp,dept where emp.deptno=dept.deptno;

  
[oracle@oracle ~]$ export ORACLE_SID=prod
[oracle@oracle ~]$ echo $ORACLE_SID
prod
[oracle@oracle ~]$ sqlplus / as sysdba   
SQL> show parameter name

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
db_file_name_convert                 string
db_name                              string      prod
db_unique_name                       string      prod
global_names                         boolean     FALSE
instance_name                        string      prod
lock_name_space                      string
log_file_name_convert                string
processor_group_name                 string
service_names                        string      prod  
SQL> create or replace directory dir as '/home/oracle/data';
SQL> create table ext_emp_pump
  2  (
  3  empno number,
  4  ename varchar2(30),
  5  dname varchar2(30)
  6  )
  7  organization external
  8  (
  9  type oracle_datapump
 10  default directory dir
 11  location('emp.dat')
 12  );

Table created.

SQL> select count(*) from ext_emp_pump;

  COUNT(*)
----------
        14