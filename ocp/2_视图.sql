通过子查询建立视图
子查询可以包含复杂的select语法
子查询不能使用order by

创建复杂视图
CREATE [OR REPLACE] [FORCE|NOFORCE] VIEW view
[(alias[, alias]...)]
AS subquery
[WITH CHECK OPTION [CONSTRAINT constraint]]
[WITH READ ONLY [CONSTRAINT constraint]];

查看视图结构
Desc view_name;

--要拥有创建视图的权限
SQL> grant create view to scott;

Grant succeeded.

SQL> conn scott/oracle
Connected.
SQL> CREATE VIEW EMP_V10
AS SELECT EMPNO,ENAME,SAL,COMM,hIREDATE,DEPTNO
      FROM EMP
  4        WHERE DEPTNO=10 order by DEPTNO;

View created.

SQL> select * from emp_v10;

     EMPNO ENAME             SAL       COMM HIREDATE      DEPTNO
---------- ---------- ---------- ---------- --------- ----------
      7782 CLARK            2450            09-JUN-81         10
      7839 KING             5000            17-NOV-81         10
      7934 MILLER           1300            23-JAN-82         10
--修改视图
SQL> CREATE or replace VIEW EMP_V10
  2  AS SELECT EMPNO,ENAME,SAL,COMM,hIREDATE,DEPTNO
  3        FROM EMP
  4        WHERE DEPTNO in (10,20) order by DEPTNO;

View created.

SQL> select * from emp_v10;

     EMPNO ENAME             SAL       COMM HIREDATE      DEPTNO
---------- ---------- ---------- ---------- --------- ----------
      7934 MILLER           1300            23-JAN-82         10
      7782 CLARK            2450            09-JUN-81         10
      7839 KING             5000            17-NOV-81         10
      7902 FORD             3000            03-DEC-81         20
      7876 ADAMS            1100            23-MAY-87         20
      7566 JONES            2975            02-APR-81         20
      7369 SMITH             800            17-DEC-80         20
      7788 SCOTT            3000            19-APR-87         20

8 rows selected.