sqlplus / as sysdba
shutdown immediate;
/*
4种状态
open
nomount　
mount
shutdown

启动指令
shutdown->nomount
内存:根据参数文件/u01/app/oracle/product/11.2.0/db_1/dbs/spfileorcl.ora
进程：
nomount->mount	读取控制文件 
	实验: ORA-01507: database not mounted
	startup nomount; 
	alter database backup controlfile to trace;
	alter database mount;
	alter database backup controlfile to trace;
	conn scott/oracle 此时连普通用户,因为用户名、口令存储在数据文件中的
	ORA-01033: ORACLE initialization or shutdown in progress
mount->open		读取日志文件，数据文件
	conn / as sysdba;
	alter database open;
	@/u01/app/oracle/product/11.2.0/db_1/rdbms/admin/utlsampl.sql
	alter user scott identified by oracle account unlock;
	
startup
startup open
startup nomount
startup mount
--pfile参数文件
startup force=shutdown abort+startup

修改指令
alter database nomount/mount/open;
*/
conn / as sysdba; --联到管理员
select status from v$instance;--查看当前数据库状态
startup nomount;
--查看进程
ps -ef | grep ora_
--查看日志
tail -200f $ORACLE_BASE/diag/rdbms/orcl/orcl/trace/alert_orcl.log

clone session->
su - oracle 
clear
more /u01/app/oracle/product/11.2.0/db_1/dbs/spfileorcl.ora


--pfile参数文件 指定非默认值的参数
conn / as sysdba;
show parameter name; --查看实例名
/*
1实例(内存+进程)->1数据库
多个实例(内存+进程)->1数据库(集群)
--查看动态参数文件
ls $ORACLE_HOME/dbs/
动态参数文件，二进制文件，不能修改spfilesid.ora -> spfileorcl.ora
静态参数文件initsid.ora -> initorcl.ora
show parameter spfile
启动进寻找3个参数文件,如果找不到，实例无法启动，还会报错
查找顺序	spfilesid.ora->spfile.ora->initsid.ora
*/
create pfile from spfile;--从动态初始文件创建静态初始化文件
--关闭实例
shutdown
shutdown normal(等用户断开)
shutdown transactional(等事务断开)
shutdown immediate(强制检查点并关闭文件)
shutdown force
shutdown abort
/*
当数据库发生故障时，进程两种操作
	redo重做
	undo撤消
实例恢复　smon进程自行恢复，不需要人工操作

查看数据库名
	1. select name from v$database;
	2. show parameter db_
	3. show parameter spfile
		more /u01/app/oracle/product/11.2.0/db_1/dbs/spfileorcl.ora
*/
--查看数据库域名
show parameter domain
select value from v$parameter where name='db_domain';
/*
全局数据库名
全局数据库名=数据库名+数据库域名，如前述福建节点的全局数据库名是：oradb.fj.jtyz
*/
--查看服务名
show parameter service_name;
select value from v$parameter where name='service_names';

