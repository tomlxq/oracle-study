备份
	nocatalog
		控制文件（$ORACLE_HOME/dbs/iniSID.ora，control_file_record_keep_time）
			list backup
			启动控制文件自动备份 rman中configure controlfile autobackup on | off;
			记录dbid
			控制文件冗余到不同的磁盘
			保留所有的rman备份日志
	catalog
		恢复目录到一个专有的数据库中
		catalog：恢复目录数据库
		target:　目录数据库
		
		
		
	
RMAN> list backup;

[oracle@oracle ~]$ ls $ORACLE_HOME/dbs/
[oracle@oracle ~]$ export DISPLAY=192.168.21.1:0.0
[oracle@oracle ~]$ dbca　新建一个数据库emrep（取消em,取消recover erea,安装schema simple）
orcl: target
emrep:catalog
	创建用户，表空间
	创建catalog,设置catalog数据存存放在该表空间
	注册数据库
[oracle@oracle ~]$ export ORACLE_SID=emrep
[oracle@oracle ~]$ echo $ORACLE_SID
[oracle@oracle ~]$ su -
[root@oracle ~]# mkdir -p /oradata/emrep
[root@oracle ~]# chown -R oracle.oinstall /oradata/emrep
drop tablespace rc_data including contents and datafiles cascade constraints;
SQL> create tablespace rc_data 
    datafile '/u01/app/oracle/oradata/emrep/rc_data01.dbf' size 100m
    autoextend on next 10m
    extent management local
    segment space management auto;
SQL> create user rc_admin identified by oracle default tablespace rc_data;
SQL> grant connect,resource,recovery_catalog_owner to rc_admin; --recovery_catalog_owner会创始表和视图，用来存备份信息 
[oracle@oracle ~]$ su - oracle
[oracle@oracle ~]$ lsnrctl start
[oracle@oracle ~]$ rman catalog rc_admin/oracle@127.0.0.1:1521/emrep
--配置一下服务
[oracle@oracle ~]$ vi /u01/app/oracle/product/11.2.0/db_1/network/admin/tnsnames.ora 
EMREP_S =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = oracle.example.com)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = emrep)
    )
  )
--配置完成后ping一下
[oracle@oracle ~]$ tnsping emrep_s
--现在可以用emrep_s代替127.0.0.1:1521/emrep
[oracle@oracle ~]$ rman catalog rc_admin/oracle@emrep_s 
RMAN> create catalog tablespace rc_data;
切到orcl
[oracle@oracle ~]$ echo $ORACLE_SID
orcl
[oracle@oracle ~]$ rman target / catalog rc_admin/oracle@emrep_s
RMAN> register database;
RMAN> resync catalog;
RMAN> unregister database;  --取消注册
RMAN> drop catalog;
切到emrep
[oracle@oracle ~]$ echo $ORACLE_SID
emrep
[oracle@oracle ~]$ sqlplus / as sysdba
SQL> conn rc_admin/oracle;
SQL> select * from tab;
SQL> select * from RC_DATABASE;
    DB_KEY  DBINC_KEY       DBID NAME     RESETLOGS_CHANGE# RESETLOGS
---------- ---------- ---------- -------- ----------------- ---------
         1          2 1461627167 ORCL               1435092 19-FEB-17

注意：
	rman target /									不会写到catalog库
	rman target / catalog rc_admin/oracle@emrep_s	会写到catalog库
	
	
	[oracle@oracle dbs]$ df -h | grep shm 
	