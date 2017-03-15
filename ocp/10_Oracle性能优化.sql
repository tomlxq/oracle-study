性能优化的工具
	告警日志
	SQL跟踪
		sql_trace
		10046事件-10053
			alter session set events '10046 trace name context forever, level 1';
			alter sesssion set events '10046 trace name context off';
	statspack
	awr
	addm
		@/rdbms/admin/addmrpti
io调优
	全表扫描
	索引扫描
	物理读
	日志文档、归档日志
共享池
	执行计划
buffer cache\redo buffer与java
pga与排序
sql调优
	优化器
	访问路径
	Hints
	大纲
	诊断工具
		statspack
		explain plan for
		sql_trace
		sqlplus autotrace
资料库收集
	柱状图
	analyze
存储空间管理
	区(大区、小区)
	块(大块、小块)
	OLAP\OLTP
索引组织表
分区表
各类索引
物化视图


Preferences:
	官方文档: Performance Tuning Guide