SQL> show parameter optimizer_mode --查询当前数据库的默认优化方式 set autotrace off 没有关时查不到

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
optimizer_mode                       string      ALL_ROWS

--Oracle提供了三种优化方式来满足不同的查询需求，即all_rows、first_rows_n以及first_rows。
SQL> alter system set optimizer_mode=first_rows_10 scope=both;

System altered.
SQL> alter session set optimizer_mode=all_rows;

Session altered.

SQL> show parameter optimizer_mode

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
optimizer_mode                       string      ALL_ROWS
SQL> select /*+first_rows_10*/ename,sal,mgr from scott.emp;

ENAME             SAL        MGR
---------- ---------- ----------
SMITH             800       7902
ALLEN            1600       7698
WARD             1250       7698
JONES            2975       7839
MARTIN           1250       7698
BLAKE            2850       7839
CLARK            2450       7839
SCOTT            3000       7566
KING             5000
TURNER           1500       7698
ADAMS            1100       7788

ENAME             SAL        MGR
---------- ---------- ----------
JAMES             950       7698
FORD             3000       7566
MILLER           1300       7782

14 rows selected.
/*
优化器工作过程 CBO通过几个步骤即
	SQL转换
	确定访问路径
	确定联结方法
	确定联结次序
四个步骤完成SQL的优化，最终生成一个成本最小的执行计划。
*/
--CBO自动收集统计数据
--查看GATHER_STATS_JOB的当前运行状态
SQL> select job_name,state,owner from dba_scheduler_jobs;

JOB_NAME                       STATE           OWNER
------------------------------ --------------- ------------------------------
PURGE_LOG                      SCHEDULED       SYS
FILE_WATCHER                   DISABLED        SYS
ORA$AUTOTASK_CLEAN             SCHEDULED       SYS
HM_CREATE_OFFLINE_DICTIONARY   DISABLED        SYS
DRA_REEVALUATE_OPEN_FAILURES   SCHEDULED       SYS
MGMT_CONFIG_JOB                SCHEDULED       ORACLE_OCM
MGMT_STATS_CONFIG_JOB          SCHEDULED       ORACLE_OCM
BSLN_MAINTAIN_STATS_JOB        SCHEDULED       SYS
FGR$AUTOPURGE_JOB              DISABLED        SYS
RSE$CLEAN_RECOVERABLE_SCRIPT   SCHEDULED       SYS
SM$CLEAN_AUTO_SPLIT_MERGE      SCHEDULED       SYS

JOB_NAME                       STATE           OWNER
------------------------------ --------------- ------------------------------
XMLDB_NFS_CLEANUP_JOB          DISABLED        SYS
RLM$EVTCLEANUP                 SCHEDULED       EXFSYS
RLM$SCHDNEGACTION              SCHEDULED       EXFSYS

14 rows selected.
SQL> set linesize 200
--通过数据字典DBA_TABSES查询用户scott拥有表的统计分析情况
SQL> select last_analyzed,table_name,owner,num_rows,sample_size from dba_tables where owner='SCOTT';

LAST_ANAL TABLE_NAME                     OWNER                            NUM_ROWS SAMPLE_SIZE
--------- ------------------------------ ------------------------------ ---------- -----------
26-FEB-17 BONUS                          SCOTT                                   0           0
26-FEB-17 DEPT                           SCOTT                                   4           4
26-FEB-17 EMP                            SCOTT                                  14          14
          EXT_EMP                        SCOTT
26-FEB-17 SALGRADE                       SCOTT                                   5           5
--以用DBMS_STATS包手工收集统计数据
SQL> exec dbms_stats.gather_schema_stats(ownname=>'SCOTT');

PL/SQL procedure successfully completed.
--验证模式scott的数据统计是否成功
SQL> select last_analyzed,table_name,owner,num_rows,sample_size from dba_tables where owner='SCOTT';

LAST_ANAL TABLE_NAME                     OWNER                            NUM_ROWS SAMPLE_SIZE
--------- ------------------------------ ------------------------------ ---------- -----------
23-MAR-17 BONUS                          SCOTT                                   0           0
23-MAR-17 DEPT                           SCOTT                                   4           4
23-MAR-17 EMP                            SCOTT                                  14          14
          EXT_EMP                        SCOTT
23-MAR-17 SALGRADE                       SCOTT    
--对特定表进行手工统计表
SQL> exec dbms_stats.gather_table_stats('HR','EMPLOYEES');

PL/SQL procedure successfully completed.
SQL> select last_analyzed,table_name,owner,num_rows,sample_size from dba_tables where owner='HR' and table_name='EMPLOYEES';

LAST_ANAL TABLE_NAME                     OWNER                            NUM_ROWS SAMPLE_SIZE
--------- ------------------------------ ------------------------------ ---------- -----------
23-MAR-17 EMPLOYEES                      HR                                    107         107
--手工收集特定索引的统计数据
--查询scott模式下的索引
SQL> select index_name,table_name from dba_indexes where owner='SCOTT';

INDEX_NAME                     TABLE_NAME
------------------------------ ------------------------------
PK_DEPT                        DEPT
PK_EMP                         EMP
--为表dept的主键索引PK_DEPT进行统计数据
SQL> exec dbms_stats.gather_index_stats('SCOTT','PK_DEPT');

PL/SQL procedure successfully completed.
--验证主键索引是否成功统计
SQL> select index_name,table_name,owner,last_analyzed from dba_indexes where index_name='PK_DEPT';

INDEX_NAME                     TABLE_NAME                     OWNER                          LAST_ANAL
------------------------------ ------------------------------ ------------------------------ ---------
PK_DEPT                        DEPT                           SCOTT                          23-MAR-17
PK_DEPT                        DEPT                           U01                            25-FEB-17
--手工收集数据库级别的统计数据
--在手工收集数据库级别的统计数据之前，需要对初始参数job_queue_processes设置一个非0值，才能保证过程gather_database_stats正常工作，否则gather_database_stats不会工作。
SQL> show parameter job_queue_processes

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
job_queue_processes                  integer     1000
SQL> alter system set job_queue_processes=1000 scope=both;

System altered.
--手工收集整个数据库的统计数据

SQL> exec dbms_stats.gather_database_stats(estimate_percent=>null); --其中estimate_percent=>null说明要为所有数据进行统计。

SQL> select num_rows,avg_space,avg_row_len,num_freelist_blocks,last_analyzed from dba_tab_statistics where table_name='EMP';

  NUM_ROWS  AVG_SPACE AVG_ROW_LEN NUM_FREELIST_BLOCKS LAST_ANAL
---------- ---------- ----------- ------------------- ---------
        14          0          38                   0 23-MAR-17
--统计操作系统数据
/*
当CBO选择最佳查询路径时
	需要使用数据库对象如表、索引等的统计数据，
	操作系统的统计数据如I/O速度，CPU周期等进行SQL的操作耗时计算，
选择花费时间最少的执行计划为最佳执行计划。 
Oracle使用gather_system_stats过程来统计操作系统数据。
*/
SQL> exec dbms_stats.gather_system_stats('NOWORKLOAD',10);

PL/SQL procedure successfully completed.
SQL> exec dbms_stats.gather_system_stats('start');

PL/SQL procedure successfully completed.

SQL> exec dbms_stats.gather_system_stats('stop');

PL/SQL procedure successfully completed.
SQL> select * from sys.aux_stats$;
--手工统计字典数据
SQL> exec dbms_stats.gather_fixed_objects_stats;--收集固定字典表的统计数据
SQL> exec dbms_stats.gather_dictionary_stats;--收集数据库字典表的统计数据
SQL> exec dbms_stats.gather_schema_stats('sys');--统计数据字典数据
--主动优化SQL语句
--1、 where谓词的注意事项
SQL> set linesize 200
SQL> select * from scott.emp where ename=upper(&ename);--使用一个绑定变量来代替并且该变量做为SQL函数upper的参数，但此时没有使用索引，所以这样的情况下最好使用基于SQL函数的索引。
Enter value for ename: 'ford'
old   1: select * from scott.emp where ename=upper(&ename)
new   1: select * from scott.emp where ename=upper('ford')

     EMPNO ENAME      JOB              MGR HIREDATE         SAL       COMM     DEPTNO
---------- ---------- --------- ---------- --------- ---------- ---------- ----------
      7902 FORD       ANALYST         7566 03-DEC-81       3000                    20
SQL> create index idx_soctt_emp_name on scott.emp(upper(ename));
/*
在存在多个表的查询时，往往需要表之间的连接操作，而选择合适的连接对查询性能影响很大，
所以在选择连接方法时，尽量使用等价连接，使用带where子句的等价连接可以有效减少读取的数据量。
2、 使用索引
如发现某个SQL语句总是使用全表扫描实现用户的查询，则需要通过建立索引，加快查询速度。
3、 使用绑定变量
*/
select empno,ename,job,sal from scott.emp where deptno=&deptno;
--4、 SQL语句优化工具 
--5、 索引类型
/*
被动优化SQL语句
一般是建立或删除索引，建立分区表等操作。
1、 使用分区表 (考虑根据时间或范围以及组合条件来创建分区表)
2、 使用表和索引压缩
*/
SQL> create table compress_emp compress tablespace users as select * from scott.emp;

Table created.
SQL> select table_name,tablespace_name,compression from user_tables where table_name like 'COMPRESS%';

TABLE_NAME                     TABLESPACE_NAME                COMPRESS
------------------------------ ------------------------------ --------
COMPRESSION$                   SYSTEM                         DISABLED
COMPRESS_EMP                   USERS                          ENABLED
SQL> create index idx_emp_compress on compress_emp(ename) compress;

Index created.
--3、 创建合适的索引