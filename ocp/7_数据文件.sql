/*
<<<<<<< HEAD
����em������
1. ��dbca
2. netmgr
	��Ӽ���
3.���������� lsnrctl start [your_listener_name] (listener control)
4.��lsnrctl status �鿴����״̬
=======
配置em管理器
1. 打开dbca
2. netmgr
	添加监听
3.　启动监听 lsnrctl start [your_listener_name] (listener control)
4.　lsnrctl status 查看监听状态
>>>>>>> 16549245ec5920ce1df0bd26dac116c65e15c408
	
	df -h
*/

su - oracle 
export display=192.168.21.1:0.0 
<<<<<<< HEAD
--win7�д�Xmanager
dbca
--�鿴��ǰʵ����״̬
select status from v$instance;
--���û�д����
=======
--win7中打开Xmanager
dbca
--查看当前实例的状态
select status from v$instance;
--如果没有打开则打开
>>>>>>> 16549245ec5920ce1df0bd26dac116c65e15c408
alter database open;


/*
<<<<<<< HEAD
����DBCA��ʾconfigureѡ��Ϊ��ɫ
�޸�/etc�µ�oratab�ļ�
=======
运行DBCA显示configure选项为灰色
修改/etc下的oratab文件
>>>>>>> 16549245ec5920ce1df0bd26dac116c65e15c408
vi /etc/oratab
orcl:/u01/app/oracle/product/11.2.0/db_1:<Y|N>
*/

/*
<<<<<<< HEAD
���ü���
=======
配置监听
>>>>>>> 16549245ec5920ce1df0bd26dac116c65e15c408
su - oracle
export DISPLAY=192.168.21.1:0.0
netmgr/netca
host: oracle.localdomain
port: 1521
<<<<<<< HEAD
�رմ���ʱ����һ��
=======
关闭窗口时保存一下
>>>>>>> 16549245ec5920ce1df0bd26dac116c65e15c408
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

<<<<<<< HEAD
��������������Ч�󣬷���remote_login_passwordfile������֮ǰ�Ĳ����б��޸��ˣ��Ļغ����ڳɹ�
=======
尝试上述步骤无效后，发现remote_login_passwordfile参数在之前的测试中被修改了，改回后终于成功
>>>>>>> 16549245ec5920ce1df0bd26dac116c65e15c408
SQL> show parameter remote
SQL> alter system set remote_login_passwordfile='exclusive' scope=spfile;
SQL> shutdown immediate

<<<<<<< HEAD
2. ORA-25153: Temporary Tablespace is Empty   ��ʱ��ռ�Ϊ��
	ͨ�����鿴����ʱ��ռ�ȷ�����ڡ�
	select FILE_NAME,TABLESPACE_NAME,STATUS from dba_temp_files;
	alter tablespace temp add tempfile '//oradata/orcl/temp01.dbf';
*/
/*��ϵͳ���ú��ˣ�https://oracle.example.com:1158/em
=======
2. ORA-25153: Temporary Tablespace is Empty   临时表空间为空
	通过语句查看，临时表空间确不存在。
	select FILE_NAME,TABLESPACE_NAME,STATUS from dba_temp_files;
	alter tablespace temp add tempfile '//oradata/orcl/temp01.dbf';
*/
/*当系统配置好了，https://oracle.example.com:1158/em
>>>>>>> 16549245ec5920ce1df0bd26dac116c65e15c408
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
<<<<<<< HEAD
/*
SQL> conn scott/oracle;
SQL> select * from tab;

schema->���ݿ�->��ռ�->��->��->��
���С
	Ⱥ��һ����4K��
	��ʵ�� 8K
	show parameter db_block_size
*/
SELECT * FROM v$controlfile;
SELECT * FROM v$datafile;
SELECT * FROM v$log;
SELECT * FROM v$logfile;
SELECT * FROM v$instance;
SELECT * FROM v$database;
SELECT * FROM v$tablespace;

--��μǲ�ס��β���
desc v$tablespace;
select table_name from dict where table_name like '%TABLESPACE%';
--���ҵ�ǰ���ݿ�ı�ռ�
select TS#,name from v$tablespace;
--���ұ�ռ估��Ӧ��·��
desc dba_data_files;
col TABLESPACE for a10
col FILE_NAME for a45
select TABLESPACE_NAME,FILE_NAME from dba_data_files;
--���ұ�ռ��Ӧ�ı�
desc dba_tables;
select owner,table_name,TABLESPACE_NAME from dba_tables where TABLESPACE_NAME='USERS';
/*
ϵͳ��ռ䶼���ýű�ά����
cd /u01/app/oracle/product/11.2.0/db_1/rdbms/admin/
--��������Ҫ�Ľű�������
ls -l catalog.sql
ls -l catproc.sql
ϵͳ��ռ�system������:��������ֵ�(�����ѻ�������ֻ��������������������ɾ��)
	1.�����ѻ����ѻ��˲��ܷ����ˣ�
	select name from v$tablespace;
	SQL> alter tablespace system offline;
	alter tablespace system offline
	*
	ERROR at line 1:
	ORA-01541: system tablespace cannot be brought offline; shut down if necessary

	alter tablespace users offline;
	select owner,table_name,TABLESPACE_NAME from dba_tables where TABLESPACE_NAME='USERS';
	select * from hr.jobs(��ʱ���ܲ�)
	alter tablespace users online;
	select * from hr.jobs(��ʱ���Բ�)
	2.��������Ϊֻ��
	SQL> alter tablespace system read only;
	alter tablespace system read only
	*
	ERROR at line 1:
	ORA-01643: system tablespace can not be made read-only
	3.����������
	SQL> alter tablespace system rename to system2;
	alter tablespace system rename to system2
	*
	ERROR at line 1:
	ORA-00712: cannot rename system tablespace
	4.����ɾ��
	SQL> drop tablespace system including contents and datafiles;
	drop tablespace system including contents and datafiles
	*
	ERROR at line 1:
	ORA-01550: cannot drop system tablespace
������ռ�sysaux:�������������10g���� ���Ḻ�ɡ�������Ƭ��������ʱ�����Ĺ�����Ȼ���á����ѻ�
��ʱ��ռ䣺�����ʱ���ݡ�pga->��ʱ��ռ�,��ʱ���䣬�رջ��գ������õıȽ϶ࣩ
	10g ��ʱ��ռ���
	�鿴���λ��
	select FILE_NAME,TABLESPACE_NAME ,BYTES/1024/1024 from dba_data_files;
	create temporary tablespace temptbs1 tempfile '/oradata/orcl/temptbs1.dbf' size 2m tablespace group group1;
	create temporary tablespace temptbs2 tempfile '/oradata/orcl/temptbs2.dbf' size 2m tablespace group group2;
	��ѯ��ʱ��ռ���
	SQL> select * from dba_tablespace_groups;

	GROUP_NAME                     TABLESPACE_NAME
	------------------------------ ------------------------------
	GROUP1                         TEMPTBS1
	GROUP2                         TEMPTBS2
	�ƶ���ʱ�����
	alter tablespace TEMPTBS1 tablespace group group2; 
	Ϊ�û�ָ����ʱ��ռ���
	alter user scott temporary tablespace group2;
	Ϊ�������ݿ�ָ���ٱ��
	SQL> alter database orcl default temporary tablespace group2;
	SQL> alter database default temporary tablespace group2;
	ɾ���ٱ�ռ�
	SQL> alter tablespace TEMPTBS1 tablespace group group1;
	SQL> drop tablespace TEMPTBS1 including contents and datafiles;
�����ռ���Ҫ�ı���ͼ 
	dba_data_files��dba_tables��dba_free_spaces��v$tablespace��v$datafiles 
	�������ݿ�Ĭ�ϱ�ռ�
	alter database default tablespace table_name
	SQL> col PROPERTY_VALUE for a30;
	SQL> col PROPERTY_NAME for a30;
	SQL> select  PROPERTY_NAME,PROPERTY_VALUE from database_properties where property_name like '%DEFAULT_%';

	PROPERTY_NAME                  PROPERTY_VALUE
	------------------------------ ------------------------------
	DEFAULT_TEMP_TABLESPACE        TEMP
	DEFAULT_PERMANENT_TABLESPACE   USERS����������û�û��ָ����ռ䣬�ͻ�ѱ��������
	DEFAULT_EDITION                ORA$BASE
	DEFAULT_TBS_TYPE               SMALLFILE
	
	sqlplus / as sysdba;
	create table a(id number);
	SQL> select OWNER,TABLE_NAME,TABLESPACE_NAME from dba_tables where table_name='A';
	OWNER                          TABLE_NAME                     TABLESPACE
	------------------------------ ------------------------------ ----------
	SYS                            A                              SYSTEM
	��ͨ�û������ı��Ƿ���Ĭ�ϱ�յ�
	SQL> conn scott/oracle
	SQL> create table a(id number);
	SQL> col owner for a10
	SQL> select OWNER,TABLE_NAME,TABLESPACE_NAME from dba_tables where table_name='A';
	OWNER      TABLE_NAME                     TABLESPACE_NAME
	---------- ------------------------------ ------------------------------
	SYS        A                              SYSTEM
	SCOTT      A                              USERS

	��ѯ�û��ı�ռ�
	SQL> select username,default_tablespace from dba_users where username='SCOTT';

	USERNAME                       DEFAULT_TABLESPACE
	------------------------------ ------------------------------
	SCOTT                          USERS

�鿴�����ļ�����Ŀռ��С:
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
=======

SQL> conn scott/oracle;
SQL> select * from tab;
/*
schema->数据库->表空间->段->区->块
块大小
	群集一般是4K　
	单实例 8K
	show parameter db_block_size
v$control v$log v$logfile v$instance v$database v$spacefile	
>>>>>>> 16549245ec5920ce1df0bd26dac116c65e15c408
*/