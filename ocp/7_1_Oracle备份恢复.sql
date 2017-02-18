/*
scn: system change number 系统更改号
	current scn
		select current_scn from v$database;
	system checkpoint scn
		controlfile存放在控制文件
		select checkpoint_change# from v$database;
		alter system checkpoint;(代表数据库同步到的一个状态)
	datafile checkpoint scn
		每个数据文件都有一个scn,也是存在控制文件中的
		select name,checkpoint_change# from v$datafile;
		查看实验1，实验2
	start scn
		记录在数据文件中
		SQL> select name,checkpoint_change# from v$datafile_header;
	stop scn
		正常情况，online的数据文件为,scn为null
		存在控制文件中
		SQL> select name,last_change# from v$datafile;
		如果所有stop scn都有值，说明数据库是正常关闭
		这时要实例恢复instance recover,不需要人工干预（检查scn号，将重做日志里的操作写入数据数据）
*/
/*
实验1: 如何启用归档
	SQL> archive log list
	SQL> select * from v$log;　在线日志，循环使用
	希望脱机保存，就要归档，首先要设置归档　　　
	SQL> show parameter arch
	--设置归档的路径cd $ORACLE_BASE/arch/$ORACLE_SID/
	SQL> alter system set log_archive_dest_1='location=/u01/app/oracle/arch/orcl';
	--归档需要在mount状态下设置alter database archivelog/alter database open
	SQL> shutdown immediate
	SQL> startup mount
	SQL> alter database archivelog;
	SQL> alter database open;
	--查看当前日志的归档情况
	SQL> archive log list
实验2: 搞清楚SCN
SQL> desc dba_data_files
SQL> col file_name for a30
SQL> select FILE_NAME,FILE_ID,TABLESPACE_NAME from dba_data_files;
--这里每个文件的scn不同，对某个数据文件脱机，只能改变它的scn号
--如果合部文件脱机，意味着数据库关掉，则scn号都要变
SQL> alter database datafile 4 offline;　将4号文件脱机
SQL> select name,checkpoint_change# from v$datafile_header;
SQL> alter system checkpoint;
SQL> select name,checkpoint_change# from v$datafile_header; 将4号文件脱机文件scn不会变，其它都变了
SQL> select name,last_change# from v$database; 也是一样的
SQL> recover datafile 4;联机一下
SQL> alter database datafile 4 online;

数据库恢复
	是否需要介质恢复?为什么要有两个scn
		database checkping SCN		start SCN
		数据文件		SCN			ctl控制文件SCN
		ctl				--16:25		16:25
		system02.dbf	--16:25		16:25
		sysaux01.dbf	--16:25		16:25
		user01.dbf		--16:15		16:25(则说不正常，丢了10分钟数据)
		判断start SCN、database checkping SCN是否一致,需要人工干预
	是否需要实例恢复?instance recover 
		判断stop scn==null, 需要实例恢复,不需要人工干预
*/