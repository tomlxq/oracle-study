--1. 该动态性能视图用于列出所有可用的动态性能视图和动态性能表
SQL> select name from v$fixed_table where name like 'V$%';

--2. 获取当前例程的详细信息
SQL> set linesize 300
SQL> select instance_name,host_name,status from v$instance;

INSTANCE_NAME    HOST_NAME                                                        STATUS
---------------- ---------------------------------------------------------------- ------------
orcl             oel.example.com                                                  OPEN

--3. 显示SGA主要组成部分
SQL> select * from v$sga;

NAME                      VALUE
-------------------- ----------
Fixed Size              1348244
Variable Size         503319916
Database Buffers      339738624
Redo Buffers            5124096

--4. 取得SGA的更详细信息
SQL> select * from  V$SGAINFO;

NAME                                                    BYTES RES
-------------------------------------------------- ---------- ---
Fixed SGA Size                                        1348244 No
Redo Buffers                                          5124096 No
Buffer Cache Size                                   339738624 Yes
Shared Pool Size                                    150994944 Yes
Large Pool Size                                       4194304 Yes
Java Pool Size                                        4194304 Yes
Streams Pool Size                                           0 Yes
Shared IO Pool Size                                         0 Yes
Granule Size                                          4194304 No
Maximum SGA Size                                    849530880 No
Startup overhead in Shared Pool                      58326776 No

NAME                                                    BYTES RES
-------------------------------------------------- ---------- ---
Free SGA Memory Available                           343932928

12 rows selected.

--5. 取得初始化参数的详细信息
SQL> col DESCRIPTION for a50
SQL> select name,value,description from v$parameter where name='db_name';

NAME       VALUE                DESCRIPTION
---------- -------------------- --------------------------------------------------
db_name    orcl                 database name specified in CREATE DATABASE

--5. 获取ORACLE版本的详细信息
SQL> select * from v$version;

BANNER
--------------------------------------------------------------------------------
Oracle Database 11g Enterprise Edition Release 11.2.0.3.0 - Production
PL/SQL Release 11.2.0.3.0 - Production
CORE    11.2.0.3.0      Production
TNS for Linux: Version 11.2.0.3.0 - Production
NLSRTL Version 11.2.0.3.0 - Production

--7. 显示已经安装的ORACLE选项
SQL> select * from V$OPTION;

PARAMETER                                                        VALUE
---------------------------------------------------------------- -----------------------------------
Partitioning                                                     TRUE
Objects                                                          TRUE
Real Application Clusters                                        FALSE
Advanced replication                                             TRUE
Bit-mapped indexes                                               TRUE
Connection multiplexing                                          TRUE
Connection pooling                                               TRUE
Database queuing                                                 TRUE
Incremental backup and recovery                                  TRUE
Instead-of triggers                                              TRUE
Parallel backup and recovery                                     TRUE
...

--9. V$SESSION 显示会话的详细信息
SQL> select sid,serial#,username from v$session where username is not null;

       SID    SERIAL# USERNAME
---------- ---------- ------------------------------
         1          3 SYS
		
--9．V$PROCESS 显示与ORACLE相关的所有进程信息（包括后台进程和服务器进程）
SQL> select a.terminal,a.spid,a.pga_alloc_mem from v$process a,v$session b where a.addr=b.paddr and b.username='SYS';

TERMINAL                       SPID                     PGA_ALLOC_MEM
------------------------------ ------------------------ -------------
UNKNOWN                        15063                          1250788


--10. V$BGPROCESS 显示后台进程详细信息
SQL> select name,description from v$bgprocess where paddr!='00';

NAME  DESCRIPTION
----- ----------------------------------------------------------------
PMON  process cleanup
VKTM  Virtual Keeper of TiMe process
GEN0  generic0
DIAG  diagnosibility process
DBRM  DataBase Resource Manager
VKRM  Virtual sKeduler for Resource Manager
PSP0  process spawner 0
DIA0  diagnosibility process 0
MMAN  Memory Manager
DBW0  db writer process 0
LGWR  Redo etc.

NAME  DESCRIPTION
----- ----------------------------------------------------------------
CKPT  checkpoint
SMON  System Monitor Process
SMCO  Space Manager Process
RECO  distributed recovery
CJQ0  Job Queue Coordinator
QMNC  AQ Coordinator
MMON  Manageability Monitor Process
MMNL  Manageability Monitor Process 2

19 rows selected.

--11. V$DATABASE 取得当前数据库的详细信息
SQL> select name,log_mode,created from v$database;

NAME      LOG_MODE     CREATED
--------- ------------ ---------
ORCL      NOARCHIVELOG 25-MAR-17

--12. 取得当前数据库所有控制文件的信息
SQL> select file#,name,bytes from v$controlfile;

NAME
--------------------------------------------------------------------------------
/u01/app/oracle/oradata/orcl/control01.ctl
/u01/app/oracle/oradata/orcl/control02.ctl

--13. V$DATAFILE 取得当前数据库的所有数据文件的详细信息
SQL> select file#,name,bytes from v$datafile;

     FILE# NAME                                                    BYTES
---------- -------------------------------------------------- ----------
         1 /u01/app/oracle/oradata/orcl/system01.dbf           754974720
         2 /u01/app/oracle/oradata/orcl/sysaux01.dbf           555745280
         3 /u01/app/oracle/oradata/orcl/undotbs01.dbf           57671680
         4 /u01/app/oracle/oradata/orcl/users01.dbf              5242880
         5 /u01/app/oracle/oradata/orcl/example01.dbf          362414080
--14. V$DBFILE 取得数据文件编号及名称
SQL> select * from v$dbfile;

     FILE# NAME
---------- --------------------------------------------------
         4 /u01/app/oracle/oradata/orcl/users01.dbf
         3 /u01/app/oracle/oradata/orcl/undotbs01.dbf
         2 /u01/app/oracle/oradata/orcl/sysaux01.dbf
         1 /u01/app/oracle/oradata/orcl/system01.dbf
         5 /u01/app/oracle/oradata/orcl/example01.dbf
		 
--15. V$LOGFILE 显示重做日志成员的信息
SQL> col member for a50
SQL> select group#,member from v$logfile;

    GROUP# MEMBER
---------- --------------------------------------------------
         3 /u01/app/oracle/oradata/orcl/redo03.log
         2 /u01/app/oracle/oradata/orcl/redo02.log
         1 /u01/app/oracle/oradata/orcl/redo01.log

--16. V$LOG 显示日志组的详细信息
SQL> select group#,thread#,sequence#,bytes,members,status from v$log;

    GROUP#    THREAD#  SEQUENCE#      BYTES    MEMBERS STATUS
---------- ---------- ---------- ---------- ---------- ----------------
         1          1          4   52428800          1 CURRENT
         2          1          2   52428800          1 INACTIVE
         3          1          3   52428800          1 INACTIVE
		 
--17. V$THREAD 取得重做线程的详细信息，当使用RAC结构时，每个例程都对应一个重做线程，并且每个重做线程包含独立的重做日志组
SQL> col INSTANCE for a10
SQL> select thread#,status,groups,instance,sequence# from V$thread;

   THREAD# STATUS     GROUPS INSTANCE    SEQUENCE#
---------- ------ ---------- ---------- ----------
         1 OPEN            3 orcl                4

--18. V$LOCK 显示锁信息，通过与V$SESSION进行连接查询，可以显示占有锁的会话，以及等待锁的会话。
SQL> col username for a20
SQL> select a.username,a.machine,b.lmode,b.request,a.type from v$session a,v$lock b where a.sid=b.sid and a.type='USER'; 

USERNAME             MACHINE                   LMODE    REQUEST TYPE
-------------------- -------------------- ---------- ---------- ----------
SYS                  oel.example.com               4          0 USER

--19．V$LOCKED_OBJECT 显示被加锁的数据库对象。通过与DBA_OBJECTS进行连接查询，以显示具体的对象名及执行加锁操作的ORACLE用户名。
SQL> col object for a30
SQL> select a.oracle_username,b.owner||'.'||b.object_name object from V$locked_object a,dba_objects b where a.object_id=b.object_id;

ORACLE_USERNAME                OBJECT
------------------------------ ------------------------------
SYS                            SCOTT.EMP

--20. V$ROLLNAME V$ROLLSTAT V$ROLLNAME显示处于ONLINE状态的UNDO段，V$ROLLSTAT显示UNDO段的统计信息。通过二者执行连接查询，以显示UNDO的详细统计信息。
SQL> select a.name,b.xacts from V$rollname a,V$rollstat b where a.usn=b.usn;

NAME                                XACTS
------------------------------ ----------
SYSTEM                                  0
_SYSSMU1_3138885392$                    0
_SYSSMU2_4228238222$                    0
_SYSSMU3_2210742642$                    0
_SYSSMU4_1455318006$                    0
_SYSSMU5_3787622316$                    0
_SYSSMU6_2460248069$                    0
_SYSSMU7_1924883037$                    1
_SYSSMU8_1909280886$                    0
_SYSSMU9_3593450615$                    0
_SYSSMU10_2490256178$                   0

11 rows selected.

--21．V$TABLESPACE 显示表空间信息
SQL> select * from v$tablespace;

       TS# NAME                           INC BIG FLA ENC
---------- ------------------------------ --- --- --- ---
         0 SYSTEM                         YES NO  YES
         1 SYSAUX                         YES NO  YES
         2 UNDOTBS1                       YES NO  YES
         4 USERS                          YES NO  YES
         3 TEMP                           NO  NO  YES
         6 EXAMPLE                        YES NO  YES

6 rows selected.

--22. V$TEMPFILE 显示数据库所包含的临时文件
SQL> select name from v$tempfile;

NAME
--------------------------------------------------------------------------------
/u01/app/oracle/oradata/orcl/temp01.dbf