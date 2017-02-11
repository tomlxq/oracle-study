--ORA-01045: user HR lacks CREATE SESSION privilege; logon denied
grant connect, resource to hr;
grant create session to hr;
grant restricted session to hr;
 
grant connect, resource to scott;
grant create session to scott;
grant restricted session to scott;
--创建hr样例
conn / as sysdba;  
@/home/oracle/hr_main.sql
alter user hr identified by oracle account unlock