v$session
	当前会话记录保存在v$session中
v$session_wait
	处于等待状态的会话会被复制一份放在v$session_wait中
v$_session_wait_history
	保存了每个活动session在v$session_wait中最近10次的等待事件

v$active_session_history
	ASH（active session history）
	保存处于等待状态的活动session的信息，每秒从v$session_wait中采样一次，并将采样信息保存在内存中，诊断当前数据库的状态，需要最近的五到十分钟的详细信息
AWR
	ASH的采样数据是保存在内存中，而分配给ASH的内存空间是有限的，当所分配空间占满后，旧的记录就会被覆盖掉；
	而且数据库重启后，所有的ASH信息都会消失。
	这样，对于长期检测oracle的性能是不可能的。
	在Oracle中，提供了永久保留ASH信息的方法，这就是AWR（auto workload repository）。
	ASH中的信息被保存到了AWR中的视图wrh$_active_session_history中。ASH是AWR的真子集。
	dbms_workload_repository
wrh$_active_session_history
	每小时对v$active_session_history进行采样一次，并将信息保存到磁盘中
dba_hist_active_sess_history



[oracle@oracle ~]$ cd  /u01/app/oracle/product/11.2.0/db_1/rdbms/admin/
[oracle@oracle admin]$ ls -l awr*
-rw-r--r-- 1 oracle oinstall  1148 Dec  1  2006 awrblmig.sql
-rw-r--r-- 1 oracle oinstall 20892 May 23  2005 awrddinp.sql
-rw-r--r-- 1 oracle oinstall  7450 Jul 25  2011 awrddrpi.sql
-rw-r--r-- 1 oracle oinstall  2005 May 27  2005 awrddrpt.sql
-rw-r--r-- 1 oracle oinstall 11082 Mar 24  2009 awrextr.sql
-rw-r--r-- 1 oracle oinstall 16457 Mar 13  2008 awrgdinp.sql
-rw-r--r-- 1 oracle oinstall  7393 Jul 25  2011 awrgdrpi.sql
-rw-r--r-- 1 oracle oinstall  1897 Apr 29  2009 awrgdrpt.sql
-rw-r--r-- 1 oracle oinstall  7440 Mar 13  2008 awrginp.sql
-rw-r--r-- 1 oracle oinstall  6444 Jul 25  2011 awrgrpti.sql
-rw-r--r-- 1 oracle oinstall  1523 Apr 29  2009 awrgrpt.sql
-rw-r--r-- 1 oracle oinstall 49166 Sep  1  2004 awrinfo.sql
-rw-r--r-- 1 oracle oinstall  2462 Jan  5  2005 awrinpnm.sql
-rw-r--r-- 1 oracle oinstall  8603 Mar  3  2006 awrinput.sql
-rw-r--r-- 1 oracle oinstall 10368 Jul 15  2009 awrload.sql
-rw-r--r-- 1 oracle oinstall  7704 Jul 25  2011 awrrpti.sql
-rw-r--r-- 1 oracle oinstall  1999 Oct 24  2003 awrrpt.sql
-rw-r--r-- 1 oracle oinstall  6803 Jul 25  2011 awrsqrpi.sql
-rw-r--r-- 1 oracle oinstall  1469 Jan  5  2005 awrsqrpt.sql
--生成awr report报告
SQL> @?/rdbms/admin/awrrpt.sql
Enter value for report_type: 
Enter value for num_days: 2

Listing the last 2 days of Completed Snapshots

                                                        Snap
Instance     DB Name        Snap Id    Snap Started    Level
------------ ------------ --------- ------------------ -----
orcl         ORCL               107 14 Mar 2017 06:35      1
                                108 14 Mar 2017 21:52      1
                                109 14 Mar 2017 23:00      1
                                110 15 Mar 2017 21:03      1



Specify the Begin and End Snapshot Ids
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Enter value for begin_snap: 109
Enter value for end_snap: 110
Enter value for report_name: /home/oracle/a.html

如何看awr报告
1. 版本
2. cpu,内存，是不是集群rac
3. Elapsed 30~60分钟是比较适当　　DB Time*CPUs>Elapsed 说明数据有问题
4. Cache Sizes
	Std Block Size:
5. Load Profile
	Rollbacks　如果回滚多，说明了经历了很多无用的操作
6. Instance Efficiency Percentages (Target 100%)
	Buffer Nowait %\NoWait % 希望是100%不要小于99%
7. Shared Pool Statistics
	Memory Usage %:	75~90　比较合适
8. Top 5 Timed Foreground Events排名前５的等待事件
	导常事件，需要关注，如
	cursor: pin S wait on X
	library cache load lock
	再如
	latch shared pool
9. Main Report(根据前面的报告，大致锁定问题，然后根据问题到这里查找详细信息)
	Segment Statistics
10. init.ora Parameters 了解这里的参数也是必要的
如下面的参数就比较小，生产环境往往要加大
open_cursors	300	  　　
processes	150


[oracle@oracle admin]$ ls -l addm*               
-rw-r--r-- 1 oracle oinstall 4748 Jan  5  2005 addmrpti.sql
-rw-r--r-- 1 oracle oinstall 3168 Oct 15  2003 addmrpt.sql
-rw-r--r-- 1 oracle oinstall 6196 Mar  6  2007 addmtmig.sql
addmrpt.sql　是智能帮我们诊断awr的工具
awrsqrpt.sql 针对某个sql去看它详细的报告
