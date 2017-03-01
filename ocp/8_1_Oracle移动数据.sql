迁移数据
	导入导出
	数据泵导入导出
		
		表、表空间、schema、database、传输表空间
		目录
			dumpfile=dump_dir:mydb_%U.dat
			directory=dump_dir dumpfile=mydb_%U.dat
			grant read,write | all on directory dump_dir to scott;
	sql*loader
	
目标数据库
	 192.168.21.3
源数据库 
	192.168.21.4
	创建导出目录
	df -h
	mkdir -p /home/oracle/exp
	cd /home/oracle/exp/
	
	sqlplus / as sysdba;
	alter user hr identified by oracle account unlock;
	create directory exp_dir as '/home/oracle/exp';
	grant all on directory exp_dir to hr;
	