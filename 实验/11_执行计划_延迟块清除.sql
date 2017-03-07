slot

英 [slɒt]  美 [slɑt]
n. 位置；狭槽；水沟；硬币投币口
vt. 跟踪；开槽于
n. (Slot)人名；(英、荷)斯洛特

快速块清除（fast block clean out）
	当发生fast commit cleanout，系统将transaction 提交时刻的scn 作为commit scn，更新
		block 上事物槽（itl）
		undo segment header 的Transaction table 的slot 上的scn
		并修改block scn，三者是一致的
事物槽
	ITL(Interested Transaction List)是Oracle 数据块内部的一个组成部分，位于数据块头（block header），
	itl 由xid，uba，flag，lck 和scn/fsc 组成，用来记录该块所有发生的事务，
	一个itl 可以看作是一条事务记录。
	当然，如果这个事务已经提交，那么这个itl 的位置就可以被反复使用了，因为itl 类似记录，所以，有的时候也叫itl 槽位。
	如果一个事务一直没有提交，那么，这个事务将一直占用一个itl 槽位，itl 里面记录了事务信息，回滚段的入口，事务类型等等。
	如果这个事务已经提交，那么，itl 槽位中还保存的有这个事务提交时候的SCN 号。
延迟块清除
	块清除（block clean out） 是指把一个块中的数据从dirty 变为clean
	本质上是更改block header 中的一个标志位。
	有时候在执行select 操作的时候也可能会产生redo，一个可能原因就是oracle 块清除。
	在进行块清除的时候,如果是一个大事务,就会进行延迟块清除。
	COMMIT 实际的释放方式即清除块上相应的事务槽，但这里存在一个性能的考量。
	设想一个UPDATE 大量数据的操作，因为执行时间较长，一部分已修改的块已被缓冲池flush out 写至磁盘，
	当UPDATE 操作完成执行COMMIT 操作时，则需要将那些已写至磁盘的数据块重新读入，这将消耗大量I/O，并使COMMIT 操作十分缓慢；
	为了解决这一矛盾，Oracle使用了延迟块清除的方案，对待存在以下情况的块COMMIT 操作不做块清除：
		在更新过程中，被缓冲池flush out 写至磁盘的块
		若更新操作涉及的块超过了块缓冲区缓存的10%时，超出的部分块。
	虽然COMMIT 放弃对这些块的块清除(block cleanout)操作，但COMMIT 操作仍会修改回滚段的段头，回滚段的段头包括了段中的事务的字典，COMMIT 操作将本事务转化为非ACTIVE 状态。
	当下一次操作如SELECT,UPDATE,INSERT 或DELETE 访问到这些块时可能需要在读入后完成块清除，这样的操作称之为块延迟清除（deferred block cleanout）；
	块延迟清除通过事务槽上的回滚段号，槽号等信息访问回滚段头的事务字典，若事务不再活跃或事务过期则完成清除块上的事务槽，事务槽清除后继续执行相应的操作。
	块延迟清除的影响在SELECT 操作过程中体现的最为明显。
	总结来说块延迟清除是COMMIT 操作的一个延续，始终是一种十分轻微的操作，且该种操作是行级的，不会使段(Segment)的属性有所改变。



实验1: 延迟块清除
SQL> set autotrace off
SQL> drop table t purge;
SQL> create table t as select 1 id,object_name from dba_objects;
SQL> update t set id=99 where rownum=1;
SQL> set autotrace traceonly;
SQL> select * from t;--数据被缓存到buffer_cache

75594 rows selected.


Execution Plan
----------------------------------------------------------
Plan hash value: 1601196873

--------------------------------------------------------------------------
| Id  | Operation         | Name | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      | 79525 |  6135K|    95   (2)| 00:00:02 |
|   1 |  TABLE ACCESS FULL| T    | 79525 |  6135K|    95   (2)| 00:00:02 |
--------------------------------------------------------------------------

Note
-----
   - dynamic sampling used for this statement (level=2)


Statistics
----------------------------------------------------------
          5  recursive calls
          0  db block gets
        492  consistent gets
         86  physical reads
          0  redo size
    2457498  bytes sent via SQL*Net to client
       1244  bytes received via SQL*Net from client
         77  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
      75594  rows processed

SQL> update t set id=99; --修改buffer_cache,旧值保存到undo

75594 rows updated.


Execution Plan
----------------------------------------------------------
Plan hash value: 931696821

---------------------------------------------------------------------------
| Id  | Operation          | Name | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------
|   0 | UPDATE STATEMENT   |      | 79525 |  1009K|    95   (2)| 00:00:02 |
|   1 |  UPDATE            | T    |       |       |            |          |
|   2 |   TABLE ACCESS FULL| T    | 79525 |  1009K|    95   (2)| 00:00:02 |
---------------------------------------------------------------------------

Note
-----
   - dynamic sampling used for this statement (level=2)


Statistics
----------------------------------------------------------
         86  recursive calls
      80375  db block gets
        872  consistent gets
          2  physical reads
   24648332  redo size
        685  bytes sent via SQL*Net to client
        590  bytes received via SQL*Net from client
          3  SQL*Net roundtrips to/from client
          1  sorts (memory)
          0  sorts (disk)
      75594  rows processed

SQL> alter system flush buffer_cache; --清空内存  数据被存放到数据文件<commit>
SQL> alter system flush shared_pool;

System altered.

SQL> 
System altered.

SQL> commit; --快速提交，触发lgwr进程 

Commit complete.

SQL> select * from t; --延迟块清除(已提交)

75594 rows selected.


Execution Plan
----------------------------------------------------------
Plan hash value: 1601196873

--------------------------------------------------------------------------
| Id  | Operation         | Name | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      | 79525 |  6135K|    95   (2)| 00:00:02 |
|   1 |  TABLE ACCESS FULL| T    | 79525 |  6135K|    95   (2)| 00:00:02 |
--------------------------------------------------------------------------

Note
-----
   - dynamic sampling used for this statement (level=2)


Statistics
----------------------------------------------------------
         73  recursive calls
          0  db block gets
        933  consistent gets
        356  physical reads
      24452  redo size
    2457498  bytes sent via SQL*Net to client
       1244  bytes received via SQL*Net from client
         77  SQL*Net roundtrips to/from client
         10  sorts (memory)
          0  sorts (disk)
      75594  rows processed