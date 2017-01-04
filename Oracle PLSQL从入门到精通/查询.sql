/*
查询表数据
指定条件查询
  简单where子句
  日期与字符串比较
  使用范围操作符
  判断null值
  使用逻辑组合
  优先规则
排序
使用函数
  单行函数
  多行函数
    sum,avg,min,max,count,count(*)
统计函数
分组统计
dual表
distinct关键字
rownum伪列
rowid伪列
*/
--指定列查询
SELECT view_name, text
  FROM user_views;

SELECT ename, empno, job, hiredate
  FROM scott.emp;
--使用表达式查询
SELECT empno, ename, sal * (1 + 0.12)
  FROM emp;
SELECT empno, ename, sal * (1 + 0.12) raised_sal
  FROM emp;
SELECT empno 员工名称, ename "员工姓名_NAME", job 职级, sal AS 薪水
  FROM emp;
/*使用连结符查询*/
SELECT ename || '的薪资为：' || sal 员工薪水
  FROM emp;
/*所有列查询*/  
SELECT *
  FROM emp
 WHERE deptno = 20;

SELECT *
  FROM emp;
/*范围查询*/
SELECT empno, ename, job, mgr, hiredate, sal
  FROM emp
 WHERE sal BETWEEN 1500 AND 2500;


SELECT empno, ename, job, mgr, hiredate, sal
  FROM emp
 WHERE sal >= 1500 AND sal <= 2500;


SELECT empno, ename, job, mgr, hiredate, sal
  FROM emp
 WHERE hiredate BETWEEN TO_DATE ('1981-01-01', 'YYYY-MM-DD')
                    AND TO_DATE ('1981-12-31', 'YYYY-MM-DD');


SELECT empno, ename, job, mgr, hiredate, sal
  FROM emp
 WHERE job IN ('SALESMAN', 'CLERK', 'ANALYST');


SELECT empno, ename, job, mgr, hiredate, sal
  FROM emp
 WHERE mgr IN (7698, 7839);


SELECT empno, ename, job, mgr, hiredate, sal
  FROM emp
 WHERE mgr = 7698 OR mgr = 7839;


SELECT empno, ename, job, mgr, hiredate, sal
  FROM emp
 WHERE ename LIKE 'J%';


SELECT empno, ename, job, mgr, hiredate, sal
  FROM emp
 WHERE hiredate LIKE '%81';

SELECT empno, ename, job, mgr, hiredate, sal
  FROM emp
 WHERE ename LIKE '__A%';
/*空值、非空查询*/
SELECT empno, ename, job, mgr, hiredate
  FROM emp
 WHERE mgr IS NULL;

SELECT empno, ename, job, mgr, hiredate
  FROM emp
 WHERE mgr IS NOT NULL;
/*特定条件查询*/
--查询部门编号20并且员工入职日期为1982年的员工列表。
SELECT empno, ename, job, mgr, hiredate, sal, deptno
  FROM emp
 WHERE deptno = 20 AND hiredate LIKE '%82';

 --查询部门编号20或员工入职日期为1982年的员工列表。  
SELECT empno, ename, job, mgr, hiredate, sal, deptno
  FROM emp
 WHERE deptno = 20 OR hiredate LIKE '%82';


SELECT empno, ename, job, mgr, hiredate, sal, deptno
  FROM emp
 WHERE NOT (deptno = 20 AND hiredate LIKE '%82');


SELECT *
  FROM emp;

SELECT empno, ename, job, mgr, hiredate, sal, deptno
  FROM emp
 WHERE job NOT IN ('CLERK', 'MANAGER', 'SALESMAN');

SELECT empno, ename, job, mgr, hiredate, sal, deptno
  FROM emp
 WHERE sal NOT BETWEEN 1000 AND 2500;

SELECT empno, ename, job, mgr, hiredate, sal, deptno
  FROM emp
 WHERE ename NOT LIKE '%A%';
/*查询的顺序*/
SELECT   empno, ename, job, mgr, hiredate, sal, deptno
    FROM emp
   WHERE deptno = 20
ORDER BY empno;


SELECT   empno, ename, job, mgr, hiredate, sal, deptno
    FROM emp
   WHERE deptno = 20
ORDER BY empno, ename DESC;


SELECT   empno, ename, job, mgr, hiredate, sal, deptno
    FROM emp
   WHERE deptno = 20
ORDER BY 4 DESC;

SELECT   empno, ename, job, mgr, hiredate, sal, deptno
    FROM emp
   WHERE deptno = 20
ORDER BY 6 DESC; 
/*使用函数查询*/
--在emp表中，查询出来的ename都为大写字符，为了具有更友好的显示方式，可以使用Oracle提供的INITCAP函数转换显示方式为首字母大小，如下语句所示：
SELECT empno, INITCAP (ename) ename, hiredate
  FROM emp
 WHERE deptno = 20;


SELECT CONCAT (empno, INITCAP (ename)) ename, hiredate,comm
  FROM emp
 WHERE deptno = 20;
 
 
SELECT empno, ename, hiredate,ROUND(comm) comm
  FROM emp
 WHERE deptno = 20;
/*计数*/
SELECT COUNT (*) 记录条数 FROM emp;
SELECT COUNT (*) 记录条数 FROM emp WHERE deptno=20;
SELECT * FROM emp;
SELECT * FROM dept;
SELECT COUNT(comm) 提成员工数 FROM emp;
SELECT COUNT(ALL comm) 提成员工数 FROM emp;
SELECT * from emp;
SELECT COUNT(DISTINCT job) 职位个数 FROM emp; 
/*统计函数*/
SELECT AVG(sal) 平均薪资,AVG(comm) 平均提成 FROM emp;
SELECT MIN(sal) 最低薪资,MAX(sal) 最高薪资 FROM emp;
SELECT MIN(hiredate) 最早雇佣日期,MAX(hiredate) 最晚雇佣日期 FROM emp;
SELECT MIN (ename), MAX (ename) FROM emp;
SELECT MIN(NVL(comm,0)) 最低提成,MAX(NVL(comm,0)) 最高提成 FROM emp;
/*分组*/
SELECT   deptno, SUM (sal) 部门薪资小计
    FROM emp
GROUP BY deptno;

SELECT   deptno, SUM (sal) 部门薪资小计
    FROM emp
GROUP BY deptno;


SELECT   deptno, SUM (sal) 部门薪资小计
    FROM emp
GROUP BY deptno
ORDER BY SUM (sal);


SELECT   SUM (sal) 部门薪资小计,AVG(sal) 部门薪资平均值
    FROM emp
GROUP BY deptno
ORDER BY SUM (sal);


SELECT   deptno, job, SUM (sal) 薪资小计
    FROM emp
GROUP BY deptno, job;


SELECT   deptno, job, SUM (sal) 薪资小计
    FROM emp
   WHERE deptno IN (20, 30)
GROUP BY deptno, job
  HAVING SUM (sal) > 2000;
/*dual查询*/  
SELECT TO_CHAR (SYSDATE, 'yyyy-mm-dd hh24:mi:ss') FROM DUAL;
/*rownum*/
SELECT ROWNUM, x.*
  FROM emp x
 WHERE x.deptno = 20;
SELECT ROWNUM, empno, ename, job, mgr, hiredate
  FROM emp
 WHERE deptno = 20;
SELECT ROWNUM, empno, ename, job, mgr, hiredate
  FROM emp
 WHERE ROWNUM <= 10;
/*rowid*/
SELECT ROWIDTOCHAR (ROWID), x.ename, x.empno, x.job, x.hiredate
  FROM emp x
 WHERE ROWNUM <= 5;
SELECT SUBSTR (ROWIDTOCHAR (ROWID), 0, 6) 数据对象编号,
       SUBSTR (ROWIDTOCHAR (ROWID), 7, 3) 文件编号,
       SUBSTR (ROWIDTOCHAR (ROWID), 10, 6) 文件编号,
       SUBSTR (ROWIDTOCHAR (ROWID), 16, 3) 文件编号
  FROM emp
 WHERE ROWNUM <= 5;
 SELECT ROWID,x.* FROM emp x;
 
CREATE TABLE emp_rowid AS SELECT * FROM emp;
INSERT INTO emp_rowid SELECT * FROM emp;
SELECT *
  FROM emp_rowid
 WHERE ROWID NOT IN (SELECT   MIN (ROWID)
                         FROM emp_rowid
                     GROUP BY empno);
select empno  from emp_rowid group by empno having count(*) >1;


SELECT ROWIDTOCHAR (ROWID), x.ename, x.empno, x.job, x.hiredate
  FROM emp_rowid x;
DELETE FROM emp_rowid
      WHERE ROWID NOT IN (SELECT   MIN (ROWID)
                              FROM emp_rowid
                          GROUP BY empno);  
/*
子查询
  非相关子查询
  相关子查询                                                
*/   
--非相关子查询                      
SELECT *
  FROM emp
 WHERE sal > (SELECT sal
                FROM emp
               WHERE ename = 'SMITH');
SELECT empno, ename, job, mgr, hiredate, sal
  FROM emp
 WHERE job = (SELECT job
                FROM emp
               WHERE ename = 'SMITH');
SELECT empno, ename, job, mgr, hiredate, sal
  FROM emp
 WHERE sal = (SELECT MIN(sal)
                FROM emp
               WHERE ename = 'SMITH');               
SELECT empno, ename, job, mgr, hiredate, sal
  FROM emp
 WHERE sal = (SELECT MIN (sal)
                FROM emp);                   
SELECT empno, ename, job, mgr, hiredate, sal, deptno
  FROM emp
 WHERE sal IN (SELECT   MIN (sal)
                   FROM emp
               GROUP BY deptno);    
               
               
SELECT empno, ename, job, mgr, hiredate, sal
  FROM emp
 WHERE sal >SOME(SELECT sal FROM emp WHERE job='CLERK') 
 AND job<>'CLERK';                   

SELECT empno, ename, job, mgr, hiredate, sal
  FROM emp
 WHERE sal > ALL (SELECT sal
                    FROM emp
                   WHERE job = 'CLERK') AND job <> 'CLERK';
--相关子查询                   
SELECT   e1.empno, e1.ename, e1.deptno
    FROM emp e1
   WHERE e1.sal > (SELECT AVG (sal)
                     FROM emp e2
                    WHERE e2.deptno = e1.deptno)
ORDER BY e1.deptno;                          
/*
多表的连接查询
      内连接
      外连接
         (左外，右外连接)
      交叉连接
      自然连接
*/
--内连接
SELECT e.*,d.* FROM emp e,dept d WHERE e.deptno=d.deptno;
--左外连接
SELECT * FROM emp;
INSERT INTO emp(empno,ename,job,mgr,hiredate,sal) VALUES(9004,'罗小强','clerk',7566,SYSDATE,6000);
SELECT e.*,d.* FROM emp e,dept d WHERE e.deptno=d.deptno(+);
SELECT e.*,d.* FROM emp e LEFT JOIN dept d ON e.deptno=d.deptno;
SELECT e.*,d.* FROM emp e LEFT OUTER JOIN dept d ON e.deptno=d.deptno;
SELECT * FROM dept;
--右外连接
INSERT INTO dept VALUES(50,'研发部','广东深圳');
SELECT e.*,d.* FROM emp e,dept d WHERE e.deptno(+)=d.deptno;
SELECT e.*,d.* FROM emp e RIGHT JOIN dept d ON e.deptno=d.deptno;
SELECT e.*,d.* FROM emp e RIGHT OUTER JOIN dept d ON e.deptno=d.deptno;
  
/*
表集合运算
  联合与全联合运算
  相交运算
  相减运算
*/               
SELECT * FROM emp;                  
--去重
CREATE TABLE emp_history AS SELECT * FROM emp;
SELECT   empno, ename, sal, hiredate, deptno
    FROM emp
   WHERE deptno = 20
UNION
SELECT   empno, ename, sal, hiredate, deptno
    FROM emp_history
   WHERE deptno = 30;
   
--不去复   
SELECT   empno, ename, sal, hiredate, deptno
    FROM emp
   WHERE deptno = 20
UNION ALL
SELECT   empno, ename, sal, hiredate, deptno
    FROM emp_history
   WHERE deptno = 20;  
   
--交集   
SELECT   empno, ename, sal, hiredate, deptno
    FROM emp
   WHERE deptno = 20
INTERSECT
SELECT   empno, ename, sal, hiredate, deptno
    FROM emp_history
   WHERE deptno = 20;     
   
--差异   
SELECT   empno, ename, sal, hiredate, deptno
    FROM emp
   WHERE deptno = 20
MINUS
SELECT   empno, ename, sal, hiredate, deptno
    FROM emp_history
   WHERE deptno = 20;        
   
    
SELECT * FROM hr.employees;   


/*
lpad(' ',(level-1)*2) 
         表示左填充，填充为空格，
         level表示层级　
         表示填充的个数(level-1)*2
         level-1表示顶格不填充
*/
SELECT level,e.employee_id,lpad(' ',(level-1)*2)||e.last_name AS name,e.salary,e.manager_id FROM hr.employees e
START WITH e.manager_id IS NULL
CONNECT BY e.manager_id=PRIOR employee_id;
    
   
SELECT * FROM hr.employees;  
   
   
SELECT     LEVEL, LPAD ('  ', 2 * (LEVEL - 1)) || last_name "EmpName",
           hire_date, salary
      FROM hr.employees
--表示根节点为
START WITH manager_id IS NULL
--PRIOR表示父行的employee_id，等于当前行的manager_id
CONNECT BY manager_id = PRIOR employee_id;                          

/*
set define off关闭替代变量功能 


在SQL*Plus中默认的"&amp;"表示替代变量，也就是说，只要在命令中出现该符号，SQL*Plus就会要你输入替代值。这就意味着你无法将一个含有该符号的字符串输入数据库或赋给变量，如字符串“SQL&amp;Plus”系统会理解为以“SQL”打头的字符串，它会提示你输入替代变量 Plus的值，如果你输入ABC，则最终字符串转化为“SQLABC”。 
set define off 则关闭该功能，“&amp;”将作为普通字符，如上例，最终字符就为“SQL&amp;Plus” 

set define off关闭替代变量功能 
set define on 开启替代变量功能 
*/
set define * 将默认替代变量标志符该为“*”(也可以设为其它字符)
