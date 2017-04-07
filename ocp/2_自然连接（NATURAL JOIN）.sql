自然连接（NATURAL JOIN）是一种特殊的等值连接，将表中具有相同名称的列自动进行匹配。

1.自然连接不必指定任何连接条件。
SQL> conn scott/oracle
Connected.
SQL> desc emp
 Name                                      Null?    Type
 ----------------------------------------- -------- ----------------------------
 EMPNO                                     NOT NULL NUMBER(4)
 ENAME                                              VARCHAR2(10)
 JOB                                                VARCHAR2(9)
 MGR                                                NUMBER(4)
 HIREDATE                                           DATE
 SAL                                                NUMBER(7,2)
 COMM                                               NUMBER(7,2)
 DEPTNO                                             NUMBER(2)

SQL> desc dept
 Name                                      Null?    Type
 ----------------------------------------- -------- ----------------------------
 DEPTNO                                    NOT NULL NUMBER(2)
 DNAME                                              VARCHAR2(14)
 LOC                                                VARCHAR2(13)
 SQL> set linesize 200
--以上两张表中，有deptno这列名字相同，而且数据类型一致。
--自然连接之后，两张表等值连接，DEPTNO这列自动合并成一列。
SQL> select * from emp natural join dept;

    DEPTNO      EMPNO ENAME      JOB              MGR HIREDATE         SAL       COMM DNAME          LOC
---------- ---------- ---------- --------- ---------- --------- ---------- ---------- -------------- -------------
        10       7782 CLARK      MANAGER         7839 09-JUN-81       2450            ACCOUNTING     NEW YORK
        10       7839 KING       PRESIDENT            17-NOV-81       5000            ACCOUNTING     NEW YORK
        10       7934 MILLER     CLERK           7782 23-JAN-82       1300            ACCOUNTING     NEW YORK
        20       7566 JONES      MANAGER         7839 02-APR-81       2975            RESEARCH       DALLAS
        20       7902 FORD       ANALYST         7566 03-DEC-81       3000            RESEARCH       DALLAS
        20       7876 ADAMS      CLERK           7788 23-MAY-87       1100            RESEARCH       DALLAS
        20       7369 SMITH      CLERK           7902 17-DEC-80        800            RESEARCH       DALLAS
        20       7788 SCOTT      ANALYST         7566 19-APR-87       3000            RESEARCH       DALLAS
        30       7521 WARD       SALESMAN        7698 22-FEB-81       1250        500 SALES          CHICAGO
        30       7844 TURNER     SALESMAN        7698 08-SEP-81       1500          0 SALES          CHICAGO
        30       7499 ALLEN      SALESMAN        7698 20-FEB-81       1600        300 SALES          CHICAGO

    DEPTNO      EMPNO ENAME      JOB              MGR HIREDATE         SAL       COMM DNAME          LOC
---------- ---------- ---------- --------- ---------- --------- ---------- ---------- -------------- -------------
        30       7900 JAMES      CLERK           7698 03-DEC-81        950            SALES          CHICAGO
        30       7698 BLAKE      MANAGER         7839 01-MAY-81       2850            SALES          CHICAGO
        30       7654 MARTIN     SALESMAN        7698 28-SEP-81       1250       1400 SALES          CHICAGO

14 rows selected.


2.如果两张表中有相同名字的列，但是数据类型不一致，如果能隐式转换，则能正常连接，但如果隐式转换不成功，则报错。
SQL> create table dept2 as select * from dept;
SQL> create table emp2 as select * from emp;
SQL> alter table dept2 modify deptno number(10);
上例中，emp2和dept2两张表，有一个同名的列deptno,dept2中，deptno列是number(10),emp2列中，deptno列是number(2),虽然长度不一致，但是也能正常匹配。
SQL> select * from emp2 natural join dept2;

    DEPTNO      EMPNO ENAME      JOB              MGR HIREDATE         SAL       COMM DNAME          LOC
---------- ---------- ---------- --------- ---------- --------- ---------- ---------- -------------- -------------
        20       7369 SMITH      CLERK           7902 17-DEC-80        800            RESEARCH       DALLAS
        30       7499 ALLEN      SALESMAN        7698 20-FEB-81       1600        300 SALES          CHICAGO
        30       7521 WARD       SALESMAN        7698 22-FEB-81       1250        500 SALES          CHICAGO
        20       7566 JONES      MANAGER         7839 02-APR-81       2975            RESEARCH       DALLAS
        30       7654 MARTIN     SALESMAN        7698 28-SEP-81       1250       1400 SALES          CHICAGO
        30       7698 BLAKE      MANAGER         7839 01-MAY-81       2850            SALES          CHICAGO
        10       7782 CLARK      MANAGER         7839 09-JUN-81       2450            ACCOUNTING     NEW YORK
        20       7788 SCOTT      ANALYST         7566 19-APR-87       3000            RESEARCH       DALLAS
        10       7839 KING       PRESIDENT            17-NOV-81       5000            ACCOUNTING     NEW YORK
        30       7844 TURNER     SALESMAN        7698 08-SEP-81       1500          0 SALES          CHICAGO
        20       7876 ADAMS      CLERK           7788 23-MAY-87       1100            RESEARCH       DALLAS

    DEPTNO      EMPNO ENAME      JOB              MGR HIREDATE         SAL       COMM DNAME          LOC
---------- ---------- ---------- --------- ---------- --------- ---------- ---------- -------------- -------------
        30       7900 JAMES      CLERK           7698 03-DEC-81        950            SALES          CHICAGO
        20       7902 FORD       ANALYST         7566 03-DEC-81       3000            RESEARCH       DALLAS
        10       7934 MILLER     CLERK           7782 23-JAN-82       1300            ACCOUNTING     NEW YORK

14 rows selected.

SQL> truncate table dept2;
SQL> alter table dept2 modify deptno varchar2(10);
SQL> insert into dept2(deptno,dname,loc) select deptno,dname,loc from dept;

4 rows created.

SQL> select * from emp2 natural join dept2;

DEPTNO          EMPNO ENAME      JOB              MGR HIREDATE         SAL       COMM DNAME          LOC
---------- ---------- ---------- --------- ---------- --------- ---------- ---------- -------------- -------------
20               7369 SMITH      CLERK           7902 17-DEC-80        800            RESEARCH       DALLAS
30               7499 ALLEN      SALESMAN        7698 20-FEB-81       1600        300 SALES          CHICAGO
30               7521 WARD       SALESMAN        7698 22-FEB-81       1250        500 SALES          CHICAGO
20               7566 JONES      MANAGER         7839 02-APR-81       2975            RESEARCH       DALLAS
30               7654 MARTIN     SALESMAN        7698 28-SEP-81       1250       1400 SALES          CHICAGO
30               7698 BLAKE      MANAGER         7839 01-MAY-81       2850            SALES          CHICAGO
10               7782 CLARK      MANAGER         7839 09-JUN-81       2450            ACCOUNTING     NEW YORK
20               7788 SCOTT      ANALYST         7566 19-APR-87       3000            RESEARCH       DALLAS
10               7839 KING       PRESIDENT            17-NOV-81       5000            ACCOUNTING     NEW YORK
30               7844 TURNER     SALESMAN        7698 08-SEP-81       1500          0 SALES          CHICAGO
20               7876 ADAMS      CLERK           7788 23-MAY-87       1100            RESEARCH       DALLAS

DEPTNO          EMPNO ENAME      JOB              MGR HIREDATE         SAL       COMM DNAME          LOC
---------- ---------- ---------- --------- ---------- --------- ---------- ---------- -------------- -------------
30               7900 JAMES      CLERK           7698 03-DEC-81        950            SALES          CHICAGO
20               7902 FORD       ANALYST         7566 03-DEC-81       3000            RESEARCH       DALLAS
10               7934 MILLER     CLERK           7782 23-JAN-82       1300            ACCOUNTING     NEW YORK

14 rows selected.
--上例中，emp2和dept2列中同名的列deptno，在dept2列是，是varchar2(10)类型，在dept2列是，是number(2),但是，列中的数据，在匹配时能自动隐式转换，所以也能正常匹配。
SQL> insert into dept2 values('abc','internat','shenzhen');
SQL> select * from emp2 natural join dept2;
select * from emp2 natural join dept2
*
ERROR at line 1:
ORA-01722: invalid number
--上例中，在emp2的deptno列中，插入了一个字符'abc'，这个就不能再隐式转换成数字了，所以报错。


3.使用自然连接时，不能使用表名或表的别名修饰列。
SQL> select dname,deptno,dname from emp natural join dept;

DNAME              DEPTNO DNAME
-------------- ---------- --------------
ACCOUNTING             10 ACCOUNTING
ACCOUNTING             10 ACCOUNTING
ACCOUNTING             10 ACCOUNTING
RESEARCH               20 RESEARCH
RESEARCH               20 RESEARCH
RESEARCH               20 RESEARCH
RESEARCH               20 RESEARCH
RESEARCH               20 RESEARCH
SALES                  30 SALES
SALES                  30 SALES
SALES                  30 SALES

DNAME              DEPTNO DNAME
-------------- ---------- --------------
SALES                  30 SALES
SALES                  30 SALES
SALES                  30 SALES

14 rows selected.
SQL> select emp.dname,emp.deptno,dept.dname from emp natural join dept;
select emp.dname,emp.deptno,dept.dname from emp natural join dept
                 *
ERROR at line 1:
ORA-25155: column used in NATURAL join cannot have qualifier


4.自然连接会两张表中相同名称的所有列。
SQL> select * from employees natural join  departments;
两张表，有两列列名相同，DEPARTMENT_ID和MANAGER_ID 列，并且数据类型一致。自然连接也可以指定显示列。
SQL> select FIRST_NAME,DEPARTMENT_ID,DEPARTMENT_NAME from employees natural join  departments;

FIRST_NAME           DEPARTMENT_ID DEPARTMENT_NAME
-------------------- ------------- ------------------------------
Pat                             20 Marketing
William                        110 Accounting
Neena                           90 Executive
Lex                             90 Executive
Bruce                           60 IT
David                           60 IT
Valli                           60 IT
Diana                           60 IT
Daniel                         100 Finance
John                           100 Finance
Ismael                         100 Finance

FIRST_NAME           DEPARTMENT_ID DEPARTMENT_NAME
-------------------- ------------- ------------------------------
Jose Manuel                    100 Finance
Luis                           100 Finance
Alexander                       30 Purchasing
Shelli                          30 Purchasing
Sigal                           30 Purchasing
Guy                             30 Purchasing
Karen                           30 Purchasing
Laura                           50 Shipping
Mozhe                           50 Shipping
James                           50 Shipping
TJ                              50 Shipping

FIRST_NAME           DEPARTMENT_ID DEPARTMENT_NAME
-------------------- ------------- ------------------------------
Peter                           80 Sales
David                           80 Sales
Peter                           80 Sales
Christopher                     80 Sales
Nanette                         80 Sales
Oliver                          80 Sales
Nandita                         50 Shipping
Alexis                          50 Shipping
Julia                           50 Shipping
Anthony                         50 Shipping

32 rows selected.
--两张表，有两列列名相同，DEPARTMENT_ID和MANAGER_ID 列，并且数据类型一致。

-- 和下面这个用内连接效果结果是一样的。
SQL> select e.EMPLOYEE_ID,e.FIRST_NAME,d.DEPARTMENT_ID,d.DEPARTMENT_NAME
  2  from employees e,departments d
  3  where e.department_id=d.department_id and e.MANAGER_ID=d.MANAGER_ID;

EMPLOYEE_ID FIRST_NAME           DEPARTMENT_ID DEPARTMENT_NAME
----------- -------------------- ------------- ------------------------------
        202 Pat                             20 Marketing
        206 William                        110 Accounting
        101 Neena                           90 Executive
        102 Lex                             90 Executive
        104 Bruce                           60 IT
        105 David                           60 IT
        106 Valli                           60 IT
        107 Diana                           60 IT
        109 Daniel                         100 Finance
        110 John                           100 Finance
        111 Ismael                         100 Finance

EMPLOYEE_ID FIRST_NAME           DEPARTMENT_ID DEPARTMENT_NAME
----------- -------------------- ------------- ------------------------------
        112 Jose Manuel                    100 Finance
        113 Luis                           100 Finance
        115 Alexander                       30 Purchasing
        116 Shelli                          30 Purchasing
        117 Sigal                           30 Purchasing
        118 Guy                             30 Purchasing
        119 Karen                           30 Purchasing
        129 Laura                           50 Shipping
        130 Mozhe                           50 Shipping
        131 James                           50 Shipping
        132 TJ                              50 Shipping

EMPLOYEE_ID FIRST_NAME           DEPARTMENT_ID DEPARTMENT_NAME
----------- -------------------- ------------- ------------------------------
        150 Peter                           80 Sales
        151 David                           80 Sales
        152 Peter                           80 Sales
        153 Christopher                     80 Sales
        154 Nanette                         80 Sales
        155 Oliver                          80 Sales
        184 Nandita                         50 Shipping
        185 Alexis                          50 Shipping
        186 Julia                           50 Shipping
        187 Anthony                         50 Shipping

32 rows selected.
总结：
      自然连接，自动匹配同名的列，虽然很方便，不用指定匹配的列。
      但也有缺点，虽然可以指定查询结果包括哪些列，但不能人为地指定哪些列被匹配,而内连接就可以自由指定。
      比如上例，用自然连接，就只能DEPARTMENT_ID和MANAGER_ID列都匹配，但用内连接，可以随意指定一个匹配，也可以指定两个都匹配，更加灵活。