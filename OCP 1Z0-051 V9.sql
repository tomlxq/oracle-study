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