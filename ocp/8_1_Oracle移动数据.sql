迁移数据
	导入导出
	数据泵导入导出
		表: 用户存不存在，表空间存不存在，约束（是否要多表一起导出）
		表空间:　确认哪些不能导入，哪些导入不成功，不成功的对象是不是需要手工创建(DBMS_METADATA.GET_DDL(object_type=>'',name='',schema=>''))
		schema、
		database、
		传输表空间(跨平台): 
			1.检查平台　
			2.自包含（数据可能不在同样的表空间）
				表、索引、分区表、约束、lob
				file:///D:/%E8%85%BE%E7%A7%91/%E5%AE%98%E6%96%B9%E6%96%87%E6%A1%A3/E11882_01/server.112/e25494/tspaces013.htm
			3. read only导出　只导出元数据，表数据还在数据,dmp和dbf一同传输到target
			4. dbf和dmp传输
			5. 导入
			6. read write
		目录
			dumpfile=dump_dir:mydb_%U.dat
			directory=dump_dir dumpfile=mydb_%U.dat
			grant read,write | all on directory dump_dir to scott;
	sql*loader

exp		imp
源库	目标库
expdp	impdp





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
	[oracle@ocm ~]$ expdp dumpfile=full_%U.dmp directory=exp_dir parallel=4 full=y logfile=full_db.log
	SQL> select job_name,operation,job_mode,state from user_datapump_jobs;
	Ctr+c		不能停止备份
	help		查看帮助　
	status		查看状态
	[oracle@ocm ~]$ expdp attach=SYS_EXPORT_FULL_01 directory=exp_dir parallel=4　可以继续查看之前备份的情况
	[oracle@ocm exp]$ ps -ef | grep ora_ 查看死掉的进程
	SQL> desc user_datapump_jobs;
	 Name                                      Null?    Type
	 ----------------------------------------- -------- ----------------------------
	 JOB_NAME                                           VARCHAR2(30)
	 OPERATION                                          VARCHAR2(30)
	 JOB_MODE                                           VARCHAR2(30)
	 STATE                                              VARCHAR2(30)
	 DEGREE                                             NUMBER
	 ATTACHED_SESSIONS                                  NUMBER
	 DATAPUMP_SESSIONS                                  NUMBER
实验5: 传输表空间 
	SQL> EXECUTE DBMS_TTS.TRANSPORT_SET_CHECK('TBS01', TRUE);
	PL/SQL procedure successfully completed.
	SQL>  SELECT * FROM TRANSPORT_SET_VIOLATIONS;
	no rows selected
	SQL> ALTER TABLESPACE tbs01 READ ONLY; 先要设置为只读
	[oracle@ocm exp]$ expdp system dumpfile=expdat.dmp directory=exp_dir transport_tablespaces=tbs01 logfile=exp_tbs01.log
	查询是什么平台
	SQL> SELECT d.PLATFORM_NAME, ENDIAN_FORMAT　　　
	  2       FROM V$TRANSPORTABLE_PLATFORM tp, V$DATABASE d
	  3       WHERE tp.PLATFORM_NAME = d.PLATFORM_NAME;

	PLATFORM_NAME
	--------------------------------------------------------------------------------
	ENDIAN_FORMAT
	--------------
	Linux IA (32-bit)
	Little
	[oracle@ocm ~]$ rman target /
	RMAN> CONVERT TABLESPACE tbs01
		TO PLATFORM 'Linux IA (32-bit)'  
		FORMAT '/tmp/%U';
	将文件传到目标机子上
	[oracle@ocm exp]$ cd /tmp/
    [oracle@ocm tmp]$ scp data_D-EMREP_I-4159861329_TS-TBS01_FNO-6_01ru7scp  192.168.21.3:/tmp/
	[oracle@ocm exp]$ scp expdat.dmp 192.168.21.3:/home/oracle/imp/ 
	
	在目标平台
	[oracle@oracle ~]$ cd /tmp/
	[oracle@oracle tmp]$ mv data_D-EMREP_I-4159861329_TS-TBS01_FNO-6_01ru7scp tbs01.dbf
	RMAN>  CONVERT DATAFILE 
	'/tmp/tbs01.dbf'
	TO PLATFORM="Linux IA (32-bit)"
	FROM PLATFORM="Linux IA (32-bit)"
	DB_FILE_NAME_CONVERT=
	'/tmp/', '/home/oracle/imp/'
	PARALLELISM=4;
	SQL> create user u03 identified by oralce account unlock;
	SQL> grant connect,resource to u03;
	[oracle@oracle prod]$ impdp system/oracle dumpfile=expdat.dmp directory=imp_dir transport_datafiles=/u01/app/oracle/oradata/prod/tbs01.dbf remap_schema=hr:u03 logfile=imp_trans_tbs01.log
	ORA-39123: Data Pump transportable tablespace job aborted
	ORA-29345: cannot plug a tablespace into a database using an incompatible character set

	ORA-29345: cannot plug a tablespace into a database using an incompatible character set
	说明字符集不一样
	192.168.21.3
	SQL> select userenv('language') from dual;　
	AMERICAN_AMERICA.WE8MSWIN1252
	192.168.21.4
	SQL> select userenv('language') from dual;
	AMERICAN_AMERICA.AL32UTF8
	
	192.168.21.3
	SQL> alter system enable restricted session;
	SQL> alter database character set AL32UTF8;
	alter database character set AL32UTF8
	*
	ERROR at line 1:
	ORA-12712: new character set must be a superset of old character set
	SQL> alter database character set internal_use  AL32UTF8;
	SQL> alter system disable restricted session;
	
	
	SQL> alter tablespace t3 read write;
	传输表空间的官方文档　
	Master Book List->Administrator's Guide->Transporting Tablespaces Between Databases
实验6: DB link	
	源机器中配置好listener.ora,tnsnames.ora
	[oracle@ocm admin]$ lsnrctl start
	SQL> alter user scott identified by oracle account unlock;
	目标库配置好listener.ora,tnsnames.ora、创建db link
	[oracle@oracle prod]$ cat /etc/hosts
	# Do not remove the following line, or various programs
	# that require network functionality will fail.
	127.0.0.1     localhost.localdomain localhost
	::1             localhost6.localdomain6 localhost6
	192.168.21.3 oracle.example.com oracle
	192.168.21.4 ocm.example.com ocm
	[oracle@oracle prod]$ cat /u01/app/oracle/product/11.2.0/db_1/network/admin/tnsnames.ora 
	ORCL =
	  (DESCRIPTION =
		(ADDRESS = (PROTOCOL = TCP)(HOST = oracle.example.com)(PORT = 1521))
		(CONNECT_DATA =
		  (SERVER = DEDICATED)
		  (SERVICE_NAME = orcl)
		)
	  )

	emrep =
	  (DESCRIPTION =
		(ADDRESS = (PROTOCOL = TCP)(HOST = ocm.example.com)(PORT = 1521))
		(CONNECT_DATA =
		  (SERVER = DEDICATED)
		  (SERVICE_NAME = emrep)
		)
	  )
	[root@ocm ~]# ls -ltr .    
	SQL> select table_name from dict where table_name like '%LINK%';
	SQL> select * from dba_db_links;
	SQL> create public database link scott_emrep connect to scott identified by oracle using 'emrep';
	SQL> select * from dept@scott_emrep;
	SQL> grant exp_full_database to u01;
	[oracle@oracle ~]$ expdp u01/oracle directory=imp_dir network_link=scott_emrep dumpfile=scott_dept.dmp tables=scott.dept
	[oracle@oracle ~]$ impdp u01/oracle directory=imp_dir dumpfile=scott_dept.dmp remap_schema=scott:u01
	
	
实验7: 直接导入	
	SQL> create user u04 identified by oralce account unlock;
	SQL> grant connect,resource,imp_full_database to u04;
	SQL> grant all on directory imp_dir to u04;
	[oracle@oracle ~]$ impdp u04/oracle directory=imp_dir network_link=scott_emrep tables=scott.emp remap_schema=scott:u04;
	[oracle@oracle ~]$ impdp u04/oracle  network_link=scott_emrep tables=scott.dept remap_schema=scott:u04;
	[oracle@oracle ~]$ sqlplus u04/oracle 
	SQL> select count(*) from u04.dept;
	SQL> select count(*) from u04.emp;
	
	
	SQL> select count(*) from u04.emp;
	SQL> delete from u04.emp where empno>7900;
	SQL> select current_scn from v$database;
	CURRENT_SCN
	-----------
		1031062
	SQL> commit;
	SQL> select count(*) from u04.emp;
	  COUNT(*)
	----------
			12
	SQL> select count(*) from u04.emp as of scn 1031062;
	  COUNT(*)
	----------
			14
	expdp u04/oracle directory=imp_dir dumpfile=emp.dmp tables=emp logfile=exp_emp.log;
		
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

3. 解决no listener的错误
[root@ocm ~]# vi /etc/hosts
# Do not remove the following line, or various programs
# that require network functionality will fail.
127.0.0.1       localhost.localdomain localhost
::1             localhost6.localdomain6 localhost6
192.168.21.4    ocm.example.com ocm 
192.168.21.3    oracle.example.com oracle
[oracle@ocm admin]$ cat /u01/app/oracle/product/11.2.0/db_1/network/admin/listener.ora 
SID_LIST_LISTENER=
(SID_LIST=
        (SID_DESC=
                (GLOBAL_DBNAME=emrep)
                (ORACLE_HOME=/u01/app/oracle/product/11.2.0/db_1)
                (SID_NAME=emrep)
        )
)
LISTENER =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = ocm.example.com)(PORT = 1521))
  )

ADR_BASE_LISTENER = /u01/app/oracle
[oracle@ocm admin]$ cat /u01/app/oracle/product/11.2.0/db_1/network/admin/tnsnames.ora 
emrep =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = ocm.example.com)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = emrep)
    )
  )
  [oracle@ocm admin]$ lsnrctl start
  [oracle@ocm admin]$ lsnrctl status
  [oracle@ocm admin]$ tnsping emrep

4.ORA-39213: Metadata processing is not available
[oracle@oracle ~]$ expdp u01/oracle directory=imp_dir network_link=scott_emrep dumpfile=scott_dept.dmp tables=scott.dept
ORA-39006: internal error
ORA-39213: Metadata processing is not available
[oracle@oracle ~]$ oerr ora 39213
39213, 00000, "Metadata processing is not available"
// *Cause:  The Data Pump could not use the Metadata API.  Typically,
//          this is caused by the XSL stylesheets not being set up properly.
// *Action: Connect AS SYSDBA and execute dbms_metadata_util.load_stylesheets
//          to reload the stylesheets.
[oracle@oracle ~]$ sqlplus  sys/oracle@prod as sysdba  
SQL> execute dbms_metadata_util.load_stylesheets

5.
[oracle@oracle ~]$ expdp u01/oracle directory=imp_dir network_link=scott_emrep dumpfile=scott_dept.dmp tables=scott.dept
ORA-31631: privileges are required
ORA-39149: cannot link privileged user to non-privileged user
去源机子
[oracle@ocm exp]$ sqlplus sys/oracle@emrep as sysdba   
SQL> grant exp_full_database to scott;
