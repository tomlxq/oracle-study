实验１：将数据文件和控制文件组合在一起	
[oracle@oracle ~]$ vi /home/oracle/data/demo1.ctl
LOAD DATA
INFILE *
INTO TABLE scott.T_DEPT
FIELDS TERMINATED BY ','
(DEPTNO, DNAME, LOC )
BEGINDATA
10,Sales,Virginia
20,Accounting,Virginia
30,Consulting,Virginia
40,Finance,Virginia
[oracle@oracle ~]$ sqlplus / as sysdba 
SQL> conn scott/oracle
SQL> create table t_dept
  2  (deptno number(2) constraint dept_pk primary key,
  3  dname varchar2(20),
  4  loc varchar2(20));
SQL> exit
[oracle@oracle ~]$ sqlldr scott/oracle control=/home/oracle/data/demo1.ctl

SQL*Loader: Release 11.2.0.3.0 - Production on Wed Mar 8 21:29:36 2017

Copyright (c) 1982, 2011, Oracle and/or its affiliates.  All rights reserved.

Commit point reached - logical record count 4
[oracle@oracle ~]$ sqlplus / as sysdba 
SQL> conn scott/oracle
Connected.
SQL> select * from t_dept;

    DEPTNO DNAME                LOC
---------- -------------------- --------------------
        10 Sales                Virginia
        20 Accounting           Virginia
        30 Consulting           Virginia
        40 Finance              Virginia
实验２：将数据文件和控制文件分离实现数据装载		
[oracle@oracle ~]$ vi /home/oracle/data/demo2.ctl                                                         

LOAD DATA
INFILE '/home/oracle/data/demo1.data'
INTO TABLE scott.T_DEPT
FIELDS TERMINATED BY ','
(DEPTNO, DNAME, LOC )
[oracle@oracle ~]$ vi /home/oracle/data/demo2.data                                                        
10,Sales,Virginia
20,Accounting,Virginia
30,Consulting,Virginia
40,Finance,Virginia
[oracle@oracle data]$ sqlldr scott/oracle control=/home/oracle/data/demo2.ctl log=/home/oracle/data/demo2.log

SQL*Loader: Release 11.2.0.3.0 - Production on Wed Mar 8 22:32:07 2017

Copyright (c) 1982, 2011, Oracle and/or its affiliates.  All rights reserved.

Commit point reached - logical record count 4

SQL> select * from scott.t_dept;

    DEPTNO DNAME                LOC
---------- -------------------- --------------------
        10 Sales                Virginia
        20 Accounting           Virginia
        30 Consulting           Virginia
        40 Finance              Virginia