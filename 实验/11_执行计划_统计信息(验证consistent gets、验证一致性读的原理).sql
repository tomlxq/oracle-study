DDL 
	Data Definition Language 
	alter create drop
DML
	Data Manipulation Language
	insert delete update 
DQL 
	Data Query Language
	select 
SQL> set autotrace traceonly
SQL> select * from t order by id;

75593 rows selected.


Execution Plan
----------------------------------------------------------
Plan hash value: 961378228

-----------------------------------------------------------------------------------
| Id  | Operation          | Name | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |      | 75593 |  1993K|       |   673   (1)| 00:00:09 |
|   1 |  SORT ORDER BY     |      | 75593 |  1993K|  2688K|   673   (1)| 00:00:09 |
|   2 |   TABLE ACCESS FULL| T    | 75593 |  1993K|       |    95   (2)| 00:00:02 |
-----------------------------------------------------------------------------------


Statistics
----------------------------------------------------------
          1  recursive calls
          0  db block gets
        342  consistent gets
          0  physical reads
          0  redo size
    2291060  bytes sent via SQL*Net to client
      55848  bytes received via SQL*Net from client
       5041  SQL*Net roundtrips to/from client
          1  sorts (memory)
          0  sorts (disk)
      75593  rows processed
1) recursive calls
	比如做一些操作的分配空间，执行ddl，或者触发trigger，或者在解析的时候数据字典缓存需要一些对象的信息
	主要是因为需要数据字典信息，解析和分配空间导致了递归调用的产生。
SQL> set autotrace off
SQL> alter system flush shared_pool;
SQL> alter system flush buffer_cache;
SQL> set autotrace traceonly
SQL> select * from t order by id;

75593 rows selected.


Execution Plan
----------------------------------------------------------
Plan hash value: 961378228

-----------------------------------------------------------------------------------
| Id  | Operation          | Name | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |      | 75593 |  1993K|       |   673   (1)| 00:00:09 |
|   1 |  SORT ORDER BY     |      | 75593 |  1993K|  2688K|   673   (1)| 00:00:09 |
|   2 |   TABLE ACCESS FULL| T    | 75593 |  1993K|       |    95   (2)| 00:00:02 |
-----------------------------------------------------------------------------------


Statistics
----------------------------------------------------------
          9  recursive calls
          0  db block gets
        362  consistent gets
        344  physical reads
          0  redo size
    2291060  bytes sent via SQL*Net to client
      55848  bytes received via SQL*Net from client
       5041  SQL*Net roundtrips to/from client
          4  sorts (memory)
          0  sorts (disk)
      75593  rows processed
SQL> /

75593 rows selected.


Execution Plan
----------------------------------------------------------
Plan hash value: 961378228

-----------------------------------------------------------------------------------
| Id  | Operation          | Name | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |      | 75593 |  1993K|       |   673   (1)| 00:00:09 |
|   1 |  SORT ORDER BY     |      | 75593 |  1993K|  2688K|   673   (1)| 00:00:09 |
|   2 |   TABLE ACCESS FULL| T    | 75593 |  1993K|       |    95   (2)| 00:00:02 |
-----------------------------------------------------------------------------------


Statistics
----------------------------------------------------------
          0  recursive calls
          0  db block gets
        342  consistent gets
          0  physical reads
          0  redo size
    2291060  bytes sent via SQL*Net to client
      55848  bytes received via SQL*Net from client
       5041  SQL*Net roundtrips to/from client
          1  sorts (memory)
          0  sorts (disk)
      75593  rows processed
多执行几次，让recursive calls 和physical reads 都变为零，即完全从内存中读取。
可以看到至少需要342个逻辑读，或者342个读block 操作。
2) Db block gets
在即时读模式下所读的块数。比较少和特殊，例如数据字典数据获取，在DML 中，更改或删除数据是要用到当前读模式。
3) Consistent gets 在一致性模式下所读的块数。
	即时读（current mode）（db block gets）（UPDATE/DELETE）
	SQL> update t set id=95 where rownum=1;

	1 row updated.


	Execution Plan
	----------------------------------------------------------
	Plan hash value: 1542290936

	----------------------------------------------------------------------------
	| Id  | Operation           | Name | Rows  | Bytes | Cost (%CPU)| Time     |
	----------------------------------------------------------------------------
	|   0 | UPDATE STATEMENT    |      |     1 |     3 |    95   (2)| 00:00:02 |
	|   1 |  UPDATE             | T    |       |       |            |          |
	|*  2 |   COUNT STOPKEY     |      |       |       |            |          |
	|   3 |    TABLE ACCESS FULL| T    | 75593 |   221K|    95   (2)| 00:00:02 |
	----------------------------------------------------------------------------

	Predicate Information (identified by operation id):
	---------------------------------------------------

	   2 - filter(ROWNUM=1)


	Statistics
	----------------------------------------------------------
			  5  recursive calls
			  1  db block gets
			 11  consistent gets
			  0  physical reads
			332  redo size
			685  bytes sent via SQL*Net to client
			605  bytes received via SQL*Net from client
			  3  SQL*Net roundtrips to/from client
			  3  sorts (memory)
			  0  sorts (disk)
			  1  rows processed
	一致性读（consistent mode）（consistent gets）（SELECT）
		如果一个事务需要修改数据块中数据，
		会先在回滚段中保存一份修改前数据和SCN 的数据块，
		然后再更新Buffer Cache 中的数据块的数据及其SCN，并标识其为“脏”数据。
		当其他进程读取数据块时，会先比较数据块上的SCN 和自己的SCN。如果数据块上的SCN 小于等于进程本身的SCN，则直接读取数据块上的数据；
		如果数据块上的SCN 大于进程本身的SCN，则会从回滚段中找出修改前的数据块读取数据。通常，普通查询都是一致性读。
		当查询开始的时候oracle 将确立一个时间点，凡是在这个时间点以前提交的数据oracle 将能看见，之后提交的数据将不能看见。
		但查询的时候可能遇上这样的情况，该块中数据已经被修改了，没有提交，或者提交的时间点比查询开始的时间晚，则oracle 为了保证读的一致性，需要去回滚段获取该块中变化前的数据。这叫consistent reads 。

	LOGIC IO（逻辑读次数）= db block gets + consistent gets
	逻辑读指的就是从（或者视图从）Buffer Cache 中读取数据块。按照访问数据块的模式不同，可以分为
		即时读（Current Read）
		一致性读（Consistent Read
	对于全表扫描一个表获取全部行产生的一致性读的一个计算公式：
	consistent gets=numrows/arraysize + blocks --查看实验1、2、3
		arraysize 定义了一次返回到客户端的行数
		show arraysize --查看默认值
		set arraysize 100 --手工修改arraysize
4) physical reads
	物理读。从磁盘或者IO 缓存中读取的次数
	当数据块第一次读取到,就会缓存到buffer cache 中,而第二次读取和修改该数据块时就在内存buffer cache 了
	数据块被重新读入buffer cache ,这种发生在如果有新的数据需要被读入Buffer Cache中，而Buffer Cache 又没有足够的空闲空间，Oracle 就根据LRU 算法将LRU 链表中LRU端的数据置换出去。当这些数据被再次访问到时，需要重新从磁盘读入。
5) redo size
产生的redo 数量。

	
实验1 验证 consistent gets=numrows/arraysize + blocks	
SQL> set autotrace off
SQL> select blocks,num_rows,empty_blocks from dba_tables where table_name='T';

    BLOCKS   NUM_ROWS EMPTY_BLOCKS
---------- ---------- ------------
       339      75593            0

SQL> show arraysize
arraysize 100
SQL> select 75593/100+339 from dual;

75593/100+339
-------------
      1094.93

SQL> set autotrace trace statistics
SQL> select * from t;

75593 rows selected.


Statistics
----------------------------------------------------------
          1  recursive calls
          0  db block gets
       1097  consistent gets
          0  physical reads
          0  redo size
    2545867  bytes sent via SQL*Net to client
       8724  bytes received via SQL*Net from client
        757  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
      75593  rows processed
实验2 验证一致性读的原理
多执行几次使得recursive calls 将为0。
SQL> select * from t;

75593 rows selected.


Statistics
----------------------------------------------------------
          0  recursive calls
          0  db block gets
       1097  consistent gets
          0  physical reads
          0  redo size
    2545867  bytes sent via SQL*Net to client
       8724  bytes received via SQL*Net from client
        757  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
      75593  rows processed

SQL> update t set id = 2 where rownum = 1; --另一个session

SQL> /

75593 rows selected.


Statistics
----------------------------------------------------------
          0  recursive calls
          0  db block gets
       1098  consistent gets
          0  physical reads
          0  redo size
    2545867  bytes sent via SQL*Net to client
       8724  bytes received via SQL*Net from client
        757  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
      75593  rows processed
--看到一致性读增加了1。
SQL> rollback;--另一个session
SQL> /

75593 rows selected.


Statistics
----------------------------------------------------------
          0  recursive calls
          0  db block gets
       1097  consistent gets
          0  physical reads
          0  redo size
    2545867  bytes sent via SQL*Net to client
       8724  bytes received via SQL*Net from client
        757  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
      75593  rows processed
--可以看到一致性读又减少了1.

实验3 再次验证consistent gets=num_rows/arraysize + blocks
SQL> set arraysize 1000;
SQL> show arraysize
arraysize 1000
SQL> select * from t;

75593 rows selected.


Statistics
----------------------------------------------------------
          0  recursive calls
          0  db block gets
        418  consistent gets
          0  physical reads
          0  redo size
    2457467  bytes sent via SQL*Net to client
       1244  bytes received via SQL*Net from client
         77  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
      75593  rows processed
SQL> set autotrace off
SQL> select blocks,num_rows,empty_blocks from dba_tables where table_name='T';

    BLOCKS   NUM_ROWS EMPTY_BLOCKS
---------- ---------- ------------
       339      75593            0

SQL> select 75593/1000+339 from dual;

75593/1000+339
--------------
       414.593