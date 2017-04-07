表连接
表连接分为：CROSS JOIN、INNERT JOIN、OUTER JOIN、SELF JOIN。

一、CROSS JOIN 交叉连接
CROSS JOIN连接用于生成两张表的笛卡尔集。
1、返回的记录数为两个表的记录数乘积。比如，A表有n条记录，B表有m条记录，则返回n*m条记录。
2、将A表的所有行分别与B表的所有行进行连接。
SQL> conn scott/oracle
Connected.
SQL> create table emp2 as select * from emp;

Table created.

SQL> create table dept2 as select * from dept;

Table created.

SQL> insert into dept2 values(60,'HR','A City');

1 row created.

SQL> insert into emp2(empno,ename,sal) values(1234,'test',4000);

1 row created.

SQL> commit;

Commit complete.

SQL> set linesize 200
SQL> select * from emp2;

     EMPNO ENAME      JOB              MGR HIREDATE         SAL       COMM     DEPTNO
---------- ---------- --------- ---------- --------- ---------- ---------- ----------
      7369 SMITH      CLERK           7902 17-DEC-80        800                    20
      7499 ALLEN      SALESMAN        7698 20-FEB-81       1600        300         30
      7521 WARD       SALESMAN        7698 22-FEB-81       1250        500         30
      7566 JONES      MANAGER         7839 02-APR-81       2975                    20
      7654 MARTIN     SALESMAN        7698 28-SEP-81       1250       1400         30
      7698 BLAKE      MANAGER         7839 01-MAY-81       2850                    30
      7782 CLARK      MANAGER         7839 09-JUN-81       2450                    10
      7788 SCOTT      ANALYST         7566 19-APR-87       3000                    20
      7839 KING       PRESIDENT            17-NOV-81       5000                    10
      7844 TURNER     SALESMAN        7698 08-SEP-81       1500          0         30
      7876 ADAMS      CLERK           7788 23-MAY-87       1100                    20

     EMPNO ENAME      JOB              MGR HIREDATE         SAL       COMM     DEPTNO
---------- ---------- --------- ---------- --------- ---------- ---------- ----------
      7900 JAMES      CLERK           7698 03-DEC-81        950                    30
      7902 FORD       ANALYST         7566 03-DEC-81       3000                    20
      7934 MILLER     CLERK           7782 23-JAN-82       1300                    10
      1234 test                                            4000

15 rows selected.

SQL> select * from dept2;

    DEPTNO DNAME          LOC
---------- -------------- -------------
        10 ACCOUNTING     NEW YORK
        20 RESEARCH       DALLAS
        30 SALES          CHICAGO
        40 OPERATIONS     BOSTON
        60 HR             A City

SQL> SELECT ename,dname FROM emp2 CROSS JOIN dept2; --cross join,返回 15 * 5行记录

ENAME      DNAME
---------- --------------
SMITH      ACCOUNTING
ALLEN      ACCOUNTING
WARD       ACCOUNTING
JONES      ACCOUNTING
MARTIN     ACCOUNTING
BLAKE      ACCOUNTING
CLARK      ACCOUNTING
SCOTT      ACCOUNTING
KING       ACCOUNTING
TURNER     ACCOUNTING
ADAMS      ACCOUNTING

ENAME      DNAME
---------- --------------
JAMES      ACCOUNTING
FORD       ACCOUNTING
MILLER     ACCOUNTING
test       ACCOUNTING
SMITH      RESEARCH
ALLEN      RESEARCH
WARD       RESEARCH
JONES      RESEARCH
MARTIN     RESEARCH
BLAKE      RESEARCH
CLARK      RESEARCH

ENAME      DNAME
---------- --------------
SCOTT      RESEARCH
KING       RESEARCH
TURNER     RESEARCH
ADAMS      RESEARCH
JAMES      RESEARCH
FORD       RESEARCH
MILLER     RESEARCH
test       RESEARCH
SMITH      SALES
ALLEN      SALES
WARD       SALES

ENAME      DNAME
---------- --------------
JONES      SALES
MARTIN     SALES
BLAKE      SALES
CLARK      SALES
SCOTT      SALES
KING       SALES
TURNER     SALES
ADAMS      SALES
JAMES      SALES
FORD       SALES
MILLER     SALES

ENAME      DNAME
---------- --------------
test       SALES
SMITH      OPERATIONS
ALLEN      OPERATIONS
WARD       OPERATIONS
JONES      OPERATIONS
MARTIN     OPERATIONS
BLAKE      OPERATIONS
CLARK      OPERATIONS
SCOTT      OPERATIONS
KING       OPERATIONS
TURNER     OPERATIONS

ENAME      DNAME
---------- --------------
ADAMS      OPERATIONS
JAMES      OPERATIONS
FORD       OPERATIONS
MILLER     OPERATIONS
test       OPERATIONS
SMITH      HR
ALLEN      HR
WARD       HR
JONES      HR
MARTIN     HR
BLAKE      HR

ENAME      DNAME
---------- --------------
CLARK      HR
SCOTT      HR
KING       HR
TURNER     HR
ADAMS      HR
JAMES      HR
FORD       HR
MILLER     HR
test       HR

75 rows selected.
二、INNER JOIN 内连接
内连接就是关联的两张或多张表中，根据关联条件，显示所有匹配的记录，匹配不上的，不显示。
a inner join b on a.xxx=b.xxx
a join b on a.xxx=b.xxx
a join b using (xxx)
a,b where a.xxx=b.xxx
SQL> SELECT ename,sal,dname FROM emp2 e INNER JOIN dept2 d ON e.deptno=d.deptno;

ENAME             SAL DNAME
---------- ---------- --------------
SMITH             800 RESEARCH
ALLEN            1600 SALES
WARD             1250 SALES
JONES            2975 RESEARCH
MARTIN           1250 SALES
BLAKE            2850 SALES
CLARK            2450 ACCOUNTING
SCOTT            3000 RESEARCH
KING             5000 ACCOUNTING
TURNER           1500 SALES
ADAMS            1100 RESEARCH

ENAME             SAL DNAME
---------- ---------- --------------
JAMES             950 SALES
FORD             3000 RESEARCH
MILLER           1300 ACCOUNTING

14 rows selected.

SQL> SELECT ename,sal,dname FROM emp2 e JOIN dept2 d ON e.deptno=d.deptno; --也可以省略inner关键字，直接写join

ENAME             SAL DNAME
---------- ---------- --------------
SMITH             800 RESEARCH
ALLEN            1600 SALES
WARD             1250 SALES
JONES            2975 RESEARCH
MARTIN           1250 SALES
BLAKE            2850 SALES
CLARK            2450 ACCOUNTING
SCOTT            3000 RESEARCH
KING             5000 ACCOUNTING
TURNER           1500 SALES
ADAMS            1100 RESEARCH

ENAME             SAL DNAME
---------- ---------- --------------
JAMES             950 SALES
FORD             3000 RESEARCH
MILLER           1300 ACCOUNTING

14 rows selected.
SQL> SELECT ename,sal FROM emp2 e JOIN dept2 d USING(deptno); --如果两张表的关联字段名相同，也可以使用USING子句。

ENAME             SAL
---------- ----------
SMITH             800
ALLEN            1600
WARD             1250
JONES            2975
MARTIN           1250
BLAKE            2850
CLARK            2450
SCOTT            3000
KING             5000
TURNER           1500
ADAMS            1100

ENAME             SAL
---------- ----------
JAMES             950
FORD             3000
MILLER           1300

14 rows selected.
SQL> SELECT ename,sal FROM emp2 e,dept2 d WHERE e.deptno=d.deptno; --Oracle的写法

ENAME             SAL
---------- ----------
SMITH             800
ALLEN            1600
WARD             1250
JONES            2975
MARTIN           1250
BLAKE            2850
CLARK            2450
SCOTT            3000
KING             5000
TURNER           1500
ADAMS            1100

ENAME             SAL
---------- ----------
JAMES             950
FORD             3000
MILLER           1300

14 rows selected.
三、OUTER JOIN 外连接
外连接，又分为：
        1.LEFT OUTER JOIN/LEFT JOIN（左外连接）
        2.RIGHT OUTER JOIN/RIGHT JOIN（右外连接）
        3.FULL OUTER JOIN/FULL JOIN(全外连接)

1.LEFT OUTER JOIN/LEFT JOIN（左外连接）
        左外连接就是关联的两张或多张表中，根据关联条件，显示匹配的记录，左表中有的记录，但是右表中没有匹配上的，以空(null)显示。
        LEFT OUTER JOIN也可以简写成LEFT JOIN，效果是一样的。
       左外连接有SQL标准写法，也有oracle特有的写法。
a left outer join b on a.xxx=b.xxx
a left join b on a.xxx=b.xxx
a left join b using(xxx)
a,b where a.xxx=b.xxx(+)
SQL> SELECT ename,sal,dname FROM emp2 e LEFT OUTER JOIN dept2 d ON e.deptno=d.deptno;

ENAME             SAL DNAME
---------- ---------- --------------
MILLER           1300 ACCOUNTING
KING             5000 ACCOUNTING
CLARK            2450 ACCOUNTING
FORD             3000 RESEARCH
ADAMS            1100 RESEARCH
SCOTT            3000 RESEARCH
JONES            2975 RESEARCH
SMITH             800 RESEARCH
JAMES             950 SALES
TURNER           1500 SALES
BLAKE            2850 SALES

ENAME             SAL DNAME
---------- ---------- --------------
MARTIN           1250 SALES
WARD             1250 SALES
ALLEN            1600 SALES
test             4000

15 rows selected.
SQL> SELECT ename,sal,dname FROM emp2 e LEFT JOIN dept2 d ON e.deptno=d.deptno; --也可以去掉OUTER关键字，写成LEFT JOIN

ENAME             SAL DNAME
---------- ---------- --------------
MILLER           1300 ACCOUNTING
KING             5000 ACCOUNTING
CLARK            2450 ACCOUNTING
FORD             3000 RESEARCH
ADAMS            1100 RESEARCH
SCOTT            3000 RESEARCH
JONES            2975 RESEARCH
SMITH             800 RESEARCH
JAMES             950 SALES
TURNER           1500 SALES
BLAKE            2850 SALES

ENAME             SAL DNAME
---------- ---------- --------------
MARTIN           1250 SALES
WARD             1250 SALES
ALLEN            1600 SALES
test             4000

15 rows selected.
SQL> SELECT ename,sal FROM emp2 e LEFT JOIN dept2 d USING(deptno); --如果两张表的关联字段名相同，也可以使用USING子句

ENAME             SAL
---------- ----------
MILLER           1300
KING             5000
CLARK            2450
FORD             3000
ADAMS            1100
SCOTT            3000
JONES            2975
SMITH             800
JAMES             950
TURNER           1500
BLAKE            2850

ENAME             SAL
---------- ----------
MARTIN           1250
WARD             1250
ALLEN            1600
test             4000

15 rows selected.
SQL> SELECT ename,sal,dname FROM emp2 e,dept2 d  WHERE e.deptno=d.deptno(+); --oracle的写法

ENAME             SAL DNAME
---------- ---------- --------------
MILLER           1300 ACCOUNTING
KING             5000 ACCOUNTING
CLARK            2450 ACCOUNTING
FORD             3000 RESEARCH
ADAMS            1100 RESEARCH
SCOTT            3000 RESEARCH
JONES            2975 RESEARCH
SMITH             800 RESEARCH
JAMES             950 SALES
TURNER           1500 SALES
BLAKE            2850 SALES

ENAME             SAL DNAME
---------- ---------- --------------
MARTIN           1250 SALES
WARD             1250 SALES
ALLEN            1600 SALES
test             4000

15 rows selected.

2.RIGHT OUTER JOIN/RIGHT JOIN（右外连接）
        右外连接就是关联的两张或多张表中，根据关联条件，显示匹配的记录。右表中有的记录，但是左表中没有匹配上的，以空(null)显示。
        RIGHT OUTER JOIN也可以简写成RIGHT JOIN，效果是一样的。
       右外连接有SQL标准写法，也有oracle特有的写法。
SQL> SELECT ename,sal,dname FROM emp2 e RIGHT OUTER JOIN dept2 d ON e.deptno=d.deptno;

ENAME             SAL DNAME
---------- ---------- --------------
SMITH             800 RESEARCH
ALLEN            1600 SALES
WARD             1250 SALES
JONES            2975 RESEARCH
MARTIN           1250 SALES
BLAKE            2850 SALES
CLARK            2450 ACCOUNTING
SCOTT            3000 RESEARCH
KING             5000 ACCOUNTING
TURNER           1500 SALES
ADAMS            1100 RESEARCH

ENAME             SAL DNAME
---------- ---------- --------------
JAMES             950 SALES
FORD             3000 RESEARCH
MILLER           1300 ACCOUNTING
                      OPERATIONS
                      HR

16 rows selected.

--去掉OUTER关键字
SQL> SELECT ename,sal,dname FROM emp2 e RIGHT JOIN dept2 d ON e.deptno=d.deptno;

ENAME             SAL DNAME
---------- ---------- --------------
SMITH             800 RESEARCH
ALLEN            1600 SALES
WARD             1250 SALES
JONES            2975 RESEARCH
MARTIN           1250 SALES
BLAKE            2850 SALES
CLARK            2450 ACCOUNTING
SCOTT            3000 RESEARCH
KING             5000 ACCOUNTING
TURNER           1500 SALES
ADAMS            1100 RESEARCH

ENAME             SAL DNAME
---------- ---------- --------------
JAMES             950 SALES
FORD             3000 RESEARCH
MILLER           1300 ACCOUNTING
                      OPERATIONS
                      HR

16 rows selected.

--如果两张表的关联字段名相同，也可以使用USING子句
SQL> SELECT ename,sal,dname FROM emp2 e RIGHT JOIN dept2 d using(deptno);

ENAME             SAL DNAME
---------- ---------- --------------
SMITH             800 RESEARCH
ALLEN            1600 SALES
WARD             1250 SALES
JONES            2975 RESEARCH
MARTIN           1250 SALES
BLAKE            2850 SALES
CLARK            2450 ACCOUNTING
SCOTT            3000 RESEARCH
KING             5000 ACCOUNTING
TURNER           1500 SALES
ADAMS            1100 RESEARCH

ENAME             SAL DNAME
---------- ---------- --------------
JAMES             950 SALES
FORD             3000 RESEARCH
MILLER           1300 ACCOUNTING
                      OPERATIONS
                      HR

16 rows selected.

--oracle的写法
SQL> SELECT ename,sal,dname FROM emp2 e , dept2 d where e.deptno(+)=d.deptno;

ENAME             SAL DNAME
---------- ---------- --------------
SMITH             800 RESEARCH
ALLEN            1600 SALES
WARD             1250 SALES
JONES            2975 RESEARCH
MARTIN           1250 SALES
BLAKE            2850 SALES
CLARK            2450 ACCOUNTING
SCOTT            3000 RESEARCH
KING             5000 ACCOUNTING
TURNER           1500 SALES
ADAMS            1100 RESEARCH

ENAME             SAL DNAME
---------- ---------- --------------
JAMES             950 SALES
FORD             3000 RESEARCH
MILLER           1300 ACCOUNTING
                      OPERATIONS
                      HR

16 rows selected.

3.FULL OUTER JOIN/FULL JOIN（全外连接）
        全外连接就是关联的两张或多张表中，根据关联条件，显示所有匹配和不匹配的记录。
        左表中有的记录，但是右表中没有匹配上的，以空(null)显示。右表中有的记录，但是左表中没有匹配上的，也以空(null)显示。
        FULL OUTER JOIN也可以简写成FULL JOIN，效果是一样的。

        全外连接只有SQL标准写法，没有oracle特有的写法。
SQL> SELECT ename,sal,dname FROM emp2 e FULL OUTER JOIN dept2 d ON e.deptno=d.deptno;

ENAME             SAL DNAME
---------- ---------- --------------
SMITH             800 RESEARCH
ALLEN            1600 SALES
WARD             1250 SALES
JONES            2975 RESEARCH
MARTIN           1250 SALES
BLAKE            2850 SALES
CLARK            2450 ACCOUNTING
SCOTT            3000 RESEARCH
KING             5000 ACCOUNTING
TURNER           1500 SALES
ADAMS            1100 RESEARCH

ENAME             SAL DNAME
---------- ---------- --------------
JAMES             950 SALES
FORD             3000 RESEARCH
MILLER           1300 ACCOUNTING
test             4000
                      OPERATIONS
                      HR

17 rows selected.

SQL> SELECT ename,sal,dname FROM emp2 e FULL JOIN dept2 d ON e.deptno=d.deptno;

ENAME             SAL DNAME
---------- ---------- --------------
SMITH             800 RESEARCH
ALLEN            1600 SALES
WARD             1250 SALES
JONES            2975 RESEARCH
MARTIN           1250 SALES
BLAKE            2850 SALES
CLARK            2450 ACCOUNTING
SCOTT            3000 RESEARCH
KING             5000 ACCOUNTING
TURNER           1500 SALES
ADAMS            1100 RESEARCH

ENAME             SAL DNAME
---------- ---------- --------------
JAMES             950 SALES
FORD             3000 RESEARCH
MILLER           1300 ACCOUNTING
test             4000
                      OPERATIONS
                      HR

17 rows selected.

--如果两张表的关联字段名相同，也可以使用USING子句
SQL> SELECT ename,sal,dname FROM emp2 e FULL JOIN dept2 d USING(deptno);

ENAME             SAL DNAME
---------- ---------- --------------
SMITH             800 RESEARCH
ALLEN            1600 SALES
WARD             1250 SALES
JONES            2975 RESEARCH
MARTIN           1250 SALES
BLAKE            2850 SALES
CLARK            2450 ACCOUNTING
SCOTT            3000 RESEARCH
KING             5000 ACCOUNTING
TURNER           1500 SALES
ADAMS            1100 RESEARCH

ENAME             SAL DNAME
---------- ---------- --------------
JAMES             950 SALES
FORD             3000 RESEARCH
MILLER           1300 ACCOUNTING
test             4000
                      OPERATIONS
                      HR

17 rows selected.
四、SELF JOIN 自连接
在上面的emp2表中,每一个员工都有自己的mgr(经理)，并且每一个经理自身也是公司的员工，自身也有自己的经理。现在需要将每一个员工自己的名字和经理的名字都找出来，应该怎么显示呢？
如果我们有两张这样的表分别教worker和mgr，那么我们就很好写SQL语句。
SELECT worker.name,Mgr.name
FROM worker,mgr
WHERE worker.id = mgr.id;

但现在我们只有一张表。你也许说我们现在在建一张表，把同样的数据拷贝过去不就可以了吗？是的，这样可以，但我们不会采用，因为这样就会很麻烦，而且数据严重冗余等等很多弊端。
这里有更好的方法，那就是自连接。
自连接，就是把一张表取两个别名，当做两张表来使用,自己和自己关联。

SQL> SELECT e.ename,e.sal,e2.ename manager_name 
   FROM emp2 e inner join emp2 e2
  3    ON e.empno=e2.mgr;

ENAME             SAL MANAGER_NA
---------- ---------- ----------
FORD             3000 SMITH
BLAKE            2850 ALLEN
BLAKE            2850 WARD
KING             5000 JONES
BLAKE            2850 MARTIN
KING             5000 BLAKE
KING             5000 CLARK
JONES            2975 SCOTT
BLAKE            2850 TURNER
SCOTT            3000 ADAMS
BLAKE            2850 JAMES

ENAME             SAL MANAGER_NA
---------- ---------- ----------
JONES            2975 FORD
CLARK            2450 MILLER

13 rows selected.
SQL> SELECT e.ename,e.sal,e2.ename manager_name    FROM emp2 e join emp2 e2  ON e.empno=e2.mgr;

ENAME             SAL MANAGER_NA
---------- ---------- ----------
FORD             3000 SMITH
BLAKE            2850 ALLEN
BLAKE            2850 WARD
KING             5000 JONES
BLAKE            2850 MARTIN
KING             5000 BLAKE
KING             5000 CLARK
JONES            2975 SCOTT
BLAKE            2850 TURNER
SCOTT            3000 ADAMS
BLAKE            2850 JAMES

ENAME             SAL MANAGER_NA
---------- ---------- ----------
JONES            2975 FORD
CLARK            2450 MILLER

13 rows selected.
五、总结
表连接分为：
1.CROSS JOIN：显示迪卡尔积。
2.INNERT JOIN:显示所有匹配的项。
3.OUTER JOIN
   外连接又分为:
     1) LEFT OUTER JOIN/LEFT JOIN：显示左表的所有项，右表没有匹配的项，则以null显示。
     2) RIGHT OUTER JOIN/RIGHT JOIN：显示右表的所有项，左表没有匹配的项，则以null显示。
     3) FULL OUTER JOIN/FULL JOIN：显示所有匹配和不匹配的项，左右两张表没有匹配的，都以null显示。
4.SELF JOIN:把一张表取两个别名，当做两张表来使用，自己和自己关联。
