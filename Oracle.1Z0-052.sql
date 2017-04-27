QUESTION 1 
The instance abnormally terminates because of a power outage. Which statement is true about redo log files during instance recovery?
A. Inactive and current redo log files are required to accomplish recovery
B. Online and archived redo files are required to accomplish instance recovery
C. All redo log entries after the last checkpoint are applied from redo log files to data files
D. All redo log entries recorded in the current log file until the checkpoint position are applied to data files
Correct Answer: C
答案解析：
参考：http://blog.csdn.net/rlhua/article/details/12616383
这个是属于实例恢复，实例恢复不需要DBA的干预。
Oracle DB 会自动从实例故障中进行恢复。实例所需要做的就是正常启动。如果Oracle 
Restart 已启用并且配置为监视该数据库，则该启动操作会自动进行。实例会装载控制文件，
然后尝试打开数据文件。如果实例发现数据文件在关闭期间尚未同步，则会使用重做日志
组中包含的信息将数据文件前滚到关闭时的状态，此时利用的重做日志信息即是自最后一次检查点以来所有的重做信息。然后，将打开数据库，并回退所有未提
交的事务处理。