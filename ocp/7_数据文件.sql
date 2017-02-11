/*
配置em管理器
1. 打开dbca
2. netmgr
	添加监听
3.　启动监听 lsnrctl start [your_listener_name] (listener control)
4.　lsnrctl status 查看监听状态
	
	df -h
*/

su - oracle 
export display=192.168.21.1:0.0 
--win7中打开Xmanager
dbca
--查看当前实例的状态
select status from v$instance;
--如果没有打开则打开
alter database open;


/*
运行DBCA显示configure选项为灰色
修改/etc下的oratab文件
vi /etc/oratab
orcl:/u01/app/oracle/product/11.2.0/db_1:<Y|N>
*/

/*
配置监听
su - oracle
export DISPLAY=192.168.21.1:0.0
netmgr/netca
host: oracle.localdomain
port: 1521
关闭窗口时保存一下
lsnrctl start
*/


/*
https://oralce.example.com:1158/em
sys/oracle 
connect as sysdba
*/
/*
1. EMCA fails with error "ORA-01017: invalid username/password; logon denied"
Cause
SYS password is invalid.
Solution
1) drop existing dbcontrol 
  $ emca -deconfig dbcontrol db -repos drop
2) reset SYS password (also in password file, if using)
3) create the dbcontrol
  $ emca -config dbcontrol -repos create

尝试上述步骤无效后，发现remote_login_passwordfile参数在之前的测试中被修改了，改回后终于成功
SQL> show parameter remote
SQL> alter system set remote_login_passwordfile='exclusive' scope=spfile;
SQL> shutdown immediate

2. ORA-25153: Temporary Tablespace is Empty   临时表空间为空
	通过语句查看，临时表空间确不存在。
	select FILE_NAME,TABLESPACE_NAME,STATUS from dba_temp_files;
	alter tablespace temp add tempfile '//oradata/orcl/temp01.dbf';
*/
/*当系统配置好了，https://oracle.example.com:1158/em
more /u01/app/oracle/product/11.2.0/db_1/install/portlist.ini 
Enterprise Manager Console HTTP Port (orcl) = 1158
Enterprise Manager Agent Port (orcl) = 3938
*/
more portlist.ini 
pwd
/u01/app/oracle/product/11.2.0/db_1/install


cd /media/Enterprise\ Linux\ dvd\ 20090908/
cd Server/
rpm -ivh firefox-3.0.12-1.0.1.el5_3.i386.rpm

firefox https://oracle.example.com:1158/em
/*
SQL> conn scott/oracle;
SQL> select * from tab;

schema->数据库->表空间->段->区->块
块大小
	群集一般是4K　
	单实例 8K
	show parameter db_block_size
*/
SELECT * FROM v$controlfile;
SELECT * FROM v$datafile;
SELECT * FROM v$log;
SELECT * FROM v$logfile;
SELECT * FROM v$instance;
SELECT * FROM v$database;
SELECT * FROM v$tablespace;

--如何记不住如何查找
desc v$tablespace;
select table_name from dict where table_name like '%TABLESPACE%';
--查找当前数据库的表空间
select TS#,name from v$tablespace;
--查找表空间及对应的路径
desc dba_data_files;
col TABLESPACE for a10
col FILE_NAME for a45
select TABLESPACE_NAME,FILE_NAME from dba_data_files;
--查找表空间对应的表
desc dba_tables;
select owner,table_name,TABLESPACE_NAME from dba_tables where TABLESPACE_NAME='USERS';
/*
系统表空间都是用脚本维护的
cd /u01/app/oracle/product/11.2.0/db_1/rdbms/admin/
--其中最重要的脚本有两个
ls -l catalog.sql
ls -l catproc.sql
系统表空间system的物性:存放数据字典(不能脱机，不能只读，不能重命名，不能删除)
	1.不能脱机（脱机了不能访问了）
	select name from v$tablespace;
	SQL> alter tablespace system offline;
	alter tablespace system offline
	*
	ERROR at line 1:
	ORA-01541: system tablespace cannot be brought offline; shut down if necessary

	alter tablespace users offline;
	select owner,table_name,TABLESPACE_NAME from dba_tables where TABLESPACE_NAME='USERS';
	select * from hr.jobs(此时不能查)
	alter tablespace users online;
	select * from hr.jobs(此时可以查)
	2.不能设置为只读
	SQL> alter tablespace system read only;
	alter tablespace system read only
	*
	ERROR at line 1:
	ORA-01643: system tablespace can not be made read-only
	3.不能重命名
	SQL> alter tablespace system rename to system2;
	alter tablespace system rename to system2
	*
	ERROR at line 1:
	ORA-00712: cannot rename system tablespace
	4.不能删除
	SQL> drop tablespace system including contents and datafiles;
	drop tablespace system including contents and datafiles
	*
	ERROR at line 1:
	ORA-01550: cannot drop system tablespace
辅助表空间sysaux:存在其它组件　10g引入 减轻负荷、避免碎片、不可用时，核心功能依然可用、可脱机
临时表空间：存放临时数据　pga->临时表空间,用时分配，关闭回收（排序用的比较多）
	10g 临时表空间组
	查看存放位置
	select FILE_NAME,TABLESPACE_NAME ,BYTES/1024/1024 from dba_data_files;
	create temporary tablespace temptbs1 tempfile '/oradata/orcl/temptbs1.dbf' size 2m tablespace group group1;
	create temporary tablespace temptbs2 tempfile '/oradata/orcl/temptbs2.dbf' size 2m tablespace group group2;
	查询临时表空间组
	SQL> select * from dba_tablespace_groups;

	GROUP_NAME                     TABLESPACE_NAME
	------------------------------ ------------------------------
	GROUP1                         TEMPTBS1
	GROUP2                         TEMPTBS2
	移动临时表空组
	alter tablespace TEMPTBS1 tablespace group group2; 
	为用户指定临时表空间组
	alter user scott temporary tablespace group2;
	为整个数据库指定临表空
	SQL> alter database orcl default temporary tablespace group2;
	SQL> alter database default temporary tablespace group2;
	删除临表空间
	SQL> alter tablespace TEMPTBS1 tablespace group group1;
	SQL> drop tablespace TEMPTBS1 including contents and datafiles;
管理表空间重要的表及视图 
	dba_data_files、dba_tables、dba_free_spaces、v$tablespace、v$datafiles 
	设置数据库默认表空间
	alter database default tablespace table_name
	SQL> col PROPERTY_VALUE for a30;
	SQL> col PROPERTY_NAME for a30;
	SQL> select  PROPERTY_NAME,PROPERTY_VALUE from database_properties where property_name like '%DEFAULT_%';

	PROPERTY_NAME                  PROPERTY_VALUE
	------------------------------ ------------------------------
	DEFAULT_TEMP_TABLESPACE        TEMP
	DEFAULT_PERMANENT_TABLESPACE   USERS　　　如果用户没有指定表空间，就会把表放在这里
	DEFAULT_EDITION                ORA$BASE
	DEFAULT_TBS_TYPE               SMALLFILE
	
	sqlplus / as sysdba;
	create table a(id number);
	SQL> select OWNER,TABLE_NAME,TABLESPACE_NAME from dba_tables where table_name='A';
	OWNER                          TABLE_NAME                     TABLESPACE
	------------------------------ ------------------------------ ----------
	SYS                            A                              SYSTEM
	普通用户创建的表是放在默认表空的
	SQL> conn scott/oracle
	SQL> create table a(id number);
	SQL> col owner for a10
	SQL> select OWNER,TABLE_NAME,TABLESPACE_NAME from dba_tables where table_name='A';
	OWNER      TABLE_NAME                     TABLESPACE_NAME
	---------- ------------------------------ ------------------------------
	SYS        A                              SYSTEM
	SCOTT      A                              USERS

	查询用户的表空间
	SQL> select username,default_tablespace from dba_users where username='SCOTT';

	USERNAME                       DEFAULT_TABLESPACE
	------------------------------ ------------------------------
	SCOTT                          USERS

查看数据文件所点的空间大小:
1. 
	SQL> col file_name for a30
	SQL> select FILE_NAME,TABLESPACE_NAME ,BYTES/1024/1024 from dba_data_files;

	FILE_NAME                      TABLESPACE_NAME                BYTES/1024/1024
	------------------------------ ------------------------------ ---------------
	/oradata/orcl/user01.dbf       USERS                                      100
	/oradata/orcl/sysaux01.dbf     SYSAUX                                     800
	/oradata/orcl/system01.dbf     SYSTEM                                    1000
	/oradata/orcl/undotbs2.dbf     UNDOTBS2                                    50
	/u01/app/oracle/dbda           FBDA1
2. 
	cd /oradata/orcl/ 
	du -sh/du -h
*/