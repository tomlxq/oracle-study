SQL> conn scott/oracle
Connected.

SQL> drop table dept_t purge;

Table dropped.

SQL> create table dept_t as select * from scott.dept;

Table created.

SQL> insert into dept_t values(70,'boss7','shenzhen');

1 row created.

SQL> insert into dept_t values(80,'boss8','shenzhen');

1 row created.

SQL> insert into dept_t values(90,'boss9','shenzhen');

1 row created.

SQL> savepoint b;

Savepoint created.

SQL> delete from dept_t where deptno=70;

1 row deleted.

SQL> select * from dept_t;

    DEPTNO DNAME          LOC
---------- -------------- -------------
        10 ACCOUNTING     NEW YORK
        20 RESEARCH       DALLAS
        30 SALES          CHICAGO
        40 OPERATIONS     BOSTON
        80 boss8          shenzhen
        90 boss9          shenzhen

6 rows selected.

SQL> savepoint c;

Savepoint created.

SQL> update dept_t set deptno=81 where deptno=80;

1 row updated.

SQL> select * from dept_t;

    DEPTNO DNAME          LOC
---------- -------------- -------------
        10 ACCOUNTING     NEW YORK
        20 RESEARCH       DALLAS
        30 SALES          CHICAGO
        40 OPERATIONS     BOSTON
        81 boss8          shenzhen
        90 boss9          shenzhen

6 rows selected.

SQL> rollback to c;

Rollback complete.

SQL> select * from dept_t;

    DEPTNO DNAME          LOC
---------- -------------- -------------
        10 ACCOUNTING     NEW YORK
        20 RESEARCH       DALLAS
        30 SALES          CHICAGO
        40 OPERATIONS     BOSTON
        80 boss8          shenzhen
        90 boss9          shenzhen

6 rows selected.

SQL> rollback to b;

Rollback complete.

SQL> select * from dept_t;

    DEPTNO DNAME          LOC
---------- -------------- -------------
        10 ACCOUNTING     NEW YORK
        20 RESEARCH       DALLAS
        30 SALES          CHICAGO
        40 OPERATIONS     BOSTON
        70 boss7          shenzhen
        80 boss8          shenzhen
        90 boss9          shenzhen

7 rows selected.

SQL> rollback;

Rollback complete.

SQL> select * from dept_t;

    DEPTNO DNAME          LOC
---------- -------------- -------------
        10 ACCOUNTING     NEW YORK
        20 RESEARCH       DALLAS
        30 SALES          CHICAGO
        40 OPERATIONS     BOSTON
		
事务的几个重要操作
1 设置保存点 savepoint a 
2 取消部分事务 rollback to a 
3 取消全部事务 rollback
若执行SQL> commit;提交操作，则该事务中所有保存点都不存在了。如果没有手动执行commit而是exit会自动提交。		
		