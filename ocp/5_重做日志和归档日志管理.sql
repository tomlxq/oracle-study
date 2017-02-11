/*
日志切换时会发生，重做日志同步
CKPT->DBWn->将重做日志文件写入datafile中
*/
select * from v$logfile;
select * from v$log;
set linesize 200;  
/
--SEQUENCE# 在发生日志切换时会发生变化
alter system switch logfile;
select * from v$log;

--Checkpoint not complete （考虑添加日志组）
create table t1 as select * from dba_objects;
select * from v$log;
alter system switch logfile;
/
/　--这儿会卡住一会儿，这是数据没有同步  
--增加日志组
alter database add logfile group 4 '/oradata/orcl/redo04.log' size 20m;
--删除日志组
alter database drop logfile group 4;
--查询当前的归档模式,是否归档
select log_mode from v$database;
--归档模式下，在数据库open状态下进行备份，热备份
/*
归档日志文件有两个好处：恢复和备份
*/
--设置归档日志
su - oracle
cd $ORACLE_BASE
mkdir -p arch/orcl
cd arch/orcl
pwd
alter system set log_archive_dest_1='location=/u01/app/oracle/arch/orcl' scope=both|spfile|memory
--spfile 必须保证数据库启动时用的是spfile
1. 改参数: 		alter system set log_archive_dest_1='location=/u01/app/oracle/arch/orcl';
2. 关闭数据库: 	shutdown immediate;     
3. 重启到mount:	startup mount;
4. 再打开到archive:	alter database archivelog;
select log_mode from v$database; --结果是ARCHIVELOG为归档模式
select * from v$log;--查看目前的日志文件
alter system switch logfile;--切换日志 做3件事：日志序列号自动加1，CKPR进程发出检查点->scn->DBWn->数据高速缓存中的脏缓冲区写到数据文件，arch进行开始归档
--/u01/app/oracle/arch/orcl　可以看到这个目录下有归档日志文件


