--显示时间
SQL> set timing on 
SQL> create table t (x int);
SQL> alter system flush shared_pool;
SQL> create or replace procedure p1
  2  as 
  3  begin
  4      for i in 1..1000000
  5      loop
  6            execute immediate
  7            'insert into t values ('||i||')';
  8  commit;
  9      end loop;
 10  end;
 11  /

Procedure created.

Elapsed: 00:00:02.18
--由于上面的过程p1，因为没有绑定变量，于是每个语句必须得硬解析1次，执行1次，硬解析了100w次，
SQL> exec p1;

PL/SQL procedure successfully completed.

Elapsed: 00:14:16.66
--删除t表，清空共享池
SQL> drop table t purge;
SQL> create table t (x int);
SQL> alter system flush shared_pool;

SQL> create or replace procedure p2
  2  as 
  3  begin
  4      for i in 1..1000000
  5      loop
  6            execute immediate
  7            'insert into t values(:x)' using i;
  8  commit;
  9      end loop;
 10  end;
 11  /

Procedure created.

Elapsed: 00:00:00.36
--绑定变量后hash成为一个唯一的hash值，解析一次，执行了100w次。语句执行硬解析1次，之后的999999次都是软解析
SQL> exec p2;

PL/SQL procedure successfully completed.

Elapsed: 00:05:02.06

SQL> drop table t purge;
SQL> create table t (x int);
SQL> alter system flush shared_pool;
--execute immediate是一种动态的SQL写法，常用于于表名字段名是变量，入参的情况，由于表名都不知道，所以当然不能直接写SQL语句了，所以要靠动态SQL语句根据传入表名参数，来拼成一条SQL语句，由  execute immediate调用执行，。但是当知道表名的时候就是多此一举了。一般来说，静态sql会知道使用绑定变量。动态SQL的特点是执行过程中再解析，而静态SQL的特点是编译的过程解析好了，这样又节省了时间。
SQL> create or replace procedure p3
  2  as 
  3  begin
  4      for i in 1..1000000
  5      loop
  6           insert into t values(i);
  7  commit;
  8      end loop;
  9  end;
 10  /

Procedure created.

Elapsed: 00:00:00.10
SQL> exec p3;

PL/SQL procedure successfully completed.

Elapsed: 00:04:39.84
-- commit 触发LGWR 将REDO BUFFER 写到redo buffer中，并且将回滚段的活动事务标记为不活动，同时让回滚段中记录对应前镜像记录的所在位置标记为可以重写，（commit 不是写数据的动作，将数据从databuffer刷出磁盘是有CKPT决定的，）所以commit做的事情开销并不大，单词提交可能需要0.001秒即可完成，不管多大批量操作后的提交，针对commit而言，也是做这三件事情，所花费的总时间不可能超过1秒钟加入1条记录执行完后commit的提交时间需要0.8秒，但是100w条记录，就远远不止0.8秒。
SQL> drop table t purge;
SQL> create table t (x int);
SQL> alter system flush shared_pool;
SQL> create or replace procedure p4
  2  as 
  3  begin
  4      for i in 1..1000000
  5      loop
  6           insert into t values(i);
  7      end loop;
  8  commit;
  9  end;
 10  /

Procedure created.

Elapsed: 00:00:02.14
--把过程变成了SQL一条一条插入变成了一个集合的概念，变成了一个整批的写进DATA ,这就相当于一瓢一瓢的向池子里面注水，变成了一桶一桶的注水。
SQL> exec p4;

PL/SQL procedure successfully completed.

Elapsed: 00:02:43.50
SQL> drop table t purge;
SQL> create table t (x int);
SQL> alter system flush shared_pool;
-- insert into t select ...的方式是将数据先写到data buffer 中，然后再刷到磁盘。
--而create table t的方式确实跳过了数据缓存区，直接写进磁盘中，这种方式称之为直接路径读写方式。原本是先写到内存，再写到磁盘，改为直接写到磁盘，少了一个步骤。
SQL>  insert into t select rownum from dual connect by level<=1000000;

1000000 rows created.

Elapsed: 00:00:09.89
--直接路径读写方式的缺点在于由于数据不经过数据缓存区，所以在数据缓存区中一定读不到这些数据，因此一定会有物理读。但是实际很多情况下，尤其是海量数据需要迁移插入的时候，快速插入才是真正的第一目的。该表一般记录巨大，date buffer 甚至存放不下其十分之一，百分之一，那么这写共享的数据意义也就不大了。这是，我们一般会选择直接路径读写方式来完成海量数据的插入。
SQL> drop table t purge;
SQL> alter system flush shared_pool;
SQL> create table t as select rownum x from dual connect by level <=1000000;

Table created.

Elapsed: 00:00:06.08
SQL> select count(*) from t;

  COUNT(*)
----------
   1000000
--nologging方式，并行方式，等等
SQL> drop table t purge;
SQL> alter system flush shared_pool;
SQL> create table t nologging parallel 16 as select rownum x from dual connect by level<=1000000;

Table created.

Elapsed: 00:00:11.07