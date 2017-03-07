表之间的连接
	可以将连接分为等值连接（如WHERE A.COL3 = B.COL4）
	非等值连接（WHERE A.COL3 > B.COL4）
	外连接（WHEREA.COL3 = B.COL4（+））
典型的连接类型分３种
	合并连接Sort merge join SMJ
	嵌套循环Nested loops
	哈希连接Hash join
	笛卡尔连接Cartesian Product(一般情况下，尽量避免使用)
	
--1. 合并连接Sort merge join SMJ
--SQL> explain plan for select /*+ ordered +*/ e.deptno,d.deptno from scott.emp e,scott.dept d where e.deptno=d.deptno order by e.deptno,d.deptno;
--SQL> select * from table(dbms_xplan.display);
SQL> explain plan for select e.ename,d.dname from scott.emp e,scott.dept d where e.deptno=d.deptno;
SQL> select * from table(dbms_xplan.display);
Plan hash value: 844388907

----------------------------------------------------------------------------------------
| Id  | Operation                    | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |         |    14 |   308 |     6  (17)| 00:00:01 |
|   1 |  MERGE JOIN                  |         |    14 |   308 |     6  (17)| 00:00:01 |
|   2 |   TABLE ACCESS BY INDEX ROWID| DEPT    |     4 |    52 |     2   (0)| 00:00:01 |
|   3 |    INDEX FULL SCAN           | PK_DEPT |     4 |       |     1   (0)| 00:00:01 |
|*  4 |   SORT JOIN                  |         |    14 |   126 |     4  (25)| 00:00:01 |
|   5 |    TABLE ACCESS FULL         | EMP     |    14 |   126 |     3   (0)| 00:00:01 |


--2．嵌套循环（Nested Loops， NL）
从内部连接过程来看，需要用row source1中的每一行，去匹配row source2中的所有行，所以此时保持row source1尽可能的小与高效的访问row source2（一般通过索引实现）
是影响这个连接效率的关键问题。这只是理论指导原则，目的是使整个连接操作产生最少的物理I/O 次数，而且如果遵守这个原则，一般也会使总的物理I/O 数最少。
但是如果不遵从这个指导原则，反而能用更少的物理I/O 实现连接操作，那尽管违反指导原则吧！因为最少的物理I/O 次数才是我们应该遵从的真正的指导原则
内部连接过程：
Row source1的Row 1 —— Probe ->Row source 2
Row source1的Row 2 —— Probe ->Row source 2
Row source1的Row 3 —— Probe ->Row source 2
……
Row source1的Row n —— Probe ->Row source 2
Row source1为驱动表或外部表。Row Source2被称为被探查表或内部表。

--3．哈希连接（Hash Join， HJ）
explain plan for select /*+ use_hash（emp） */ empno from scott.emp,scott.dept where emp.deptno = dept.deptno;
--4．笛卡尔连接Cartesian Product
SQL> explain plan for select empno from scott.emp,scott.dept;
SQL> select * from table(dbms_xplan.display);


排序 - - 

合并连接（Sort Merge Join， SMJ）：
a） 对于非等值连接，这种连接方式的效率是比较高的。
b） 如果在关联的列上都有索引，效果更好。
c） 对于将2个较大的row source 做连接，该连接方法比NL 连接要好一些。
d） 但是如果sort merge 返回的row source 过大，则又会导致使用过多的rowid 在表中查询数据时，数据库性能下降，因为过多的I/O.

嵌套循环（Nested Loops， NL）：
a） 如果driving row source（外部表）比较小，并且在inner row source（内部表）上有唯一索引，或有高选择性非唯一索引时，使用这种方法可以得到较好的效率。
b） NESTED LOOPS 有其它连接方法没有的的一个优点是：可以先返回已经连接的行，而不必等待所有的连接操作处理完才返回数据，这可以实现快速的响应时间。

哈希连接（Hash Join， HJ）：
a） 这种方法是在oracle7后来引入的，使用了比较先进的连接理论，一般来说，其效率应该好于其它2种连接，但是这种连接只能用在CBO 优化器中，而且需要设置合适的hash_area_size 参数，才能取得较好的性能。
b） 在2个较大的row source 之间连接时会取得相对较好的效率，在一个row source较小时则能取得更好的效率。
c） 只能用于等值连接中