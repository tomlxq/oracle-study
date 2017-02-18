/*

闪回版本查询flashback version query(versions)
	来源undo
	查询某个时间点数据select ... from ... as of scn | timestamp ...;
闪回事务
	11g: alter database add supplemental log data
	来源undo
	flashback_transaction_query的undo_sql语句
	通过执行undo_sql语句实现闪回
闪回表
	系统表不能闪回、DDL后不能闪回、写入alert日志、产生undo和redo数据
	来源undo
	flashback table ... to scn ...
	把表还原到以前的某个时间点
	前提是要启用row movement, alter table .. enable row movement
总结:	DML
		上面的三种都来源于undo,
		如果破坏了就找不回来了

闪回丢弃flashback drop(DDL)
	来源回收站
	drop table t;
	drop table purge;
	已经删除在回收站的表可以查询show recycle,用recyclebin name来查
	flashback table ... to before drop [rename to ...]
闪回数据归档flashback data archive
	缓冲区高速缓存中的原始数据
		undo data
		fbda
	来源回收站閃回數據歸檔區（指定特定的表）
	主要是和undo分開,可以長時間保留
闪回数据库flashback database
	1. 啟用歸檔模式
		如何查看归档
			SQL> archive log list
		如何开启归档
			1.　修改参数，设置归档路径
				show parameter archive
				alter system set log_archive_dest_1='location=/u01/app/oracle/arch/'
			2.  数据库置为mount状态 shutdown、immedate/startup mount
			3.　alter database archivelog;
			4.　alter database open;
	2.　启用闪回(10g要在mount状态开启)
		SQL> show parameter recover
		SQL> alter system set db_recovery_file_dest_size=4G;先要设置大小，否则会报错
		SQL> alter system set db_recovery_file_dest='/u01/app/oracle/flashback/orcl';
		SQL> select flashback_on from v$database;查询有没有开闪回
			FLASHBACK_ON
			------------------
			NO
		SQL> alter database flashback on;
		SQL> alter system set db_flashback_retention_target=1440 scope=both; 这里设置闪回日志的保存时间,以分钟为单位
	不完全恢复（没有恢复到最新时间点）
		resetlogs
		noresetlogs
		read only->recover database

实验1：闪回版本查询　
SQL> create table t as select * from scott.dept;
SQL> select * from t;
SQL> insert into t values(50,'DBA','SZ');
SQL> commit;
SQL> update t set loc='GZ' where deptno=50;
SQL> commit;
SQL> delete from t where deptno=50;
SQL> commit;
SQL> insert into t values(50,'DBA','SZ');
SQL> commit;
SQL> select deptno,dname,loc,versions_xid,versions_startscn,versions_endscn,versions_operation from t versions between scn minvalue and maxvalue where deptno=50;

    DEPTNO DNAME          VERSIONS_XID  VERSIONS_STARTSCN VERSIONS_ENDSCN V
---------- -------------- ------------- ----------------- --------------- -
        50 DBA            SZ                      1305511                 I
        50 DBA            GZ                      1305504                 D
        50 DBA            GZ                      1305480         1305504 U
        50 DBA            SZ                      1305446         1305480 I
SQL> select deptno,dname,loc versions_xid,versions_startscn,versions_endscn,versions_operation from t versions  between timestamp  to_timestamp(systimestamp-1/24) and systimestamp where deptno=50;                                                                                           *
ERROR at line 1:
ORA-01466: unable to read data - table definition has changed

SQL> select current_scn from v$database;

CURRENT_SCN
-----------
    1306960
SQL> delete from scott.t where deptno=50;
SQL> commit;
SQL> select * from t;

    DEPTNO DNAME          LOC
---------- -------------- -------------
        10 ACCOUNTING     NEW YORK
        20 RESEARCH       DALLAS
        30 SALES          CHICAGO
        40 OPERATIONS     BOSTON
SQL> select * from t as of timestamp sysdate-6/1440;

    DEPTNO DNAME          LOC
---------- -------------- -------------
        10 ACCOUNTING     NEW YORK
        20 RESEARCH       DALLAS
        30 SALES          CHICAGO
        40 OPERATIONS     BOSTON
        50 DBA            SZ
SQL> select * from t as of scn 1306960; 1306960表示这个时间点还没有删除数据，这里的数据来自于undo

    DEPTNO DNAME          LOC
---------- -------------- -------------
        10 ACCOUNTING     NEW YORK
        20 RESEARCH       DALLAS
        30 SALES          CHICAGO
        40 OPERATIONS     BOSTON
        50 DBA            SZ

		
undo: 存放旧数据的地方
	事务回退rollback
	实例恢复instance recovery
	读一致性
实验2：验证闪回数据确实来源于undo　
SQL> select current_scn from v$database;

CURRENT_SCN
-----------
    1307331

SQL> show parameter undo

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
undo_management                      string      AUTO
undo_retention                       integer     900
undo_tablespace                      string      undotbs2
SQL> desc dba_data_files
SQL> col file_name for a30
SQL> select  FILE_NAME, FILE_ID,TABLESPACE_NAME from dba_data_files;

FILE_NAME                         FILE_ID TABLESPACE_NAME
------------------------------ ---------- ------------------------------
/oradata/orcl/user01.dbf                4 USERS
/oradata/orcl/sysaux01.dbf              2 SYSAUX
/oradata/orcl/system01.dbf              1 SYSTEM
/oradata/orcl/undotbs2.dbf              5 UNDOTBS2
/u01/app/oracle/dbda                    6 FBDA1
SQL> create undo tablespace UNDOTBS1 datafile '/oradata/orcl/undotbs1.dbf' size 50m;
SQL> show parameter undo  
SQL> alter system set undo_tablespace='UNDOTBS1';  
SQL> drop tablespace UNDOTBS2 including contents;
[oracle@oracle ~]$ rm -rf /oradata/orcl/undotbs2.dbf
SQL> select * from t as of scn 1306960;此时还有

    DEPTNO DNAME          LOC
---------- -------------- -------------
        10 ACCOUNTING     NEW YORK
        20 RESEARCH       DALLAS
        30 SALES          CHICAGO
        40 OPERATIONS     BOSTON
        50 DBA            SZ
SQL> alter system flush buffer_cache;清一下内存
SQL> alter system flush shared_pool;
SQL> select * from t as of scn 1306960; 此时没有了，证明确实来源于undo
ERROR:
ORA-01555: snapshot too old: rollback segment number  with name "" too small
no rows selected
快照太旧，回滚段太小，有新的数据写入了，实际是切换了undo表空间
上述主要是把用新的undo代替旧的，并把旧的undo给删掉

实验2：闪回事务
SQL> drop table t purge;
SQL> create table t as select * from scott.dept;
SQL> select * from t;
SQL> insert into t values(50,'DBA','SZ');
SQL> commit;
SQL> update t set loc='GZ' where deptno=50;
SQL> commit;
SQL> delete from t where deptno=50;
SQL> commit;
SQL> insert into t values(50,'DBA','SZ');
SQL> commit;
SQL> select deptno,dname,loc,versions_xid,versions_startscn,versions_endscn,versions_operation from t versions between scn minvalue and maxvalue where deptno=50;
SQL> insert into t values(60,'DBA','SZ');
SQL> insert into t values(70,'DBA','SZ');
SQL> commit;
SQL> select commit_scn,operation,undo_sql from flashback_transaction_query where xid='090009001D030000';

COMMIT_SCN OPERATION  UNDO_SQL
---------- ---------- -------------------------------------------------------
   1311451 INSERT     delete from "SCOTT"."T" where ROWID = 'AAAGfBAAEAAAAIvAAA';

   1311451 INSERT     delete from "SCOTT"."T" where ROWID = 'AAAGfBAAEAAAAIvAAC';

   1311451 BEGIN
SQL> select * from "SCOTT"."T" where ROWID = 'AAAGfBAAEAAAAIvAAA';

DEPTNO DNAME          LOC
------ -------------- -----
    ## DBA            SZ

SQL> select * from "SCOTT"."T" where ROWID = 'AAAGfBAAEAAAAIvAAC';

DEPTNO DNAME          LOC
------ -------------- -----
    ## DBA            SZ	


实验3：闪回表
SQL> drop table c purge;
SQL> create table c(id number);
SQL> insert into c values(1);
SQL> insert into c values(2);
SQL> commit;
SQL> select * from c;

        ID
----------
         1
         2
SQL> alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
SQL> select sysdate from dual;
SYSDATE
-------------------
2017-02-18 11:38:20
SQL> select current_scn from v$database;

CURRENT_SCN
-----------
    1317149
SQL> delete from c;
SQL> commit;
SQL> select row_movement from user_tables where table_name='C';

ROW_MOVE
--------
DISABLED
SQL> alter table c enable row movement; 启用行移动
SQL> select * from scott.c;
no rows selected
SQL> flashback table c to scn 1317149;　相当于把undo_sql都做一遍
SQL> select * from scott.c;

        ID
----------
         1
         2

		 
实验4：说明闪回丢充，不能放在system表空间
SQL> drop table t1 purge;
SQL> drop table t3 purge;
SQL> drop table t2 purge;
SQL> create table t1 as select * from dba_objects;
SQL> create table t2 tablespace users as select * from dba_objects;
SQL> create table t3 tablespace users as select * from dba_objects;
SQL> select owner,table_name,tablespace_name from dba_tables where table_name in ('T1','T2','T3') and owner='SYS';
OWNER      TABLE_NAME                     TABLESPACE_NAME
---------- ------------------------------ ------------------------------
SYS        T3                             USERS
SYS        T2                             USERS
SYS        T1                             SYSTEM
SQL> drop table t1;
SQL> drop table t2;
SQL> drop table t2 purge;
SQL> show recycle 只看到t2表
SQL> purge table t2;清空回收站的表
SQL> purge tablespace users;
SQL> purge recyclebin;
SQL> purge dba_recyclebin;


实验5：闪回表
SQL> create table t1 tablespace users as select * from scott.emp;
SQL> create table t2 tablespace users as select * from scott.dept;
SQL> drop table t2;
SQL> drop table t1;
SQL> show recycle;
ORIGINAL NAME    RECYCLEBIN NAME                OBJECT TYPE  DROP TIME
---------------- ------------------------------ ------------ -------------------
T1               BIN$SMf8Y+bdK2/gUwMVqMDOgw==$0 TABLE        2017-02-18:14:39:50
T2               BIN$SMf8Y+bcK2/gUwMVqMDOgw==$0 TABLE        2017-02-18:14:39:47
SQL> desc "BIN$SMf8Y+bdK2/gUwMVqMDOgw==$0"
SQL> desc "BIN$SMf8Y+bcK2/gUwMVqMDOgw==$0"
SQL> select * from "BIN$SMf8Y+bcK2/gUwMVqMDOgw==$0";

    DEPTNO DNAME          LOC
---------- -------------- -------------
        10 ACCOUNTING     NEW YORK
        20 RESEARCH       DALLAS
        30 SALES          CHICAGO
        40 OPERATIONS     BOSTON
SQL> flashback table t1 to before drop;
SQL> flashback table t2 to before drop;
SQL> select * from t2;

实验6：闪回表之处理同名表
SQL> select * from t2;
SQL> show recycle;
SQL> drop table t1;
SQL> create table t1 tablespace users as select * from scott.dept;
SQL> drop table t1;
SQL> show recycle;
ORIGINAL NAME    RECYCLEBIN NAME                OBJECT TYPE  DROP TIME
---------------- ------------------------------ ------------ -------------------
T1               BIN$SMf8Y+bfK2/gUwMVqMDOgw==$0 TABLE        2017-02-18:14:47:19
T1               BIN$SMf8Y+beK2/gUwMVqMDOgw==$0 TABLE        2017-02-18:14:46:52
SQL> flashback table t1 to before drop;　如果表同名，会把最近的表给闪回
SQL> show recycle;
ORIGINAL NAME    RECYCLEBIN NAME                OBJECT TYPE  DROP TIME
---------------- ------------------------------ ------------ -------------------
T1               BIN$SMf8Y+beK2/gUwMVqMDOgw==$0 TABLE        2017-02-18:14:46:52
SQL> drop table t1;
SQL> show recycle;
ORIGINAL NAME    RECYCLEBIN NAME                OBJECT TYPE  DROP TIME
---------------- ------------------------------ ------------ -------------------
T1               BIN$SMf8Y+bgK2/gUwMVqMDOgw==$0 TABLE        2017-02-18:14:50:42
T1               BIN$SMf8Y+beK2/gUwMVqMDOgw==$0 TABLE        2017-02-18:14:46:52
SQL> flashback table "BIN$SMf8Y+beK2/gUwMVqMDOgw==$0" to before drop;如果想闪回老表则用recyclebin name
SQL> select * from t1;
SQL> show recycle;
ORIGINAL NAME    RECYCLEBIN NAME                OBJECT TYPE  DROP TIME
---------------- ------------------------------ ------------ -------------------
T1               BIN$SMf8Y+bgK2/gUwMVqMDOgw==$0 TABLE        2017-02-18:14:50:42
SQL> flashback table t1 to before drop; 如果还想闪回t1表，则不允许，因为表名重复了
flashback table t1 to before drop
*
ERROR at line 1:
ORA-38312: original name is used by an existing object
SQL> flashback table t1 to before drop rename to t3; 闪回t1表时，重命名为t3

实验7：閃回數據歸檔
	1.　創建表空間
		create tablespace tbs1 datafile '/oradata/orcl/tbs1.dbf' size 50m
	2. 創建閃回數據歸檔
		create flashback archive fla1 default tablespace tbs1 quota 10g retention 5 year;
	3. 對表啟用表跟蹤
		alter table t1 flashback archive fla1;
	4. 記錄scn、數據增刪改
		select * from t1 of scn ...
	5. 後面恢復與閃回版本查詢和閃回事務是一樣的
	
SQL> create tablespace tbs1 datafile '/oradata/orcl/tbs1.dbf' size 50m;
SQL> create flashback archive fla1 tablespace tbs1 quota 10g retention 5 year;
SQL> alter table t2 flashback archive fla1;
SQL> select current_scn from v$database;

CURRENT_SCN
-----------
    1328816
QL> select * from t2;
    DEPTNO DNAME          LOC
---------- -------------- -------------
        10 ACCOUNTING     NEW YORK
        20 RESEARCH       DALLAS
        30 SALES          CHICAGO
        40 OPERATIONS     BOSTON
SQL> delete from t2;
SQL> commit;
SQL> select * from t2;
no rows selected
SQL> select * from t2 as of scn 1328816;  从undo裡查還是舊數據

    DEPTNO DNAME          LOC
---------- -------------- -------------
        10 ACCOUNTING     NEW YORK
        20 RESEARCH       DALLAS
        30 SALES          CHICAGO
        40 OPERATIONS     BOSTON

--下面刪除undo表空間
SQL> show parameter undo

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
undo_management                      string      AUTO
undo_retention                       integer     900
undo_tablespace                      string      UNDOTBS1
SQL> select FILE_NAME,FILE_ID,TABLESPACE_NAME from dba_data_files;　查看當前的數據文件
SQL> create undo tablespace undotbs2 datafile '/oradata/orcl/undotbs2.dbf' size 50m;　創建一個undo表空間
SQL> alter system set undo_tablespace='undotbs2';　把當前undo表空間切到新建的表空間
SQL> drop tablespace undotbs1 including contents;刪除舊的表空間
如果出現
ORA-30013: undo tablespace 'UNDOTBS1' is currently in use
試著用shutdown immediate/startup，然後再刪
如果出現，報_SYSSMU13_1129596808，活躍的，要通過加參數讓它脫機
ORA-01548: active rollback segment '_SYSSMU13_1129596808$' found. terminate dropping tablespace
試著修改參數文件
create pfile from spfile;
su - oracle
cd $ORACLE_HOME/dbs/
vi initorcl.ora
_offline_rollback_segments='_SYSSMU13_1129596808$' 在initorcl.ora行尾加上這句，再重啟後刪除

經過上刪除undo表空間的步驟，此時仍然可以查到數據，這個數據是來自於数据归档區
SQL> select * from t2 as of scn 1328816;

    DEPTNO DNAME          LOC
---------- -------------- -------------
        10 ACCOUNTING     NEW YORK
        20 RESEARCH       DALLAS
        30 SALES          CHICAGO
        40 OPERATIONS     BOSTON
如果沒有的話會報
SQL> !oerr ora 01555
01555, 00000, "snapshot too old: rollback segment number %s with name \"%s\" too small"
如何證明，將t2取消歸檔
SQL> alter table t2 no flashback archive;
SQL> select * from t2 as of scn 1328816;？？

解決錯誤
SQL> drop tablespace tbs1 including contents and datafiles;
drop tablespace tbs1 including contents and datafiles
*
ERROR at line 1:
ORA-55641: Cannot drop tablespace used by Flashback Data Archive
SQL> drop flashback archive fla1;
SQL> drop tablespace tbs1 including contents and datafiles;


create flashback archive default ... tablespace ... quota 10g retention 5 year;
alter table ... flashback archive;
alter table ... no flashback archive

实验8：闪回数据库
--create table t1--drop table t1--create table t2--|
---------|a--------|b-----------------------------c|
希望在最新的时间找回被误删的表a
在b点导出a表,现恢复到最新的时间点，再导入a

SQL> create table t1 as select * from scott.emp;
SQL> select current_scn from v$database;
CURRENT_SCN
-----------
    1342135
SQL> drop table t1 purge;
SQL> select current_scn from v$database;
CURRENT_SCN
-----------
    1342185
SQL> create table t2 as select * from scott.dept;
SQL> select current_scn from v$database;
CURRENT_SCN
-----------
    1342231
将数据库闪回到a,数据库闪回要在mount下闪回
SQL> shutdown immediate
SQL> startup mount
SQL> flashback database to scn 1342135
也可以使用时间flashback database to timestamp to_timestamp('09-10-14 14:37:05','yy-mm-dd hh24:mi:ss')
SQL> alter database open;
alter database open
*
ERROR at line 1:
ORA-01589: must use RESETLOGS or NORESETLOGS option for database open
SQL> alter database open read only; 此时我们不重置日志，以只读方式打开
SQL> select count(1) from t1; 此时我们己找回了t1表

  COUNT(1)
----------
        16		
SQL> select count(1) from t2;此时没有t2表，因为我们的数据库前推了
select count(1) from t2
                     *
ERROR at line 1:
ORA-00942: table or view does not exist
SQL> !　临时切到主目录
[oracle@oracle ~]$ exp file='/oradata/orcl/t1.dmp' tables=t1; 导出t1表
Username: sys/oracle as sysdba
. . exporting table                             T1         16 rows exported　可以看到导出16行记录
[oracle@oracle ~]$ ll /oradata/orcl/t1.dmp 
[oracle@oracle ~]$ exit
--现在我们要将数据库推到最新的时间点
SQL> shutdown immediate
SQL> startup mount
SQL> recover database
SQL> alter database open;
SQL> select count(*) from t2;

  COUNT(*)
----------
         4

SQL> desc t1;
ERROR:
ORA-04043: object t1 does not exist
SQL> !
[oracle@oracle ~]$ imp file=/oradata/orcl/t1.dmp tables=t1;	
Username: sys/oracle as sysdba
. . importing table                           "T1"         16 rows imported
[oracle@oracle ~]$ exit
SQL> desc t1; 可以看到t1表被成功找回来了

实验9：闪回数据库resetlogs
SQL> select * from v$log;
SQL> shutdown immediate
SQL> startup mount
SQL> flashback database to scn 1342135；
SQL> alter database open resetlogs; 这个时间点之后的操作全没有了
SQL> select * from v$log;

知识点:
1. as of scn/as of timestamp
	查询时间，实际也是查scn，对应关系如下表
	SQL> select scn,to_char(time_dp,'yyyy-mm-dd hh24:mi:ss') from sys.smon_scn_time;
2.　物理地址rowid，为最高效定位数据的方式
	rowid为物理的绝对地址AAAGfBAAEAAAAIvAAC  
	object_id	file_id					block_id	块内的行
	AAAGfB		AAE						AAAAIv		AAC
				0*64^2+0*64^1+4*64^0=4
	说明t在4号文件			
	SQL> select file_id,file_name,tablespace_name from dba_data_files;

	   FILE_ID FILE_NAME                      TABLESPACE_NAME
	---------- ------------------------------ ------------------------------
			 4 /oradata/orcl/user01.dbf       USERS
			 2 /oradata/orcl/sysaux01.dbf     SYSAUX
			 1 /oradata/orcl/system01.dbf     SYSTEM
			 6 /u01/app/oracle/dbda           FBDA1
			 3 /oradata/orcl/undotbs1.dbf     UNDOTBS1
	说明4号文件在users表空间
	SQL> select OWNER,TABLE_NAME,TABLESPACE_NAME from dba_tables where OWNER='SCOTT' and table_name='T';

	OWNER      TABLE_NAME                     TABLESPACE_NAME
	---------- ------------------------------ ------------------------------
	SCOTT      T                              USERS

极点五笔如何切换繁简输入法？
ctrl+j
*/

