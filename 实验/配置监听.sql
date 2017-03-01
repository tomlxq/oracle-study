配置监听：
	[oracle@oracle ~]$ cat /u01/app/oracle/product/11.2.0/db_1/network/admin/tnsnames.ora
	PROD =
	  (DESCRIPTION =
		(ADDRESS = (PROTOCOL = TCP)(HOST = oracle.example.com)(PORT = 1521))
		(CONNECT_DATA =
		  (SERVER = DEDICATED)
		  (SERVICE_NAME = prod)
		)
	  )
	ORCL =
	  (DESCRIPTION =
		(ADDRESS = (PROTOCOL = TCP)(HOST = oracle.example.com)(PORT = 1521))
		(CONNECT_DATA =
		  (SERVER = DEDICATED)
		  (SERVICE_NAME = orcl)
		)
	  )

	[oracle@oracle ~]$ cat /u01/app/oracle/product/11.2.0/db_1/network/admin/listener.ora
	SID_LIST_LISTENER=
	(SID_LIST=
			(SID_DESC=
					(GLOBAL_DBNAME=orcl)
					(ORACLE_HOME=/u01/app/oracle/product/11.2.0/db_1)
					(SID_NAME=orcl)
			)
			(SID_DESC=
					(GLOBAL_DBNAME=prod)
					(ORACLE_HOME=/u01/app/oracle/product/11.2.0/db_1)
					(SID_NAME=prod)
			)
	)
	LISTENER =
	  (DESCRIPTION =
		(ADDRESS = (PROTOCOL = TCP)(HOST = oracle.example.com)(PORT = 1521))
	  )

	ADR_BASE_LISTENER = /u01/app/oracle
	tnsping prod | orcl
	lsnrctl stop | start 
	lsnrctl status