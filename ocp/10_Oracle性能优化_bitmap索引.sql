/*
analytical

英 [ænə'lɪtɪk(ə)l]  美 [,ænə'lɪtɪkl]
adj. 分析的；解析的；善于分析的


位图索引用在增删改比较少的地方，用在olap比较多。
联机事务处理OLTP（on-line transaction processing）
联机分析处理OLAP（On-Line Analytical Processing）
典型的OLTP系统有电子商务系统、银行、证券等，如美国eBay的业务数据库，就是很典型的OLTP数据库。
位图索引也是一样，如果用在OLTP环境中，很容易造成阻塞与死锁。但是，在OLAP环境中，可能会因为其特有的特性，提高OLAP的查询速度。
*/
SQL> drop table t;

Table dropped.

SQL> create table t as select * from dba_objects;

Table created.

SQL> select distinct object_type from t;

SQL> create bitmap index idx_t on t(object_type);

Index created.
SQL> select rowid,object_type from t where object_type='JOB';

ROWID              OBJECT_TYPE
------------------ -------------------
AAATCIAABAAAsciAAD JOB
AAATCIAABAAAsciAAG JOB
AAATCIAABAAAscjAA0 JOB
AAATCIAABAAAscjAA4 JOB
AAATCIAABAAAscjAA5 JOB
AAATCIAABAAAscnABC JOB
AAATCIAABAAAscnABD JOB
AAATCIAABAAAscnABG JOB
AAATCIAABAAAscqAAE JOB
AAATCIAABAAAscqAAF JOB
AAATCIAABAAAscqAAG JOB

ROWID              OBJECT_TYPE
------------------ -------------------
AAATCIAABAAAsm8AAH JOB
AAATCIAABAAAsm/AA9 JOB
AAATCIAABAAAsm/AA+ JOB
AAATCIAABAAAsqzAAe JOB

15 rows selected.

SQL> update t set object_type='cc' where rowid='AAATCIAABAAAscnABG';
SQL> update t set object_type='bb' where rowid='AAATCIAABAAAscqAAE';--如果是同个位图段，即使它们不是同一个数据块，仍然会被锁



解决ORA-00054
SQL> drop table t purge;
drop table t purge
           *
ERROR at line 1:
ORA-00054: resource busy and acquire with NOWAIT specified or timeout expired

SQL> select t2.username,t2.sid,t2.serial#,t2.logon_time from v$locked_object t1,v$session t2 where t1.session_id=t2.sid order by t2.logon_time;

USERNAME                              SID    SERIAL# LOGON_TIM
------------------------------ ---------- ---------- ---------
SYS                                    48        637 12-MAR-17
SYS                                    50        841 14-MAR-17
SQL> select sql_text from v$session a,v$sqltext_with_newlines b where DECODE(a.sql_hash_value, 0, prev_hash_value, sql_hash_value)=b.hash_value and a.sid=&sid order by piece;
Enter value for sid: 48

SQL> select sql_text from v$session a,v$sqltext_with_newlines b where DECODE(a.sql_hash_value, 0, prev_hash_value, sql_hash_value)=b.hash_value and a.sid=&sid order by piece;
Enter value for sid: 50
SQL> alter system kill session '48,637';

System altered.

SQL> alter system kill session '50,841';

System altered.

SQL>  drop table t;

Table dropped.