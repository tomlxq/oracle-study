开启归档:
	SQL> archive log list
	SQL> show parameter archive
	SQL> alter system set log_archive_dest_1='location=/u01/app/oracle/arch/prod';
	SQL> shutdown immediate;
	SQL> startup mount;
	SQL> alter database archivelog;
	SQL> alter database open;