迁移数据
	导入导出
	数据泵导入导出
		表: 用户存不存在，表空间存不存在，约束（是否要多表一起导出）
		表空间:　确认哪些不能导入，哪些导入不成功，不成功的对象是不是需要手工创建(DBMS_METADATA.GET_DDL(object_type=>'',name='',schema=>''))
		schema、database、传输表空间
		目录
			dumpfile=dump_dir:mydb_%U.dat
			directory=dump_dir dumpfile=mydb_%U.dat
			grant read,write | all on directory dump_dir to scott;
	sql*loader
	
目标数据库
	192.168.21.3 prod
源数据库 
	192.168.21.4 emrep 
emrep--->prod
目录对象
	dumpfile=pump_dir:mydb_%U.dat
	directory=pump_dir dumpfile=mydb_%U.dat
	grant read,write | all on directory pump_dir to scott;
	
实验1: 导出导入单表	
	1. 在源库创建目录对象
	df -h
	mkdir -p /home/oracle/exp
	cd /home/oracle/exp/
	sqlplus / as sysdba;
	alter user hr identified by oracle account unlock;
	create directory exp_dir as '/home/oracle/exp';
	grant all on directory exp_dir to hr;
	select * from dba_directories where DIRECTORY_NAME='EXP_DIR';
	2. 在目标库创建目录对象
	[oracle@oracle ~]$ mkdir /home/oracle/imp
	SQL> create user u01 identified by oracle account unlock;
	SQL> grant connect,resource to u01;
	SQL> create directory imp_dir as '/home/oracle/imp';
	SQL> grant all on directory imp_dir to u01;
	3. 从源库中导出数据
	[oracle@ocm ~]$ expdp hr/oracle tables=employees dumpfile=emp.dmp directory=exp_dir logfile=expemp.log
	[oracle@ocm ~]$ expdp -help
	4. 传文件到另一台机子
	[oracle@ocm exp]$ scp emp.dmp 192.168.21.3:/home/oracle/imp
	5. 目标库导入数据
	impdp u01/oracle dumpfile=emp.dmp directory=imp_dir remap_schema=hr:u01 remap_tablespace=example:users  logfile=imp_emp.log

	工作中一般用parfile
实验2: 导出导入schema
	在目标库中创建一个新用户	
	SQL> create user u02 identified by oracle account unlock;
	SQL> grant connect,resource to u02;
	SQL> grant all on directory imp_dir to u02;
	在源库中导出hr,并上传到目标库的/home/oracle/imp/目录
	SQL> conn hr/oracle
	SQL> select count(*) from tab;
	[oracle@ocm ~]$ expdp hr/oracle schemas=hr dumpfile=hr.dmp directory=exp_dir logfile=exp_hr.log
	SQL> select job_name,operation,job_mode,state from user_datapump_jobs;
	[oracle@ocm ~]$ cd /home/oracle/exp/
	[oracle@ocm exp]$ scp hr.dmp 192.168.21.3:/home/oracle/imp/
	在目标库中执行导入
	SQL> grant create view to u02;
	[oracle@oracle ~]$ impdp u02/oracle dumpfile=hr.dmp directory=imp_dir remap_schema=hr:u02 remap_tablespace=example:users logfile=imp_hr.log

	查看完整的建表语句
	通过PL/SQL Packages and Types Reference->87 DBMS_METADATA->GET_xxx Functions
	SQL> set long 2000
	SQL> set pagesize 50
	SQL> SELECT DBMS_METADATA.GET_DDL(object_type=>'TABLE',name=>'EMPLOYEES',schema=>'HR') from dual;
	
实验3: 导出导入表空间(一般用管理员用户导入导出)
	SQL> conn sys/oracle as sysdba
	SQL> select name from v$datafile;
	SQL> create tablespace tbs01 datafile '/u01/app/oracle/oradata/emrep/tbs01.dbf' size 10m;
	SQL> create table t1 tablespace tbs01 as select * from hr.employees;	
	[oracle@ocm ~]$ expdp hr/oracle tablespaces=tbs01 dumpfile=tbs01.dmp directory=exp_dir logfile=exp_tbs01.log
	[oracle@ocm exp]$ scp tbs01.dmp 192.168.21.3:/home/oracle/imp/  	
	--查询tablespace有那些用户
	SQL> select OWNER,SEGMENT_NAME,TABLESPACE_NAME from dba_segments where TABLESPACE_NAME='TBS01';
	SQL> select distinct OWNER from dba_segments where TABLESPACE_NAME='TBS01';	
	[oracle@oracle ~]$ impdp u02/oracle tablespaces=tbs01 dumpfile=tbs01.dmp directory=imp_dir remap_schema=hr:u02 remap_tablespace=tbs01:users logfile=imp_tbs01.log 
实验4: 导出导入全库



   
官方文档
Master Book List->UTI->Utilities->HTML
file:///D:/%E8%85%BE%E7%A7%91/%E5%AE%98%E6%96%B9%E6%96%87%E6%A1%A3/E11882_01/server.112/e22490/dp_export.htm#i1007466
--------------------------------------------------------------------
1. ORA-00845: MEMORY_TARGET not supported on this system
[root@ocm ~]# df -h | grep shm
tmpfs                1014M     0 1014M   0% /dev/shm
[root@ocm ~]# mount -t tmpfs shmfs -o size=2g /dev/shm  
1.初始化参数MEMORY_TARGET或MEMORY_MAX_TARGET不能大于共享内存(/dev/shm),为了解决这个问题，可以增大/dev/shm
如：
# mount -t tmpfs shmfs -o size=2g /dev/shm
2.为了确保操作系统重启之后能生效，需要修改/etc/fstab文件
shmfs /dev/shm tmpfs size=2g 0
3.如果/dev/shm没有挂载也会报上面的错，所认需要确保已经挂载
df -h
cat /etc/fstab | grep tmpfs
mount -o remount,size=2G /dev/shm
vi /etc/fstab
df -h|grep shm

ORA-00845: MEMORY_TARGET not supported on this system 
Oracle9i引入pga_aggregate_target，可以自动对PGA进行调整；
Oracle10引入sga_target，可以自动对SGA进行调整。
Oracle11g则对这两部分进行综合，引入memory_target，可以自动调整所有的内存，这就是新引入的自动内存管理特性。
下面我们通过以下的几个命令来让大家清楚memory_target 的设置与PGA与SGA的关系：
SQL> alter system set memory_target=200m scope=spfile;
SQL> alter system set sga_target=0 scope=spfile;
SQL> alter system set pga_aggregate_target=0 scope=spfile;
SQL> shutdown immediate
SQL> startup
设置memory_target参数后，实际上Oracle会自动设置并调整以下两个参数来分配SGA和PGA的内存，这和Oracle10g自动设置sga_target后分配db_cache_size和shared_pool_size的机制是一样的

修改/etc/fstab中tmpfs对应的行，
将原来的 tmpfs /dev/shm tmpfs defaults 0 0
改成 tmpfs /dev/shm tmpfs defaults,size=1024M 0 0 ，这样tmpfs增大为1G
size参数也可以用G作单位：size＝1G。
重新mount /dev/shm使之生效：
# mount -o remount /dev/shm
马上可以用"df -h"命令检查变化。


2. ORA-01017: invalid username/password; logon denied 
SQL> select username,account_status from dba_users where username='HR';
SQL> alter user hr account unlock identified by oracle;
SQL> conn hr/oracle