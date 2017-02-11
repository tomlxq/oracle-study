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

SQL> conn scott/oracle;
SQL> select * from tab;
/*
schema->数据库->表空间->段->区->块
块大小
	群集一般是4K　
	单实例 8K
	show parameter db_block_size
v$control v$log v$logfile v$instance v$database v$spacefile	
*/