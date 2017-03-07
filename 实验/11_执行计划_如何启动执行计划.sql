[oracle@oracle ~]$ sqlplus hr/oracle 
Enter user-name: ERROR:
ORA-01017: invalid username/password; logon denied
[oracle@oracle ~]$ sqlplus sys/oracle@orcl as sysdba
SQL> alter user hr identified by oracle account unlock;
SQL> conn hr/oracle
SQL> set autotrace on 
SP2-0618: Cannot find the Session Identifier.  Check PLUSTRACE role is enabled
SP2-0611: Error enabling STATISTICS report
SQL> exit
[oracle@oracle ~]$ sqlplus sys/oracle@orcl as sysdba
--创建一个表(PLAN_TABLE)。该表用于观察SQL 语句的运行计划(Execution Plan)。
SQL> @$ORACLE_HOME/rdbms/admin/utlxplp.sql  
--创建plustrace 角色
SQL> @$ORACLE_HOME/sqlplus/admin/plustrce.sql 
--将plustrace 角色授予当前用户(无DBA 角色的用户)，或grant plustrace to public。
SQL> grant plustrace to hr;
SQL> conn hr/oracle
Connected.
SQL> set autotrace traceonly
SQL> select count(*) from hr.employees;


Execution Plan
----------------------------------------------------------
Plan hash value: 3580537945

-------------------------------------------------------------------------
| Id  | Operation        | Name         | Rows  | Cost (%CPU)| Time     |
-------------------------------------------------------------------------
|   0 | SELECT STATEMENT |              |     1 |     1   (0)| 00:00:01 |
|   1 |  SORT AGGREGATE  |              |     1 |            |          |
|   2 |   INDEX FULL SCAN| EMP_EMAIL_UK |   107 |     1   (0)| 00:00:01 |
-------------------------------------------------------------------------