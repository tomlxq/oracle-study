/*
物理备份: 数据文件、日志文件、控制文件
逻辑备份: 全库、表空间、schema、表 imp/exp impdp/expdp

冷备份：脱机
热备份：联机

完全备份
不完全备份
增量备份

完全恢复
不完全恢复

一致性备份
非一致性备份
关掉闪回：　alter database flashback off;

归档模式
非归档模式（热备份不行）

SQL> archive log list

控制文件（1~8个）
	SQL> show parameter control
	SQL> select * from v$controlfile;
	实验1：丢失一个控制文件
			原理互为镜象,cp到一个好的到丢失的
	实验2：丢失所有控制文件
			手工
				1.备份（二进制或文本）alter database backup controlefile to ...
				2.模拟数据，模拟故障（删除所有控制文件）
				3.重启数据库，查看故障
					alter database datafile 4 offline;在alert_orcl.log中查看日志
					alter database open;好处是减少停机时间
				4.restore（cp）
				5.recover（根据scn号找重做日志）
				----
				重建控制文件
			RMAN: catalog/nocatalog
日志文件
数据文件: （system/sysaux/temp/undo）temp丢失不用恢复
	系统表空间
	非系统表空间
	备份：
		冷备份：正常关机cp
		热备份:
			alter tablespace ... begin backup;冰结scn号
			cp ... ...
			alter tablespace ... end backup;
			脱机/只读
		实验3：丢失数据文件（删除非系统表空间）



如何查看警告日志？
	SQL> show parameter dump
	[oracle@oracle ~]$ tail -200f /u01/app/oracle/diag/rdbms/orcl/orcl/trace/alert_orcl.log 
实验1：丢失一个控制文件	
SQL> show parameter control
SQL> !rm -rf /oradata/orcl/control01.ctl
SQL> startup force
ORA-00205: error in identifying control file, check alert log for more info
SQL> !cp /oradata/orcl/control02.ctl /oradata/orcl/control01.ctl
SQL> alter database mount;
SQL> alter database open;

注意实验之前保存快照：
	1.　VM->snapshot->Take Snapshot,看下面的进度，如果满100%就可以做下面的实验了
	2.　
		SQL> shutdown immediate
		[oracle@oracle orcl]$ cp -r /oradata/ /u01/app/oracle/backup/orcl/orcl_bak
		[oracle@oracle orcl]$ du -sh /u01/app/oracle/backup/orcl/orcl_bak
		SQL> startup
实验2：丢失所有控制文件
SQL> alter database backup controlfile to trace as '/u01/app/oracle/backup/orcl/ctl.ctl';
SQL> alter database backup controlfile to '/u01/app/oracle/backup/orcl/ctl.bak';
SQL> !rm -rf /oradata/orcl/control*.ctl
SQL> startup force
ORA-00205: error in identifying control file, check alert log for more info
警告日志文件报错,说所有日志文件找不到了
[oracle@oracle ~]$ tail -200f /u01/app/oracle/diag/rdbms/orcl/orcl/trace/alert_orcl.log
SQL> !
[oracle@oracle ~]$ cp /u01/app/oracle/backup/orcl/ctl.bak /oradata/orcl/control02.ctl
[oracle@oracle ~]$ cp /u01/app/oracle/backup/orcl/ctl.bak /oradata/orcl/control01.ctl
[oracle@oracle ~]$ cp /u01/app/oracle/backup/orcl/ctl.bak /oradata/orcl/control03.ctl
SQL> alter database mount;（因为只读了控制文件，所以能mount）
（因为控制文件的时间点比数据文件的时间点早）
SQL> alter database open;
alter database open
*
ERROR at line 1:
ORA-01589: must use RESETLOGS or NORESETLOGS option for database open

SQL> alter database open resetlogs;
alter database open resetlogs
*
ERROR at line 1:(这里报1号文件需要恢复，实质1文件是最新的，只是控制文件旧而己)
ORA-01194: file 1 needs more recovery to be consistent
ORA-01110: data file 1: '/oradata/orcl/system01.dbf'
SQL> recover database（不要有recover datafile 1，这里所有数据文件都不对）
ORA-00283: recovery session canceled due to errors
ORA-01610: recovery using the BACKUP CONTROLFILE option must be done
SQL> recover database using backup controlfile;
ORA-00279: change 1433211 generated at 02/19/2017 16:50:46 needed for thread 1
ORA-00289: suggestion : /u01/app/oracle/arch/orcl/1_12_936362596.dbf
ORA-00280: change 1433211 for thread 1 is in sequence #12

另开一个终端看一下日志情况
QL> select  GROUP#,STATUS,member from v$logfile;

    GROUP# STATUS  MEMBER
---------- ------- ------------------------------
         3         /oradata/orcl/redo03.log
         2         /oradata/orcl/redo02.log
         4         /oradata/orcl/redo04.log
         1         /oradata/orcl/redo01.log

SQL> select GROUP# ,SEQUENCE#,FIRST_CHANGE#,NEXT_CHANGE# from v$log;

    GROUP#  SEQUENCE# FIRST_CHANGE# NEXT_CHANGE#
---------- ---------- ------------- ------------
         1         11       1410366      1432470
         4          8       1390283      1390286
         3         12       1432470   2.8147E+14
         2         10       1390290      1410366		 

1433211>1432470 12号文件正好与/u01/app/oracle/arch/orcl/1_12_936362596.dbf相匹配
ORA-00289: suggestion : /u01/app/oracle/arch/orcl/1_12_936362596.dbf这个文件是不存在的，要切换日志才存在
根据分析，是属于3组日志，对应文件为/oradata/orcl/redo03.log
在这句Specify log: {<RET>=suggested | filename | AUTO | CANCEL}后贴上
/oradata/orcl/redo03.log
然后回车
SQL> alter database open;
alter database open
*
ERROR at line 1:
ORA-01589: must use RESETLOGS or NORESETLOGS option for database open
SQL> alter database open resetlogs;


实验3：丢失数据文件（有备份）（删除非系统表空间）
SQL> select name from v$tablespace;
SQL> select  FILE#, STATUS,NAME from v$datafile;
SQL> alter tablespace USERS begin backup;
SQL> !cp /oradata/orcl/user01.dbf /u01/app/oracle/backup/orcl/user01_bak.dbf
SQL> create table tb1 tablespace users as select * from scott.emp;
SQL> !rm -rf /oradata/orcl/user01.dbf
SQL> create table tb2 tablespace users as select * from scott.dept;
SQL> alter system checkpoint;
alter system checkpoint
                      *
ERROR at line 1:
ORA-03113: end-of-file on communication channel
Process ID: 20909
Session ID: 1 Serial number: 3
SQL> exit
[oracle@oracle ~]$ sqlplus / as sysdba
Connected to an idle instance.
SQL> startup mount;
--SQL> alter database datafile 4 offline;(ORA-01110: data file 4: '/oradata/orcl/user01.dbf')
--SQL> alter database open;
SQL> alter database datafile 4 online;会报错
SQL> !cp /u01/app/oracle/backup/orcl/user01_bak.dbf /oradata/orcl/user01.dbf
SQL> recover datafile 4;
SQL> alter database datafile 4 online;
SQL> alter database open;
SQL> select count(*) from tb1; 可以看到发生故障后数据找回来了
SQL> c/tb1/tb2
SQL> /

实验4：丢失数据文件（有备份）（删除系统表空间）
SQL> select name from v$tablespace;
SQL> select name from v$datafile;
SQL> alter tablespace SYSTEM begin backup;
SQL> !cp /oradata/orcl/system01.dbf /u01/app/oracle/backup/orcl/system01_bak.dbf
SQL> alter tablespace system end backup;
SQL> !rm -rf /oradata/orcl/system01.dbf
SQL> create table tbsys1 as select * from scott.emp;
SQL> create table tbsys2 tablespace system  as select * from scott.emp;
SQL> alter system checkpoint;
SQL> exit
[oracle@oracle ~]$ sqlplus / as sysdba
Connected to an idle instance.
SQL> startup mount;
SQL> alter database datafile 1 offline;（ORA-01110: data file 1: '/oradata/orcl/system01.dbf'）
SQL> !cp '/u01/app/oracle/backup/orcl/system01_bak.dbf' '/oradata/orcl/system01.dbf'
SQL> alter database open;
ORA-01147: SYSTEM tablespace file 1 is offline
ORA-01110: data file 1: '/oradata/orcl/system01.dbf'
SQL> alter database datafile 1 online;
SQL> recover datafile 1;
SQL> select count(*) from tbsys1;
SQL> c/tbsys1/tbsys2
SQL> /

实验5：丢失数据文件（没有备份）（删除非系统表空间）
SQL> create tablespace tbs02 datafile '/oradata/orcl/tbs02.dbf' size 20m;
SQL> create table tb02 tablespace tbs02 as select * from scott.dept;
SQL> select name from v$tablespace;
SQL> select name from v$datafile;
SQL> alter system checkpoint;
[oracle@oracle ~]$ sqlplus / as sysdba
Connected to an idle instance.
SQL> startup mount;
SQL> alter database open;
ORA-01157: cannot identify/lock data file 8 - see DBWR trace file
ORA-01110: data file 8: '/oradata/orcl/tbs02.dbf
SQL> alter database datafile 8 offline drop;
SQL> select tablespace_name from dba_tablespaces;
SQL> col name for a30
SQL> select name,status from v$datafile;
SQL> drop tablespace TBS02 including contents and datafiles cascade constraints;
SQL> select name,status from v$datafile;
SQL> select tablespace_name from dba_tablespace;

实验5：RMAN丢失数据文件（有备份）（删除非系统表空间）
	步骤：
		1.RMAN> backup tablespace users;
		2.操作数据，模拟故障
			create table t1 tablespace users as select * from scott.emp;
			!rm -rf /oradata/orcl/user01.dbf
		3.重启数据库，查看故障
			startup force
		4. 恢复
			startup mount
			sql 'alter database datafile 4 offline'
			alter database open
			restore open
			recover datafile 4;
			sql 'alter database datafile 4 online'
[oracle@oracle trace]$ rman target /
RMAN> backup tablespace users;
RMAN> exit;
SQL> create table t1 tablespace users as select * from scott.emp;
SQL> select name,status from v$datafile;
SQL> !rm -rf /oradata/orcl/user01.dbf
SQL> startup force
ORA-01157: cannot identify/lock data file 4 - see DBWR trace file
ORA-01110: data file 4: '/oradata/orcl/user01.dbf'
[oracle@oracle trace]$ rman target /
RMAN> restore datafile 4;
RMAN> recover datafile 4;
RMAN> alter database open;
SQL> select count(*) from t1;

实验6：丢失所有online_redo文件
SQL> select member from v$logfile;
MEMBER
--------------------------------------------------------------------------------
/oradata/orcl/redo03.log
/oradata/orcl/redo02.log
/oradata/orcl/redo04.log
/oradata/orcl/redo01.log
[oracle@oracle ~]$ rm -rf /oradata/orcl/redo*.log 
[oracle@oracle ~]$ ls -ltr /oradata/orcl/ 
SQL> alter system switch logfile;
SQL> /
SQL> /
SQL> /
SQL> /
SQL> shutdown abort;
SQL> startup mount;
SQL> alter database clear unarchived logfile group 1;
SQL> alter database clear unarchived logfile group 2;
SQL> alter database clear unarchived logfile group 3;
SQL> alter database clear unarchived logfile group 4;
SQL> recover database until cancel;
auto
SQL> alter database open resetlogs;
--SQL> alter system set "_allow_resetlogs_corruption"=true scope=spfile;
--SQL> startup force;
--SQL> alter database open RESETLOGS;
--SQL> alter system set "_allow_resetlogs_corruption" scope=spfile sid='*';
--SQL> startup force;
--SQL> select member from v$logfile;
*/


ORA-00845: MEMORY_TARGET not supported on this system
[root@oracle ~]# mount -o size=4000M -o nr_inodes=1000000 -o noatime,nodiratime -o remount /dev/shm  