SP2-0618: Cannot find the Session Identifier. Check PLUSTRACE role is enable
以前一直用 SYS 用户使用 autotrace, 今天用其它用户使用 autotrace 来获得执行计划报如下错误
SQL> set autotrace traceonly;
SP2-0618: Cannot find the Session Identifier.  Check PLUSTRACE role is enabled
SP2-0611: Error enabling STATISTICS report
SQL> conn / as sysdba
Connected.
SQL> grant plustrace to hr;
grant plustrace to hr
      *
ERROR at line 1:
ORA-01919: role 'PLUSTRACE' does not exist


SQL> @$ORACLE_HOME/sqlplus/admin/plustrce.sql
SQL> 
SQL> drop role plustrace;
drop role plustrace
          *
ERROR at line 1:
ORA-01919: role 'PLUSTRACE' does not exist


SQL> create role plustrace;

Role created.

SQL> 
SQL> grant select on v_$sesstat to plustrace;

Grant succeeded.

SQL> grant select on v_$statname to plustrace;

Grant succeeded.

SQL> grant select on v_$mystat to plustrace;

Grant succeeded.

SQL> grant plustrace to dba with admin option;

Grant succeeded.

SQL> 
SQL> set echo off
SQL> grant plustrace to hr;

Grant succeeded.

SQL> conn hr/oracle
Connected.
SQL> set autotrace traceonly;