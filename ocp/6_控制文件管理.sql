rman target /
CONFIGURE RETENTION POLICY TO REDUNDANCY 2;
exit;
more '/home/oracle/c1'

alter database backup controlfile to trace as '/home/oracle/c1';  --备份控制文件到文本文件
/*
控制文件
	可变
		备份信息
		归档信息
	不可变
		数据库信息
*/
cat c1 | grep -v ^- | grep -v ^$ > c1.sql
  '/oradata/orcl/user01.dbf'
cat c1.sql 
STARTUP NOMOUNT
CREATE CONTROLFILE REUSE DATABASE "ORCL" NORESETLOGS  ARCHIVELOG
    MAXLOGFILES 64
    MAXLOGMEMBERS 4
    MAXDATAFILES 2000
    MAXINSTANCES 8
    MAXLOGHISTORY 1168
LOGFILE
  GROUP 1 '/oradata/orcl/redo01.log'  SIZE 50M BLOCKSIZE 512,
  GROUP 2 '/oradata/orcl/redo02.log'  SIZE 50M BLOCKSIZE 512,
  GROUP 3 '/oradata/orcl/redo03.log'  SIZE 50M BLOCKSIZE 512,
  GROUP 4 '/oradata/orcl/redo04.log'  SIZE 50M BLOCKSIZE 512
DATAFILE
  '/oradata/orcl/system01.dbf',
  '/oradata/orcl/sysaux01.dbf',
  '/oradata/orcl/undotbs01.dbf',
  '/oradata/orcl/user01.dbf'
/*
vi编辑脚本时如何快速删除当前行和后面的全部内容？ [复制链接]
dG是删除当前后面的全部内容
*/ 
  sqlplus / as sysdba;
  shutdown immediate;
  startup nomount;
   @/home/oracle/c1.sql
   /
  SELECT type, record_size, records_total, records_used FROM v$controlfile_record_section;
  
/*	
	增加一个控制文件
		1>逻辑 control_files　+　control03.ctl
		2>物理 cp
	删除一个控制文件
		1>逻辑 control_files　-　control03.ctl
		2>物理 rm
	移动一个控制文件
		1>逻辑 control_files 修改路径　control03.ctl
		2>物理 mv	
故障：丢失控制文件
	丢失一个控制文件
		再拷贝一个
		直接修改参数文件把丢失的文件去掉
	丢失全部控制文件
		有备份
			二进制备份
			文件备份: 重建控制文件
		没有备份
			只能照下面的格式造一个文本，来创建控制文件
			[oracle@oracle dbs]$ more '/home/oracle/c1.sql'
			CREATE CONTROLFILE REUSE DATABASE "ORCL" NORESETLOGS  ARCHIVELOG
				MAXLOGFILES 64
				MAXLOGMEMBERS 4
				MAXDATAFILES 2000
				MAXINSTANCES 8
				MAXLOGHISTORY 1168
			LOGFILE
			  GROUP 1 '/oradata/orcl/redo01.log'  SIZE 50M BLOCKSIZE 512,
			  GROUP 2 '/oradata/orcl/redo02.log'  SIZE 50M BLOCKSIZE 512,
			  GROUP 3 '/oradata/orcl/redo03.log'  SIZE 50M BLOCKSIZE 512,
			  GROUP 4 '/oradata/orcl/redo04.log'  SIZE 50M BLOCKSIZE 512
			DATAFILE
			  '/oradata/orcl/system01.dbf',
			  '/oradata/orcl/sysaux01.dbf',
			  '/oradata/orcl/undotbs01.dbf',
			  '/oradata/orcl/user01.dbf'
	*/
  /u01/app/oracle/product/11.2.0/db_1/dbs
  vi initorcl.ora
  *.control_files='/oradata/orcl/control01.ctl','/oradata/orcl/control02.ctl','/oradata/orcl/control03.ctl'
  cp spfileorcl.ora spfileorcl.ora.bak --备份动态参数文件
 
  shutdown immediate;
  create spfile from pfile;
  cd oradata/orcl/
  cp control01.ctl control03.ctl 
  startup mount;
  show parameter control;
  
 
  