--USER_TAB_PARTITIONS:可查看分区表的名字、归属表空间以及表的详细分区情况。
--USER_PART_TABLES：可查看用户所有的分区表，以及分区方式。
--v$dba_tables
--v$user_tables
--SQL> drop tablespace t4 including contents and datafiles cascade constraints ;

--实验１：按时间分区
SQL> select table_name from dba_tables where partitioned='YES';
SQL> SELECT TABLE_NAME,PARTITION_NAME,TABLESPACE_NAME FROM USER_TAB_PARTITIONS where TABLESPACE_NAME='T1';

TABLE_NAME                     PARTITION_NAME                 TABLESPACE_NAME
------------------------------ ------------------------------ ------------------------------
PDBA                           P1                             T1

SQL> SELECT TABLE_NAME,PARTITION_NAME,TABLESPACE_NAME FROM USER_TAB_PARTITIONS where TABLE_NAME='PDBA';

TABLE_NAME                     PARTITION_NAME                 TABLESPACE_NAME
------------------------------ ------------------------------ ------------------------------
PDBA                           P1                             T1
PDBA                           P2                             T2
PDBA                           P3                             T3
PDBA                           P4                             T4


--创建分区表
SQL> create tablespace t1 datafile '/u01/app/oracle/oradata/orcl/t1.dbf' size 10m;

Tablespace created.

SQL> create tablespace t2 datafile '/u01/app/oracle/oradata/orcl/t2.dbf' size 10m;

Tablespace created.

SQL> create tablespace t3 datafile '/u01/app/oracle/oradata/orcl/t3.dbf' size 10m;

Tablespace created.

SQL> create tablespace t4 datafile '/u01/app/oracle/oradata/orcl/t4.dbf' size 10m;

Tablespace created.

SQL> select name from v$datafile;
SQL> create table pdba(username varchar2(20),birthday date)
  2  partition by range (birthday)
  3  (
  4  partition p1 values less than (to_date('2017-01-01','yyyy-mm-dd')) tablespace t1,
  5  partition p2 values less than (to_date('2017-02-01','yyyy-mm-dd')) tablespace t2,
  6  partition p3 values less than (to_date('2017-03-01','yyyy-mm-dd')) tablespace t3,
  7  partition p4 values less than (maxvalue) tablespace t4
  8  );

Table created.
SQL> select TABLE_NAME,PARTITION_NAME,SUBPARTITION_COUNT,NUM_ROWS from user_tab_partitions where table_name='PDBA';

TABLE_NAME                     PARTITION_NAME                 SUBPARTITION_COUNT   NUM_ROWS
------------------------------ ------------------------------ ------------------ ----------
PDBA                           P1                                              0
PDBA                           P2                                              0
PDBA                           P3                                              0
PDBA                           P4                                              0
SQL> insert into pdba values('tom',date'2016-05-24');

1 row created.

SQL> insert into pdba values('tom',date'2017-01-24');

1 row created.

SQL> insert into pdba values('tom',date'2017-02-24');

1 row created.

SQL> insert into pdba values('tom',date'2017-03-24');

1 row created.

SQL> insert into pdba values('tom',date'2017-04-24');

1 row created.
SQL> select count(*) from pdba;

  COUNT(*)
----------
         5
SQL> select count(*) from pdba partition(p1);

  COUNT(*)
----------
         1

SQL> select count(*) from pdba partition(p2);

  COUNT(*)
----------
         1

SQL> select count(*) from pdba partition(p3);

  COUNT(*)
----------
         1

SQL> select count(*) from pdba partition(p4);

  COUNT(*)
----------
         2
SQL> select * from pdba;

USERNAME             BIRTHDAY
-------------------- ---------
tom                  24-MAY-16
tom                  24-JAN-17
tom                  24-FEB-17
tom                  24-MAR-17
tom                  24-APR-17
SQL> update pdba set birthday=date'2016-03-04' where birthday='24-MAR-17'; --修改不了，因为没有启动行移动
update pdba set birthday=date'2016-03-04' where birthday='24-MAR-17' 
       *
ERROR at line 1:
ORA-14402: updating partition key column would cause a partition change
SQL> select row_movement,table_name from dba_tables where table_name='PDBA'; --查询这个表的行移动状态

ROW_MOVE TABLE_NAME
-------- ------------------------------
DISABLED PDBA

SQL> alter table pdba enable row movement;　--开启移动状态

Table altered.

SQL> update pdba set birthday=date'2016-03-04' where birthday='24-MAR-17';

1 row updated.

SQL> select count(*) from pdba partition(p1);

  COUNT(*)
----------
         2
		 
		 
numtodsinterval(<x>,<c>) ,x是一个数字,c是一个字符串,
表明x的单位,这个函数把x转为interval day to second数据类型
常用的单位有 ('day','hour','minute','second')
SQL> alter session set nls_date_format='yyyy-mm-dd hh12:mi:ss';
SQL> set linesize 200
SQL> select sysdate,sysdate+numtodsinterval(3,'day'),sysdate+numtodsinterval(3,'hour'),sysdate+numtodsinterval(3,'minute'),sysdate+numtodsinterval(3,'second') as res from dual;

SYSDATE             SYSDATE+NUMTODSINTE SYSDATE+NUMTODSINTE SYSDATE+NUMTODSINTE RES
------------------- ------------------- ------------------- ------------------- -------------------
2017-03-09 08:06:47 2017-03-12 08:06:47 2017-03-09 11:06:47 2017-03-09 08:09:47 2017-03-09 08:06:50
numtoyminterval 与numtodsinterval函数类似,将x转为interval year to month数据类型
常用的单位有'year','month'
SQL> select sysdate,sysdate+numtoyminterval(3,'year') ,sysdate+numtoyminterval(3,'month') as res from dual;

SYSDATE             SYSDATE+NUMTOYMINTE RES
------------------- ------------------- -------------------
2017-03-09 08:09:18 2020-03-09 08:09:18 2017-06-09 08:09:18

--实验２：自动按月分区
SQL> create table month_date(c1 number,c2 date)
  2  partition by range(c2)
  3  interval(numtoyminterval(1,'month'))
  4  (
  5  partition p1 values less than (to_date('2017-01-01','yyyy-mm-dd')),
  6  partition p2 values less than (to_date('2017-02-01','yyyy-mm-dd'))
  7  );

Table created.
SQL> begin
  2  for i in 0 .. 11 loop
  3  insert into month_date values(i,add_months(to_date('2017-02-01','yyyy-mm-dd'),i));
  4  end loop;
  5  commit;
  6  end;
  7  /

PL/SQL procedure successfully completed.
SQL> alter session set nls_date_format='yyyy-mm-dd';

Session altered.

SQL> select * from month_date;

        C1 C2
---------- ----------
         0 2017-02-01
         1 2017-03-01
         2 2017-04-01
         3 2017-05-01
         4 2017-06-01
         5 2017-07-01
         6 2017-08-01
         7 2017-09-01
         8 2017-10-01
         9 2017-11-01
        10 2017-12-01

        C1 C2
---------- ----------
        11 2018-01-01

12 rows selected.

SQL> select table_name,tablespace_name,partition_name from user_tab_partitions where table_name='MONTH_DATE';

TABLE_NAME                     TABLESPACE_NAME                PARTITION_NAME
------------------------------ ------------------------------ ------------------------------
MONTH_DATE                     SYSTEM                         P1
MONTH_DATE                     SYSTEM                         P2
MONTH_DATE                     SYSTEM                         SYS_P81
MONTH_DATE                     SYSTEM                         SYS_P82
MONTH_DATE                     SYSTEM                         SYS_P83
MONTH_DATE                     SYSTEM                         SYS_P84
MONTH_DATE                     SYSTEM                         SYS_P85
MONTH_DATE                     SYSTEM                         SYS_P86
MONTH_DATE                     SYSTEM                         SYS_P87
MONTH_DATE                     SYSTEM                         SYS_P88
MONTH_DATE                     SYSTEM                         SYS_P89

TABLE_NAME                     TABLESPACE_NAME                PARTITION_NAME
------------------------------ ------------------------------ ------------------------------
MONTH_DATE                     SYSTEM                         SYS_P90
MONTH_DATE                     SYSTEM                         SYS_P91
MONTH_DATE                     SYSTEM                         SYS_P92

14 rows selected.

SQL> select * from month_date partition(SYS_P81);

        C1 C2
---------- ----------
         0 2017-02-01
		 
--实验３: 分区表的妙用
SQL> create table tab_part(c1 varchar2(30),c2 date) 
  2  partition by range(c2) 
  3  (partition tab_part_maxvalue values less than (maxvalue));
SQL> create index idx_c1 on tab_part(c1);
SQL> insert into tab_part values('jack',date'2016-06-01');
SQL> insert into tab_part values('jack',date'2017-06-01');
SQL> select * from tab_part;

C1                             C2
------------------------------ ---------
jack                           01-JUN-16
jack                           01-JUN-17
SQL> create table tab_test(c1 varchar2(30),c2 date);

Table created.

SQL> alter table tab_part exchange partition tab_part_maxvalue with table tab_test;

Table altered.

SQL> select * from tab_part;

no rows selected

SQL> select * from tab_test;

C1                             C2
------------------------------ ---------
jack                           01-JUN-16
jack                           01-JUN-17

SQL> set linesize 200
SQL> select table_name,partition_name,tablespace_name from user_tab_partitions where table_name='TAB_PART';

TABLE_NAME                     PARTITION_NAME                 TABLESPACE_NAME
------------------------------ ------------------------------ ------------------------------
TAB_PART                       TAB_PART_MAXVALUE              SYSTEM

SQL> alter table tab_part split partition tab_part_maxvalue at (to_date('2016-01-01','yyyy-mm-dd')) into (partition tab_part_2016,partition tab_part_maxvalue);

Table altered.

SQL> alter table tab_part split partition tab_part_maxvalue at (to_date('2017-01-01','yyyy-mm-dd')) into (partition tab_part_2017,partition tab_part_maxvalue);

Table altered.

SQL> select table_name,partition_name,tablespace_name from user_tab_partitions where table_name='TAB_PART';

TABLE_NAME                     PARTITION_NAME                 TABLESPACE_NAME
------------------------------ ------------------------------ ------------------------------
TAB_PART                       TAB_PART_2016                  SYSTEM
TAB_PART                       TAB_PART_2017                  SYSTEM
TAB_PART                       TAB_PART_MAXVALUE              SYSTEM

SQL> create index inx_test_tab01 on tab_test(c1);

Index created.

SQL> insert into tab_part select * from tab_test where c2>sysdate-10; 

1 row created.

SQL> select * from tab_part;

C1                             C2
------------------------------ ---------
jack                           01-JUN-17