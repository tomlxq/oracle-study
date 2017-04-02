/*
Oracle计算时间函数(numtodsinterval、numtoyminterval)
numtodsinterval(<x>,<c>) ,x是一个数字,c是一个字符串
表明x的单位,这个函数把x转为interval day to second数据类型
常用的单位有 ('day','hour','minute','second')

numtoyminterval 与numtodsinterval函数类似,将x转为interval year to month数据类型
常用的单位有'year','month'
*/


SQL> select sysdate,sysdate+numtodsinterval(3,'hour') as res from dual;

SYSDATE             RES
------------------- -------------------
2017-03-26 13:38:24 2017-03-26 16:38:24


SQL> alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';

Session altered.

SQL>  select sysdate,sysdate+numtoyminterval(3,'year') as res from dual;

SYSDATE             RES
------------------- -------------------
2017-03-26 13:38:05 2020-03-26 13:38:05

