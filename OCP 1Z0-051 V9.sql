QUESTION 1
SQL> conn sh/oracle
Connected.
SQL> select * from sh.sales where rownum<4;

   PROD_ID    CUST_ID TIME_ID   CHANNEL_ID   PROMO_ID QUANTITY_SOLD AMOUNT_SOLD
---------- ---------- --------- ---------- ---------- ------------- -----------
        13        987 10-JAN-98          3        999             1     1232.16
        13       1660 10-JAN-98          3        999             1     1232.16
        13       1762 10-JAN-98          3        999             1     1232.16

SQL> CREATE TABLE new_sales(prod_id, cust_id, order_date DEFAULT SYSDATE)
  2  AS
  3  SELECT prod_id, cust_id, time_id
  4  FROM sales;
SQL> select * from sh.new_sales where rownum<4;

   PROD_ID    CUST_ID ORDER_DAT
---------- ---------- ---------
        13        987 10-JAN-98
        13       1660 10-JAN-98
        13       1762 10-JAN-98 
新创建表有没有约束
QUESTION 2
SQL> conn sh/oracle
Connected.
SQL> CREATE VIEW v3
  2  AS SELECT * FROM SALES
  3  WHERE cust_id = 2034
  4  WITH CHECK OPTION;

View created.

SQL> CREATE VIEW v1
  2  AS SELECT * FROM SALES
  3  WHERE time_id <= SYSDATE - 2*365
  4  WITH CHECK OPTION;

View created.
新创建视图有没有ＤＭＬ操作

QUESTION 3
SQL> create table test_sales as select * from sh.sales;
select * from test_sales where rownum<5;
SQL> alter table test_sales modify (prod_id varchar2(20));
alter table test_sales modify (prod_id varchar2(20))
                               *
ERROR at line 1:
ORA-01439: column to be modified must be empty to change datatype
SQL> alter table test_sales add(tmp_col varchar2(20));
SQL> update test_sales set tmp_col = to_char(prod_id);
SQL> alter table test_sales drop column prod_id;
SQL> alter table test_sales add(prod_id varchar2(20)); 
SQL> update test_sales set prod_id = tmp_col;
SQL> alter table test_sales drop column tmp_col;
SQL> insert into test_sales values(987,sysdate,3,999,1,1234,'_D123');
SQL> set linesize 200
SQL> select * from test_sales where prod_id LIKE '%\_D123%' ESCAPE '\';

   CUST_ID TIME_ID   CHANNEL_ID   PROMO_ID QUANTITY_SOLD AMOUNT_SOLD PROD_ID
---------- --------- ---------- ---------- ------------- ----------- --------------------
       987 25-MAR-17          3        999             1        1234 _D123

SQL> select * from test_sales where prod_id LIKE '%\_D123%';

no rows selected

SQL> select * from test_sales where prod_id LIKE '%_D123%';

   CUST_ID TIME_ID   CHANNEL_ID   PROMO_ID QUANTITY_SOLD AMOUNT_SOLD PROD_ID
---------- --------- ---------- ---------- ------------- ----------- --------------------
       987 25-MAR-17          3        999             1        1234 _D123
	   
QUESTION 5
SQL> SELECT TO_CHAR(1890.55,'$0G000D00') FROM DUAL;

TO_CHAR(18
----------
 $1,890.55

SQL> SELECT TO_CHAR(1890.55,'$9,999V99') FROM DUAL;

TO_CHAR(1
---------
 $1,89055

SQL> SELECT TO_CHAR(1890.55,'$99,999D99') FROM DUAL;
SELECT TO_CHAR(1890.55,'$99,999D99') FROM DUAL
                       *
ERROR at line 1:
ORA-01481: invalid number format model


SQL> SELECT TO_CHAR(1890.55,'$99G999D00') FROM DUAL;

TO_CHAR(189
-----------
  $1,890.55

SQL> SELECT TO_CHAR(1890.55,'$99G999D99') FROM DUAL;

TO_CHAR(189
-----------
  $1,890.55

QUESTION 6  
SQL> create table shipments(
  2  PO_ID  NUMBER(3) NOT NULL,
  3  PO_DATE  DATE NOT NULL,
  4  SHIPMENT_DATE  DATE NOT NULL,
  5  SHIPMENT_MODE VARCHAR2(30),
  6  SHIPMENT_COST NUMBER(8,2)
  7  );

Table created.
SQL> insert into shipments values(1, date'2015-05-06',date'2015-05-24','SALES',56);

1 row created.

SQL> insert into shipments values(2, date'2015-05-06',date'2015-06-26','SALES',56);

1 row created.

SQL> insert into shipments values(3, date'2015-05-06',date'2015-06-25','SALES',56);

1 row created.
SQL> SELECT po_id, CASE
  2  WHEN MONTHS_BETWEEN (shipment_date,po_date)>1 THEN
  3  TO_CHAR((shipment_date - po_date) * 20) ELSE 'No Penalty' END PENALTY
  4  FROM shipments;

     PO_ID PENALTY
---------- ----------------------------------------
         1 No Penalty
         2 1020
         3 1000
QUESTION 12		 
SQL> SELECT cust_last_name AS "Name", cust_credit_limit + 1000 AS "New Credit Limit" FROM sh.customers where rownum<5;

Name                                     New Credit Limit
---------------------------------------- ----------------
Ruddy                                                2500
Ruddy                                                8000
Ruddy                                               12000
Ruddy                                                2500

QUESTION 13
C. SELECT prod_name ||q'\'s\'|| ' category is ' ||prod_category CATEGORIES FROM sh.products;
D. SELECT prod_name ||q'<'s>'|| ' category is '|| prod_category CATEGORIES FROM sh.products;
Correct Answer: CD


QUESTION 14
SQL> SELECT DISTINCT cust_income_level||' ' ||cust_credit_limit * 0.50 AS "50% Credit Limit" FROM sh.customers where rownum<5;

50% Credit Limit
-----------------------------------------------------------------------
G: 130,000 - 149,999 5500
G: 130,000 - 149,999 3500
G: 130,000 - 149,999 750

QUESTION 16
SQL> SELECT promo_name ||q'{'s start date was }'|| promo_begin_date AS "Promotion Launches" FROM sh.promotions where rownum<5;

Promotion Launches
---------------------------------------------------------
NO PROMOTION #'s start date was 01-JAN-99
newspaper promotion #16-108's start date was 23-DEC-00
post promotion #20-232's start date was 25-SEP-98
newspaper promotion #16-349's start date was 10-JUL-98

SQL> SELECT promo_name ||q'<'s start date was >'|| promo_begin_date AS "Promotion Launches" FROM sh.promotions where rownum<5;

Promotion Launches
---------------------------------------------------------
NO PROMOTION #'s start date was 01-JAN-99
newspaper promotion #16-108's start date was 23-DEC-00
post promotion #20-232's start date was 25-SEP-98
newspaper promotion #16-349's start date was 10-JUL-98

SQL> SELECT promo_name ||q'\'s start date was \'|| promo_begin_date AS "Promotion Launches" FROM sh.promotions where rownum<5;

Promotion Launches
---------------------------------------------------------
NO PROMOTION #'s start date was 01-JAN-99
newspaper promotion #16-108's start date was 23-DEC-00
post promotion #20-232's start date was 25-SEP-98
newspaper promotion #16-349's start date was 10-JUL-98

QUESTION 17
SQL> SELECT ename || ' joined on '|| hiredate ||', the total compensation paid is ' || TO_CHAR(ROUND(ROUND(SYSDATE-hiredate)/365) * sal + comm) "COMPENSATION UNTIL DATE" FROM scott.emp where rownum<5;

COMPENSATION UNTIL DATE
-------------------------------------------------------------------------------------------------------
SMITH joined on 17-DEC-80, the total compensation paid is
ALLEN joined on 20-FEB-81, the total compensation paid is 57900
WARD joined on 22-FEB-81, the total compensation paid is 45500
JONES joined on 02-APR-81, the total compensation paid is
C. It executes successfully but does not give the correct output.
Correct Answer: C

QUESTION 18
The management wants to see a report of unique promotion costs in each promotion category.
SQL> SELECT DISTINCT promo_category, promo_cost FROM sh.promotions where rownum<5 ORDER BY 1;

PROMO_CATEGORY                 PROMO_COST
------------------------------ ----------
NO PROMOTION                            0
newspaper                             200
newspaper                             400
post                                  300
D. SELECT DISTINCT promo_category, promo_cost FROM promotions ORDER BY 1;
Correct Answer: D


QUESTION 19
SQL> SELECT INTERVAL '300' MONTH,
  2  INTERVAL '54-2' YEAR TO MONTH,
  3  INTERVAL '11:12:10.1234567' HOUR TO SECOND
  4  FROM dual;

INTERVAL'300'MONTH   INTERVAL'54-2'YEARTO INTERVAL'11:12:10.1234567'HOURTOSECOND
-------------------- -------------------- ---------------------------------------------------------------------------
+25-00               +54-02               +00 11:12:10.123457
SQL> select 300/12 from dual;

    300/12
----------
        25
INTERVAL YEAR TO MONTH数据类型

Oracle语法:
INTERVAL 'integer [- integer]' {YEAR | MONTH} [(precision)][TO {YEAR | MONTH}]
该数据类型常用来表示一段时间差, 注意时间差只精确到年和月. precision为年或月的精确域, 有效范围是0到9, 默认值为2.
eg:
INTERVAL '123-2' YEAR(3) TO MONTH
表示: 123年2个月, "YEAR(3)" 表示年的精度为3, 可见"123"刚好为3为有效数值, 如果该处YEAR(n), n<3就会出错, 注意默认是2.

INTERVAL '123' YEAR(3)
表示: 123年0个月

INTERVAL '300' MONTH(3)
表示: 300个月, 注意该处MONTH的精度是3啊.

INTERVAL '4' YEAR
表示: 4年, 同 INTERVAL '4-0' YEAR TO MONTH 是一样的

INTERVAL '50' MONTH
表示: 50个月, 同 INTERVAL '4-2' YEAR TO MONTH 是一样

INTERVAL '123' YEAR
表示: 该处表示有错误, 123精度是3了, 但系统默认是2, 所以该处应该写成 INTERVAL '123' YEAR(3) 或"3"改成大于3小于等于9的数值都可以的

INTERVAL '5-3' YEAR TO MONTH + INTERVAL '20' MONTH =
INTERVAL '6-11' YEAR TO MONTH
表示: 5年3个月 + 20个月 = 6年11个月
Reference:
http://blog.sina.com.cn/s/blog_854ec93b0101aahp.html

QUESTION 20
Which three statements are true regarding the data types in Oracle Database 10g/11g? (Choose
three.)
A. Only one LONG column can be used per table.
B. A TIMESTAMP data type column stores only time values with fractional seconds. 
C. The BLOB data type column is used to store binary data in an operating system file.
D. The minimum column width that can be specified for a VARCHAR2 data type column is one.
E. The value for a CHAR data type column is blank-padded to the maximum defined column width.
Answer: ADE
答案解析：
参考：http://blog.csdn.net/rlhua/article/details/12905109


准则
• 在使用子查询创建表时不复制LONG列。
• 不能在GROUP BY或ORDER BY子句中包括LONG列。
• 每个表只能使用一个LONG列。
• 不能对LONG列定义约束条件。
• 可以要求使用CLOB列，而不是LONG列。

A. 每个表中只能使用一个LONG列。正确
B. 一个TIMESTAMP数据类型列只能存储带有小数秒的时间值。错误，也可以存储不带小数秒的日期或时间
C. BLOB数据类型列被用于存储二进制数据的操作系统文件。错误，不是操作系统文件。
D. 对于VARCHAR2数据类型最小的列宽可以为1（VARCHAR2为可变长度的数据类型）.
E. CHAR数据类型列的值是用空格填充到列定义的最大值（也就是说，如果定义了CHAR(20),而字符串长度不够20个，则用空格填充不够的位数，CHAR为固定长度数据类型）
答案解析：
http://blog.csdn.net/rlhua/article/details/12905109

QUESTION 21
Examine the description of the EMP_DETAILS table given below:
name NULL TYPE
EMP_ID NOT NULL NUMBER
EMP_NAME NOT NULL VARCHAR2 (40)
EMP_IMAGE LONG
Which two statements are true regarding SQL statements that can be executed on the EMP_DETAIL
table? (Choose two.)
A. An EMP_IMAGE column can be included in the GROUP BY clause.
B. An EMP_IMAGE column cannot be included in the ORDER BY clause. 不能在GROUP BY或ORDER BY子句中包括LONG列
C. You cannot add a new column to the table with LONG as the data type.　每个表只能使用一个LONG列。
D. You can alter the table to include the NOT NULL constraint on the EMP_IMAGE column.　不能对LONG列定义约束条件
Correct Answer: BC

QUESTION 22
You need to create a table for a banking application. One of the columns in the table has the following requirements: 
1) You want a column in the table to store the duration of the credit period. 
2) The data in the column should be stored in a format such that it can be easily added and subtracted with     
   DATE data type without using conversion functions. 
3) The maximum period of the credit provision in the application is 30 days. 
4) The interest has to be calculated for the number of days an individual has taken a credit for. 
Which data type would you use for such a column in the table? 
（你需要创建一个银行业务表，其中一个字段有如下要求：
1）该字段需要存储信贷期限的持续时间。
2）不使用转换函数，就可以简单的和Date数据类型加减。
3）应用中信贷发放的最大周期是30天
4）已经拥有信用卡的个人，按天计算利息。）
A. DATE 
B. NUMBER 
C. TIMESTAMP 
D. INTERVAL DAY TO SECOND 
E. INTERVAL YEAR TO MONTH 

Answer: D 

A：Date类型存储的是一个时间点，不是一段时间 （错误）
B：number类型不能和date类型简单的加减 （错误）
C: 和A一样存储的是时间点（错误）
D: 正确
E: 错误，不能精确到天

QUESTION 23
Examine the structure proposed for the TRANSACTIONS table:
name Null Type
TRANS_ID NOT NULL NUMBER(6)
CUST_NAME NOT NULL VARCHAR2(20)
CUST_STATUS NOT NULL CHAR
TRANS_DATE NOT NULL DATE
TRANS_VALIDITY VARCHAR2
CUST_CREDIT_LIMIT NUMBER
Which statements are true regarding the creation and storage of data in the above table structure?
(Choose all that apply.)
A. The CUST_STATUS column would give an error.
B. The TRANS_VALIDITY column would give an error.
C. The CUST_STATUS column would store exactly one character.
D. The CUST_CREDIT_LIMIT column would not be able to store decimal values.
E. The TRANS_VALIDITY column would have a maximum size of one character.
F. The TRANS_DATE column would be able to store day, month, century, year, hour, minutes, seconds,
and fractions of seconds.
Correct Answer: BC
查看TRANSACTIONS表结构
关于上面表结构数据创建和存储哪句话是正确的？（选择所有正确的选项）
A. CUST_STATUS列将报错
B. TRANS_VALIDITY列将报错
C. CUST_STATUS列将精确的存储一个字符
D. CUST_CREDIT_LIMIT列不能存储小数值
E. TRANS_VALIDITY列将会有一个字符的最大大小
F. TRANS_DATE列能存储日，月，世纪，年，小时，分，秒，小数秒
题目解析
A选项不正确，因为CUST_STATUS列定义的CHAR类型是可以省略size的，默认为1byte
B选项正确，因为TRANS_VALIDITY的varchar2类型，没有长度，所以会报错。
C选项正确，因为CHAR类型不写长度，默认是1.
D选项不正确，因为NUMBER可以存储小数值，会四舍五入。
E选项不正确，因为VARCHAR2数据类型必须要指定size，比如VARCHAR(10)，否则会报错
F选项不正确，因为DATE类型不能存储小数秒

QUESTION 24
Examine the structure proposed for the TRANSACTIONS table:
Name                 Null           Type
TRANS_ID            NOT NULL     NUMBER(6)
CUST_NAME           NOT NULL     VARCHAR2(20)
CUST_STATUS         NOT NULL     VARCHAR2
TRANS_DATE          NOT NULL     DATE
TRANS_VALIDITY                   INTERVAL DAY TO SECOND
CUST_CREDIT_VALUE                NUMBER(10)
Which two statements are true regarding the storage of data in the above table structure? (Choose two.)
A. The TRANS_DATE column would allow storage of dates only in the dd-mon-yyyy format.
B. The CUST_CREDIT_VALUE column would allow storage of positive and negative integers.
C. The TRANS_VALIDITY column would allow storage of a time interval in days, hours, minutes, and seconds.
D. The CUST_STATUS column would allow storage of data up to the maximum VARCHAR2 size of 4,000 characters.

答案：BC

二、题目翻译
查看下面TRANSACTIONS表的结构：
关于该表结构的数据存储哪两句话是正确的？(选择两个)
A. TRANS_DATE列只能存储dd-mon-yyyy格式的数据。
B. CUST_CREDIT_VALUE列可以存储正整数与负整数。
C. TRANS_VALIDITY列可以存储从days, hours, minutes, 到seconds的一段时间区间。
D. CUST_STATUS列存储的数据可以达到VARCHAR2的最大值4000个字符。

三、题目解析
A选项不正确，因为DATE不仅仅只能存储该dd-mon-yyyy格式的日期数据，还可以存其它格式，比如：yyyy-mm-dd这样的格式，还可以带有时分秒的
D选项不正确，因为VARCHAR2不能省略size，所以会报错，需要加上长度，比如: VARCHAR2(10)

QUESTION 25
You need to create a table with the following column specifications:
1. Employee ID (numeric data type) for each employee
2. Employee Name (character data type) that stores the employee name
3. Hire date, which stores the date of joining the organization for each employee
4. Status (character data type), that contains the value 'ACTIVE' if no data is entered
5. Resume (character large object [CLOB] data type), which contains the resume submitted by the
employee
Which is the correct syntax to create this table?
D. CREATE TABLE EMP_1
(emp_id NUMBER,
emp_name VARCHAR2(25),
start_date DATE,
emp_status VARCHAR2(10) DEFAULT 'ACTIVE',
resume CLOB);
Correct Answer: D

QUESTION 26
Which is the valid CREATE TABLE statement?
A.CREATE TABLE emp9$# (emp_no NUMBER (4));
B.CREATE TABLE 9emp$# (emp_no NUMBER(4));
C.CREATE TABLE emp*123 (emp_no NUMBER(4));
D.CREATE TABLE emp9$# (emp_no NUMBER(4),date DATE);
答案：A
解析：
B：不能以数字开头
C：不能有*
D：date 是sql保留字
命名规则 

QUESTION 27
Which two statements are true regarding tables? (Choose two.)
A. A table name can be of any length.
B. A table can have any number of columns.
C. A column that has a DEFAULT value cannot store null values.
D. A table and a view can have the same name in the same schema
E. A table and a synonym can have the same name in the same schema.
F. The same table name can be used in different schemas in the same database.

答案: EF
二、题目翻译
关于表哪两个句子是正确的？（选择两个）
A. 表名可以是任意长度的。
B. 表能有任意数量的列。
C. 有DEFAULT值的列不能存储空值。
D. 在相同的schema里，表和视图可以有相同的名字。
E. 在相同的schema里，表和同义词可以有相同的名字。
F. 在相同的数据库不同的schema里，表名可以相同。

三、题目解析
A选项不正确，因为表名的长度为1-30个字符
B选项不正确，因为表的列最多为1000个
C选项不正确，因为有DEFAULT值的列可以存储空值
D选项不正确，因为在相同的schema里，表和视图的名字不能相同
E在这里说明一个，我使用CREATE SYNONYM建立相同表名字的SYNONYM不成功，但是建立PUBLIC SYNONYM成功，所以这句话算是正确。句子中说的是可以有同样的名字，具体实验看下面。
F选项正确，不同的schema，表名可以相同。

详见联机文档oracle对象命令规则：
 http://docs.oracle.com/cd/E11882_01/server.112/e41084/sql_elements008.htm#SQLRF00223
实验１：不能创建同名的表和视图
SQL> create table t(id number);
Table created.
SQL> create view t as select * from t;
create view t as select * from t
            *
ERROR at line 1:
ORA-00955: name is already used by an existing object
SQL> create view v_t as select * from t;
View created.
实验２：创建同名的表和公共的同义词可以，私有同义词不可以
SQL> conn / as sysdba
Connected.
SQL> grant create public synonym to scott;
SQL> grant create synonym to scott;
SQL> conn scott/oracle
Connected.
SQL> create public synonym emp for scott.emp;
Synonym created.
SQL> conn / as sysdba
SQL> drop public synonym emp;

Synonym dropped.

SQL> conn scott/oracle
Connected.
SQL> create synonym emp for scott.emp;
create synonym emp for scott.emp
*
ERROR at line 1:
ORA-01471: cannot create a synonym with same name as object

QUESTION 28
Which two statements are true regarding constraints? (Choose two.)
A. A foreign key cannot contain NULL values.
B. A column with the UNIQUE constraint can contain NULL values.
C. A constraint is enforced only for the INSERT operation on a table.
D. A constraint can be disabled even if the constraint column contains data.
E. All constraints can be defined at the column level as well as the table level.
Correct Answer: BD
二、题目翻译
下面的哪两个语句是正确的?
A.外键不能包含空值。
B.唯一约束的列可以插入空值。
C.约束只有在向一张表中插入数据的时候，才会强制。
D.如果约束列上有数据，约束列可以被设置为无效(disabled)。
E.所有的约束都能在列级和表级定义。
三、题目解析
A选项不正确，外键中可以包含空值。
B选项正确，唯一约束可以插入null值，并且可以插入任意多个null值。
C选项不正确，约束有做所有操作的时候，都会强制，不光是插入数据的时候。
D选项正确，约束可以设置为enable和disable,列有有数据的时候，不影响设置disable，如果是设置为enable,则需要列中的数据符合约束。
E选项不正确，NOT NULL约束没有表级定义，但实际上，not null也可以用CHECK约束来实现表级形式。
实验:
Ａ外键能插入空值,错误
SQL> create table t1 (id number constraint uk_id unique);
Table created.
SQL> insert into t1 values(1);
1 row created.
SQL> commit;
Commit complete.
SQL> create table t2(id number,constraint fk_id foreign key (id) references t1(id));
Table created.
SQL> insert into t2 values(null);
1 row created.
SQL> commit;
B.唯一键可插入空值，正确
SQL> insert into t1 values(null);
1 row created.


QUESTION 29
Which two statements are true regarding constraints? (Choose two.)
A. A foreign key cannot contain NULL values.
B. The column with a UNIQUE constraint can store NULLS .
C. A constraint is enforced only for an INSERT operation on a table.
D. You can have more than one column in a table as part of a primary key.
Correct Answer: BD
解析：
A选项，由上题可知是错误的
B选项，由上题可知是正确的
C选项，由上题可知是错误的
D选项，一个表中只能有虽然只有一个约束，但是可以建立一个联合主键约束，这样就有多列为主键约束，所以D选项正确

QUESTION 30
Evaluate the following CREATE TABLE commands:
CREATE TABLE orders
(ord_no NUMBER(2) CONSTRAINT ord_pk PRIMARY KEY,
ord_date DATE,
cust_id NUMBER(4));
CREATE TABLE ord_items
(ord_no NUMBER(2),
item_no NUMBER(3),
qty NUMBER(3) CHECK (qty BETWEEN 100 AND 200),
expiry_date date CHECK (expiry_date > SYSDATE),
CONSTRAINT it_pk PRIMARY KEY (ord_no,item_no),
CONSTRAINT ord_fk FOREIGN KEY(ord_no) REFERENCES orders(ord_no));
The above command fails when executed. What could be the reason?
A. SYSDATE cannot be used with the CHECK constraint.
B. The BETWEEN clause cannot be used for the CHECK constraint.
C. The CHECK constraint cannot be placed on columns having the DATE data type.
D. ORD_NO and ITEM_NO cannot be used as a composite primary key because ORD_NO is also the
FOREIGN KEY.
Correct Answer: A
实验：
SQL> CREATE TABLE orders(
  2  ord_no NUMBER(2)CONSTRAINT ord_pk PRIMARY KEY,
  3  ord_date DATE,
  4  cust_id NUMBER(4));

Table created.

SQL> CREATE TABLE ord_items
  2  (ord_no NUMBER(2),
  3  item_no NUMBER(3),
  4  qty NUMBER(3) CHECK (qty BETWEEN 100 AND 200),
  5  expiry_date date CHECK (expiry_date > SYSDATE),
  6  CONSTRAINT it_pk PRIMARY KEY (ord_no,item_no),
  7  CONSTRAINT ord_fk FOREIGN KEY(ord_no) REFERENCES orders(ord_no));
expiry_date date CHECK (expiry_date > SYSDATE),
                                      *
ERROR at line 5:
ORA-02436: date or system variable wrongly specified in CHECK constraint

QUESTION 31
Evaluate the following SQL commands:
SQL>CREATE SEQUENCE ord_seq
INCREMENT BY 10
START WITH 120
MAXVALUE 9999
NOCYCLE;
SQL>CREATE TABLE ord_items
(ord_no NUMBER(4)DEFAULT ord_seq.NEXTVAL NOT NULL,
item_no NUMBER(3),
qty NUMBER(3) CHECK (qty BETWEEN 100 AND 200),
expiry_date date CHECK (expiry_date > SYSDATE),
CONSTRAINT it_pk PRIMARY KEY (ord_no,item_no),
CONSTRAINT ord_fk FOREIGN KEY(ord_no) REFERENCES orders(ord_no));
The command to create a table fails. Identify the reason for the SQL statement failure? (Choose all that
apply.)
A. You cannot use SYSDATE in the condition of a CHECK constraint.
B. You cannot use the BETWEEN clause in the condition of a CHECK constraint.
C. You cannot use the NEXTVAL sequence value as a DEFAULT value for a column.
D. You cannot use ORD_NO and ITEM_NO columns as a composite primary key because ORD_NO is
also the FOREIGN KEY.
Correct Answer: AC
实验：
SQL> CREATE SEQUENCE ord_seq
  2  INCREMENT BY 10
  3  START WITH 120
  4  MAXVALUE 9999
  5  NOCYCLE;

Sequence created.

SQL> CREATE TABLE ord_items
  2  (ord_no NUMBER(4)DEFAULT ord_seq.NEXTVAL NOT NULL,
  3  item_no NUMBER(3),
  4  qty NUMBER(3) CHECK (qty BETWEEN 100 AND 200),
  5  expiry_date date CHECK (expiry_date > SYSDATE),
  6  CONSTRAINT it_pk PRIMARY KEY (ord_no,item_no),
  7  CONSTRAINT ord_fk FOREIGN KEY(ord_no) REFERENCES orders(ord_no));
(ord_no NUMBER(4)DEFAULT ord_seq.NEXTVAL NOT NULL,
                         *
ERROR at line 2:
ORA-00984: column not allowed here
第 2 行出现错误:
ORA-00984: 列在此处不允许
由上题可知A选项正确，B，D选项错误，经上面测试，C选项正确

QUESTION 32
Which CREATE TABLE statement is valid?
A. CREATE TABLE ord_details
(ord_no NUMBER(2) PRIMARY KEY,
item_no NUMBER(3) PRIMARY KEY,
ord_date DATE NOT NULL);
B. CREATE TABLE ord_details
(ord_no NUMBER(2) UNIQUE, NOT NULL,
item_no NUMBER(3),
ord_date DATE DEFAULT SYSDATE NOT NULL);
C. CREATE TABLE ord_details
(ord_no NUMBER(2) ,
item_no NUMBER(3),
ord_date DATE DEFAULT NOT NULL,
CONSTRAINT ord_uq UNIQUE (ord_no),
CONSTRAINT ord_pk PRIMARY KEY (ord_no));
D. CREATE TABLE ord_details
(ord_no NUMBER(2),
item_no NUMBER(3),
ord_date DATE DEFAULT SYSDATE NOT NULL,
CONSTRAINT ord_pk PRIMARY KEY (ord_no, item_no));
Correct Answer: D
解析：
A选项：一个表中不能有两个主键
B选项：一个列不能同时附加上两个约束
C选项：default用法错误，以及一个列不能同时附加两个 约束
D选项正确

QUESTION 33
You want to create an ORD_DETAIL table to store details for an order placed having the following
business requirement:
1) The order ID will be unique and cannot have null values.
2) The order date cannot have null values and the default should be the current date.
3) The order amount should not be less than 50.
4) The order status will have values either shipped or not shipped.
5) The order payment mode should be cheque, credit card, or cash on delivery (COD).
Which is the valid DDL statement for creating the ORD_DETAIL table?
A. CREATE TABLE ord_details
(ord_id NUMBER(2) CONSTRAINT ord_id_nn NOT NULL,
ord_date DATE DEFAULT SYSDATE NOT NULL,
ord_amount NUMBER(5, 2) CONSTRAINT ord_amount_min
CHECK (ord_amount > 50),
ord_status VARCHAR2(15) CONSTRAINT ord_status_chk
CHECK (ord_status IN ('Shipped', 'Not Shipped')),
ord_pay_mode VARCHAR2(15) CONSTRAINT ord_pay_chk
CHECK (ord_pay_mode IN ('Cheque', 'Credit Card',
'Cash On Delivery')));
B. CREATE TABLE ord_details
(ord_id NUMBER(2) CONSTRAINT ord_id_uk UNIQUE NOT NULL,
ord_date DATE DEFAULT SYSDATE NOT NULL,
ord_amount NUMBER(5, 2) CONSTRAINT ord_amount_min
CHECK (ord_amount > 50),
ord_status VARCHAR2(15) CONSTRAINT ord_status_chk
CHECK (ord_status IN ('Shipped', 'Not Shipped')),
ord_pay_mode VARCHAR2(15) CONSTRAINT ord_pay_chk
CHECK (ord_pay_mode IN ('Cheque', 'Credit Card',
'Cash On Delivery')));
C. CREATE TABLE ord_details
(ord_id NUMBER(2) CONSTRAINT ord_id_pk PRIMARY KEY,
ord_date DATE DEFAULT SYSDATE NOT NULL,
ord_amount NUMBER(5, 2) CONSTRAINT ord_amount_min
CHECK (ord_amount >= 50),
ord_status VARCHAR2(15) CONSTRAINT ord_status_chk
CHECK (ord_status IN ('Shipped', 'Not Shipped')),
ord_pay_mode VARCHAR2(15) CONSTRAINT ord_pay_chk
CHECK (ord_pay_mode IN ('Cheque', 'Credit Card',
'Cash On Delivery')));
D. CREATE TABLE ord_details
(ord_id NUMBER(2),
ord_date DATE NOT NULL DEFAULT SYSDATE,
ord_amount NUMBER(5, 2) CONSTRAINT ord_amount_min
CHECK (ord_amount >= 50),
ord_status VARCHAR2(15) CONSTRAINT ord_status_chk
CHECK (ord_status IN ('Shipped', 'Not Shipped')),
ord_pay_mode VARCHAR2(15) CONSTRAINT ord_pay_chk
CHECK (ord_pay_mode IN ('Cheque', 'Credit Card',
'Cash On Delivery')));
Correct Answer: C
解析：
根据题目第一句话：The order ID willbe unique and cannot have null values
只有主键才能满足这个条件，unique是可以为空值的
正确答案只能为C选项
实验：
SQL> CREATE TABLE ord_details(
  2  ord_id NUMBER(2) CONSTRAINT ord_id_pk PRIMARY KEY,
  3  ord_date DATE DEFAULT SYSDATE NOT NULL,
  4  ord_amount NUMBER(5, 2) CONSTRAINT ord_amount_min CHECK (ord_amount >= 50),
  5  ord_status VARCHAR2(15) CONSTRAINT ord_status_chk CHECK (ord_status IN ('Shipped', 'Not Shipped')),
  6  ord_pay_mode VARCHAR2(15) CONSTRAINT ord_pay_chk CHECK (ord_pay_mode IN ('Cheque', 'Credit Card','Cash On Delivery'))
  7  );

Table created.

QUESTION 34
You created an ORDERS table with the following description:
name Null Type
ORD_ID NOT NULL NUMBER(2)
CUST_ID NOT NULL NUMBER(3)
ORD_DATE NOT NULL DATE
ORD_AMOUNT NOT NULL NUMBER (10,2)
You inserted some rows in the table. After some time, you want to alter the table by creating the PRIMARY
KEY constraint on the ORD_ID column. Which statement is true in this scenario?
A. You cannot have two constraints on one column.
B. You cannot add a primary key constraint if data exists in the column.
C. The primary key constraint can be created only at the time of table creation .
D. You can add the primary key constraint even if data exists, provided that there are no duplicate values.
Correct Answer: D
解析：
题目意思是在一个已有数据的表中，将第一列改为主键约束，只要该列没有重复值是可以更改的
实验：
SQL> create table t(id number);
Table created.
SQL> insert into t values(1);
1 row created.
SQL> insert into t values(2);
1 row created.
SQL> insert into t values(3);
1 row created.
SQL> select * from t;
        ID
----------
         1
         2
         3
SQL> alter table t add constraint pk_k primary key(id);
SQL> drop table t;
Table dropped.
SQL> create table t(id number);
Table created.
SQL> insert into t values(1);
1 row created.
SQL> insert into t values(1);
1 row created.
SQL> insert into t values(2);
1 row created.
SQL> insert into t values(3);
1 row created.
SQL> select * from t;
        ID
----------
         1
         1
         2
         3
SQL> alter table t add constraint pk_k primary key(id);
alter table t add constraint pk_k primary key(id)                            *
ERROR at line 1:
ORA-02437: cannot validate (SCOTT.PK_K) - primary key violated
第 1 行出现错误:
ORA-02437: 无法验证 (SCOTT.P_PK) - 违反主键
所以选项D正确

QUESTION 35
Which two statements are true regarding constraints? (Choose two.)
A. A table can have only one primary key and one foreign key.
B. A table can have only one primary key but multiple foreign keys
C. Only the primary key can be defined at the column and table levels.
D. The foreign key and parent table primary key must have the same name
E. Both primary key and foreign key constraints can be defined at both column and table levels.
Correct Answer: BE
解析：
一个表中只能有一个主键约束，多个外键约束，除了非空约束不能定位表级约束，其他约都可以，外键只需数据类型一样，无需字段名一样
所以选项为BE

QUESTION 36
Examine the following SQL commands:
SQL>CREATE TABLE products (
prod_id NUMBER(3) CONSTRAINT p_ck CHECK (prod_id > 0),
prod_name CHAR(30),
prod_qty NUMBER(6),
CONSTRAINT p_name NOT NULL,
CONSTRAINT prod_pk PRIMARY KEY (prod_id));
SQL>CREATE TABLE warehouse (
warehouse_id NUMBER(4),
roomno NUMBER(10) CONSTRAINT r_id CHECK(roomno BETWEEN 101 AND 200),
location VARCHAR2(25),
prod_id NUMBER(3),
CONSTRAINT wr_pr_pk PRIMARY KEY (warehouse_id,prod_id),
CONSTRAINT prod_fk FOREIGN KEY (prod_id) REFERENCES products(prod_id));
Which statement is true regarding the execution of the above SQL commands?
Answer: B
A. Both commands execute successfully.
B. The first CREATE TABLE command generates an error because the NULL constraint is not valid.
C. The second CREATE TABLE command generates an error because the CHECK constraint is not valid.
D. The first CREATE TABLE command generates an error because CHECK and PRIMARY KEY
constraints cannot be used for the same column.
E. The first CREATE TABLE command generates an error because the column PROD_ID cannot be used
in the PRIMARY KEY and FOREIGN KEY constraints.
Correct Answer: B
解析：
非空约束不能作为表级约束，所以B选项正确

QUESTION 37
You issued the following command to drop the PRODUCTS table:
SQL> DROP TABLE products;
What is the implication of this command? (Choose all that apply.)
A. All data along with the table structure is deleted.
B. The pending transaction in the session is committed.
C. All indexes on the table will remain but they are invalidated.
D. All views and synonyms will remain but they are invalidated.
E. All data in the table are deleted but the table structure will remain.
Correct Answer: ABD
答案:ABD
解析:题目说的是删除语句有和影响
A:正确，数据和数据结构都会删除
B:正确，之前没有提交的事务都会提交，提交事务的语句ddl(比如：create,alter,drop,rename,truncate，dcl(grant,revoke)，tc(commit,rollback,savepoint除外）
C:错误，表上的索引将会被删除
D:正确，所有的视图和同义词将保持但是无效
E:错误，表中所有的数据被删除，表结构也会被删除
引用官方文档：
http://docs.oracle.com/cd/E11882_01/server.112/e41084/statements_9003.htm#SQLRF01806
当然oracle使用drop删除是数据和表结构一起删除，delete是只删除数据，当前和该表的事务也应当马上提交

QUESTION 38
Which two statements are true regarding views? (Choose two.)
A. A simple view in which column aliases have been used cannot be updated.
B. Rows cannot be deleted through a view if the view definition contains the DISTINCT keyword.
C. Rows added through a view are deleted from the table automatically when the view is dropped.
D. The OR REPLACE option is used to change the definition of an existing view without dropping and recreating
it.
E. The WITH CHECK OPTION constraint can be used in a view definition to restrict the columns
displayed through the view.
Correct Answer: BD
二、题目翻译
关于视图哪两个句子是正确的？（选择两个）
A. 一个简单的视图中使用别名的列不能被更新。
B. 如果视图定义时包含了DISTINCT关键字，不能通过视图删除行。
C. 当视图被删除时，通过视图添加的行从表中自动删除。
D. OR REPLACE选项用于改变一个已存在的视图的定义，而不需要删除后重建。
E. WITH CHECK OPTION用于限制通过视图显示的列。

三、题目解析
A选项不正确，只要是简单视图，使用别名的列是可以使用UPDATE命令更新的。
C选项不正确，视图被删除，不影响基表的数据。
E选项不正确，WITH CHECK OPTION用于限制通过视图更改基表的条件，禁止更改不包含在子查询条件里的行。

39. 
Evaluate the following command: 
CREATE TABLE employees
(employee_id      NUMBER(2) PRIMARY KEY, 
last_name        VARCHAR2(25) NOT NULL, 
department_id    NUMBER(2)NOT NULL, 
job_id           VARCHAR2(8), 
salary        NUMBER(10,2));
You issue the following command to create a view that displays the IDs and last names of the sales staff
in the organization:
CREATE OR REPLACE VIEW sales_staff_vu AS   
SELECT employee_id, last_name,job_id
FROM employees
WHERE job_id LIKE 'SA_%' 
WITH CHECK OPTION
Which two statements are true regarding the above view? (Choose two.)
A. It allows you to insert rows into the  EMPLOYEES table .
B. It allows you to delete details of the existing sales staff from the EMPLOYEES table.
C. It allows you to update job IDs of the existing sales staff to any other job ID in the EMPLOYEES table. 
D. It allows you to insert IDs, last names, and job IDs of the sales staff from the view if it is used in multitable INSERT statements.
Answer: BD
答案解析：
如果硬要选两个，我觉得应该是BC

SQL> drop table employees;

Table dropped.

SQL> CREATE TABLE employees
  2  (employee_id NUMBER(6) PRIMARY KEY,
  3  last_name VARCHAR2(25) NOT NULL,
  4  department_id NUMBER(4)NOT NULL,
  5  job_id VARCHAR2(10),
  6  salary NUMBER(10,2));

Table created.
SQL> CREATE OR REPLACE VIEW sales_staff_vu AS   
  2  SELECT employee_id, last_name,job_id
  3  FROM employees
  4  WHERE job_id LIKE 'SA_%' 
  5  WITH CHECK OPTION;

View created.
SQL> insert into employees select EMPLOYEE_ID,LAST_NAME,DEPARTMENT_ID,JOB_ID,SALARY from hr.employees
where job_id like 'SA_%' and rownum<6;
SQL>  select * from employees;

EMPLOYEE_ID LAST_NAME                 DEPARTMENT_ID JOB_ID         SALARY
----------- ------------------------- ------------- ---------- ----------
        145 Russell                              80 SA_MAN          14000
        146 Partners                             80 SA_MAN          13500
        147 Errazuriz                            80 SA_MAN          12000
        148 Cambrault                            80 SA_MAN          11000
        149 Zlotkey                              80 SA_MAN          10500
SQL>  select * from sales_staff_vu;

EMPLOYEE_ID LAST_NAME                 JOB_ID
----------- ------------------------- ----------
        145 Russell                   SA_MAN
        146 Partners                  SA_MAN
        147 Errazuriz                 SA_MAN
        148 Cambrault                 SA_MAN
        149 Zlotkey                   SA_MAN
SQL> insert into sales_staff_vu values (501,'lihua','SA_MAN');
insert into sales_staff_vu values (501,'lihua','SA_MAN')
*
ERROR at line 1:
ORA-01400: cannot insert NULL into ("SYS"."EMPLOYEES"."DEPARTMENT_ID")
 A答案：A答案错误，DEPARTMENT_ID为非空，不能插入null值。
SQL> delete from sales_staff_vu where EMPLOYEE_ID=145;

1 row deleted.
B答案：正确，可以删除

SQL> update sales_staff_vu set JOB_ID='MK_REP' where EMPLOYEE_ID=146;
update sales_staff_vu set JOB_ID='MK_REP' where EMPLOYEE_ID=146
       *
ERROR at line 1:
ORA-01402: view WITH CHECK OPTION where-clause violation


SQL> update sales_staff_vu set JOB_ID='SA_REP' where EMPLOYEE_ID=146;

1 row updated.
C答案：可以将job_id更新为SA_开头的，不能更新为其他不是SA_开头的。
SQL> insert into sales_staff_vu 
   select EMPLOYEE_ID,LAST_NAME,JOB_ID from employees
   where job_id like 'SA_%';
insert into sales_staff_vu
*
ERROR at line 1:
ORA-01400: cannot insert NULL into ("SYS"."EMPLOYEES"."DEPARTMENT_ID")
D答案：multitable INSERT不能插入非空
SQL> create or replace view sales_staff_vu_new as
 select employee_id,last_name,job_id,department_id from employees
where job_id like 'SA_%'
 with check option
  5   /

View created.
SQL>  insert into sales_staff_vu_new
  select EMPLOYEE_ID,LAST_NAME,JOB_ID,DEPARTMENT_ID from hr.employees where job_id like 'SA_%'
  and EMPLOYEE_ID in (150,151);


2 rows created.
SQL> select * from sales_staff_vu_new;

EMPLOYEE_ID LAST_NAME                 JOB_ID     DEPARTMENT_ID
----------- ------------------------- ---------- -------------
        146 Partners                  SA_REP                80
        147 Errazuriz                 SA_MAN                80
        148 Cambrault                 SA_MAN                80
        149 Zlotkey                   SA_MAN                80
        150 Tucker                    SA_REP                80
        151 Bernstein                 SA_REP                80

6 rows selected.

QUESTION 40
View the Exhibit to examine the description for the SALES and PRODUCTS tables.
You want to create a SALE_PROD view by executing the following SQL statement:
CREATE VIEW sale_prod
AS SELECT p.prod_id, cust_id, SUM(quantity_sold) "Quantity" , SUM(prod_list_price) "Price"
FROM products p, sales s
WHERE p.prod_id=s.prod_id
GROUP BY p.prod_id, cust_id;
Which statement is true regarding the execution of the above statement?
A. The view will be created and you can perform DML operations on the view.
B. The view will be created but no DML operations will be allowed on the view.
C. The view will not be created because the join statements are not allowed for creating a view.
D. The view will not be created because the GROUP BY clause is not allowed for creating a view.
Correct Answer: B


答案解析：
A错误，此视图为复杂视图，带有group by子句，不能对视图进行DML操作，
B正确，可以创建成功，但不能进行DML操作。
SQL> select count(*) from sh.products;

  COUNT(*)
----------
        72
SQL> select count(*) from sh.sales;

  COUNT(*)
----------
    918843
SQL> CREATE OR REPLACE VIEW sale_prod
AS SELECT p.prod_id, cust_id, SUM(quantity_sold) "Quantity" , SUM(prod_list_price) "Price"
FROM sh.products p, sh.sales s
  4  WHERE p.prod_id=s.prod_id
  5  GROUP BY p.prod_id, cust_id;

View created.
SQL> select * from sale_prod where rownum<5;

   PROD_ID    CUST_ID   Quantity      Price
---------- ---------- ---------- ----------
        13          2          4    3599.96
        13          9          5    4499.95
        13         11          1     899.99
        13         23          1     899.99
 
View created.
C错误，可以通过join来连接两张表创建视图。
D错误，可以通过group by 子句来创建视图。

QUESTION 41
Which two statements are true regarding views? (Choose two.)
A. A subquery that defines a view cannot include the GROUP BY clause.
B. A view that is created with the subquery having the DISTINCT keyword can be updated.
C. A view that is created with the subquery having the pseudo column ROWNUM keyword cannot be
updated.
D. A data manipulation language ( DML) operation can be performed on a view that is created with the
subquery having all the NOT NULL columns of a table.
Correct Answer: CD
答案解析：
参考：http://blog.csdn.net/rlhua/article/details/12790467
A错误，创建视图的子查询可以使用group by子句。
B错误，子查询中带有DISTINCT 不能对视图进行DML操作。
C正确，子查询中带有ROWNUM 关键字不能对视图进行DML操作。
D正确，所有非空列都可以进行DML操作。

QUESTION 42
Which three statements are true regarding views? (Choose three.)
A. Views can be created only from tables.
B. Views can be created from tables or other views.
C. Only simple views can use indexes existing on the underlying tables.
D. Both simple and complex views can use indexes existing on the underlying tables.
E. Complex views can be created only on multiple tables that exist in the same schema.
F. Complex views can be created on multiple tables that exist in the same or different schemas.
Correct Answer: BDF
答案解析：
参考：http://blog.csdn.net/rlhua/article/details/12790467
A错误，视图是一种基于表或其它视图的逻辑表。
B正确，视图是一种基于表或其它视图的逻辑表。
C错误，简单视图和复杂视图都能使用相关表的索引。
D正确，同C.
E错误，可以是不同schema间。
F正确，复杂视图的子查询可以是相同或者不同的schema间的多张表。

QUESTION 43
Evaluate the following CREATE SEQUENCE statement:
CREATE SEQUENCE seq1
START WITH 100
INCREMENT BY 10
MAXVALUE 200
CYCLE
NOCACHE;
The SEQ1 sequence has generated numbers up to the maximum limit of 200. You issue the following
SQL statement:
SELECT seq1.nextval FROM dual;
What is displayed by the SELECT statement?
A. 1
B. 10
C. 100
D. an error
Correct Answer: A
解析：
指定cycle选项后，如果达到了该序列的最大值（maxvalue)，则会从它的最小值（minvalue)开始，产生下一个值。
注意，不是从start with开始。如果没指定minvalues，则相当于指定nominvalue选项，则minvalue的值为1。
SQL> CREATE SEQUENCE seq1
START WITH 100
INCREMENT BY 10
MAXVALUE 200
CYCLE
NOCACHE;
SQL> SELECT seq1.nextval FROM dual;

   NEXTVAL
----------
       100

SQL> /

   NEXTVAL
----------
       110

SQL> /

   NEXTVAL
----------
       120

SQL> /

   NEXTVAL
----------
       130

SQL> /

   NEXTVAL
----------
       140

SQL> /

   NEXTVAL
----------
       150

SQL> /

   NEXTVAL
----------
       160

SQL> /

   NEXTVAL
----------
       170

SQL> /

   NEXTVAL
----------
       180

SQL> /

   NEXTVAL
----------
       190

SQL> /

   NEXTVAL
----------
       200

SQL> /

   NEXTVAL
----------
         1

SQL> /

   NEXTVAL
----------
        11

SQL> /

   NEXTVAL
----------
        21

SQL> /

   NEXTVAL
----------
        31
如果指定了minvalue
SQL> drop sequence seq1;

Sequence dropped.

SQL> CREATE SEQUENCE seq1
  2  START WITH 100
  3  INCREMENT BY 10
  4  MAXVALUE 200  MINVALUE 15
  5  CYCLE  
  6  NOCACHE;

Sequence created.

SQL> select seq1.nextval from dual;

   NEXTVAL
----------
       100

SQL> /

   NEXTVAL
----------
       110

SQL> //

   NEXTVAL
----------
       120

SQL> /

   NEXTVAL
----------
       130

SQL> /

   NEXTVAL
----------
       140

SQL> /

   NEXTVAL
----------
       150

SQL> /

   NEXTVAL
----------
       160

SQL> /

   NEXTVAL
----------
       170

SQL> /

   NEXTVAL
----------
       180

SQL> /

   NEXTVAL
----------
       190

SQL> /

   NEXTVAL
----------
       200

SQL> /

   NEXTVAL
----------
        15

SQL> /

   NEXTVAL
----------
        25

SQL> /

   NEXTVAL
----------
        35


QUESTION 44
View the Exhibit and examine the structure of the ORD table.
Evaluate the following SQL statements that are executed in a user session in the specified order:
CREATE SEQUENCE ord_seq;
SELECT ord_seq.nextval
FROM dual;
INSERT INTO ord
VALUES (ord_seq.CURRVAL, '25-jan-2007',101);
UPDATE ord
SET ord_no= ord_seq.NEXTVAL
WHERE cust_id =101;
What would be the outcome of the above statements?
A. All the statements would execute successfully and the ORD_NO column would contain the value 2 for
the CUST_ID 101.
B. The CREATE SEQUENCE command would not execute because the minimum value and maximum
value for the sequence have not been specified.
C. The CREATE SEQUENCE command would not execute because the starting value of the sequence
and the increment value have not been specified.
D. All the statements would execute successfully and the ORD_NO column would have the value 20 for
the CUST_ID 101 because the default CACHE value is 20.
Correct Answer: A
验证：
SQL> create table ord (ord_no number(2) not null, ord_date date,cust_id number(4));

Table created.

SQL> create sequence ord_seq;

Sequence created.

SQL> select ord_seq.nextval from dual;

   NEXTVAL
----------
         1

SQL> insert into ord values(ord_seq.currval,'25-jan-2017',101);

1 row created.

SQL> update ord set ord_no=ord_seq.nextval where cust_id=101;

1 row updated.

SQL> select * from ord;

    ORD_NO ORD_DATE     CUST_ID
---------- --------- ----------
         2 25-JAN-17        101

QUESTION 45
Which two statements are true about sequences created in a single instance database? (Choose two.)
A. The numbers generated by a sequence can be used only for one table.
B. DELETE <sequencename> would remove a sequence from the database.
C. CURRVAL is used to refer to the last sequence number that has been generated.
D. When the MAXVALUE limit for a sequence is reached, you can increase the MAXVALUE limit by using
the ALTER SEQUENCE statement.
E. When a database instance shuts down abnormally, the sequence numbers that have been cached but
not used would be available once again when the database instance is restarted.
Correct Answer: CD
二、题目翻译
在单实例数据库中关于创建序列哪两句话是正确的？（选择两个）
A. 一个序列生成的值只能用于一个表。
B. DELETE <sequencename>可以从数据库里移除一个序列。
C. CURRVAL是指生成的最后的序列值。
D. 当达到序列的MAXVALUE限制时，你可以使用ALTER SEQUENCE语句增加MAXVALUE。
E. 当数据库实例非正常关闭，已经缓存到内存里但是没有被使用的序列数当实例再次打开后可以再次使用。

三、题目解析
A选项不正确，因为一个序列生成的值可以用于多个表。
B选项不正确，因为删除序列要用 DROP SEQUENCE sequencename。
E选项不正确，因为如果内存非正常关闭，缓存的数会丢失，不能再继续使用了。

QUESTION 46
Which statements are correct regarding indexes? (Choose all that apply.)
A. When a table is dropped, the corresponding indexes are automatically dropped.
B. A FOREIGN KEY constraint on a column in a table automatically creates a nonunique index.
C. A nondeferrable PRIMARY KEY or UNIQUE KEY constraint in a table automatically creates a unique
index.
D. For each data manipulation language (DML) operation performed, the corresponding indexes are
automatically updated.
Correct Answer: ACD
二、题目翻译
关于索引哪句话是正确的？（选择所有正确的项）
A. 当表被删除后，对应的索引也自动删除。
B. 表中列上的外键约束自动创始一个非唯一索引。
C. 表中的非延迟PRIMARY KEY或者UNIQUE KEY约束自动创建一个唯一索引。
D. 对于执行的每一个DML操作，对应的索引也自动更新。
三、题目解析
PRIMARY KEY和UNIQUE KEY约束自动创建一个唯一索引，而FOREIGN KEY和NOT NULL、CHECK约束都不会自动创建索引。

QUESTION 47
View the Exhibit and examine the structure of ORD and ORD_ITEMS tables.
The ORD_NO column is PRIMARY KEY in the ORD table and the ORD_NO and ITEM_NO columns are
composite PRIMARY KEY in the ORD_ITEMS table.
Which two CREATE INDEX statements are valid? (Choose two.)
A. CREATE INDEX ord_idx1
ON ord(ord_no);
B. CREATE INDEX ord_idx2
ON ord_items(ord_no);
C. CREATE INDEX ord_idx3
ON ord_items(item_no);
D. CREATE INDEX ord_idx4
ON ord,ord_items(ord_no, ord_date,qty);
Correct Answer: BC
二、题目翻译
看下面ORD和ORD_ITEMS表的结构，
ORD 表中ORD_NO列是PRIMARY KEY，ORD_ITEMS表中ORD_NO and ITEM_NO是组合PRIMARY KEY。
哪两个CREATE INDEX语句是有效的？（选择两个）
三、题目解析
A选项不正确，因为ORD 表中ORD_NO列是PRIMARY KEY，已经自动创建索引，不能再创建。
B、C选项正确，虽然这两列已经是组合索引，但是可以在两个列中分别再建立索引
D选项，语法不正确

SQL> drop table ord;

Table dropped.

SQL> create table ord(ord_no number(2) not null primary key,
  2  ord_date date,
  3  cust_id number(4));

Table created.

SQL> create table ord_items(ord_no number(2) not null,
  2  item_no number(3) not null,
  3  qty number(8,2));

Table created.

SQL> alter table ord_items add constraint pk_ord_item_no primary key(ord_no,item_no);

Table altered.

SQL> CREATE INDEX ord_idx1
  2  ON ord(ord_no);
ON ord(ord_no)
       *
ERROR at line 2:
ORA-01408: such column list already indexed


SQL>  CREATE INDEX ord_idx2
  2  ON ord_items(ord_no);

Index created.

SQL> CREATE INDEX ord_idx3
  2  ON ord_items(item_no);

Index created.

SQL> CREATE INDEX ord_idx4
  2  ON ord,ord_items(ord_no, ord_date,qty);
ON ord,ord_items(ord_no, ord_date,qty)
      *
ERROR at line 2:
ORA-00906: missing left parenthesis

QUESTION 48
Which two statements are true regarding indexes? (Choose two.)
A. They can be created on tables and clusters
B. They can be created on tables and simple views
C. You can create only one index by using the same columns.
D. You can create more than one index by using the same columns if you specify distinctly different
combinations of the columns.
Correct Answer: AD
二、题目翻译
关于索引哪两个句子是正确的？（选择两个）
A. 可以在表(tables)和簇（clusters）上建立索引
B. 可以在表和简单视图上创建索引
C. 同一个列只能创建一个索引
D. 如果你指定了不同列组合，可以使用相同的列创建多个索引
三、题目解析
B不正确因为简单视图上不能创建索引
C选项不正确，D选项正确

C、D可以参考11g的联机文档的INDEX部分：
http://docs.oracle.com/cd/E11882_01/server.112/e40540/indexiot.htm#CNCPT88833

摘录如下:
You can create multiple indexes using the same columns if you specify distinctly different permutations of the columns. For example, the following SQL statements specify valid permutations:
相同列上可以创建多个索引，如果指定了不同列组合，下面的例子就是有效的：
CREATE INDEX employee_idx1 ON employees (last_name, job_id);
CREATE INDEX employee_idx2 ON employees (job_id, last_name);

multiple
英 ['mʌltɪpl]  美 ['mʌltəpl]
n. 倍数；[电] 并联
adj. 多重的；多样的；许多的
permutation
英 [pɜːmjʊ'teɪʃ(ə)n]  美 ['pɝmjʊ'teʃən]
n. [数] 排列；[数] 置换

QUESTION 49
The ORDERS table belongs to the user OE. OE has granted the SELECT privilege on the ORDERS
table to the user HR.
Which statement would create a synonym ORD so that HR can execute the following query successfully?
SELECT * FROM ord;
A. CREATE SYNONYM ord FOR orders; This command is issued by OE.
B. CREATE PUBLIC SYNONYM ord FOR orders; This command is issued by OE.
C. CREATE SYNONYM ord FOR oe.orders; This command is issued by the database administrator.
D. CREATE PUBLIC SYNONYM ord FOR oe.orders; This command is issued by the database administrator.
二、题目翻译
ORDERS表属于OE用户.OE把ORDERS表的SELECT权限授予HR用户。
下面哪个语句创建了一个ORD同义词，以便HR能成功执行下面这个查询？
三、题目解析
A和C选项，都不正确，因为都创建了一个私有同义词，其它用户不能访问。
B选项，描述不完整，因为题中没有提到OE用户有CREATE PUBLIC SYNONYM的权限，如果有，就是正确的，如果没有则提示权限不足不能建立。
SQL> show user
USER is "SYS"
SQL> grant select on hr.employees to scott;

Grant succeeded.
SQL> alter user scott identified by oracle account unlock;

User altered.
SQL> alter user hr identified by oracle account unlock;

User altered.
SQL> conn hr/oracle
Connected.
SQL> create synonym emp1 for hr.employees;

Synonym created.

SQL> conn scott/oracle
Connected.
SQL> select * from emp1;--创建私有的同义词scott用户不能访问
select * from emp1
              *
ERROR at line 1:
ORA-00942: table or view does not exist
SQL> conn hr/oracle
Connected.
SQL> create public synonym emp1 for hr.employees; --创建共有的同义词hr没有权限
create public synonym emp1 for hr.employees
*
ERROR at line 1:
ORA-01031: insufficient privileges
SQL> conn / as sysdba
Connected.
SQL> create public synonym emp1 for hr.employees;

Synonym created.

SQL> conn scott/oracle
Connected.
SQL> select count(*) from emp1;

  COUNT(*)
----------
       107
	   
QUESTION 50
SLS is a private synonym for the SH.SALES table.
The user SH issues the following command:
DROP SYNONYM sls;
Which statement is true regarding the above SQL statement?
A. Only the synonym would be dropped.
B. The synonym would be dropped and the corresponding table would become invalid.
C. The synonym would be dropped and the packages referring to the synonym would be dropped.
D. The synonym would be dropped and any PUBLIC synonym with the same name becomes invalid.
Correct Answer: A
二、题目翻译
SLS是SH.SALES表的私有同义词。
SH用户执行下面的命令：
关于上面的语句哪句话是正确的？
A. 只删除同义词。
B. 同义词被删除，并且对应的表也变的无效。
C. 同义词被删除，并且关联同义词的包也被删除。
D. 同义词被删除，并且同名的公共同义词也变的无效。
SQL> conn hr/oracle
Connected.
SQL> drop synonym emp1;

Synonym dropped.

SQL> select count(*) from hr.employees;　--删除同义词表仍然可访问

  COUNT(*)
----------
       107

SQL> conn scott/oracle
Connected.
SQL> select count(*) from emp1;--删除同义词，同名的公共同义词仍然可访问

  COUNT(*)
----------
       107

QUESTION 51
Which statement is true regarding synonyms?
A. Synonyms can be created only for a table.
B. Synonyms are used to reference only those tables that are owned by another user.
C. A public synonym and a private synonym can exist with the same name for the same table.
D. The DROP SYNONYM statement removes the synonym, and the table on which the synonym has
been created becomes invalid.
Correct Answer: C
二、题目翻译
关于同义词，下面哪句话是正确的？
A. 只能为表建立同义词。
B. 同义词只能用来关联那些属于另一个用户的表。
C. 对同一个表可以存在同名的public synonym和private synonym。
D. DROP SYNONYM语句移除同义词，并且创建同义词的表也变的无效。
三、题目解析
A选项不正确, 因为同义词是一个schema object的别名，例如可以为table、view、sequence 或者another synonym等等建立同义词。
B选项不正确，当前自己用户的表，也可以建同义词。
D选项不正确，DROP SYNONYM仅仅只删除了同义词，不影响相关的表。

QUESTION 52
View the Exhibit and examine the structure of the PRODUCTS table.
Using the PRODUCTS table, you issue the following query to generate the names, current list price,
and discounted list price for all those products whose list price falls below $10 after a discount of 25% is
applied on it.
SQL>SELECT prod_name, prod_list_price,
prod_list_price - (prod_list_price * .25) "DISCOUNTED_PRICE"
FROM products
WHERE discounted_price < 10;
The query generates an error.
What is the reason for the error?
A. The parenthesis should be added to enclose the entire expression.
B. The double quotation marks should be removed from the column alias.
C. The column alias should be replaced with the expression in the WHERE clause.
D. The column alias should be put in uppercase and enclosed with in double quotation marks in the
WHERE clause.
Correct Answer: C
二、题目翻译
下面是PRODUCTS表的结构:
使用PRODUCTS表，执行下面的查询来获取当产品打折25%之后价格低于$10的产品的名称，当前价格，打折后的价格。
查询会报错，错误的原因是什么？
A. 括号应该把整个表达式都括起来。
B. 双引号应该从列别名中移除。
C. WHERE子句中的列别名应该使用表达式替换。
D. WHERE子句中的列别名应该大写并且使用双引号引起来。
三、题目解析
WHERE子句中不能使用列别名，所以要用表达式替换掉。

QUESTION 53
View the Exhibit and examine the data in the PROMOTIONS table.
PROMO_BEGIN_DATE is stored in the default date format, dd-mon-rr.
You need to produce a report that provides the name, cost, and start date of all promos in the POST
category that were launched before January 1, 2000.
Which SQL statement would you use?
A. SELECT promo_name, promo_cost, promo_begin_date
FROM promotions
WHERE promo_category = 'post' AND promo_begin_date < '01-01-00';
B. SELECT promo_name, promo_cost, promo_begin_date
FROM promotions
WHERE promo_cost LIKE 'post%' AND promo_begin_date < '01-01-2000';
C. SELECT promo_name, promo_cost, promo_begin_date
FROM promotions
WHERE promo_category LIKE 'P%' AND promo_begin_date < '1-JANUARY-00';
D. SELECT promo_name, promo_cost, promo_begin_date
FROM promotions
WHERE promo_category LIKE '%post%' AND promo_begin_date < '1-JAN-00';
Correct Answer: D
二、题目翻译
检查PROMOTIONS表的数据
PROMO_BEGIN_DATE列使用默认日期格式dd-mon-rr存储.
要生成一个报表，显示所有2000年1月1日之前的、促销种类为POST的promos的名称，成本和开始日期，
应该使用哪个SQL语句？
三、题目解析
A和B选项都不正确，promo_begin_date条件格式不对。
C选项不正确，promo_category 条件不对。
SQL>  SELECT promo_name, promo_cost, promo_begin_date
  2  FROM sh.promotions
  3  WHERE promo_category LIKE '%post%' AND promo_begin_date < '1-JAN-00' and rownum<5;

PROMO_NAME                     PROMO_COST PROMO_BEG
------------------------------ ---------- ---------
post promotion #20-232                300 25-SEP-98
post promotion #21-166               2000 25-SEP-98
post promotion #20-449               4200 10-NOV-98
post promotion #20-407               6100 16-APR-99

QUESTION 54
View the Exhibit and examine the structure of the CUSTOMERS table.
Evaluate the query statement:
SQL> SELECT cust_last_name, cust_city, cust_credit_limit
FROM customers
WHERE cust_last_name BETWEEN 'A' AND 'C' AND cust_credit_limit BETWEEN
1000 AND 3000;
What would be the outcome of the above statement?
A. It executes successfully.
B. It produces an error because the condition on CUST_LAST_NAME is invalid.
C. It executes successfully only if the CUST_CREDIT_LIMIT column does not contain any null values.
D. It produces an error because the AND operator cannot be used to combine multiple BETWEEN
clauses.
Correct Answer: A
二、题目翻译
查看CUSTOMERS表结构，下面的查询语句的结果是什么？
A. 上面的语句执行成功。
B. 报错，因为CUST_LAST_NAME的条件是无效的。
C. 如果CUST_CREDIT_LIMIT列没有包含任何null值就可以执行成功。
D. 报错，因为AND操作符不能联合多个BETWEEN子句。
SQL> desc sh.customers
 Name                                      Null?    Type
 ----------------------------------------- -------- ----------------------------
 CUST_ID                                   NOT NULL NUMBER
 CUST_FIRST_NAME                           NOT NULL VARCHAR2(20)
 CUST_LAST_NAME                            NOT NULL VARCHAR2(40)
 CUST_GENDER                               NOT NULL CHAR(1)
 CUST_YEAR_OF_BIRTH                        NOT NULL NUMBER(4)
 CUST_MARITAL_STATUS                                VARCHAR2(20)
 CUST_STREET_ADDRESS                       NOT NULL VARCHAR2(40)
 CUST_POSTAL_CODE                          NOT NULL VARCHAR2(10)
 CUST_CITY                                 NOT NULL VARCHAR2(30)
 CUST_CITY_ID                              NOT NULL NUMBER
 CUST_STATE_PROVINCE                       NOT NULL VARCHAR2(40)
 CUST_STATE_PROVINCE_ID                    NOT NULL NUMBER
 COUNTRY_ID                                NOT NULL NUMBER
 CUST_MAIN_PHONE_NUMBER                    NOT NULL VARCHAR2(25)
 CUST_INCOME_LEVEL                                  VARCHAR2(30)
 CUST_CREDIT_LIMIT                                  NUMBER
 CUST_EMAIL                                         VARCHAR2(30)
 CUST_TOTAL                                NOT NULL VARCHAR2(14)
 CUST_TOTAL_ID                             NOT NULL NUMBER
 CUST_SRC_ID                                        NUMBER
 CUST_EFF_FROM                                      DATE
 CUST_EFF_TO                                        DATE
 CUST_VALID                                         VARCHAR2(1)
SQL> set linesize 200
SQL> SELECT cust_last_name, cust_city, cust_credit_limit
  2  FROM sh.customers
WHERE cust_last_name BETWEEN 'A' AND 'C' AND cust_credit_limit BETWEEN
  4  1000 AND 3000 and rownum<5;

CUST_LAST_NAME                           CUST_CITY                      CUST_CREDIT_LIMIT
---------------------------------------- ------------------------------ -----------------
Aaron                                    Pune                                        1500
Aaron                                    Diss                                        3000
Aaron                                    Hoofddorp                                   1500
Aaron                                    Stockport                                   3000

QUESTION 55
Evaluate the following two queries:
SQL> SELECT cust_last_name, cust_city
FROM customers
WHERE cust_credit_limit IN (1000, 2000, 3000);
SQL> SELECT cust_last_name, cust_city
FROM customers
WHERE cust_credit_limit = 1000 OR cust_credit_limit = 2000 OR
cust_credit_limit = 3000;
Which statement is true regarding the above two queries?
A. Performance would improve in query 2.
B. Performance would degrade in query 2.
C. There would be no change in performance.
D. Performance would improve in query 2 only if there are null values in the CUST_CREDIT_LIMIT
column.
Correct Answer: C
二、题目翻译
评估下面的两个查询：
关于上面的两条语句哪一个是正确的？
A. 查询2的性能比较高。
B. 查询2的性能比较低。
C. 性能没有变化。
D. 只要CUST_CREDIT_LIMIT列中有空值，则查询2的性能比较高。
三、题目解析
语句1的这种in条件，在oracle执行的时候，也会转成or的形式来执行，所以性能上没什么不同，是一样的。

SQL> show user
USER is "SYS"
SQL> alter user sh identified by oracle account unlock;

User altered.

SQL> conn sh/oracle
Connected.
SQL> desc customers
SQL> set autotrace traceonly
SELECT cust_last_name, cust_city
FROM customers
  3  WHERE cust_credit_limit IN (1000, 2000, 3000);

7975 rows selected.


Execution Plan
----------------------------------------------------------
Plan hash value: 2008213504

-------------------------------------------------------------------------------
| Id  | Operation         | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |           | 20556 |   441K|   407   (1)| 00:00:05 |
|*  1 |  TABLE ACCESS FULL| CUSTOMERS | 20556 |   441K|   407   (1)| 00:00:05 |
-------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("CUST_CREDIT_LIMIT"=1000 OR "CUST_CREDIT_LIMIT"=2000 OR
              "CUST_CREDIT_LIMIT"=3000)


Statistics
----------------------------------------------------------
          1  recursive calls
          0  db block gets
       1978  consistent gets
          0  physical reads
          0  redo size
     204095  bytes sent via SQL*Net to client
       6260  bytes received via SQL*Net from client
        533  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
       7975  rows processed
SQL> SELECT cust_last_name, cust_city
  2  FROM customers
  3  WHERE cust_credit_limit = 1000 OR cust_credit_limit = 2000 OR
  4  cust_credit_limit = 3000;

7975 rows selected.


Execution Plan
----------------------------------------------------------
Plan hash value: 2008213504

-------------------------------------------------------------------------------
| Id  | Operation         | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |           | 20556 |   441K|   407   (1)| 00:00:05 |
|*  1 |  TABLE ACCESS FULL| CUSTOMERS | 20556 |   441K|   407   (1)| 00:00:05 |
-------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("CUST_CREDIT_LIMIT"=1000 OR "CUST_CREDIT_LIMIT"=2000 OR
              "CUST_CREDIT_LIMIT"=3000)


Statistics
----------------------------------------------------------
          1  recursive calls
          0  db block gets
       1978  consistent gets
          0  physical reads
          0  redo size
     204095  bytes sent via SQL*Net to client
       6260  bytes received via SQL*Net from client
        533  SQL*Net roundtrips to/from client
          0  sorts (memory)
          0  sorts (disk)
       7975  rows processed
可以看到两条sql的Cost (%CPU)都一样，性能并没有提升
