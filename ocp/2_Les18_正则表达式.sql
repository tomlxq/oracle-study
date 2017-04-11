regular expressions
	REGEXP_LIKE
	REGEXP_REPLACE
	REGEXP_INSTR
	REGEXP_SUBSTR
	REGEXP_COUNT
POSIX 正则表达式由标准的元字符（metacharacters）所构成：
'^' 匹配输入字符串的开始位置，在方括号表达式中使用，此时它表示不接受该字符集合。
'$' 匹配输入字符串的结尾位置。如果设置了 RegExp 对象的 Multiline 属性，则 $ 也匹
配 '\n' 或 '\r'。
'.' 匹配除换行符之外的任何单字符。
'?' 匹配前面的子表达式零次或一次。
'+' 匹配前面的子表达式一次或多次。
'*' 匹配前面的子表达式零次或多次。
'|' 指明两项之间的一个选择。例子'^([a-z]+|[0-9]+)$'表示所有小写字母或数字组合成的
字符串。
'( )' 标记一个子表达式的开始和结束位置。
'[]' 标记一个中括号表达式。
'{m,n}' 一个精确地出现次数范围，m=<出现次数<=n，'{m}'表示出现m次，'{m,}'表示至少
出现m次。
\num 匹配 num，其中 num 是一个正整数。对所获取的匹配的引用。
字符簇： 
[[:alpha:]] 任何字母。
[[:digit:]] 任何数字。
[[:alnum:]] 任何字母和数字。
[[:space:]] 任何白字符。
[[:upper:]] 任何大写字母。
[[:lower:]] 任何小写字母。
[[:punct:]] 任何标点符号。
[[:xdigit:]] 任何16进制的数字，相当于[0-9a-fA-F]。
各种操作符的运算优先级
\转义符
(), (?:), (?=), [] 圆括号和方括号
*, +, ?, {n}, {n,}, {n,m} 限定符
^, $, anymetacharacter 位置和顺序
| 
*/

SQL> SELECT first_name, last_name
FROM employees
  3  WHERE REGEXP_LIKE (last_name, '^K(i|o).');

FIRST_NAME           LAST_NAME
-------------------- -------------------------
Janette              King
Steven               King
Neena                Kochhar


SQL> SELECT first_name, last_name
  2  FROM employees
  3  WHERE REGEXP_LIKE (first_name, '^Ste(v|ph)en$');

FIRST_NAME           LAST_NAME
-------------------- -------------------------
Steven               King
Steven               Markle
Stephen              Stiles
SQL> select ename,hiredate from emp where regexp_like(to_char(hiredate,'yyyy'),'^198[5-8]$') and regexp_like(ename,'^A');

ENAME      HIREDATE
---------- ------------------
ADAMS      23-MAY-87
--；REGEXP_INSTR()返回pattern出现的位置。匹配位置从1开始
SQL> SELECT REGEXP_replace('But, soft! What light through yonder window breaks?', 'l[[:alpha:]]{4}','xxx') AS result FROM dual;

RESULT
-------------------------------------------------
But, soft! What xxx through yonder window breaks?

SQL> SELECT regexp_replace (street_address, ' ', '') AS "Street Address" from locations where rownum<5;

Street Address
--------------------------------------------------------------------------------
1297ViaColadiRie
93091CalledellaTesta
2017Shinjuku-ku
9450Kamiya-cho
SQL> SELECT street_address,regexp_replace (street_address, 'St$','Street') new_addr
  2  FROM locations
  3  WHERE regexp_like (street_address, 'St');

STREET_ADDRESS                           NEW_ADDR
---------------------------------------- --------------------------------------------------
2007 Zagora St                           2007 Zagora Street
6092 Boxwood St                          6092 Boxwood Street
12-98 Victoria Street                    12-98 Victoria Street
8204 Arthur St                           8204 Arthur Street

SQL> SELECT REGEXP_INSTR('But, soft! What light through yonder window breaks?', 'l[[:alpha:]]{4}') AS result FROM dual;

    RESULT
----------
        17

SQL> SELECT REGEXP_INSTR('But, soft! What light through yonder window softly breaks?', 's[[:alpha:]]{3}', 1, 2) AS result FROM dual;

    RESULT
----------
        45

SQL> SELECT REGEXP_INSTR('But, soft! What light through yonder window breaks?', 'o', 10, 2) AS result FROM dual;

    RESULT
----------
        32
SQL> SELECT REGEXP_substr('But, soft! What light through yonder window breaks?', 'l[[:alpha:]]{4}') AS result FROM dual;

RESUL
-----
light

SQL> SELECT REGEXP_COUNT( '123gtccc333abcgtc888wwgtcxxxgtc123', 'gtc') AS Count FROM dual;

     COUNT
----------
         4
--添加检查约束
SQL> create table emp8(id number ,email varchar2(30));

Table created.

SQL> insert into emp8 values(1,'123@gmail.com');

1 row created.

SQL> ALTER TABLE emp8
  2  ADD CONSTRAINT email_addr
  3  CHECK(REGEXP_LIKE(email,'@')) NOVALIDATE;

Table altered.

SQL> insert into emp8 values(2,'ChrisP2creme.com');
insert into emp8 values(2,'ChrisP2creme.com')
*
ERROR at line 1:
ORA-02290: check constraint (SH.EMAIL_ADDR) violated


SQL> insert into emp8 values(2,'Chris@creme.com');

1 row created.



SQL> create table contacts(last_name varchar2(30),p_num varchar2(50) constraint p_num_format check(regexp_like(p_num, '\(\d{3}\) \d{3}-\d{4}$')));

Table created.

SQL> insert into contacts values('jack','(123) 235-4567');

1 row created.

SQL> insert into contacts values('wuhan','1232354567');
insert into contacts values('wuhan','1232354567')
*
ERROR at line 1:
ORA-02290: check constraint (HR.P_NUM_FORMAT) violated