共享池(Shared pool)
	Library cache(库缓存)
		存放SQL、PL/SQL代码,命令块,解析代码，执行计划 
			1、Shared SQL areas 
			2、Private SQL areas 
			3、PL/SQL procedures and packages 
			4、Various control structures
	Data dictionary cache(数据字典缓存)
		Row cache
		Library cache
		存放数据对象的数据字典信息
			存储数据库中数据文件、表、索引、列、用户和其它数据对象的定义和权限信息
SQL> show parameter shared_pool_size

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
shared_pool_size                     big integer 0
--为0，表明由系统自动分配

SQL语句的执行过程如下： 
	A、SQL代码的语法(语法的正确性)及语义检查(对象的存在性与权限) 
	B、将SQL代码的文本进行哈希得到哈希值 
	C、如果共享池中存在相同的哈希值，则对这个命令进一步判断是否进行软解析，否则到e步骤。 
	D、对于存在相同哈希值的新命令行，其文本将与已存在的命令行的文本逐个进行比较。
		这些比较包括大小写，字符串是否一致，空格，注释等，如果一致，则对其进行软解析，转到步骤f。否则到e步骤。 
	E、硬解析，生成执行计划。 
	F、执行SQL代码，返回结果。

SQL> col NAMESPACE for a15
SQL> SELECT namespace,gets,gethits,ROUND(GETHITRATIO*100,2) gethit_ratio,pins,pinhits, ROUND(PINHITRATIO*100,2)pinhit_ratio,reloads,invalidations FROM v$librarycache;

NAMESPACE             GETS    GETHITS GETHIT_RATIO       PINS    PINHITS PINHIT_RATIO    RELOADS INVALIDATIONS
--------------- ---------- ---------- ------------ ---------- ---------- ------------ ---------- -------------
SQL AREA            273970     217255         79.3    3773410    3602654        95.47      14563         19689
TABLE/PROCEDURE     712683     691171        96.98    1269834    1198052        94.35      22563             0
BODY                 28910      28142        97.34     254740     253637        99.57        247             0
TRIGGER               8899       8531        95.86       8901       8527         95.8          0             2
INDEX                62961      54272         86.2      55088      37871        68.75       1192             0
CLUSTER              10067       9994        99.27      11079      11006        99.34          0             0
DIRECTORY              139        119        85.61        174        136        78.16          2             0
QUEUE                  597        562        94.14       3300       3203        97.06         33             0
CONTEXT POLICY           2          0            0          2          0            0          0             0
SUMMARY                248        246        99.19        248        246        99.19          0             0
APP CONTEXT              9          8        88.89         18         17        94.44          0             0

NAMESPACE             GETS    GETHITS GETHIT_RATIO       PINS    PINHITS PINHIT_RATIO    RELOADS INVALIDATIONS
--------------- ---------- ---------- ------------ ---------- ---------- ------------ ---------- -------------
RULESET                434        310        71.43       1660       1476        88.92         10             0
XML SCHEMA              26         11        42.31         38          9        23.68          1             0
SUBSCRIPTION            60         10        16.67         60         10        16.67          0             0
RULE                   181         93        51.38        181         81        44.75         12             0
XDB CONFIG               1          0            0          1          0            0          0             0
TEMPORARY TABLE      15087      10839        71.84      15087          0            0      10839             0
TEMPORARY INDEX       4807        952         19.8       4807          0            0        952             0
EDITION               2583       2567        99.38       3580       3549        99.13          0             0
DBLINK                 444        424         95.5          0          0          100          0             0
OBJECT ID             1058          0            0          0          0          100          0             0
SCHEMA               33236      33078        99.52          0          0          100          0             1

NAMESPACE             GETS    GETHITS GETHIT_RATIO       PINS    PINHITS PINHIT_RATIO    RELOADS INVALIDATIONS
--------------- ---------- ---------- ------------ ---------- ---------- ------------ ---------- -------------
DBINSTANCE               1          0            0          0          0          100          0             0
SQL AREA STATS       59391       7125           12      59391       7125           12          0             0
ACCOUNT_STATUS          55         42        76.36          0          0          100          0             0
SQL AREA BUILD       60669       9929        16.37          0          0          100          0             0

26 rows selected.

RELOADS列：表示对象被重新加载的次数，理论上该值应该接近于零。过大是由于对象无效或library pool过小被换出。 
INVALIDATIONS：列表示对象失效的次数，对象失效后，需要被再次解析。 
GETHITRATIO：该列值过低，表明过多的对象被换出内存。 
GETPINRATIO：该列值过低，表明会话没有多次执行相同的游标，即使对象被不同的会话共享或会话没有找到共享的游标。
--查询数据字典缓存的命中率与缺失率
SQL> SELECT ROUND(((1-SUM(getmisses)/(SUM(gets)+SUM(getmisses))))*100,3) "Hit Ratio",ROUND(SUM(getmisses)/sum(gets)*100,3) "Misses Ratio" FROM v$rowcache WHERE gets+getmisses <> 0;

 Hit Ratio Misses Ratio
---------- ------------
    97.093        2.994
--整个数据字典的缺失率
SQL> SELECT ROUND((100*SUM(getmisses)/decode(SUM(gets),0,1,SUM(gets))),2) Getmiss_ratio FROM v$rowcache;

GETMISS_RATIO
-------------
            3
--调整shared_pool_size
考虑是否存在过多的reloads和invalidations
SQL> set linesize 200
SQL> SELECT NAMESPACE,GETS,GETHITS,round(GETHITRATIO * 100, 2) gethit_ratio, PINS,PINHITS,round(PINHITRATIO * 100, 2) pinhit_ratio,RELOADS,INVALIDATIONS FROM V$LIBRARYCACHE;

NAMESPACE        GETS    GETHITS GETHIT_RATIO       PINS    PINHITS PINHIT_RATIO    RELOADS INVALIDATIONS
---------- ---------- ---------- ------------ ---------- ---------- ------------ ---------- -------------
SQL AREA       274716     217974        79.35    3778122    3607116        95.47      14606         19689
TABLE/PROC     713013     691491        96.98    1271405    1199526        94.35      22590             0
EDURE

BODY            28974      28205        97.35     255275     254171        99.57        247             0
TRIGGER          8899       8531        95.86       8901       8527         95.8          0             2
INDEX           62961      54272         86.2      55088      37871        68.75       1192             0
CLUSTER         10107      10034        99.28      11119      11046        99.34          0             0
DIRECTORY         139        119        85.61        174        136        78.16          2             0
QUEUE             597        562        94.14       3300       3203        97.06         33             0
CONTEXT PO          2          0            0          2          0            0          0             0

NAMESPACE        GETS    GETHITS GETHIT_RATIO       PINS    PINHITS PINHIT_RATIO    RELOADS INVALIDATIONS
---------- ---------- ---------- ------------ ---------- ---------- ------------ ---------- -------------
LICY

SUMMARY           248        246        99.19        248        246        99.19          0             0
APP CONTEX          9          8        88.89         18         17        94.44          0             0
T

RULESET           434        310        71.43       1660       1476        88.92         10             0
XML SCHEMA         26         11        42.31         38          9        23.68          1             0
SUBSCRIPTI         60         10        16.67         60         10        16.67          0             0
ON


NAMESPACE        GETS    GETHITS GETHIT_RATIO       PINS    PINHITS PINHIT_RATIO    RELOADS INVALIDATIONS
---------- ---------- ---------- ------------ ---------- ---------- ------------ ---------- -------------
RULE              181         93        51.38        181         81        44.75         12             0
XDB CONFIG          1          0            0          1          0            0          0             0
TEMPORARY       15087      10839        71.84      15087          0            0      10839             0
TABLE

TEMPORARY        4807        952         19.8       4807          0            0        952             0
INDEX

EDITION          2600       2584        99.38       3605       3574        99.14          0             0
DBLINK            446        426        95.52          0          0          100          0             0
OBJECT ID        1058          0            0          0          0          100          0             0

NAMESPACE        GETS    GETHITS GETHIT_RATIO       PINS    PINHITS PINHIT_RATIO    RELOADS INVALIDATIONS
---------- ---------- ---------- ------------ ---------- ---------- ------------ ---------- -------------
SCHEMA          33261      33102        99.52          0          0          100          0             1
DBINSTANCE          1          0            0          0          0          100          0             0
SQL AREA S      59476       7125        11.98      59476       7125        11.98          0             0
TATS

ACCOUNT_ST         55         42        76.36          0          0          100          0             0
ATUS

SQL AREA B      60774       9947        16.37          0          0          100          0             0
UILD


26 rows selected.
--当库缓存的重载率大于零，应考虑增大shared_pool_size
SQL> SELECT SUM(pins) "Executions",SUM(reloads) "Cache Misses while Executing", ROUND(SUM(reloads)/SUM(pins)*100,2) AS "Reload Ratio, %" FROM V$LIBRARYCACHE;

Executions Cache Misses while Executing Reload Ratio, %
---------- ---------------------------- ---------------
   5468676                        50484             .92
--库缓存的命中率应保持在95%，否则应考虑增大shared_pool_size
SQL> SELECT SUM(pins) "Executions",SUM(reloads) "Cache Misses while Executing",ROUND((SUM(pins)/(SUM(reloads)+SUM(pins)))*100,2) "Hit Ratio, %" FROM V$LIBRARYCACHE;

Executions Cache Misses while Executing Hit Ratio, %
---------- ---------------------------- ------------
   5468759                        50484        99.09   
--4.估算Library cache占用大小，shared pool的可用空间，总大小
--查看共享池可用空间，当shared pool有过多的可用空间，再调大shared pool则意义不大
SQL> SELECT pool,name,bytes/1024/1024 FROM v$sgastat WHERE name LIKE '%free memory%' AND pool = 'shared pool';

POOL         NAME                       BYTES/1024/1024
------------ -------------------------- ---------------
shared pool  free memory                     133.612755
--查询已使用的Library cache大小总和 
--实际上还有一部分为用户游标使用占用的空间，此处略去
SQL> WITH cte AS( 
  2  SELECT SUM(sharable_mem) sharable_mem_count FROM v$db_object_cache --查询非SQL语句(包，视图)占用的Library cache大小 
  3  UNION ALL 
  4  SELECT SUM(sharable_mem) FROM v$sqlarea --查询SQL语句占用的Library cache大小 
  5  ) 
  6  SELECT SUM(sharable_mem_count)/1024/1024 FROM cte;

SUM(SHARABLE_MEM_COUNT)/1024/1024
---------------------------------
                       131.747043
--查询分配的shared_pool_size的大小 
SQL> SELECT SUM(bytes)/1024/1024 FROM v$sgastat WHERE pool LIKE '%shar%';

SUM(BYTES)/1024/1024
--------------------
                 312
SQL> SELECT * FROM v$sgainfo WHERE name LIKE 'Shared%';

NAME                                  BYTES RES
-------------------------------- ---------- ---
Shared Pool Size                  327155712 Yes
Shared IO Pool Size                       0 Yes				 
--５.根据上述的各个情况的判断，检查v$shared_pool_advice来判断增加shared_pool_size
SQL> SELECT shared_pool_size_for_estimate est_size,shared_pool_size_factor size_factor,estd_lc_size,estd_lc_memory_objects obj_cnt,estd_lc_time_saved_factor sav_factor FROM v$shared_pool_advice;

  EST_SIZE SIZE_FACTOR ESTD_LC_SIZE    OBJ_CNT SAV_FACTOR
---------- ----------- ------------ ---------- ----------
       184       .5897           25       1711      .7125
       216       .6923           56       3777       .869
       248       .7949           88       6164      .9536
       272       .8718          112       7569      .9868
       276       .8846          116       7706      .9881
       280       .8974          120       7843      .9894
       284       .9103          124       7980      .9908
       288       .9231          128       8117       .992
       292       .9359          132       8254      .9934
       296       .9487          136       8391      .9946
       300       .9615          140       8528      .9966

  EST_SIZE SIZE_FACTOR ESTD_LC_SIZE    OBJ_CNT SAV_FACTOR
---------- ----------- ------------ ---------- ----------
       304       .9744          144       8665      .9978
       308       .9872          148       8802      .9989
       312           1          152       8939          1
       316      1.0128          156       9076     1.0001
       320      1.0256          160       9213     1.0001
       324      1.0385          164       9439     1.0002
       328      1.0513          168       9743     1.0002
       332      1.0641          172      10047     1.0002
       336      1.0769          176      10351     1.0003
       340      1.0897          180      10655     1.0003
       344      1.1026          184      10959     1.0003

  EST_SIZE SIZE_FACTOR ESTD_LC_SIZE    OBJ_CNT SAV_FACTOR
---------- ----------- ------------ ---------- ----------
       348      1.1154          188      11263     1.0004
       376      1.2051          216      13396     1.0005
       408      1.3077          248      15833     1.0007
       440      1.4103          280      18270      1.001
       472      1.5128          312      19839     1.0012
       504      1.6154          344      21274     1.0016
       536      1.7179          376      22636     1.0018
       568      1.8205          408      24908     1.0019
       600      1.9231          440      27180     1.0019
       632      2.0256          472      29452      1.002

32 rows selected.

共享池调优工具 
	几个重要的性能视图 
		v$sgastat 
		v$librarycache 
		v$sql 
		v$sqlarea 
		v$sqltext 
		v$db_object_cache 
	几个重要参数 
		shared_pool_size 
		open_cursors 
		session_cached_cursors
		cursor_space_for_time 
		cursor_sharing 
		shared_pool_reserved_size
3.查询视图获得相关信息 
--查询执行次数小于5的SQL语句 
select sql_text from v$sqlarea where executions < 5 order by upper(sql_text); 
--查询解析的次数 
select sql_text,parse_calls,executions from v$sqlarea order by parse_calls;


--查询特定对象获得句柄的命中率
SQL> select gethitratio from v$librarycache where namespace='SQL AREA';

GETHITRATIO
-----------
 .794008788
--查询当前用户正在运行哪些SQL语句
SQL> set linesize 200
SQL> select * from v$sqltext where sql_text like 'select * from scott.emp where %';

ADDRESS  HASH_VALUE SQL_ID        COMMAND_TYPE      PIECE SQL_TEXT
-------- ---------- ------------- ------------ ---------- ----------------------------------------------------------------
3B5C39DC  446363866 0gm0bm8d9py6u            3          0 select * from scott.emp where ename=upper('ford')
--收集表的统计信息
SQL> execute dbms_stats.gather_table_stats('SCOTT','EMP');

PL/SQL procedure successfully completed.
--通过动态性能视图获得有关share pool size的建议
     208544
       344     1.1026          165             208549

 POOL_SIZE     FACTOR ESTD_LC_SIZE ESTD_LC_TIME_SAVED
---------- ---------- ------------ ------------------
       348     1.1154          169             208554
       376     1.2051          197             208581
       408     1.3077          229             208631
       440     1.4103          261             208674
       472     1.5128          293             208726
       504     1.6154          325             208808
       536     1.7179          357             208857
       568     1.8205          389             208886
       600     1.9231          421             208897
       632     2.0256          453             208908

32 rows selected.
--通过视图v$sql_plan查看执行计划
SQL> SELECT operation,object_owner,object_name,COST FROM v$sql_plan ORDER BY hash_value;
--SQL语句与执行计划的对照 v$sql中有一列为plan_hash_value 与v$sql_plan相互参照
SELECT a.operation,object_owner,object_name,COST,b.sql_text FROM v$sql_plan a JOIN v$sql b ON a.plan_hash_value=b.plan_hash_value WHERE a.object_owner = 'SCOTT' ORDER BY a.hash_value;


--1、清空共享池（目的方便对sql语句的分析）
SQL> alter system flush shared_pool;

System altered.
--2、启动会话级的sql追踪功能 SYS@orcl>
SQL> alter session set sql_trace=true;

Session altered.
--3、执行sql查询语句并查看追踪文件
SQL> select ename,sal,mgr from scott.emp where sal>4000;

ENAME             SAL        MGR
---------- ---------- ----------
KING             5000
[oracle@oracle ~]$ vi /u01/app/oracle/diag/rdbms/orcl/orcl/trace/orcl_ora_6789.trc
在上述追踪文件中参数mis对应的值说明是否发生硬解析，如果该参数值为1，说明发生了硬解析，再执行一个类似的查询，看是否发生硬解析。参数mis=0说明此时没有硬解析。