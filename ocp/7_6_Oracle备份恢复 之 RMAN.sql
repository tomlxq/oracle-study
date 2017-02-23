[oracle@oracle ~]$ rman target /
[oracle@oracle ~]$ rman target sys/oracle@orcl_s
RMAN> sql 'alter system switch logfile';
可以查看警告文件验证
SQL> show parameter dump
[oracle@oracle ~]$ tail -200f /u01/app/oracle/diag/rdbms/orcl/orcl/trace/

RMAN> show all --显示默认配置
RMAN> CONFIGURE RETENTION POLICY TO REDUNDANCY 3;　--修改默认值
RMAN> CONFIGURE RETENTION POLICY clear; --清除默认配置
RMAN> CONFIGURE CONTROLFILE AUTOBACKUP ON;　--打开自动备份功能
-- %F或%U都是文件格式名称，最常用
RMAN> CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO '/u01/app/oracle/backup/orcl/%F.ctl';
RMAN> backup tablespace users; 对users表空间作备份，可以看到生成备份控制文件c-1461627167-20170222-00.ctl
--piece handle=/u01/app/oracle/backup/orcl/c-1461627167-20170222-00.ctl comment=NONE

