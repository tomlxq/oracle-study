/*
备份策略
	1.　预防
	2.　mtbf(mean-time-between-failures)
	3.	mttr(mean-time-to-recover)
		fast_start_mttr_target　控制数据库在多长时间启动起来
	4. 最小丢失

media failure
	取决于数据丢失量,磁盘，dba水平，备份情况
instance failure
	日志量		redo log->datafile

理念:
	data guard,双机备份	
	自动化运维
	周期性测试备份恢复策略

策略应包含的内容：
	健壮性
	本地容灾
	备份方法
	备份文件
	执行时机
	执行频度
	存储方法和位置
	异地容灾--ogg数据同步
常见故障
	语句故障
	用户进程故障
	
SQL> show parameter mttr

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
fast_start_mttr_target               integer     0
*/

pmon 监听注册服务、自动回滚事务并释放资源、自动检测非正常终止用户进程
asm+rac(存储复制)、data guard(考虑逻辑坏块)
itpub

逻辑备份	表导出来备份
物理备份	数据文件备份
