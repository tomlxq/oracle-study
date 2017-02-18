/*
<<<<<<< HEAD
ÅäÖÃem¹ÜÀíÆ÷
1. ´ò¿ªdbca
2. netmgr
	Ìí¼Ó¼àÌý
3.¡¡Æô¶¯¼àÌý lsnrctl start [your_listener_name] (listener control)
4.¡¡lsnrctl status ²é¿´¼àÌý×´Ì¬
=======
é…ç½®emç®¡ç†å™¨
1. æ‰“å¼€dbca
2. netmgr
	æ·»åŠ ç›‘å¬
3.ã€€å¯åŠ¨ç›‘å¬ lsnrctl start [your_listener_name] (listener control)
4.ã€€lsnrctl status æŸ¥çœ‹ç›‘å¬çŠ¶æ€
>>>>>>> 16549245ec5920ce1df0bd26dac116c65e15c408
	
	df -h
*/

su - oracle 
export display=192.168.21.1:0.0 
<<<<<<< HEAD
--win7ÖÐ´ò¿ªXmanager
dbca
--²é¿´µ±Ç°ÊµÀýµÄ×´Ì¬
select status from v$instance;
--Èç¹ûÃ»ÓÐ´ò¿ªÔò´ò¿ª
=======
--win7ä¸­æ‰“å¼€Xmanager
dbca
--æŸ¥çœ‹å½“å‰å®žä¾‹çš„çŠ¶æ€
select status from v$instance;
--å¦‚æžœæ²¡æœ‰æ‰“å¼€åˆ™æ‰“å¼€
>>>>>>> 16549245ec5920ce1df0bd26dac116c65e15c408
alter database open;


/*
<<<<<<< HEAD
ÔËÐÐDBCAÏÔÊ¾configureÑ¡ÏîÎª»ÒÉ«
ÐÞ¸Ä/etcÏÂµÄoratabÎÄ¼þ
=======
è¿è¡ŒDBCAæ˜¾ç¤ºconfigureé€‰é¡¹ä¸ºç°è‰²
ä¿®æ”¹/etcä¸‹çš„oratabæ–‡ä»¶
>>>>>>> 16549245ec5920ce1df0bd26dac116c65e15c408
vi /etc/oratab
orcl:/u01/app/oracle/product/11.2.0/db_1:<Y|N>
*/

/*
<<<<<<< HEAD
ÅäÖÃ¼àÌý
=======
é…ç½®ç›‘å¬
>>>>>>> 16549245ec5920ce1df0bd26dac116c65e15c408
su - oracle
export DISPLAY=192.168.21.1:0.0
netmgr/netca
host: oracle.localdomain
port: 1521
<<<<<<< HEAD
¹Ø±Õ´°¿ÚÊ±±£´æÒ»ÏÂ
=======
å…³é—­çª—å£æ—¶ä¿å­˜ä¸€ä¸‹
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
³¢ÊÔÉÏÊö²½ÖèÎÞÐ§ºó£¬·¢ÏÖremote_login_passwordfile²ÎÊýÔÚÖ®Ç°µÄ²âÊÔÖÐ±»ÐÞ¸ÄÁË£¬¸Ä»ØºóÖÕÓÚ³É¹¦
=======
å°è¯•ä¸Šè¿°æ­¥éª¤æ— æ•ˆåŽï¼Œå‘çŽ°remote_login_passwordfileå‚æ•°åœ¨ä¹‹å‰çš„æµ‹è¯•ä¸­è¢«ä¿®æ”¹äº†ï¼Œæ”¹å›žåŽç»ˆäºŽæˆåŠŸ
>>>>>>> 16549245ec5920ce1df0bd26dac116c65e15c408
SQL> show parameter remote
SQL> alter system set remote_login_passwordfile='exclusive' scope=spfile;
SQL> shutdown immediate

<<<<<<< HEAD
2. ORA-25153: Temporary Tablespace is Empty   ÁÙÊ±±í¿Õ¼äÎª¿Õ
	Í¨¹ýÓï¾ä²é¿´£¬ÁÙÊ±±í¿Õ¼äÈ·²»´æÔÚ¡£
	select FILE_NAME,TABLESPACE_NAME,STATUS from dba_temp_files;
	alter tablespace temp add tempfile '//oradata/orcl/temp01.dbf';
*/
/*µ±ÏµÍ³ÅäÖÃºÃÁË£¬https://oracle.example.com:1158/em
=======
2. ORA-25153: Temporary Tablespace is Empty   ä¸´æ—¶è¡¨ç©ºé—´ä¸ºç©º
	é€šè¿‡è¯­å¥æŸ¥çœ‹ï¼Œä¸´æ—¶è¡¨ç©ºé—´ç¡®ä¸å­˜åœ¨ã€‚
	select FILE_NAME,TABLESPACE_NAME,STATUS from dba_temp_files;
	alter tablespace temp add tempfile '//oradata/orcl/temp01.dbf';
*/
/*å½“ç³»ç»Ÿé…ç½®å¥½äº†ï¼Œhttps://oracle.example.com:1158/em
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

schema->Êý¾Ý¿â->±í¿Õ¼ä->¶Î->Çø->¿é
¿é´óÐ¡
	Èº¼¯Ò»°ãÊÇ4K¡¡
	µ¥ÊµÀý 8K
	show parameter db_block_size
*/
SELECT * FROM v$controlfile;
SELECT * FROM v$datafile;
SELECT * FROM v$log;
SELECT * FROM v$logfile;
SELECT * FROM v$instance;
SELECT * FROM v$database;
SELECT * FROM v$tablespace;

--ÈçºÎ¼Ç²»×¡ÈçºÎ²éÕÒ
desc v$tablespace;
select table_name from dict where table_name like '%TABLESPACE%';
--²éÕÒµ±Ç°Êý¾Ý¿âµÄ±í¿Õ¼ä
select TS#,name from v$tablespace;
--²éÕÒ±í¿Õ¼ä¼°¶ÔÓ¦µÄÂ·¾¶
desc dba_data_files;
col TABLESPACE for a10
col FILE_NAME for a45
select TABLESPACE_NAME,FILE_NAME from dba_data_files;
--²éÕÒ±í¿Õ¼ä¶ÔÓ¦µÄ±í
desc dba_tables;
select owner,table_name,TABLESPACE_NAME from dba_tables where TABLESPACE_NAME='USERS';
/*
ÏµÍ³±í¿Õ¼ä¶¼ÊÇÓÃ½Å±¾Î¬»¤µÄ
cd /u01/app/oracle/product/11.2.0/db_1/rdbms/admin/
--ÆäÖÐ×îÖØÒªµÄ½Å±¾ÓÐÁ½¸ö
ls -l catalog.sql
ls -l catproc.sql
ÏµÍ³±í¿Õ¼äsystemµÄÎïÐÔ:´æ·ÅÊý¾Ý×Öµä(²»ÄÜÍÑ»ú£¬²»ÄÜÖ»¶Á£¬²»ÄÜÖØÃüÃû£¬²»ÄÜÉ¾³ý)
	1.²»ÄÜÍÑ»ú£¨ÍÑ»úÁË²»ÄÜ·ÃÎÊÁË£©
	select name from v$tablespace;
	SQL> alter tablespace system offline;
	alter tablespace system offline
	*
	ERROR at line 1:
	ORA-01541: system tablespace cannot be brought offline; shut down if necessary

	alter tablespace users offline;
	select owner,table_name,TABLESPACE_NAME from dba_tables where TABLESPACE_NAME='USERS';
	select * from hr.jobs(´ËÊ±²»ÄÜ²é)
	alter tablespace users online;
	select * from hr.jobs(´ËÊ±¿ÉÒÔ²é)
	2.²»ÄÜÉèÖÃÎªÖ»¶Á
	SQL> alter tablespace system read only;
	alter tablespace system read only
	*
	ERROR at line 1:
	ORA-01643: system tablespace can not be made read-only
	3.²»ÄÜÖØÃüÃû
	SQL> alter tablespace system rename to system2;
	alter tablespace system rename to system2
	*
	ERROR at line 1:
	ORA-00712: cannot rename system tablespace
	4.²»ÄÜÉ¾³ý
	SQL> drop tablespace system including contents and datafiles;
	drop tablespace system including contents and datafiles
	*
	ERROR at line 1:
	ORA-01550: cannot drop system tablespace
¸¨Öú±í¿Õ¼äsysaux:´æÔÚÆäËü×é¼þ¡¡10gÒýÈë ¼õÇá¸ººÉ¡¢±ÜÃâËéÆ¬¡¢²»¿ÉÓÃÊ±£¬ºËÐÄ¹¦ÄÜÒÀÈ»¿ÉÓÃ¡¢¿ÉÍÑ»ú
ÁÙÊ±±í¿Õ¼ä£º´æ·ÅÁÙÊ±Êý¾Ý¡¡pga->ÁÙÊ±±í¿Õ¼ä,ÓÃÊ±·ÖÅä£¬¹Ø±Õ»ØÊÕ£¨ÅÅÐòÓÃµÄ±È½Ï¶à£©
	10g ÁÙÊ±±í¿Õ¼ä×é
	²é¿´´æ·ÅÎ»ÖÃ
	select FILE_NAME,TABLESPACE_NAME ,BYTES/1024/1024 from dba_data_files;
	create temporary tablespace temptbs1 tempfile '/oradata/orcl/temptbs1.dbf' size 2m tablespace group group1;
	create temporary tablespace temptbs2 tempfile '/oradata/orcl/temptbs2.dbf' size 2m tablespace group group2;
	²éÑ¯ÁÙÊ±±í¿Õ¼ä×é
	SQL> select * from dba_tablespace_groups;

	GROUP_NAME                     TABLESPACE_NAME
	------------------------------ ------------------------------
	GROUP1                         TEMPTBS1
	GROUP2                         TEMPTBS2
	ÒÆ¶¯ÁÙÊ±±í¿Õ×é
	alter tablespace TEMPTBS1 tablespace group group2; 
	ÎªÓÃ»§Ö¸¶¨ÁÙÊ±±í¿Õ¼ä×é
	alter user scott temporary tablespace group2;
	ÎªÕû¸öÊý¾Ý¿âÖ¸¶¨ÁÙ±í¿Õ
	SQL> alter database orcl default temporary tablespace group2;
	SQL> alter database default temporary tablespace group2;
	É¾³ýÁÙ±í¿Õ¼ä
	SQL> alter tablespace TEMPTBS1 tablespace group group1;
	SQL> drop tablespace TEMPTBS1 including contents and datafiles;
¹ÜÀí±í¿Õ¼äÖØÒªµÄ±í¼°ÊÓÍ¼ 
	dba_data_files¡¢dba_tables¡¢dba_free_spaces¡¢v$tablespace¡¢v$datafiles 
	ÉèÖÃÊý¾Ý¿âÄ¬ÈÏ±í¿Õ¼ä
	alter database default tablespace table_name
	SQL> col PROPERTY_VALUE for a30;
	SQL> col PROPERTY_NAME for a30;
	SQL> select  PROPERTY_NAME,PROPERTY_VALUE from database_properties where property_name like '%DEFAULT_%';

	PROPERTY_NAME                  PROPERTY_VALUE
	------------------------------ ------------------------------
	DEFAULT_TEMP_TABLESPACE        TEMP
	DEFAULT_PERMANENT_TABLESPACE   USERS¡¡¡¡¡¡Èç¹ûÓÃ»§Ã»ÓÐÖ¸¶¨±í¿Õ¼ä£¬¾Í»á°Ñ±í·ÅÔÚÕâÀï
	DEFAULT_EDITION                ORA$BASE
	DEFAULT_TBS_TYPE               SMALLFILE
	
	sqlplus / as sysdba;
	create table a(id number);
	SQL> select OWNER,TABLE_NAME,TABLESPACE_NAME from dba_tables where table_name='A';
	OWNER                          TABLE_NAME                     TABLESPACE
	------------------------------ ------------------------------ ----------
	SYS                            A                              SYSTEM
	ÆÕÍ¨ÓÃ»§´´½¨µÄ±íÊÇ·ÅÔÚÄ¬ÈÏ±í¿ÕµÄ
	SQL> conn scott/oracle
	SQL> create table a(id number);
	SQL> col owner for a10
	SQL> select OWNER,TABLE_NAME,TABLESPACE_NAME from dba_tables where table_name='A';
	OWNER      TABLE_NAME                     TABLESPACE_NAME
	---------- ------------------------------ ------------------------------
	SYS        A                              SYSTEM
	SCOTT      A                              USERS

	²éÑ¯ÓÃ»§µÄ±í¿Õ¼ä
	SQL> select username,default_tablespace from dba_users where username='SCOTT';

	USERNAME                       DEFAULT_TABLESPACE
	------------------------------ ------------------------------
	SCOTT                          USERS

²é¿´Êý¾ÝÎÄ¼þËùµãµÄ¿Õ¼ä´óÐ¡:
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
schema->æ•°æ®åº“->è¡¨ç©ºé—´->æ®µ->åŒº->å—
å—å¤§å°
	ç¾¤é›†ä¸€èˆ¬æ˜¯4Kã€€
	å•å®žä¾‹ 8K
	show parameter db_block_size
v$control v$log v$logfile v$instance v$database v$spacefile	
>>>>>>> 16549245ec5920ce1df0bd26dac116c65e15c408
*/