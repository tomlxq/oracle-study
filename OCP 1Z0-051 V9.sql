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

QUESTION 56
View the Exhibit and examine the structure of the PROMOTIONS table.
Using the PROMOTIONS table, you need to find out the names and cost of all the promos done on 'TV'
and 'internet' that ended in the time interval 15th March '00 to 15th October '00.
Which two queries would give the required result? (Choose two.)
A. A. SELECT promo_name, promo_cost
FROM promotions
WHERE promo_category IN ('TV', 'internet') AND
promo_end_date BETWEEN '15-MAR-00' AND '15-OCT-00';
B. SELECT promo_name, promo_cost
FROM promotions
WHERE promo_category = 'TV' OR promo_category ='internet' AND
promo_end_date >='15-MAR-00' OR promo_end_date <='15-OCT-00';
C. SELECT promo_name, promo_cost
FROM promotions
WHERE (promo_category BETWEEN 'TV' AND 'internet') AND
(promo_end_date IN ('15-MAR-00','15-OCT-00'));
D. SELECT promo_name, promo_cost
FROM promotions
WHERE (promo_category = 'TV' OR promo_category ='internet') AND
(promo_end_date >='15-MAR-00' AND promo_end_date <='15-OCT-00');
Correct Answer: AD
二、题目翻译
查看PROMOTIONS表的结构。
使用PROMOTIONS表，现在要找出所有在15th March 00到15th October 00这一段时间内结束促销，促销类型为'TV'和'internet'的促销产品的名称和成本。
哪两个查询语句查出的是我们需要的结果？（选择两个）
三、题目解析
B选项不正确，因为AND比OR的优先级要高，所以最后的结果会不正确。
C选项不正确，因为promo_end_date IN ('15-MAR-00','15-OCT-00')不是一个时间段，而只是两个时间点。


SQL> SELECT promo_name, promo_cost
  2  FROM sh.promotions
  3  WHERE promo_category IN ('TV', 'internet') AND
  4  promo_end_date BETWEEN '15-MAR-00' AND '15-OCT-00' and rownum<5;

PROMO_NAME                     PROMO_COST
------------------------------ ----------
internet promotion #14-471            600
TV promotion #13-448                 1100
TV promotion #12-49                  1500
TV promotion #13-224                 5200

SQL> SELECT promo_name, promo_cost
  2  FROM sh.promotions
  3  WHERE (promo_category = 'TV' OR promo_category ='internet') AND
  4  (promo_end_date >='15-MAR-00' AND promo_end_date <='15-OCT-00') and rownum<5;

PROMO_NAME                     PROMO_COST
------------------------------ ----------
internet promotion #14-471            600
TV promotion #13-448                 1100
TV promotion #12-49                  1500
TV promotion #13-224                 5200

QUESTION 57
The CUSTOMERS table has the following structure:
name Null Type
CUST_ID NOT NULL NUMBER
CUST_FIRST_NAME NOT NULL VARCHAR2(20)
CUST_LAST_NAME NOT NULL VARCHAR2(30)
CUST_INCOME_LEVEL VARCHAR2(30)
CUST_CREDIT_LIMIT NUMBER
You need to write a query that does the following tasks:
1. Display the first name and tax amount of the customers. Tax is 5% of their credit limit.
2. Only those customers whose income level has a value should be considered.
3. Customers whose tax amount is null should not be considered.
Which statement accomplishes all the required tasks?
A. SELECT cust_first_name, cust_credit_limit * .05 AS TAX_AMOUNT
FROM customers
WHERE cust_income_level IS NOT NULL AND
tax_amount IS NOT NULL;
B. SELECT cust_first_name, cust_credit_limit * .05 AS TAX_AMOUNT
FROM customers
WHERE cust_income_level IS NOT NULL AND
cust_credit_limit IS NOT NULL;
C. SELECT cust_first_name, cust_credit_limit * .05 AS TAX_AMOUNT
FROM customers
WHERE cust_income_level <> NULL AND
tax_amount <> NULL;
D. SELECT cust_first_name, cust_credit_limit * .05 AS TAX_AMOUNT
FROM customers
WHERE (cust_income_level,tax_amount) IS NOT NULL;
Correct Answer: B
二、题目翻译
CUSTOMERS表结构如下：
现在要写一个查询完成下面的任务:
1.显示客户的first name和tax amount，Tax是credit limit的5%。
2.只考虑income level有值的客户。
3.不考虑tax amount为空的客户。
下面哪个语句能完成所需任务？
三、题目解析
A选项不正确，因为列别名不能用于WHERE子句
C选项不正确，因为WHERE子句不能使用别名，而且如果使用<>不等于操作符与NULL运算条件永远为假，所以，判断是否为null，不能使用<>，而应该用is not null。
D选项的语法不正确。

SQL> SELECT cust_first_name, cust_credit_limit * .05 AS TAX_AMOUNT
  2  FROM sh.customers
  3  WHERE cust_income_level IS NOT NULL AND
  4  cust_credit_limit IS NOT NULL and rownum<5;

CUST_FIRST_NAME      TAX_AMOUNT
-------------------- ----------
Abigail                      75
Abigail                     350
Abigail                     550
Abigail                      75

QUESTION 58
The PART_CODE column in the SPARES table contains the following list of values:
PART_CODE
A%_WQ123
A%BWQ123
AB_WQ123
Evaluate the following query:
SQL> SELECT part_code
FROM spares
WHERE part_code LIKE '%\%_WQ12%' ESCAPE '\';
Which statement is true regarding the outcome of the above query?
A. It produces an error.
B. It displays all values.
C. It displays only the values A%_WQ123 and AB_WQ123 .
D. It displays only the values A%_WQ123 and A%BWQ123 .
E. It displays only the values A%BWQ123 and AB_WQ123.
Correct Answer: D
二、题目翻译
SPARES表的PART_CODE列包含下面的值：
下面的这个查询:
关于上面查询的结果哪句话是正确的？
A. 会报错。
B. 显示所有的结果。
C. 仅显示A%_WQ123 and AB_WQ123。
D. 仅显示A%_WQ123 and A%BWQ123。
E. 仅显示A%BWQ123 and AB_WQ123。
三、题目解析
因为LIKE '%\%_WQ12%' ESCAPE '\'里的\为转译字符，把第二个%转义，而_下划线没有转义，代表一个字符，所以答案为D
SQL> create table spares (part_code varchar2(30));

Table created.

SQL> insert into spares values('AB_WQ123');

1 row created.

SQL> insert into spares values('A%BWQ123');

1 row created.

SQL> insert into spares values('A%_WQ123');

1 row created.

SQL> SELECT part_code
  2  FROM spares
  3  WHERE part_code LIKE '%\%_WQ12%' ESCAPE '\';

PART_CODE
------------------------------
A%BWQ123
A%_WQ123

QUESTION 59
View the Exhibit and examine the data in the PRODUCTS table.
You need to display product names from the PRODUCTS table that belong to the 'Software/Other '
category with minimum prices as either $2000 or $4000 and no unit of measure.
You issue the following query:
SQL>SELECT prod_name, prod_category, prod_min_price
FROM products
WHERE prod_category LIKE '%Other%' AND (prod_min_price = 2000 OR
prod_min_price = 4000) AND prod_unit_of_measure <> '';
Which statement is true regarding the above query?
A. It executes successfully but returns no result.
B. It executes successfully and returns the required result.
C. It generates an error because the condition specified for PROD_UNIT_OF_MEASURE is not valid.
D. It generates an error because the condition specified for the PROD_CATEGORY column is not valid.
Correct Answer: A
二、题目翻译
下面是PRODUCTS表的数据：
现在要显示PRODUCTS表中产品种类为Software/Other，最低价格为$2000或$4000，并且没有度量单位的产品名称。
下面的查询语句哪句的正确的？
A 执行成功但不返回结果。
B 执行成功并返回所需结果。
C 报错因为PROD_UNIT_OF_MEASURE条件是无效的。
D 报错因为PROD_CATEGORY条件是无效的。
三、题目解析
因为prod_unit_of_measure <> ''该条件为假，’’和NULL类似，不能用<>这种方式来判断，而应该用is not null,所以会导致该WHERE子句里所有AND连接的值为假，虽然执行成功但不会返回结果，正确的条件应该是prod_unit_of_measure is not null。
SQL> create table products as select prod_id,prod_name,PROD_CATEGORY,PROD_MIN_PRICE,PROD_UNIT_OF_MEASURE from sh.products where 1<>1;

Table created.

SQL> insert into products values(101,'Envoy 256MB - 40 GB','Hardware',6000,'Nos.');

1 row created.

SQL> insert into products values(102,'Y Box','Electronics',9000,'');

1 row created.

SQL> insert into products values(103,'DVD-R Disc, 4.7 GB','Software/Other',2000,'Nos.');

1 row created.

SQL> insert into products values(104,'Documentation Set - Spanish','Software/Other',4000,'');

1 row created.

SQL> SELECT prod_name, prod_category, prod_min_price
  2  FROM products
WHERE prod_category LIKE '%Other%' AND (prod_min_price = 2000 OR
  4  prod_min_price = 4000) AND prod_unit_of_measure <> '';

no rows selected

SQL> FROM products
SELECT prod_name, prod_category, prod_min_price
  2  FROM products
WHERE prod_category LIKE '%Other%' AND (prod_min_price = 2000 OR
  4  prod_min_price = 4000) AND prod_unit_of_measure != '';

no rows selected

SQL> set linesize 200
SQL> SELECT prod_name, prod_category, prod_min_price
  2  FROM products
  3  WHERE prod_category LIKE '%Other%' AND (prod_min_price = 2000 OR
  4  prod_min_price = 4000) AND prod_unit_of_measure is not null;

PROD_NAME                                          PROD_CATEGORY                                      PROD_MIN_PRICE
-------------------------------------------------- -------------------------------------------------- --------------
DVD-R Disc, 4.7 GB                                 Software/Other                                               2000

QUESTION 60
View the Exhibit and examine the structure of CUSTOMERS table.
Evaluate the following query:
SQL>SELECT cust_id, cust_city
FROM customers
WHERE cust_first_name NOT LIKE 'A_%g_%' AND
cust_credit_limit BETWEEN 5000 AND 15000 AND
cust_credit_limit NOT IN (7000, 11000) AND
cust_city NOT BETWEEN 'A' AND 'B';
Which statement is true regarding the above query?
A. It executes successfully.
B. It produces an error because the condition on the CUST_CITY column is not valid.
C. It produces an error because the condition on the CUST_FIRST_NAME column is not valid.
D. It produces an error because conditions on the CUST_CREDIT_LIMIT column are not valid.
Correct Answer: A
二、题目翻译
下面是CUSTOMERS表的结构
看下面的查询语句：
关于上面的查询哪句话是正确的？
A.执行成功。
B.报错，因为CUST_CITY列的条件无效。
C.报错，因为CUST_FIRST_NAME的条件无效。
D.报错，因为CUST_CREDIT_LIMIT的条件无效。
SQL> SELECT cust_first_name,cust_credit_limit,cust_id, cust_city
  2  FROM sh.customers
  3  WHERE cust_first_name NOT LIKE 'A_%g_%' AND
  4  cust_credit_limit BETWEEN 5000 AND 15000 AND
  5  cust_credit_limit NOT IN (7000, 11000) AND
  6  cust_city NOT BETWEEN 'A' AND 'B' and rownum<5;

CUST_FIRST_NAME      CUST_CREDIT_LIMIT    CUST_ID CUST_CITY
-------------------- ----------------- ---------- ------------------------------
Abner                            15000      36117 Wolverhampton
Abner                            15000      25470 Stuttgart
Abner                            15000       4117 Clermont-l'Herault
Abner                            15000      14784 Belfast City


QUESTION 61
View the Exhibit and examine the structure of the PROMOTIONS table.
You need to generate a report of all promos from the PROMOTIONS table based on the following
conditions:
1. The promo name should not begin with 'T' or 'N'.
2. The promo should cost more than $20000.
3. The promo should have ended after 1st January 2001.
Which WHERE clause would give the required result?
A. WHERE promo_name NOT LIKE 'T%' OR promo_name NOT LIKE 'N%' AND promo_cost > 20000
AND promo_end_date > '1-JAN-01'
B. WHERE (promo_name NOT LIKE 'T%' AND promo_name NOT LIKE 'N%')OR promo_cost > 20000
OR promo_end_date > '1-JAN-01'
C. WHERE promo_name NOT LIKE 'T%' AND promo_name NOT LIKE 'N%' AND promo_cost > 20000
AND promo_end_date > '1-JAN-01'
D. WHERE (promo_name NOT LIKE '%T%' OR promo_name NOT LIKE '%N%') AND(promo_cost >
20000 AND promo_end_date > '1-JAN-01')
Correct Answer: C
二、题目翻译
查看PROMOTIONS表结构
要从PROMOTIONS表获取所有promos的报表，基于如下的条件：
1.promo name不是以'T’或'N'开头。
2.promo的成本大于$20000。
3.在2001年1月1日之后结束的promo。
哪个WHERE子句能给出所需结果？

三、题目解析
A选项不正确，AND的优先级大于OR，会导致结果不正确。
B选项不正确，三个条件是并且(AND)关系，而不是或者(OR)。
D选项不正确，不是T或N开头，只是包含有T或N。

View the E xhibit and examine the structure of the CUSTOMERS table.
You want to generate a report showing the last names and credit limits of all customers whose last names
start with A, B, or C, and credit limit is below 10, 000.
Evaluate the following two queries:
SQL> SELECT cust_last_name, cust_credit_limit FROM customers
WHERE (UPPER(cust_last_name) LIKE 'A%' OR
UPPER(cust_last_name) LIKE 'B%' OR UPPER(cust_last_name) LIKE 'C%')
AND cust_credit_limit < 10000;
SQL>SELECT cust_last_name, cust_credit_limit FROM customers
WHERE UPPER(cust_last_name) BETWEEN 'A' AND 'C'
AND cust_credit_limit < 10000;
Which statement is true regarding the execution of the above queries?
A. Only the first query gives the correct result.
B. Only the second query gives the correct result.
C. Both execute successfully and give the same result.
D. Both execute successfully but do not give the required result.
Correct Answer: A
二、题目翻译
查看CUSTOMERS表的结构
现在要生成一个报表，显示所有customers的last names和credit limits，客户的last names以A, B, 或C开头，并且credit limit小于10，000
下面的两个查询:
关于上面的查询哪个描述是正确的？
A.只有第一个查询给出正确结果。
B.只有第二个查询给出正确结果。
C.两个都能执行成功，并给出正确结果。
D.两个都能执行成功，但不能给出所需结果。
三、题目解析
因为第二条查询语句里的BETWEEN 'A' AND 'C'，只能查出以A和B开头的，不能查出以C开头的。

具体测试如下，只出现A和B开头的，并没有出现C开头的:

SQL> SELECT cust_last_name, cust_credit_limit FROM sh.customers
  2  WHERE (UPPER(cust_last_name) LIKE 'A%' OR
  3  UPPER(cust_last_name) LIKE 'B%' OR UPPER(cust_last_name) LIKE 'C%')
  4  AND cust_credit_limit < 10000 and rownum<5;

CUST_LAST_NAME                           CUST_CREDIT_LIMIT
---------------------------------------- -----------------
Aaron                                                 5000
Aaron                                                 1500
Aaron                                                 3000
Aaron                                                 7000

SQL> SELECT cust_last_name, cust_credit_limit FROM sh.customers
WHERE UPPER(cust_last_name) BETWEEN 'A' AND 'C'
  3  AND cust_credit_limit < 10000 and rownum<5;

CUST_LAST_NAME                           CUST_CREDIT_LIMIT
---------------------------------------- -----------------
Aaron                                                 5000
Aaron                                                 1500
Aaron                                                 3000
Aaron                                                 7000

QUESTION 63
View the Exhibit and examine the structure of the PRODUCTS table.
You want to display only those product names with their list prices where the list price is at least double
the minimum price. The report should start with the product name having the maximum list price satisfying
this condition.
Evaluate the following SQL statement:
SQL>SELECT prod_name,prod_list_price
FROM products
WHERE prod_list_price >= 2 * prod_min_price
Which ORDER BY clauses can be added to the above SQL statement to get the correct output?
(Choose all that apply.)
A. ORDER BY prod_list_price DESC, prod_name;
B. ORDER BY (2*prod_min_price)DESC, prod_name;
C. ORDER BY prod_name, (2*prod_min_price)DESC;
D. ORDER BY prod_name DESC, prod_list_price DESC;
E. ORDER BY prod_list_price DESC, prod_name DESC;
Correct Answer: AE
二、题目翻译
查看PRODUCTS表的结构：
现在想显示产品价格是最低价格两倍的产品的名称.报表应该以价格列表中的最高价格的产品名称开始（即先按价格列表的降序排序，再按名称排序，但这里没有说是按升序还是降序）。
下面的SQL语句:
哪一个ORDER BY子句加到上面的SQL语句后能得到正确的结果？(选择所有正确的选项)

三、题目解析
题目的意思，先按prod_list_price降序排序, 再按prod_name排序
B选项不正确，因为是按2*prod_min_price排序，所以不正确。
C和D选项不正确，都是先按prod_name排序。

QUESTION 64
View the E xhibit and examine the data in the PROMO_CATEGORY and PROMO_COST columns of
the PROMOTIONS table.
Evaluate the following two queries:
SQL>SELECT DISTINCT promo_category to_char(promo_cost)"code"
FROM promotions
ORDER BY code;
SQL>SELECT DISTINCT promo_category promo_cost "code"
FROM promotions
ORDER BY 1;
Which statement is true regarding the execution of the above queries?
A. Only the first query executes successfully.
B. Only the second query executes successfully.
C. Both queries execute successfully but give different results.
D. Both queries execute successfully and give the same result.

二、题目翻译
查看PROMOTIONS表的PROMO_CATEGORY 和PROMO_COST列的数据
看下面两个查询
下面关于执行上面的查询的描述，哪句话是正确的？
A.只有第一个执行成功。
B.只有第二个执行成功。
C.两个都执行成功，但是结果不同。
D.两个都执行成功，并且结果相同。

三、题目解析
第一句sql执行时报错，因为ORDER BY使用列别名时要完全匹配，如果别名加了双引号，必须也要加双引号。
第二句sql执行成功，1表示使用select后的第一列进行排序。

四、测试
关于order by 后面别名的使用，测试如下：
SQL> SELECT DISTINCT promo_category,to_char(promo_cost)"code"
  2  FROM sh.promotions
  3  ORDER BY code;
ORDER BY code
         *
ERROR at line 3:
ORA-00904: "CODE": invalid identifier
SQL> SELECT DISTINCT promo_category, to_char(promo_cost)"code"
  2  FROM sh.promotions where rownum<5
  3  ORDER BY "code";

PROMO_CATEGORY                 code
------------------------------ ----------------------------------------
NO PROMOTION                   0
newspaper                      200
post                           300
newspaper                      400

SQL> SELECT DISTINCT promo_category, to_char(promo_cost)"code"
  2  FROM sh.promotions where rownum<5
  3  ORDER BY 1;

PROMO_CATEGORY                 code
------------------------------ ----------------------------------------
NO PROMOTION                   0
newspaper                      200
newspaper                      400
post                           300

QUESTION 65
View the Exhibit and examine the structure of the CUSTOMERS table.
You have been asked to produce a report on the CUSTOMERS table showing the customers details
sorted in descending order of the city and in the descending order of their income level in each city.
Which query would accomplish this task?
A. SELECT cust_city, cust_income_level, cust_last_name
FROM customers
ORDER BY cust_city desc, cust_income_level DESC ;
B. SELECT cust_city, cust_income_level, cust_last_name
FROM customers
ORDER BY cust_income_level desc, cust_city DESC;
C. SELECT cust_city, cust_income_level, cust_last_name
FROM customers
ORDER BY (cust_city, cust_income_level) DESC;
D. SELECT cust_city, cust_income_level, cust_last_name
FROM customers
ORDER BY cust_city, cust_income_level DESC;
Correct Answer: A
二、题目翻译
查看 CUSTOMERS表的结构
要根据CUSTOMERS表生成一个报表，显示员工信息，按city降序排列，并且每个city中员工的income level也降序排列显示。
哪一个查询能完成这个任务？

三、题目解析
B选项不正确，顺序错误，不是按city降序，再按income level降序排列。
C选项不正确，语法错误
D选项不正确，不是按city的降序排列，不写desc,默认是ASC升序排列。

QUESTION 66
View the Exhibit and examine the data in the COSTS table.
You need to generate a report that displays the IDs of all products in the COSTS table whose unit price is
at least 25% more than the unit cost. The details should be displayed in the descending order of 25% of
the unit cost.
You issue the following query:
SQL>SELECT prod_id
FROM costs
WHERE unit_price >= unit_cost * 1.25
ORDER BY unit_cost * 0.25 DESC;
Which statement is true regarding the above query?
A. It executes and produces the required result.
B. It produces an error because an expression cannot be used in the ORDER BY clause.
C. It produces an error because the DESC option cannot be used with an expression in the ORDER BY
clause.
D. It produces an error because the expression in the ORDER BY clause should also be specified in the
SELECT clause.
Correct Answer: A
 二、题目翻译
 
查看COSTS 表的数据
 要生成一个报表，显示COSTS表中所有产品ID，产品的unit price至少要比unit cost多25%，按unit cost的25%降序显示产品信息。
 执行下面的查询
 下面关于上面的查询的描述，哪句话是正确的？
A.获取所需的结果。
B.报错，因为表达式不能用在ORDER BY子句中。
C.报错，因为DESC不能用在ORDER BY的表达式中。
D.报错，因为ORDER BY子句中的表达式也应该在SELECT子句中。


三、题目解析
 
B选项不正确，表达式可以出现在ORDER BY子句中。
C选项不正确，DESC就是用在ORDER BY子句中按降序排序的。
D选项不正确，是SELECT子句中的表达式，应该出现在GROUP BY中，而不是ORDER BY。

SQL> SELECT prod_id
  2  FROM sh.costs
  3  WHERE unit_price >= unit_cost * 1.25 and rownum<5
  4  ORDER BY unit_cost * 0.25 DESC;

   PROD_ID
----------
        14
        14
        14
        13
		
QUESTION 67
Which two statements are true regarding the ORDER BY clause? (Choose two.)
A. It is executed first in the query execution.
B. It must be the last clause in the SELECT statement.
C. It cannot be used in a SELECT statement containin g a HAVING clause.
D. You cannot specify a column name followed by an expression in this clause.
E. You can specify a combination of numeric positions and column names in this clause.
Correct Answer: BE
解析：
选项A，应该是得到查询结果，然后在进行排序的
选项B，order by 应该放在select 语句的最后，所以B选项正确
选项C:
SQL> select sal from scott.emp group by sal order by sal;

       SAL
----------
       800
       950
      1100
      1250
      1300
      1500
      1600
      2450
      2850
      2975
      3000

       SAL
----------
      5000

12 rows selected.
所以C选项错误
D选项，可以指定一个表达式在order by后面进行排序，根据上题可知，所以D选项正确
SQL> select ename,sal from scott.emp  where rownum<5 order by 1,sal desc;

ENAME             SAL
---------- ----------
ALLEN            1600
JONES            2975
SMITH             800
WARD             1250
所以E选项正确

QUESTION 68
Which statement is true regarding the default behavior of the ORDER BY clause?
A. In a character sort, the values are case- sensitive.
B. NULL values are not considered at all by the sort operation.
C. Only those columns that are specified in the SELECT list can be used in the ORDER BY clause.
D. Numeric values are displayed from the maximum to the minimum value if they have decimal positions.
Correct Answer: A
解析：
A选项，在字符排序是，区分大小写，这个是正确的
B选项，这里oracle做排序的时候会考虑空值
C选项，order by 排序时，不需要像group by 需要在select中指定，所以C选项错误
D选项，默认都为升序

QUESTION 69
You need to generate a list of all customer last names with their credit limits from the CUSTOMERS
table. Those customers who do not have a credit limit should appear last in the list.
Which two queries would achieve the required result? (Choose two.)
A. SELECT cust_last_name, cust_credit_limit
FROM customers
ORDER BY cust_credit_limit DESC ;
B. SELECT cust_last_name, cust_credit_limit
FROM customers
ORDER BY cust_credit_limit;
C. SELECT cust_last_name, cust_credit_limit
FROM customers
ORDER BY cust_credit_limit NULLS LAST;
D. SELECT cust_last_name, cust_credit_limit
FROM customers
ORDER BY cust_last_name, cust_credit_limit NULLS LAST;
Correct Answer: BC
二、题目翻译
要根据CUSTOMERS表生成一个列表，显示客户的last name和他们的credit limits，那些没有credit limit的客户显示到列表的后面。（即null值放在最后）
哪两个查询能获取所需结果(选择两个正确的选项)
三、题目解析
A选项不正确，因为默认情况下，cust_credit_limit DESC降序排列后，空值会排列到前面。
B选项正确，默认升续排列，空值会排列到后面。
C选项正确，NULLS LAST关键字可以把空值排列到后面。
D选项不正确，因为排序条件不正确，先按名字排序了
解析：

题意要求appear last in the list，所以按照cust_credit_limit升序排序 order by 默认为升序，所以B选项正确 asc时， nulls last为默认 所以C选项正确


QUESTION 70
View the E xhibit and examine the structure of the PRODUCTS table.
You want to display only those product names with their list prices where the list price is at least double
the minimum price. The report should start with the product name having the maximum list price satisfying
this condition.
Evaluate the following SQL statement:
SQL>SELECT prod_name,prod_list_price
FROM products
WHERE prod_list_price >= 2 * prod_min_price
Which ORDER BY clauses can be added to the above SQL statement to get the correct output?
(Choose all that apply.)
A. ORDER BY prod_list_price DESC, prod_name;
B. ORDER BY (2*prod_min_price)DESC, prod_name;
C. ORDER BY prod_name, (2*prod_min_price)DESC;
D. ORDER BY prod_name DESC, prod_list_price DESC;
E. ORDER BY prod_list_price DESC, prod_name DESC;
Correct Answer: AE
二、题目翻译
查看PRODUCTS表的结构：
现在想显示产品价格是最低价格两倍的产品的名称.报表应该以价格列表中的最高价格的产品名称开始（即先按价格列表的降序排序，再按名称排序，但这里没有说是按升序还是降序）。
下面的SQL语句:
哪一个ORDER BY子句加到上面的SQL语句后能得到正确的结果？(选择所有正确的选项)

三、题目解析
题目的意思，先按prod_list_price降序排序, 再按prod_name排序
B选项不正确，因为是按2*prod_min_price排序，所以不正确。
C和D选项不正确，都是先按prod_name排序。
答案解析：
The report should start with the product name having the maximum list price satisfying this condition.
题意要求按照list price由大到小附加名字来排序，即先保证 prod_list_price是降序的后面按照name来排序，prod_name排序可升序可降序。
SQL> SELECT prod_name,prod_list_price
 FROM sh.products
 WHERE prod_list_price >= 2 * prod_min_price and rownum<5 ORDER BY prod_list_price DESC, prod_name;

no rows selected

QUESTION 71
Which arithmetic operations can be performed on a column by using a SQL function that is built into
Oracle database ? (Choose three .)
A. addition
B. subtraction
C. raising to a power
D. finding the quotient
E. finding the lowest value
Correct Answer: ACE
二、题目翻译
哪一种算术运算能被Oracle数据库内置SQL函数在一个列上执行？（即哪一种算术运算可以被内置函数替代执行）（选择三个）
A. 加法
B. 减法
C. 乘方
D. 找商
E. 找最小值
三、题目解析
A选项，例如：sum()
C选项，例如：power()
E选项，例如：min()

QUESTION 72
Which tasks can be performed using SQL functions built into Oracle Database ? (Choose three.)
A. displaying a date in a nondefault format
B. finding the number of characters in an expression
C. substituting a character string in a text expression with a specified string
D. combining more than two columns or expressions into a single column in the output
Correct Answer: ABC
二、题目翻译
哪一个任务能使用ORACLE内置函数来完成？（选择三个）
A. 显示一个非默认格式的日期。
B. 在一个表达式中查找字符的数量。
C .使用指定的字符串来替换文本表达式中的字符串。
D. 联合超过两个列或表达式输出为一个列。
三、题目解析
A选项正确，例如：to_char()转换日期输出。
B选项正确，例如：length()，regexp_count()。
C选项正确，例如：replace()。
D选项不正确，因为没有能联合超过两个列的函数，CONCAT()只能联合两个列。

QUESTION 73
Which tasks can be performed using SQL functions that are built into Oracle database ? (Choose
three .)
A. finding the remainder of a division
B. adding a number to a date for a resultant date value
C. comparing two expressions to check whether they are equal
D. checking whether a specified character exists in a given string
E. removing trailing, leading, and embedded characters from a character string
Correct Answer: ACD
二、题目翻译
哪一个任务能使用内置函数完成？（选择三个）
A. 取余。
B. 给日期添加一个数字变成一个合成的日期。
C. 比较两个表达式查看是否相等。
D. 检查指定的字符串是否存在于一个给定的字符串中。
E. 从一个字符串中移除尾部、头部、内含的字符。
三、题目解析
A选项正确，例如：MOD()。
C选项正确，例如：nullif函数，decode函数。
D选项正确，例如：INSTR()或regexp_count()。
E选项不正确，trim()只能去除前后的字符，中间的字符，可以使用replace()函数完成，但这不只一个函数。

B选项，答案是不正确，但可以用ADD_MONTHS()等这类函数完成，不知是否我理解有误，有不同意见的朋友可以留言。
QUESTION 74
Which statements are true regarding single row functions? (Choose all that apply.)
A. MOD : returns the quotient of a division
B. TRUNC : can be used with NUMBER and DATE values
C. CONCAT : can be used to combine any number of values
D. SYSDATE : returns the database server current date and time
E. INSTR : can be used to find only the first occurrence of a character in a string
F. TRIM : can be used to remove all the occurrences of a character from a string
Correct Answer: BD
二、题目翻译
关于单行函数哪句话是正确的？（选择所有正确的答案）
A. MOD返回一个商。
B. TRUNC能用于NUMBER和DATE值。
C. CONCAT能用于连接任意数量的值。
D. SYSDATE返回数据库服务器当前的日期和时间。
E. INSTR只能用于查找字符串中第一次出现的字符。
F. TRIM能用于移除所有字符串中出现的字符。
三、题目解析
A选项不正确，MOD是取余，不是求商。
B选项正确。
C选项不正确，concat只能联接任意两个值。但可以嵌套使用，比如,concat('abc',concat('def','h'));
D选项正确。
E选项不正确，instr函数可以用于查找第N次出现的字符。
F选项不正确，TRIM函数只能移除左右两侧出现的字符。
四、测试
Instr函数：格式：instr(源字符串,目标字符串,起始位置,匹配序号)
例如：instr('YOU AND SHE ARE ANGEL','AN',3,2)，
源字符串为'YOU AND SHE ARE ANGEL'，目标字符串为'AN'，从3个字符开始查找，取第2个匹配的字符串的位置。
默认查找顺序为从左到右，当起始位置为负数的时候，从右边开始查找。上面返回的值为17。

SQL> select instr('YOU AND SHE ARE ANGEL','AN',3,2) from dual;

INSTR('YOUANDSHEAREANGEL','AN',3,2)
-----------------------------------
                                 17
SQL> select instr('YOU AND SHE ARE ANGEL','AN',-3,2) from dual;

INSTR('YOUANDSHEAREANGEL','AN',-3,2)
------------------------------------
                                   5
SQL> select instr('YOU AND SHE ARE ANGEL','AN',-3,1) from dual;

SQL> select instr('YOU AND SHE ARE ANGEL','AN',-3,1) from dual;

INSTR('YOUANDSHEAREANGEL','AN',-3,1)
------------------------------------
                                  17
QUESTION 75
The following data exists in the PRODUCTS table:
PROD_ID PROD_LIST_PRICE
123456 152525.99
You issue the following query:
SQL> SELECT RPAD(( ROUND(prod_list_price)), 10,'*')
FROM products
WHERE prod_id = 123456;
What would be the outcome?
A. 152526 ****
B. **152525.99
C. 152525** **
D. an error message
Correct Answer: A
二、题目翻译
下面是PRODUCTS表中的数据
执行下面的查询语句:
结果是什么？
三、题目解析
ROUND(prod_list_price)没有第二个参数，即没有小数位，默认保留到整数。
ROUND是四舍五入，所以ROUND(prod_list_price)＝152526。
RPAD右填充函数，这里RPAD((ROUND(prod_list_price)), 10,'*')表示，round的结果，保留10个长度，如果不够，在右边用*填充。所以，RPAD((ROUND(prod_list_price)), 10,'*')的结果为152526****							   
SQL> select RPAD(( ROUND(152525.99)), 10,'*') from dual;

RPAD((ROUN
----------
152526****

QUESTION 76
You need to display the first names of all customers from the CUSTOMERS table that contain the
character 'e' and have the character 'a' in the second last position.
Which query would give the required output?
A. SELECT cust_first_name
FROM customers
WHERE INSTR(cust_first_name, 'e')<>0 AND
SUBSTR(cust_first_name, -2, 1)='a';
B. SELECT cust_first_name
FROM customers
WHERE INSTR(cust_first_name, 'e')<>'' AND
SUBSTR(cust_first_name, -2, 1)='a';
C. SELECT cust_first_name
FROM customers
WHERE INSTR(cust_first_name, 'e')IS NOT NULL AND
SUBSTR(cust_first_name, 1,-2)='a';
D. SELECT cust_first_name
FROM customers
WHERE INSTR(cust_first_name, 'e')<>0 AND
SUBSTR(cust_first_name, LENGTH(cust_first_name),-2)='a';
Correct Answer: A
二、题目翻译
要从CUSTOMERS表中显示所有customers的first names，名字中要包含e，并且倒数第二个字符要包含a
下面哪个查询语句能给出所需的结果？

三、题目解析
A选项正确，INSTR如果不包含字符则返回0，不等于0，说明包含了e字符，SUBSTR可以从倒数第二个字符开始截取一个字符。
B选项不正确，INSTR的结果<>''，永远为false。
C选项不正确，INSTR的结果不可能为null。
D选项不正确，SUBSTR不是截取的倒数第二个字符。

SQL> SELECT cust_first_name
  2  FROM sh.customers
  3  WHERE INSTR(cust_first_name, 'e')<>0 AND
  4  SUBSTR(cust_first_name, -2, 1)='a' and rownum<5;

CUST_FIRST_NAME
--------------------
Bertram
Bertram
Bertram
Bertram

QUESTION 77
In the CUSTOMERS table, the CUST_CITY column contains the value 'Paris' for the
CUST_FIRST_NAME 'ABIGAIL'.
Evaluate the following query:
SQL> SELECT INITCAP(cust_first_name|| ' '||
                         UPPER(SUBSTR(cust_city,-LENGTH(cust_city),2)))
             FROM customers
          WHERE cust_first_name = 'ABIGAIL';
What would be the outcome?
A. Abigail PA
B. Abigail Pa
C. Abigail IS
D. an error message
Correct Answer: B
二、题目翻译
CUSTOMERS表中，CUST_CITY列值为Paris，对应CUST_FIRST_NAME值为ABIGAIL
下面的语句的执行结果是什么？
三、题目解析
SUBSTR(cust_city,-LENGTH(cust_city),2),将cust_city（即'Paris'）从-5的位置（即右起第五个位置，即左起第一个位置），截取2个字符。
所以,SUBSTR截取的结果是Pa，UPPER转换后为PA，INITCAP是将首字符大写，后为Abigail Pa
SQL> SELECT INITCAP('ABIGAIL'|| ' '|| UPPER(SUBSTR('Paris',-LENGTH('Paris'),2))) from dual;

INITCAP('A
----------
Abigail Pa

QUESTION 78
Evaluate the following query:
SQL> SELECT TRUNC(ROUND(156.00,-1),-1)
FROM DUAL;
What would be the outcome?
A. 16
B. 100
C. 160
D. 200
E. 150
Correct Answer: C
二、题目解析
ROUND(156.00,-1)也就是说，156.00四舍五入，-1表示保留到小数点左边一位，也就是十位，那么，四舍五入后就是160
TRUNC是直接截断，截断后也是160。
SQL> SELECT TRUNC(ROUND(156.00,-1),-1) FROM DUAL;

TRUNC(ROUND(156.00,-1),-1)
--------------------------
                       160

SQL> SELECT TRUNC(ROUND(156.00,-1),-2) FROM DUAL;

TRUNC(ROUND(156.00,-1),-2)
--------------------------
                       100

SQL> SELECT TRUNC(ROUND(156.00,-1),-3) FROM DUAL;

TRUNC(ROUND(156.00,-1),-3)
--------------------------
                         0
QUESTION 79
View the Exhibit and examine the structure of the CUSTOMERS table.
In the CUSTOMERS table, the CUST_LAST_NAME column contains the values 'Anderson' and 'Ausson'.
You issue the following query:
SQL> SELECT LOWER(REPLACE(TRIM('son' FROM cust_last_name),'An','O'))
FROM CUSTOMERS
WHERE LOWER(cust_last_name) LIKE 'a%n';
What would be the outcome?
A. 'Oder' and 'Aus'
B. an error because the TRIM function specified is not valid
C. an error because the LOWER function specified is not valid
D. an error because the REPLACE function specified is not valid
SQL> select TRIM('son' FROM 'Anderson') from dual;
select TRIM('son' FROM 'Anderson') from dual
       *
ERROR at line 1:
ORA-30001: trim set should have only one character

SQL> select TRIM('son' FROM 'Ausson') from dual;
select TRIM('son' FROM 'Ausson') from dual
       *
ERROR at line 1:
ORA-30001: trim set should have only one character

QUESTION 80  ??
Which two statements are true regarding working with dates? (Choose two.)
A. The default internal storage of dates is in the numeric format.
B. The default internal storage of dates is in the character format.
C. The RR date format automatically calculates the century from the SYSDATE function and does not
allow the user to enter the century.
D. The RR date format automatically calculates the century from the SYSDATE function but allows the
user to enter the century if required.
Correct Answer: AD

二、题目翻译
关于处理日期型数据，哪两句话是正确的？
A. 默认内部存储的日期是使用数字格式。
B. 默认内部存储的日期是使用字符格式。
C. RR日期格式自动从SYSDATE函数中计算出世纪，不允许用户输入世纪。
D. RR日期格式自动从SYSDATE函数中计算出世纪，但是如果需要还允许用户输入世纪。
三、题目解析
A选项正确，详见联机文档的DATE Data Type描述部分:
        http://docs.oracle.com/cd/E11882_01/server.112/e40540/tablecls.htm#CNCPT413

摘录如下：
        The database stores dates internally as numbers. Dates are stored in fixed-length fields of 7 bytes each, corresponding to century, year, month, day, hour, minute, and second
RR is similar to YY (the last two digits of the year), but the century of the return value varies according to the specified two-digit year and the last two digits of the current year. Assume that in 1999 the database displays 01-JAN-11. If the date format uses RR, then 11 specifies 2011, whereas if the format uses YY, then 11 specifies 1911. You can change the default date format at both the instance and the session level.

Oracle Database stores time in 24-hour format—HH:MI:SS. If no time portion is entered, then by default the time in a date field is 00:00:00 A.M. In a time-only entry, the date portion defaults to the first day of the current month.
SQL> select to_char(sysdate,'rr'),to_char(sysdate,'yy'),sysdate from dual;

TO TO SYSDATE
-- -- ---------
17 17 31-MAR-17	

QUESTION 81
You are currently located in Singapore and have connected to a remote database in Chicago.
You issue the following command:
SQL> SELECT ROUND(SYSDATE-promo_begin_date,0)
FROM promotions
WHERE (SYSDATE-promo_begin_date)/365 > 2;
PROMOTIONS is the public synonym for the public database link for the PROMOTIONS table.
What is the outcome?
A. an error because the ROUND function specified is invalid
B. an error because the WHERE condition specified is invalid
C. number of days since the promo started based on the current Chicago date and time
D. number of days since the promo started based on the current Singapore date and time
Correct Answer: C
二、题目翻译
在Singapore（新加坡），连接到位于Chicago的远程数据库,
执行下面的命令:
PROMOTIONS是一个public synonym，通过public database link连接到PROMOTIONS表。
执行下面的命令，结果是什么？
A. 报错,因为ROUND函数无效。
B. 报错,因为WHERE条件无效。
C. 基于当前Chicago的日期和时间promo开始的天数。
D. 基于当前Singapore的日期和时间promo开始的天数。

三、题目解析
A、B选项不正确，这个SQL会执行成功。
C选项正确，因为sysdate获取的是远程服务器时间，所以D选项不正确。

QUESTION 82
Examine the data in the CUST_NAME column of the CUSTOMERS table.
CUST_NAME
Renske Ladwig
Jason Mallin
Samuel McCain
Allan MCEwen
Irene Mikkilineni
Julia Nayer
You need to display customers' second names where the second name starts with "Mc" or "MC."
Which query gives the required output?
A. SELECT SUBSTR(cust_name, INSTR(cust_name,' ')+1)
FROM customers
WHERE INITCAP(SUBSTR(cust_name, INSTR(cust_name,' ')+1))='Mc';
B. SELECT SUBSTR(cust_name, INSTR(cust_name,' ')+1)
FROM customers
WHERE INITCAP(SUBSTR(cust_name, INSTR(cust_name,' ')+1)) LIKE 'Mc%';
C. SELECT SUBSTR(cust_name, INSTR(cust_name,' ')+1)
FROM customers
WHERE SUBSTR(cust_name, INSTR(cust_name,' ')+1) LIKE INITCAP('MC%');
D. SELECT SUBSTR(cust_name, INSTR(cust_name,' ')+1)
FROM customers
WHERE INITCAP(SUBSTR(cust_name, INSTR(cust_name,' ')+1)) = INITCAP('MC%');
Correct Answer: B
二、题目翻译
下面是CUSTOMERS表CUST_NAME列的数据，
要显示第二个名字以"Mc" or "MC"开头的员工第二个名字（第二个名字，也就是空格后的名字）

三、题目解析
A选项不正确，where条件='Mc',没有第二个名字是Mc的人，所以没结果，而且题目要求包含MC或Mc,而不是等于。
B选项正确，INSTR找出空格的位置，然后用SUBSTR从空格后开始找，把找出的结果首字母大写，然后用like模糊查询。
C选项不正确，SUBSTR查找出的结果和INITCAP('MC%')匹配，只能匹配Mc，而无法匹配MC。
D选项不正确，模糊查询，不能用等号。

四、测试
以下是ABCD四个选项的测试结果:
SQL> with customers as (
select 'Renske Ladwig' CUST_NAME from dual
  3  union all 
  4  select 'Jason Mallin' CUST_NAME from dual
  5  union all
  6  select 'Samuel McCain' CUST_NAME from dual
  7  union all
  8  select 'Allan MCEwen' CUST_NAME from dual
  9  union all
 10  select 'Irene Mikkilineni' CUST_NAME from dual
 11  union all
 12  select 'Julia Nayer' CUST_NAME from dual
 13  )
 14  SELECT SUBSTR(cust_name, INSTR(cust_name,' ')+1)
 15  FROM customers
 16  WHERE INITCAP(SUBSTR(cust_name, INSTR(cust_name,' ')+1))='Mc';

no rows selected

SQL> with customers as (
  2  select 'Renske Ladwig' CUST_NAME from dual
  3  union all 
  4  select 'Jason Mallin' CUST_NAME from dual
  5  union all
  6  select 'Samuel McCain' CUST_NAME from dual
  7  union all
  8  select 'Allan MCEwen' CUST_NAME from dual
  9  union all
 10  select 'Irene Mikkilineni' CUST_NAME from dual
 11  union all
 12  select 'Julia Nayer' CUST_NAME from dual
 13  )
 14  SELECT SUBSTR(cust_name, INSTR(cust_name,' ')+1)
 15  FROM customers
 16  WHERE INITCAP(SUBSTR(cust_name, INSTR(cust_name,' ')+1)) LIKE 'Mc%';

SUBSTR(CUST_NAME,INSTR(CUST_NAME,'')+1)
--------------------------------------------------------------------
McCain
MCEwen

SQL> with customers as (
  2  select 'Renske Ladwig' CUST_NAME from dual
  3  union all 
  4  select 'Jason Mallin' CUST_NAME from dual
  5  union all
  6  select 'Samuel McCain' CUST_NAME from dual
  7  union all
  8  select 'Allan MCEwen' CUST_NAME from dual
  9  union all
 10  select 'Irene Mikkilineni' CUST_NAME from dual
 11  union all
 12  select 'Julia Nayer' CUST_NAME from dual
 13  )
 14  SELECT SUBSTR(cust_name, INSTR(cust_name,' ')+1)
 15  FROM customers
 16  WHERE SUBSTR(cust_name, INSTR(cust_name,' ')+1) LIKE INITCAP('MC%');

SUBSTR(CUST_NAME,INSTR(CUST_NAME,'')+1)
--------------------------------------------------------------------
McCain

SQL> with customers as (
  2  select 'Renske Ladwig' CUST_NAME from dual
  3  union all 
  4  select 'Jason Mallin' CUST_NAME from dual
  5  union all
  6  select 'Samuel McCain' CUST_NAME from dual
  7  union all
  8  select 'Allan MCEwen' CUST_NAME from dual
  9  union all
 10  select 'Irene Mikkilineni' CUST_NAME from dual
 11  union all
 12  select 'Julia Nayer' CUST_NAME from dual
 13  )
 14  SELECT SUBSTR(cust_name, INSTR(cust_name,' ')+1)
 15  FROM customers
 16  WHERE INITCAP(SUBSTR(cust_name, INSTR(cust_name,' ')+1)) = INITCAP('MC%');

no rows selected

QUESTION 83
Examine the data in the CUST_NAME column of the CUSTOMERS table.
CUST_NAME
Lex De Haan
Renske Ladwig
Jose Manuel Urman
Jason Mallin
You want to extract only those customer names that have three names and display the * symbol in place
of the first name as follows:
CUST NAME
*** De Haan
**** Manuel Urman
Which two queries give the required output? (Choose two.)
A. SELECT LPAD(SUBSTR(cust_name,INSTR(cust_name,' ')),LENGTH(cust_name),'*') "CUST NAME"
FROM customers
WHERE INSTR(cust_name, ' ',1,2)<>0;
B. SELECT LPAD(SUBSTR(cust_name,INSTR(cust_name,' ')),LENGTH(cust_name),'*') "CUST NAME"
FROM customers
WHERE INSTR(cust_name, ' ',-1,2)<>0;
C. SELECT LPAD(SUBSTR(cust_name,INSTR(cust_name,' ')),LENGTH(cust_name)-
INSTR(cust_name,' '),'*') "CUST NAME"
FROM customers
WHERE INSTR(cust_name, ' ',-1,-2)<>0;
D. SELECT LPAD(SUBSTR(cust_name,INSTR(cust_name,' ')),LENGTH(cust_name)-
INSTR(cust_name,' '),'*') "CUST NAME"
FROM customers
WHERE INSTR(cust_name, ' ',1,2)<>0 ;
Correct Answer: AB
二、题目翻译
下面是CUSTOMERS表CUST_NAME列的数据:
CUST_NAME
Lex De Haan
Renske Ladwig
Jose Manuel Urman
Jason Mallin
现在要提取那些有三个名字的客户，第一个名字用*号替换，比如下面这两个:
CUST NAME
*** De Haan
**** Manuel Urman
哪两个查询能得出想要的结果(选择2个)?

三、题目解析
A选项和B选项正确，
      先用INSTR(cust_name,' ')找出第一个空格的位置，
      然后，SUBSTR(cust_name,INSTR(cust_name,' '))从第一个空格开始往后截取字符串到末尾，结果是第一个空格以后所有的字符,
      最后，LPAD(SUBSTR(cust_name,INSTR(cust_name,' ')),LENGTH(cust_name),'*')用LPAD左填充到cust_name原来的长度，不足的部分用*填充，也就是将第一个空格前的位置，用*填充。
      A选项和B选项的区别是where后过滤是否有三个名字的方法不同，
      A选项INSTR(cust_name, ' ',1,2)从第一个位置，从左往右，查找第二次出现的空格，如果返回非0值，则说明有第二个空格，则有第三个名字，
      B选项INSTR(cust_name, ' ',-1,2)从最后一个位置，从右往左，查找第二次出现的空格，如果返回非0值，则说明有第二个空格，则有第三个名字。

C选项不正确，INSTR(cust_name, ' ',-1,-2)第四个参数，是第几次出现，这里不能为负。
D选项不正确，填充长度LENGTH(cust_name)- INSTR(cust_name,' ')，是总长度，减去第一个空格的位置，也就是说，总长度是第一个空格后面的字符串的长度，那就不用*填充了，不满足题目要求。

四、测试
下面是ABCD四个选项的测试结果：
SQL> col "CUST NAME" for a20
with customers as (
select 'Lex De Haan' CUST_NAME from dual
union all 
  4  select 'Renske Ladwig' CUST_NAME from dual
  5  union all
  6  select 'Jose Manuel Urman' CUST_NAME from dual
  7  union all
  8  select 'Jason Mallin' CUST_NAME from dual
  9  )
SELECT LPAD(SUBSTR(cust_name,INSTR(cust_name,' ')),LENGTH(cust_name),'*') "CUST NAME"
       FROM customers
 12      WHERE INSTR(cust_name, ' ',1,2)<>0;

CUST NAME
--------------------
*** De Haan
**** Manuel Urman

SQL> with customers as (
  2  select 'Lex De Haan' CUST_NAME from dual
  3  union all 
  4  select 'Renske Ladwig' CUST_NAME from dual
  5  union all
  6  select 'Jose Manuel Urman' CUST_NAME from dual
  7  union all
  8  select 'Jason Mallin' CUST_NAME from dual
  9  )
 10  SELECT LPAD(SUBSTR(cust_name,INSTR(cust_name,' ')),LENGTH(cust_name),'*') "CUST NAME"
 11  FROM customers
 12  WHERE INSTR(cust_name, ' ',-1,2)<>0;

CUST NAME
--------------------
*** De Haan
**** Manuel Urman

SQL> with customers as (
  2  select 'Lex De Haan' CUST_NAME from dual
  3  union all 
  4  select 'Renske Ladwig' CUST_NAME from dual
  5  union all
  6  select 'Jose Manuel Urman' CUST_NAME from dual
  7  union all
  8  select 'Jason Mallin' CUST_NAME from dual
  9  )
 10  SELECT LPAD(SUBSTR(cust_name,INSTR(cust_name,' ')),LENGTH(cust_name)-
 11  INSTR(cust_name,' '),'*') "CUST NAME"
 12  FROM customers
 13  WHERE INSTR(cust_name, ' ',-1,-2)<>0;
FROM customers
     *
ERROR at line 12:
ORA-01428: argument '-2' is out of range


SQL> with customers as (
  2  select 'Lex De Haan' CUST_NAME from dual
  3  union all 
  4  select 'Renske Ladwig' CUST_NAME from dual
  5  union all
  6  select 'Jose Manuel Urman' CUST_NAME from dual
  7  union all
  8  select 'Jason Mallin' CUST_NAME from dual
  9  )
 10  SELECT LPAD(SUBSTR(cust_name,INSTR(cust_name,' ')),LENGTH(cust_name)-
 11  INSTR(cust_name,' '),'*') "CUST NAME"
 12  FROM customers
 13  WHERE INSTR(cust_name, ' ',1,2)<>0 ;

CUST NAME
--------------------
 De Haa
 Manuel Urma
 

QUESTION 84
View the Exhibit and examine the structure of the EMPLOYEES table.
Examine the data in the ENAME and HIREDATE columns of the EMPLOYEES table:
ENAME HIREDATE
SMITH 17-DEC-80
ALLEN 20-FEB-81
WARD 22-FEB-81
You want to generate a list of user IDs as follows:
USERID
Smi17DEC80
All20FEB81
War22FEB81
You issue the following query:
SQL>SELECT CONCAT(SUBSTR(INITCAP(ename),1,3), REPLACE(hiredate,'-')) "USERID"
FROM employees;
What is the outcome?
A. It executes successfully and gives the correct output.
B. It executes successfully but does not give the correct output.
C. It generates an error because the REPLACE function is not valid.
D. It generates an error because the SUBSTR function cannot be nested in the CONCAT function.
Correct Answer: A
二、题目翻译
查看EMPLOYEES表的结构
表中ENAME and HIREDATE两列的数据如下：
ENAME      HIREDATE
SMITH       17-DEC-80
ALLEN       20-FEB-81
WARD        22-FEB-81

现在要生成如下的一个用户ID的列表：
USERID
Smi17DEC80
All20FEB81
War22FEB81

执行下面的查询语句：
SELECT CONCAT(SUBSTR(INITCAP(ename),1,3), REPLACE(hiredate,'-')) "USERID"
FROM employees;
执行结果是什么?
A.执行成功，并且能得出正确的结果。
B.执行成功，但是结果不正确。
C.报错,因为REPLACE无效。
D.报错，因为SUBSTR函数不能被嵌套在CONCAT函数中。
四、测试
下面是测试结果：
SQL> with employees as (
select 'SMITH' ename,'17-DEC-80' hiredate from dual
union all 
select 'ALLEN' ename,'20-FEB-81' hiredate from dual
union all 
select 'WARD' ename,'22-FEB-81' hiredate from dual
)
SELECT CONCAT(SUBSTR(INITCAP(ename),1,3), REPLACE(hiredate,'-')) "USERID"
  9  FROM employees;

USERID
---------------------
Smi17DEC80
All20FEB81
War22FEB81

QUESTION 85
View the E xhibit and examine the structure and data in the INVOICE table.
Which statements are true regarding data type conversion in expressions used in queries? (Choose all
that apply.)
A. inv_amt ='0255982' : requires explicit conversion
B. inv_date > '01-02-2008' : uses implicit conversion
C. CONCAT(inv_amt,inv_date) : requires explicit conversion
D. inv_date = '15-february-2008' : uses implicit conversion
E. inv_no BETWEEN '101' AND '110' : uses implicit conversion
Correct Answer: DE

二、题目翻译
下面是INVOICE表的结构:
关于查询中的表达式中的数据类型转换，哪句话是正确的？（选择所有正确的项）
A.inv_amt ='0255982' : 需要显式转换。
B.inv_date > '01-02-2008'：使用了隐式转换。
C. CONCAT(inv_amt,inv_date) ：需要显式转换。
D. inv_date = '15-february-2008' ：使用了隐式转换。
E. inv_no BETWEEN '101' AND '110'： 使用了隐式转换。

三、题目解析
A选项不正确，inv_amt列是nubmer类型，右边是字符类型，这个是隐式转换。
B选项不正确，inv_date列是date类型，右边的格式和默认格式不一致，需要用to_date显式转换。
C选项不正确，这里是使用隐式转换，转换成字符型

SQL> create table invoice(inv_no number not null,inv_date date,cust_name varchar2(20) not null,cust_cat char(1),inv_amt number(8,2));

Table created.

SQL> insert into invoice values(101,'15-FEB-08','JAMES',1,255982.55);

1 row created.

SQL> insert into invoice values(102,'18-MAR-08','SMITH',2,100000.00);

1 row created.

SQL> select * from invoice where inv_amt ='0255982';

no rows selected

SQL> select * from invoice where inv_date > '01-02-2008' ;
select * from invoice where inv_date > '01-02-2008'
                                       *
ERROR at line 1:
ORA-01843: not a valid month


SQL> select CONCAT(inv_amt,inv_date) from invoice;

CONCAT(INV_AMT,INV_DATE)
----------------------------------------------------------
255982.5515-FEB-08
10000018-MAR-08

SQL> select * from invoice where inv_date = '15-february-2008';

    INV_NO INV_DATE  CUST_NAME            C    INV_AMT
---------- --------- -------------------- - ----------
       101 15-FEB-08 JAMES                1  255982.55

SQL> select * from invoice where inv_no BETWEEN '101' AND '110' ;

    INV_NO INV_DATE  CUST_NAME            C    INV_AMT
---------- --------- -------------------- - ----------
       101 15-FEB-08 JAMES                1  255982.55
       102 18-MAR-08 SMITH                2     100000
	   
QUESTION 86
Examine the structure and data of the CUST_TRANS table:
CUST_TRANS
Name Null Type
CUSTNO NOT NULL CHAR(2)
TRANSDATE DATE
TRANSAMT NUMBER(6,2)
CUSTNO TRANSDATE TRANSAMT
11 01-JAN-07 1000
22 01-FEB-07 2000
33 01-MAR-07 3000
Dates are stored in the default date format dd-mon-rr in the CUST_TRANS table.
Which SQL statements would execute successfully? (Choose three .)
A. SELECT transdate + '10' FROM cust_trans;
B. SELECT * FROM cust_trans WHERE transdate = '01-01-07';
C. SELECT transamt FROM cust_trans WHERE custno > '11';
D. SELECT * FROM cust_trans WHERE transdate='01-JANUARY-07';
E. SELECT custno + 'A' FROM cust_trans WHERE transamt > 2000;
Correct Answer: ACD

二、题目翻译
下面是CUST_TRANS 表的结构和数据：
表中的日期使用的默认dd-mon-rr格式存储
哪一个SQL语句能执行成功（选择三个）？

三、题目解析
A选项正确，使用隐式转换把‘10’转换成了number型。
B选项不正确，where条件中的=右边，日期格式和默认格式不一致，需要使用to_date显式转换。
C选项正确，'11'隐式转换成number类型，然后进行比较。
D选项正确，where条件中的=右边，日期格式和默认格式一致。
E选项不正确，'A'是字符，不能转换成数值，所以会报错。
四、测试
下面是测试结果：
SQL> create table CUST_TRANS(
CUSTNO  CHAR(2) NOT NULL,
TRANSDATE DATE,
  4  TRANSAMT NUMBER(6,2)
  5  );
Table created.

SQL> insert into CUST_TRANS values(11, '01-JAN-07', 1000);
1 row created.

SQL> insert into CUST_TRANS values(22, '01-FEB-07', 2000);
1 row created.

SQL> insert into CUST_TRANS values(33, '01-MAR-07', 3000);
1 row created.

SQL> SELECT transdate + '10' FROM cust_trans;

TRANSDATE
---------
11-JAN-07
11-FEB-07
11-MAR-07

SQL> SELECT * FROM cust_trans WHERE transdate = '01-01-07';
SELECT * FROM cust_trans WHERE transdate = '01-01-07'
                                           *
ERROR at line 1:
ORA-01843: not a valid month


SQL> SELECT transamt FROM cust_trans WHERE custno > '11';

  TRANSAMT
----------
      2000
      3000

SQL> SELECT * FROM cust_trans WHERE transdate='01-JANUARY-07';

CU TRANSDATE   TRANSAMT
-- --------- ----------
11 01-JAN-07       1000

SQL> SELECT custno + 'A' FROM cust_trans WHERE transamt > 2000;
SELECT custno + 'A' FROM cust_trans WHERE transamt > 2000
                *
ERROR at line 1:
ORA-01722: invalid number

QUESTION 87
You want to display the date for the first Mon day of the next month and issue the following
command:
SQL>SELECT TO_CHAR(NEXT_DAY(LAST_DAY(SYSDATE),'MON'),
'dd "is the first Monday for" fmmonth rrrr')
FROM DUAL;
What is the outcome?
A. It executes successfully and returns the correct result.
B. It executes successfully but does not return the correct result.
C. It generates an error because TO_CHAR should be replaced with TO_DATE.
D. It generates an error because rrrr should be replaced by rr in the format string.
E. It generates an error because fm and double quotation marks should not be used in the format string.
Correct Answer: A
二、题目翻译
要显示下个月的第一个星期一的日期，执行下面的命令，结果是什么？
A.执行成功,并且能得出正确结果。
B.执行成功，但不能返回正确的结果。
C.报错，TO_CHAR应该用TO_DATE替换。
D.报错，格式中，rrrr应该用rr替换。
E.报错，fm和双引号不能用在格式字符串中。

三、题目解析
LAST_DAY显示本月的最后一天的日期，
NEXT_DATE函数返回从第一个参数的日期开始，紧接着下来的指定星期对应的第一个日期。

四、测试

SQL> SELECT TO_CHAR(NEXT_DAY(LAST_DAY(SYSDATE),'MON'),
  2  'dd "is the first Monday for" fmmonth rrrr')
  3  FROM DUAL;

TO_CHAR(NEXT_DAY(LAST_DAY(SYSDATE),'MON'),'DD"ISTHEFIRSTMONDAYFOR"FM
--------------------------------------------------------------------
03 is the first Monday for april 2017

QUESTION 88
You need to calculate the number of days from 1st January 2007 till date.
Dates are stored in the default format of dd-mon-rr.
Which SQL statements would give the required output? (Choose two .)
A. SELECT SYSDATE - '01-JAN-2007' FROM DUAL;
B. SELECT SYSDATE - TO_DATE('01/JANUARY/2007') FROM DUAL;
C. SELECT SYSDATE - TO_DATE('01-JANUARY-2007') FROM DUAL;
D. SELECT TO_CHAR(SYSDATE, 'DD-MON-YYYY') - '01-JAN-2007' FROM DUAL;
E. SELECT TO_DATE(SYSDATE, 'DD/MONTH/YYYY') - '01/JANUARY/2007' FROM DUAL;
Correct Answer: BC
二、题目翻译
要计算从2007.1.1到现在的天数
日期以默认的格式dd-mon-rr格式存储。
下面哪个SQL能查出所需的结果（选择2个）：

三、题目解析
A选项不正确，格式不同，不能直接减，需要显式转才行。
B，C选项正确，显式转换后，再相减。
D选项不正确，都转成字符格式了，不能相减了。
E选项不正确，sysdate本来就是日期格式，不用转换，反而减号是后面的日期需要转换，但却没转。
四、测试
SQL> SELECT SYSDATE - '01-JAN-2007' FROM DUAL;
SELECT SYSDATE - '01-JAN-2007' FROM DUAL
                 *
ERROR at line 1:
ORA-01722: invalid number


SQL> SELECT SYSDATE - TO_DATE('01/JANUARY/2007') FROM DUAL;

SYSDATE-TO_DATE('01/JANUARY/2007')
----------------------------------
                        3743.21299

SQL> SELECT SYSDATE - TO_DATE('01-JANUARY-2007') FROM DUAL;

SYSDATE-TO_DATE('01-JANUARY-2007')
----------------------------------
                        3743.21311

SQL> SELECT TO_CHAR(SYSDATE, 'DD-MON-YYYY') - '01-JAN-2007' FROM DUAL;
SELECT TO_CHAR(SYSDATE, 'DD-MON-YYYY') - '01-JAN-2007' FROM DUAL
       *
ERROR at line 1:
ORA-01722: invalid number


SQL> SELECT TO_DATE(SYSDATE, 'DD/MONTH/YYYY') - '01/JANUARY/2007' FROM DUAL;
SELECT TO_DATE(SYSDATE, 'DD/MONTH/YYYY') - '01/JANUARY/2007' FROM DUAL
                                           *
ERROR at line 1:
ORA-01722: invalid number

QUESTION 89
You need to display the date 11-oct-2007 in words as 'Eleventh of October, Two Thousand Seven'.
Which SQL statement would give the required result?
A. SELECT TO_CHAR('11-oct-2007', 'fmDdspth "of" Month, Year')
FROM DUAL;
B. SELECT TO_CHAR(TO_DATE('11-oct-2007'), 'fmDdspth of month, year')
FROM DUAL;
C. SELECT TO_CHAR(TO_DATE('11-oct-2007'), 'fmDdthsp "of" Month, Year')
FROM DUAL;
D. SELECT TO_DATE(TO_CHAR('11-oct-2007','fmDdspth ''of'' Month, Year'))
FROM DUAL;
Correct Answer: C
二、题目翻译
需要把11-oct-2007显示为Eleventh of October, Two Thousand Seven
下面哪个SQL能得出所需的结果?

三、题目解析
A选项不正确，'11-oct-2007'本来就是个字符串，还用to_char转换就不对了。
B选项不正确，日期格式不对，如果不属于转换日期格式标识符需要使用双引号，如"of"
C选项正确。
D选项不正确，语法不对，和A类似，本来就是字符串，还转。
日期格式的详细用法，详见：
http://blog.csdn.net/holly2008/article/details/25213993
四、测试
SQL> SELECT TO_CHAR('11-oct-2007', 'fmDdspth "of" Month, Year') FROM DUAL;
SELECT TO_CHAR('11-oct-2007', 'fmDdspth "of" Month, Year') FROM DUAL
               *
ERROR at line 1:
ORA-01722: invalid number


SQL> SELECT TO_CHAR(TO_DATE('11-oct-2007'), 'fmDdspth of month, year') FROM DUAL;
SELECT TO_CHAR(TO_DATE('11-oct-2007'), 'fmDdspth of month, year') FROM DUAL
                                       *
ERROR at line 1:
ORA-01821: date format not recognized


SQL> SELECT TO_CHAR(TO_DATE('11-oct-2007'), 'fmDdthsp "of" Month, Year') FROM DUAL;

TO_CHAR(TO_DATE('11-OCT-2007'),'FMDDTHS
---------------------------------------
Eleventh of October, Two Thousand Seven

SQL> SELECT TO_DATE(TO_CHAR('11-oct-2007','fmDdspth ''of'' Month, Year')) FROM DUAL;
SELECT TO_DATE(TO_CHAR('11-oct-2007','fmDdspth ''of'' Month, Year')) FROM DUAL
                       *
ERROR at line 1:
ORA-01722: invalid number

QUESTION 90
Examine the structure and data in the PRICE_LIST table:
name Null Type
PROD_ID NOT NULL NUMBER(3)
PROD_PRICE VARCHAR2(10)
PROD_ID PROD_PRICE
100 $234.55
101 $6,509.75
102 $1,234
You plan to give a discount of 25% on the product price and need to display the discount amount in the
same format as the PROD_PRICE.
Which SQL statement would give the required result?
A. SELECT TO_CHAR(prod_price* .25,'$99,999.99')
FROM PRICE_LIST;
B. SELECT TO_CHAR(TO_NUMBER(prod_price)* .25,'$99,999.00')
FROM PRICE_LIST;
C. SELECT TO_CHAR(TO_NUMBER(prod_price,'$99,999.99')* .25,'$99,999.00')
FROM PRICE_LIST;
D. SELECT TO_NUMBER(TO_NUMBER(prod_price,'$99,999.99')* .25,'$99,999.00')
FROM PRICE_LIST;
Correct Answer: C
二、题目翻译
下面是查看 PRICE_LIST表的结构和数据
现在计划给product price打折25%，并使用与PROD_PRICE相同格式显示打折后的值
下面哪句SQL能给出所需的结果?

三、题目解析
因为PROD_PRICE是vachar2(10)类型，所以不能直接运算，需要先TO_NUMBER转换成数据型后才能进行计算，然后再TO_CHAR转换成字符型显示。
四、测试
SQL> create table PRICE_LIST(
  2  PROD_ID  NUMBER(3) NOT NULL,
  3  PROD_PRICE VARCHAR2(10)
  4  );

Table created.

SQL> insert into PRICE_LIST values(100, '$234.55');

1 row created.

SQL> insert into PRICE_LIST values(101, '$6,509.75');

1 row created.

SQL> insert into PRICE_LIST values(102, '$1,234');

1 row created.

SQL> select to_char(to_number(prod_price,'$99,999.99')*0.25,'$99,999.99') from PRICE_LIST;

TO_CHAR(TO_
-----------
     $58.64
  $1,627.44
    $308.50
	
QUESTION 91
View the Exhibit and examine the structure of the PROMOTIONS table.
Which two SQL statements would execute successfully? (Choose two.)
A. UPDATE promotions
SET promo_cost = promo_cost+ 100
WHERE TO_CHAR(promo_end_date, 'yyyy') > '2000';
B. SELECT promo_begin_date
FROM promotions
WHERE TO_CHAR(promo_begin_date,'mon dd yy')='jul 01 98';
C. UPDATE promotions
SET promo_cost = promo_cost+ 100
WHERE promo_end_date > TO_DATE(SUBSTR('01-JAN-2000',8));
D. SELECT TO_CHAR(promo_begin_date,'dd/month')
FROM promotions
WHERE promo_begin_date IN (TO_DATE('JUN 01 98'), TO_DATE('JUL 01 98'));
Correct Answer: AB
二、题目翻译
下面是PROMOTIONS表的结构
哪两个SQL语句能执行成功？（选择两个）
三、题目解析
C选项不正确，SUBSTR的结果是字符串'2000',TO_DATE需要第二个参数，日期格式，这里使用YYYY格式符才能转换。
D选项不正确，TO_DATE函数，不写第二个参数，是转成默认日期格式，但这里的字符串显然不是默认日期格式，这样写是无法进行转换的，需要指定日期格式。
四、测试
SQL> UPDATE sh.promotions
  2  SET promo_cost = promo_cost+ 100
  3  WHERE TO_CHAR(promo_end_date, 'yyyy') > '2000';

42 rows updated.

SQL> SELECT promo_begin_date
  2  FROM sh.promotions
  3  WHERE TO_CHAR(promo_begin_date,'mon dd yy')='jul 01 98';

PROMO_BEG
---------
01-JUL-98
01-JUL-98
01-JUL-98
01-JUL-98
01-JUL-98
01-JUL-98

6 rows selected.

SQL> UPDATE sh.promotions
  2  SET promo_cost = promo_cost+ 100
  3  WHERE promo_end_date > TO_DATE(SUBSTR('01-JAN-2000',8));
WHERE promo_end_date > TO_DATE(SUBSTR('01-JAN-2000',8))
                               *
ERROR at line 3:
ORA-01861: literal does not match format string


SQL> SELECT TO_CHAR(promo_begin_date,'dd/month')
  2  FROM sh.promotions
  3  WHERE promo_begin_date IN (TO_DATE('JUN 01 98'), TO_DATE('JUL 01 98'));
WHERE promo_begin_date IN (TO_DATE('JUN 01 98'), TO_DATE('JUL 01 98'))
                                   *
ERROR at line 3:
ORA-01858: a non-numeric character was found where a numeric was expected


SQL> roll back;
Rollback complete.

QUESTION 92
View the E xhibit and examine the data in the PROMO_NAME and PROMO_END_DATE columns of
the PROMOTIONS table, and the required output format.
Which two queries give the correct result? (Choose two.)
Which two queries give the correct result? (Choose two.)
A. SELECT promo_name, TO_CHAR(promo_end_date,'Day')|| ', '||
                                           TO_CHAR(promo_end_date,'Month') ' '
                                           TO_CHAR(promo_end_date,'DD, YYYY') AS last_day
       FROM promotions;

B. SELECT promo_name,TO_CHAR (promo_end_date,'fxDay')|| ', '||
                                          TO_CHAR(promo_end_date,'fxMonth')|| ' '||
                                          TO_CHAR(promo_end_date,'fxDD, YYYY') AS last_day
       FROM promotions;

C. SELECT promo_name, TRIM(TO_CHAR(promo_end_date,'Day')) ||', '||
                                           TRIM(TO_CHAR(promo_end_date,'Month')) ||' '||
                                           TRIM(TO_CHAR(promo_end_date,'DD, YYYY')) AS last_day
       FROM promotions;

D. SELECT promo_name,TO_CHAR(promo_end_date,'fmDay')||','||
                                         TO_CHAR(promo_end_date,'fmMonth')||' '||
                                         TO_CHAR(promo_end_date,'fmDD, YYYY') AS last_day
        FROM promotions;
Correct Answer: CD
二、题目翻译
下面是 PROMOTIONS表的PROMO_NAME and PROMO_END_DATE列的数据 与 PROMO_END_DATE输出的所需格式：
下面哪两个查询能给出正确结果？（选择两个）

三、题目解析
A选项不正确，都是默认的，显示长度一样，即显示结果会对齐显示，没有去掉多余的空格。
B选项不正确，fx加到此处没什么作用,fx为精确匹配格式，和A选项的结果类似，也是会对齐显示，有多余的空格。
C选项正确，使用trim函数去掉左右多余的空格。
D选项正确，使用fm去掉多余的空格。

fm的详细使用方法，详见:
http://blog.csdn.net/holly2008/article/details/25213993

四、测试 
SQL> SELECT promo_name, TO_CHAR(promo_end_date,'Day')|| ', '||
  2                                             TO_CHAR(promo_end_date,'Month') ' '
  3                                             TO_CHAR(promo_end_date,'DD, YYYY') AS last_day
  4         FROM sh.promotions where rownum<5;
                                           TO_CHAR(promo_end_date,'Month') ' '
                                                                           *
ERROR at line 2:
ORA-00923: FROM keyword not found where expected

SQL> set linesize 200
SQL> SELECT promo_name,TO_CHAR (promo_end_date,'fxDay')|| ', '||
  2                                            TO_CHAR(promo_end_date,'fxMonth')|| ' '||
  3                                            TO_CHAR(promo_end_date,'fxDD, YYYY') AS last_day
  4         FROM sh.promotions where rownum<5;

PROMO_NAME                     LAST_DAY
------------------------------ -----------------------------------------------------------------------------------
NO PROMOTION #                 Friday   , January   01, 9999
newspaper promotion #16-108    Tuesday  , January   23, 2001
post promotion #20-232         Wednesday, November  25, 1998
newspaper promotion #16-349    Thursday , September 10, 1998

SQL> SELECT promo_name, TRIM(TO_CHAR(promo_end_date,'Day')) ||', '||
                                           TRIM(TO_CHAR(promo_end_date,'Month')) ||' '||
                                           TRIM(TO_CHAR(promo_end_date,'DD, YYYY')) AS last_day
  4         FROM sh.promotions where rownum<5;

PROMO_NAME                     LAST_DAY
------------------------------ -----------------------------------------------------------------------------------
NO PROMOTION #                 Friday, January 01, 9999
newspaper promotion #16-108    Tuesday, January 23, 2001
post promotion #20-232         Wednesday, November 25, 1998
newspaper promotion #16-349    Thursday, September 10, 1998

SELECT promo_name,TO_CHAR(promo_end_date,'fmDay')||','||
                                         TO_CHAR(promo_end_date,'fmMonth')||' '||
                                         TO_CHAR(promo_end_date,'fmDD, YYYY') AS last_day
  4          FROM sh.promotions where rownum<5;

PROMO_NAME                     LAST_DAY
------------------------------ ----------------------------------------------------------------------------------
NO PROMOTION #                 Friday,January 1, 9999
newspaper promotion #16-108    Tuesday,January 23, 2001
post promotion #20-232         Wednesday,November 25, 1998
newspaper promotion #16-349    Thursday,September 10, 1998

QUESTION 93
View the Exhibit and examine the structure of the CUSTOMERS table.
Using the CUSTOMERS table, y ou need to generate a report that shows an increase in the credit limit
by 15% for all customers. Customers whose credit limit has not been entered should have the message "
Not Available" displayed.
Which SQL statement would produce the required result?
A. SELECT NVL(cust_credit_limit,'Not Available')*.15 "NEW CREDIT"
FROM customers;
B. SELECT NVL(cust_credit_limit*.15,'Not Available') "NEW CREDIT"
FROM customers;
C. SELECT TO_CHAR(NVL(cust_credit_limit*.15,'Not Available')) "NEW CREDIT"
FROM customers;
D. SELECT NVL(TO_CHAR(cust_credit_limit*.15),'Not Available') "NEW CREDIT"
FROM customers;
Correct Answer: D

二、题目翻译
下面是CUSTOMERS表的结构：
根据CUSTOMERS表生成一个报表，显示所有客户增长15%的credit limit.如果客户没有credit limit则显示Not Available.
哪个SQL语句给出所需结果？

三、题目解析
A、B、C选项不正确，原因类似，NVL函数第一个参数是number类型，第二个参数是字符类型，无法隐式转换。
D选项正确，先将cust_credit_limit * 0.15，这是数值类型，用to_char转成字符类型，nvl的两个参数类型一致，就正确了。
四、测试
NVL函数的详细用法，参考：
http://blog.csdn.net/holly2008/article/details/25251513
SQL> with customers as (
  2  select 15 cust_credit_limit from dual
  3  union all 
  4  select 188.2 cust_credit_limit from dual
  5  union all 
  6  select null cust_credit_limit from dual
  7  )
  8  SELECT NVL(cust_credit_limit,'Not Available')*.15 "NEW CREDIT" FROM customers;
SELECT NVL(cust_credit_limit,'Not Available')*.15 "NEW CREDIT" FROM customers
                             *
ERROR at line 8:
ORA-01722: invalid number


SQL> with customers as (
  2  select 15 cust_credit_limit from dual
  3  union all 
  4  select 188.2 cust_credit_limit from dual
  5  union all 
  6  select null cust_credit_limit from dual
  7  )
  8  SELECT NVL(cust_credit_limit*.15,'Not Available') "NEW CREDIT"
  9  FROM customers;
SELECT NVL(cust_credit_limit*.15,'Not Available') "NEW CREDIT"
                                 *
ERROR at line 8:
ORA-01722: invalid number


SQL> with customers as (
  2  select 15 cust_credit_limit from dual
  3  union all 
  4  select 188.2 cust_credit_limit from dual
  5  union all 
  6  select null cust_credit_limit from dual
  7  )
  8  SELECT TO_CHAR(NVL(cust_credit_limit*.15,'Not Available')) "NEW CREDIT"
  9  FROM customers;
SELECT TO_CHAR(NVL(cust_credit_limit*.15,'Not Available')) "NEW CREDIT"
                                         *
ERROR at line 8:
ORA-01722: invalid number


SQL> with customers as (
  2  select 15 cust_credit_limit from dual
  3  union all 
  4  select 188.2 cust_credit_limit from dual
  5  union all 
  6  select null cust_credit_limit from dual
  7  )
  8  SELECT NVL(TO_CHAR(cust_credit_limit*.15),'Not Available') "NEW CREDIT"
  9  FROM customers;

NEW CREDIT
----------------------------------------
2.25
28.23
Not Available

1.NVL函数
       NVL(expr1,expr2)

如果expr1和expr2的数据类型一致，则：
如果expr1为空(null),那么显示expr2，
如果expr1的值不为空，则显示expr1
2.NVL2函数
   NVL2(expr1,expr2, expr3)

如果expr1不为NULL，返回expr2； expr1为NULL，返回expr3。
expr2和expr3类型不同的话，expr3会转换为expr2的类型，转换不了，则报错。
3. NULLIF函数
       NULLIF(expr1,expr2)
如果expr1和expr2相等则返回空(NULL)，否则返回expr1。
4.coalesce函数
     coalesce(expr1, expr2, expr3….. exprn)
返回表达式中第一个非空表达式，如果都为空则返回空值。
所有表达式必须是相同类型，或者可以隐式转换为相同的类型，否则报错。

Coalese函数和NVL函数功能类似，只不过选项更多。

coalesce

英 [,kəʊə'les]  美 [,koə'lɛs]
vi. 合并；结合；联合
vt. 使…联合；使…合并
过去式 coalesced过去分词 coalesced现在分词 coalescing


QUESTION 94
Examine the structure of the PROGRAMS table:
name Null Type
PROG_ID NOT NULL NUMBER(3)
PROG_COST NUMBER(8,2)
START_DATE NOT NULL DATE
END_DATE DATE
Which two SQL statements would execute successfully? (Choose two.)
A. SELECT NVL(ADD_MONTHS(END_DATE,1),SYSDATE)
FROM programs;
B. SELECT TO_DATE(NVL(SYSDATE-END_DATE,SYSDATE))
FROM programs;
C. SELECT NVL(MONTHS_BETWEEN(start_date,end_date),'Ongoing')
FROM programs;
D. SELECT NVL(TO_CHAR(MONTHS_BETWEEN(start_date,end_date)),'Ongoing')
FROM programs;
Correct Answer: AD
二、题目翻译
查看PROGRAMS表的结构
哪两个SQL语句执行成功？（选择两个）

三、题目解析
A选项正确，ADD_MONTHS返回date类型，第二参数sysdate也是date类型，NVL两个参数类型一致。
B选项不正确，SYSDATE-END_DATE结果是一个number类型，nvl的第二个参数是date类型,会隐式转换为number类型，to_date参数是number类型，会报错。
C选项不正确，MONTHS_BETWEEN返回一个number类型，nvl第一个参数number类型，第二个参数字符串类型，无法隐式转换，报错。
D选项正确，MONTHS_BETWEEN返回的是number类型，to_char转成了字符类型，这样nvl的两个参数类型一致。

Months_between函数：返回一个number类型，如果第一个参数的日期大于第二个参数参数的日期，则返回正数，否则返回负数。

四、测试
SQL> create table PROGRAMS(
  2  PROG_ID NUMBER(3) NOT NULL primary key ,
  3  PROG_COST NUMBER(8,2),
  4  START_DATE  DATE NOT NULL,
  5  END_DATE DATE);

Table created.

SQL> insert into PROGRAMS values(1,50,sysdate,null);
SQL> insert into PROGRAMS  values(2,60,'1-february-2008','1-jan-2017');
SQL> insert into PROGRAMS  values(3,75,'1-march-2016',default);

SQL> SELECT NVL(ADD_MONTHS(END_DATE,1),SYSDATE) FROM programs;

NVL(ADD_M
---------
05-APR-17
01-FEB-17
05-APR-17
SQL> SELECT TO_DATE(NVL(SYSDATE-END_DATE,SYSDATE)) FROM programs;
SELECT TO_DATE(NVL(SYSDATE-END_DATE,SYSDATE)) FROM programs
               *
ERROR at line 1:
ORA-01861: literal does not match format string
SQL> SELECT NVL(MONTHS_BETWEEN(start_date,end_date),'Ongoing') FROM programs;
SELECT NVL(MONTHS_BETWEEN(start_date,end_date),'Ongoing') FROM programs
                                               *
ERROR at line 1:
ORA-01722: invalid number

SQL> SELECT NVL(TO_CHAR(MONTHS_BETWEEN(start_date,end_date)),'Ongoing') FROM programs;

NVL(TO_CHAR(MONTHS_BETWEEN(START_DATE,EN
----------------------------------------
Ongoing
-107
Ongoing

QUESTION 95
The PRODUCTS table has the following structure:
name Null Type
PROD_ID NOT NULL NUMBER(4)
PROD_NAME VARCHAR2(25)
PROD_EXPIRY_ DATE DATE
Evaluate the following two SQL statements:
SQL>SELECT prod_id, NVL2(prod_expiry_date, prod_expiry_date + 15,'')
FROM products;
SQL>SELECT prod_id, NVL(prod_expiry_date, prod_expiry_date + 15)
FROM products;
Which statement is true regarding the outcome?
A. Both the statements execute and give different results.
B. Both the statements execute and give the same result.
C. Only the first SQL statement executes successfully.
D. Only the second SQL statement executes successfully.
Correct Answer: A


MONTH_BETWEETN的用法详见：
http://blog.csdn.net/holly2008/article/details/23141827

QUESTION 95
The PRODUCTS table has the following structure:
name Null Type
PROD_ID NOT NULL NUMBER(4)
PROD_NAME VARCHAR2(25)
PROD_EXPIRY_ DATE DATE
Evaluate the following two SQL statements:
SQL>SELECT prod_id, NVL2(prod_expiry_date, prod_expiry_date + 15,'')
FROM products;
SQL>SELECT prod_id, NVL(prod_expiry_date, prod_expiry_date + 15)
FROM products;
Which statement is true regarding the outcome?
A. Both the statements execute and give different results.
B. Both the statements execute and give the same result.
C. Only the first SQL statement executes successfully.
D. Only the second SQL statement executes successfully.
Correct Answer: A
二、题目翻译
下面是PRODUCTS表的结构：
看下面两个SQL语句
关于结果，下面哪个描述语句是正确的？
A.两个都执行成功，但给出不同的结果。
B.两个都执行成功，并给出相同的结果。
C.只有第一个执行成功。
D.只有第二个执行成功。

三、题目解析
第一条语句当prod_expiry_date为null时输出第二个参数’’也是空,不为空时输出和一个prod_expiry_date + 15，
而第二条语句当prod_expiry_date为null时输出第二个参数，不为空时输出prod_expiry_date。
MONTHS_BETWEEN (date1, date2)
用于计算date1和date2之间有几个月。

如果date1在日历中比date2晚，那么MONTHS_BETWEEN()就返回一个正数。
如果date1在日历中比date2早，那么MONTHS_BETWEEN()就返回一个负数。
如果date1和date2日期一样，那么MONTHS_BETWEEN()就返回一个0。
SQL> select months_between(to_date('2014-3-21','yyyy-mm-dd'), to_date('2014-1-10','yyyy-mm-dd')) months from dual;

    MONTHS
----------
2.35483871

SQL> select months_between(to_date('2014-1-10','yyyy-mm-dd'), to_date('2014-3-21','yyyy-mm-dd')) months from dual;

    MONTHS
----------
-2.3548387

SQL> select months_between(to_date('2014-1-10','yyyy-mm-dd'), to_date('2014-1-10','yyyy-mm-dd')) months from dual;

    MONTHS
----------
         0
SQL> select 11/31 from dual; --2014.3.21和2014.1.10之间，相差2个月加11天，11天按月换算成小数(在oracle里面，以31天为基数):

     11/31
----------
 .35483871 

详细参见11.2联机文档:
http://docs.oracle.com/cd/E11882_01/server.112/e41084/functions102.htm#SQLRF00669

MONTHS_BETWEEN returns number of months between dates date1 and date2. The month and the last day of the month are defined by the parameter NLS_CALENDAR. If date1 is later than date2, then the result is positive. If date1 is earlier than date2, then the result is negative. If date1 and date2 are either the same days of the month or both last days of months, then the result is always an integer.Otherwise Oracle Database calculates the fractional portion of the result based on a31-day month and considers the difference in time components date1 and date2.

QUESTION 96
Examine the structure of the INVOICE table.
name Null Type
INV_NO NOT NULL NUMBER(3)
INV_DATE DATE
INV_AMT NUMBER(10,2)
Which two SQL statements would execute successfully? (Choose two.)
A. SELECT inv_no,NVL2(inv_date,'Pending','Incomplete')
FROM invoice;
B. SELECT inv_no,NVL2(inv_amt,inv_date,'Not Available')
FROM invoice;
C. SELECT inv_no,NVL2(inv_date,sysdate-inv_date,sysdate)
FROM invoice;
D. SELECT inv_no,NVL2(inv_amt,inv_amt*.25,'Not Available')
FROM invoice;
Correct Answer: AC
二、题目翻译
下面是INVOICE表的结构:
下面哪些语句能执行成功(选择2个)？

三、题目解析
A选项正确，第一个参数是date类型，可以隐式转换成字符类型。
B选项不正确，inv_amt是number类型,inv_date是日期类型，最后一个参数是字符类型，number类型不能隐式转成日期类型，所以隐式转换时出错。
C选项正确，第一个参数是date类型，第二个参数是number类型，第三个参数是date类型，都可以隐式转换成number类型。
D选项不正确，第一，二个参数是number类型，第三个是字符类型，隐式转换时报错。

QUESTION 97
View the Exhibit and evaluate the structure and data in the CUST_STATUS table.
You issue the following SQL statement:
SQL> SELECT custno, NVL2(NULLIF(amt_spent, credit_limit), 0, 1000)"BONUS"
FROM cust_status;
Which statement is true regarding the execution of the above query?
A. It produces an error because the AMT_SPENT column contains a null value.
B. It displays a bonus of 1000 for all customers whose AMT_SPENT is less than CREDIT_LIMIT
C. It displays a bonus of 1000 for all customers whose AMT_SPENT equals CREDIT_LIMIT, or
AMT_SPENT is null .
D. It produces an error because the TO_NUMBER function must be used to convert the result of the
NULLIF function before it can be used by the NVL2 function.
Correct Answer: C

二、题目翻译
查看 CUST_STATUS表结构和数据，
执行下面的语句：
关于上面的查询哪句话是正确的？
A.报错，因为AMT_SPENT包含空值。
B.显示所有AMT_SPENT小于CREDIT_LIMIT的员工有1000元奖金。
C.显示所有AMT_SPENT等于CREDIT_LIMIT或AMT_SPENT为空的员工有1000元奖金。
D.报错，因为在使用NVL2函数之前，需要使用TO_NUMBER函数把NULLIF函数的结果进行转换。

NULLIF(amt_spent, credit_limit) amt_spent, credit_limit相同返回null, 否则返回amt_spent
NVL2 不为空返回０，为空返回1000
所以当amt_spent, credit_limit相同或amt_spent为空间NVL2返回第三个参数的值1000

QUESTION 98
Which statement is true regarding the COALESCE function?
A. It can have a maximum of five expressions in a list.
B. It returns the highest NOT NULL value in the list for all rows.
C. It requires that all expressions in the list must be of the same data type.
D. It requires that at least one of the expressions in the list must have a NOT NULL value.
Correct Answer: C
二、题目翻译
关于COALESCE函数哪一句话是正确的？
A. 最大只能包含5个表达式列表。
B. 返回列表中最高的一个非空值。
C. 列表中所有表达式的数据类型必须一致。
D. 列表中至少要有一个表达式为非空。

三、题目解析
A选项不正确，coalesce函数的参数，可以有多个。
B选项不正确，是返回列表中第一个非null值。
C选项正确。
D选项不正确，如果表达式都为null,则返回null。

coalesce函数
     coalesce(expr1, expr2, expr3….. exprn)
返回表达式中第一个非空表达式，如果都为空则返回空值。
所有表达式必须是相同类型，或者可以隐式转换为相同的类型，否则报错。

QUESTION 99
View the Exhibit and examine the structure of the PROMOTIONS table.
Using the PROMOTIONS table, you need to find out the average cost for all promos in the ranges
$0-2000 and $2000-5000 in category A
You issue the following SQL statement:
SQL>SELECT AVG(CASE
WHEN promo_cost BETWEEN 0 AND 2000 AND promo_category='A'
then promo_cost
ELSE null END) "CAT_2000A",
AVG(CASE
WHEN promo_cost BETWEEN 2001 AND 5000 AND promo_category='A'
THEN promo_cost
ELSE null END) "CAT_5000A"
FROM promotions;
What would be the outcome?
A. It executes successfully and gives the required result.
B. It generates an error because NULL cannot be specified as a return value.
C. It generates an error because CASE cannot be used with group functions.
D. It generates an error because multiple conditions cannot be specified for the WHEN clause.
Correct Answer: A
二、题目翻译
下面是PROMOTIONS表的结构：
使用PROMOTIONS表，你需要找出category A中在$0-2000范围和$2000-5000范围内的所有promos的平均成本(cost).
执行下面的SQL语句：
结果是什么？
A.执行成功，并得出所需结果。
B.报错，因为NULL不能作为一个返回值被指定。
C.报错，因为CASE不能用在组函数中。
D.报错，因为WHEN子句不能指定多个条件。

三、题目解析
NULL值在avg函数中不会计算，所以计算平均值时会忽略null值，例如：返回4行，有1行为空，则平均值就是总数/3。

https://github.com/tomlxq/oracle-study/blob/master/ocp/2_case%20when%E5%92%8Cdecode%E7%9A%84%E7%94%A8%E6%B3%95%E4%B8%8E%E5%8C%BA%E5%88%AB.sql

SQL> SELECT AVG(CASE
  2  WHEN promo_cost BETWEEN 0 AND 2000 AND promo_category='A'
  3  then promo_cost
  4  ELSE null END) "CAT_2000A",
  5  AVG(CASE
  6  WHEN promo_cost BETWEEN 2001 AND 5000 AND promo_category='A'
  7  THEN promo_cost
  8  ELSE null END) "CAT_5000A"
  9  FROM sh.promotions;

 CAT_2000A  CAT_5000A
---------- ----------

QUESTION 100
View the Exhibit and examine the structure of the PROMOTIONS table.
Which SQL statements are valid? (Choose all that apply.)
A. SELECT promo_id, DECODE(NVL(promo_cost,0), promo_cost,
promo_cost * 0.25, 100) "Discount"
FROM promotions;
B. SELECT promo_id, DECODE(promo_cost, 10000,
DECODE(promo_category, 'G1', promo_cost *.25, NULL),
NULL) "Catcost"
FROM promotions;
C. SELECT promo_id, DECODE(NULLIF(promo_cost, 10000),
NULL, promo_cost*.25, 'N/A') "Catcost"
FROM promotions;
D. SELECT promo_id, DECODE(promo_cost, >10000, 'High',
<10000, 'Low') "Range"
FROM promotions;
Correct Answer: AB
二、题目翻译
查看 PROMOTIONS 表的结构
选择所有有效的SQL语句（选择所有正确的选项）。

三、题目解析
C选项不正确，前面几个参数都是number类型，最后一个是字符类型，隐式转换数值时不成功。
D选项语法不正确。
decode
语法:
DECODE(col|expression, search1, result1
                       [, search2, result2,...,]
                        ...
                       [, searchn, resultn,...,]
                       [, default])
如果 条件=值1,那么显示结果1
如果 条件=值2,那么显示结果2
....
如果 条件=值n,那么显示结果n
都不符合，则显示缺省值
QUESTION 101
Examine the data in the PROMO_BEGIN_DATE column of the PROMOTIONS table:
PROMO_BEGIN _DATE
04-jan-00
10-jan-00
15-dec-99
18-oct-98
22-aug-99
You want to display the number of promotions started in 1999 and 2000.
Which query gives the correct output?
A. SELECT SUM(DECODE(SUBSTR(promo_begin_date,8),'00',1,0)) "2000",
SUM(DECODE(SUBSTR(promo_begin_date,8),'99',1,0)) "1999"
FROM promotions;
B. SELECT SUM(CASE TO_CHAR(promo_begin_date,'yyyy') WHEN '99' THEN 1
ELSE 0 END) "1999",SUM(CASE TO_CHAR(promo_begin_date,'yyyy') WHEN '00' THEN 1
ELSE 0 END) "2000"
FROM promotions;
C. SELECT COUNT(CASE TO_CHAR(promo_begin_date,'yyyy') WHEN '99' THEN 1
ELSE 0 END) "1999",COUNT(CASE TO_CHAR(promo_begin_date,'yyyy') WHEN '00' THEN 1
ELSE 0 END) "2000"
FROM promotions;
D. SELECT COUNT(CASE TO_CHAR(promo_begin_date,'yyyy') WHEN '99' THEN 1
ELSE 0 END) "1999",COUNT(CASE TO_CHAR(promo_begin_date,'yyyy') WHEN '00' THEN 1
ELSE 0 END) "2000"
FROM promotions;
Correct Answer: A
二、题目翻译
查看PROMOTIONS表中PROMO_BEGIN_DATE列的数据
要显示在1999 和2000年开始的promotions的数量
下面哪一个查询给出正确结果？

三、题目解析
B和C选项不正确，TO_CHAR(promo_begin_date, 'yyyy')这个结果就是年显示成四位，但和后面的'00'比较，肯定比对不上。
D选项不正确，SUBSTR(TO_CHAR(promo_begin_date, 'yyyy'), 8),to_char的结果只有4个字符了，截取字符的时候，从第8位开始，明显不对，超出范围。

SELECT SUM(DECODE(SUBSTR(promo_begin_date,8),'00',1,0)) "2000",
SUM(DECODE(SUBSTR(promo_begin_date,8),'99',1,0)) "1999"
  3  FROM sh.promotions;

      2000       1999
---------- ----------
       166        168
	   
QUESTION 102
Examine the structure of the TRANSACTIONS table:
name Null Type
TRANS_ID NOT NULL NUMBER(3)
CUST_NAME VARCHAR2(30)
TRANS_DATE TIMESTAMPTRANS_AMT NUMBER(10,2)
You want to display the date, time, and transaction amount of transactions that where done before 12
noon. The value zero should be displayed for transactions where the transaction amount has not been
entered.
Which query gives the required result?
A. SELECT TO_CHAR(trans_date,'dd-mon-yyyy hh24:mi:ss'),
TO_CHAR(trans_amt,'$99999999D99')
FROM transactions
WHERE TO_NUMBER(TO_DATE(trans_date,'hh24')) < 12 AND COALESCE(trans_amt,NULL)
<>NULL;
B. SELECT TO_CHAR(trans_date,'dd-mon-yyyy hh24:mi:ss'),
NVL(TO_CHAR(trans_amt,'$99999999D99'),0)
FROM transactions
WHERE TO_CHAR(trans_date,'hh24') < 12;
C. SELECT TO_CHAR(trans_date,'dd-mon-yyyy hh24:mi:ss'),
COALESCE(TO_NUMBER(trans_amt,'$99999999.99'),0)
FROM transactions
WHERE TO_DATE(trans_date,'hh24') < 12;
D. SELECT TO_DATE (trans_date,'dd-mon-yyyy hh24:mi:ss'),
NVL2(trans_amt,TO_NUMBER(trans_amt,'$99999999.99'), 0)
FROM transactions
WHERE TO_DATE(trans_date,'hh24') < 12;
Correct Answer: B
二、题目翻译
查看表结构
要显示在中午12点之前完成的交易的日期、时间和数量。如果transaction数量没有值则显示0。
哪一个查询给出所需结果？

三、题目解析
A选项不正确，WHERE条条中，应该是to_char,不是to_date
CD选项不正确，trans_amt是number类型，TO_NUMBER函数转换会出错。
QUESTION 103
Examine the structure of the TRANSACTIONS table:
name Null Type
TRANS_ID NOT NULL NUMBER(3)
CUST_NAME VARCHAR2(30)
TRANS_DATE DATE
TRANS_AMT NUMBER(10,2)
You want to display the transaction date and specify whether it is a weekday or weekend.
Evaluate the following two queries:
SQL>SELECT TRANS_DATE,CASE
WHEN TRIM(TO_CHAR(trans_date,'DAY')) IN ('SATURDAY','SUNDAY') THEN 'weekend'
ELSE 'weekday'
END "Day Type"
FROM transactions;
SQL>SELECT TRANS_DATE, CASE
WHEN TO_CHAR(trans_date,'DAY') BETWEEN 'MONDAY' AND 'FRIDAY' THEN 'weekday'
ELSE 'weekend'
END "Day Type"FROM transactions;
Which statement is true regarding the above queries?
A. Both give wrong results.
B. Both give the correct result.
C. Only the first query gives the correct result.
D. Only the second query gives the correct result.
Correct Answer: C
三、题目解析
第一句正确，用TO_CHAR(trans_date,'DAY')先显示出星期几，然后用trim把多余的空格去掉，然后用case when判断，是否是周六、周日，是的话就显示为周末，否则显示为工作日。
第二句不正确，TO_CHAR(trans_date,'DAY')转换出来的星期几，是有多余空格的，所以直接是无法匹配的，而且，这里是字符串，这样用BETWEEN..AND无法做出正确的判断，所以是否工作日，都显示成了周末。
SQL> with  TRANSACTIONS as(
select 1 TRANS_ID,'jack' CUST_NAME,to_date('08-04-2017','dd-mm-yyyy') TRANS_DATE,18.5 TRANS_AMT from dual
  union 
  select 2 TRANS_ID,'tom' CUST_NAME,to_date('07-04-2017','dd-mm-yyyy') TRANS_DATE,19.5 TRANS_AMT from dual
  union 
  select 3 TRANS_ID,'meimei' CUST_NAME,to_date('06-04-2017','dd-mm-yyyy') TRANS_DATE,19.5 TRANS_AMT from dual
  union 
  select 4 TRANS_ID,'litao' CUST_NAME,to_date('05-04-2017','dd-mm-yyyy') TRANS_DATE,19.5 TRANS_AMT from dual
  union 
  select 5 TRANS_ID,'lilei' CUST_NAME,to_date('04-04-2017','dd-mm-yyyy') TRANS_DATE,19.5 TRANS_AMT from dual
  union 
  select 6 TRANS_ID,'rose' CUST_NAME,to_date('03-04-2017','dd-mm-yyyy') TRANS_DATE,19.5 TRANS_AMT from dual
  union 
  select 6 TRANS_ID,'polly' CUST_NAME,to_date('02-04-2017','dd-mm-yyyy') TRANS_DATE,19.5 TRANS_AMT from dual
  )
  SELECT TRANS_DATE,CASE
  WHEN TRIM(TO_CHAR(trans_date,'DAY')) IN ('SATURDAY','SUNDAY') THEN 'weekend'
  ELSE 'weekday'
  END "Day Type",TO_CHAR(trans_date,'DAY')
  FROM transactions;

TRANS_DAT Day Typ TO_CHAR(TRANS_DATE,'DAY')
--------- ------- ------------------------------------
08-APR-17 weekend SATURDAY
07-APR-17 weekday FRIDAY
06-APR-17 weekday THURSDAY
05-APR-17 weekday WEDNESDAY
04-APR-17 weekday TUESDAY
02-APR-17 weekend SUNDAY
03-APR-17 weekday MONDAY

7 rows selected.
SQL> with  TRANSACTIONS as(
select 1 TRANS_ID,'jack' CUST_NAME,to_date('08-04-2017','dd-mm-yyyy') TRANS_DATE,18.5 TRANS_AMT from dual
union 
select 2 TRANS_ID,'tom' CUST_NAME,to_date('07-04-2017','dd-mm-yyyy') TRANS_DATE,19.5 TRANS_AMT from dual
union 
select 3 TRANS_ID,'meimei' CUST_NAME,to_date('06-04-2017','dd-mm-yyyy') TRANS_DATE,19.5 TRANS_AMT from dual
 union 
 select 4 TRANS_ID,'litao' CUST_NAME,to_date('05-04-2017','dd-mm-yyyy') TRANS_DATE,19.5 TRANS_AMT from dual
 union 
 select 5 TRANS_ID,'lilei' CUST_NAME,to_date('04-04-2017','dd-mm-yyyy') TRANS_DATE,19.5 TRANS_AMT from dual
 union 
 select 6 TRANS_ID,'rose' CUST_NAME,to_date('03-04-2017','dd-mm-yyyy') TRANS_DATE,19.5 TRANS_AMT from dual
 union 
 select 6 TRANS_ID,'polly' CUST_NAME,to_date('02-04-2017','dd-mm-yyyy') TRANS_DATE,19.5 TRANS_AMT from dual
 )
 SELECT TRANS_DATE, CASE
 WHEN TO_CHAR(trans_date,'DAY') BETWEEN 'MONDAY' AND 'FRIDAY' THEN 'weekday'
 ELSE 'weekend'
 END "Day Type",TO_CHAR(trans_date,'DAY') FROM transactions;

TRANS_DAT Day Typ TO_CHAR(TRANS_DATE,'DAY')
--------- ------- ------------------------------------
08-APR-17 weekend SATURDAY
07-APR-17 weekend FRIDAY
06-APR-17 weekend THURSDAY
05-APR-17 weekend WEDNESDAY
04-APR-17 weekend TUESDAY
02-APR-17 weekend SUNDAY
03-APR-17 weekend MONDAY

7 rows selected.

QUESTION 104
Examine the structure of the PROMOS table:
name Null Type
PROMO_ID NOT NULL NUMBER(3)
PROMO_NAME VARCHAR2(30)
PROMO_START_DATE NOT NULL DATE
PROMO_END_DATE DATE
You want to generate a report showing promo names and their duration (number of days). If the
PROMO_END_DATE has not been entered, the message 'ONGOING' should be displayed.
Which queries give the correct output? (Choose all that apply.)
A. SELECT promo_name, TO_CHAR(NVL(promo_end_date -promo_start_date,'ONGOING'))
FROM promos;
B. SELECT promo_name,COALESCE(TO_CHAR(promo_end_date - promo_start_date),'ONGOING')
FROM promos;
C. SELECT promo_name, NVL(TO_CHAR(promo_end_date -promo_start_date),'ONGOING')
FROM promos;
D. SELECT promo_name, DECODE(promo_end_date
-promo_start_date,NULL,'ONGOING',promo_end_date - promo_start_date)
FROM promos;
E. SELECT promo_name, decode(coalesce(promo_end_date,promo_start_date),null,'ONGOING',
promo_end_date - promo_start_date)
FROM promos;
Correct Answer: BCD
二、题目翻译
查看表结构
显示promo names和their duration，如果PROMO_END_DATE没有值，则显示'ONGOING'。
哪个查询能得出正确的结果(选择所有正确选项)？

三、题目解析
A选项不正确，因为隐式转换'ONGOING'为数值类型的会报错。
E选项不正确，不能输出正确的结果。
SQL> with PROMOS as (
select 1 PROMO_ID,'tom' PROMO_NAME, to_date('2017-04-06','yyyy-mm-dd') PROMO_START_DATE,to_date('2017-04-05','yyyy-mm-dd') PROMO_END_DATE from dual
union 
select 2 PROMO_ID,'jack' PROMO_NAME, to_date('2017-04-06','yyyy-mm-dd') PROMO_START_DATE,null PROMO_END_DATE from dual
union 
select 3 PROMO_ID,'monkey' PROMO_NAME, to_date('2017-04-06','yyyy-mm-dd') PROMO_START_DATE,null PROMO_END_DATE from dual
)SELECT promo_name, TO_CHAR(NVL(promo_end_date -promo_start_date,'ONGOING'))
  8  FROM promos;
)SELECT promo_name, TO_CHAR(NVL(promo_end_date -promo_start_date,'ONGOING'))
                                                                 *
ERROR at line 7:
ORA-01722: invalid number

SQL> with PROMOS as (
select 1 PROMO_ID,'tom' PROMO_NAME, to_date('2017-04-06','yyyy-mm-dd') PROMO_START_DATE,to_date('2017-04-05','yyyy-mm-dd') PROMO_END_DATE from dual
union 
select 2 PROMO_ID,'jack' PROMO_NAME, to_date('2017-04-06','yyyy-mm-dd') PROMO_START_DATE,null PROMO_END_DATE from dual
union 
  6  select 3 PROMO_ID,'monkey' PROMO_NAME, to_date('2017-04-06','yyyy-mm-dd') PROMO_START_DATE,null PROMO_END_DATE from dual
  7  )SELECT promo_name,COALESCE(TO_CHAR(promo_end_date - promo_start_date),'ONGOING')
  8  FROM promos;

PROMO_ COALESCE(TO_CHAR(PROMO_END_DATE-PROMO_ST
------ ----------------------------------------
tom    -1
jack   ONGOING
monkey ONGOING

SQL> with PROMOS as (
select 1 PROMO_ID,'tom' PROMO_NAME, to_date('2017-04-06','yyyy-mm-dd') PROMO_START_DATE,to_date('2017-04-05','yyyy-mm-dd') PROMO_END_DATE from dual
union 
  4  select 2 PROMO_ID,'jack' PROMO_NAME, to_date('2017-04-06','yyyy-mm-dd') PROMO_START_DATE,null PROMO_END_DATE from dual
  5  union 
  6  select 3 PROMO_ID,'monkey' PROMO_NAME, to_date('2017-04-06','yyyy-mm-dd') PROMO_START_DATE,null PROMO_END_DATE from dual
)SELECT promo_name, NVL(TO_CHAR(promo_end_date -promo_start_date),'ONGOING')
  8  FROM promos;

PROMO_ NVL(TO_CHAR(PROMO_END_DATE-PROMO_START_D
------ ----------------------------------------
tom    -1
jack   ONGOING
monkey ONGOING

SQL> with PROMOS as (
select 1 PROMO_ID,'tom' PROMO_NAME, to_date('2017-04-06','yyyy-mm-dd') PROMO_START_DATE,to_date('2017-04-05','yyyy-mm-dd') PROMO_END_DATE from dual
union 
select 2 PROMO_ID,'jack' PROMO_NAME, to_date('2017-04-06','yyyy-mm-dd') PROMO_START_DATE,null PROMO_END_DATE from dual
  5  union 
  6  select 3 PROMO_ID,'monkey' PROMO_NAME, to_date('2017-04-06','yyyy-mm-dd') PROMO_START_DATE,null PROMO_END_DATE from dual
  7  )SELECT promo_name, DECODE(promo_end_date
  8  -promo_start_date,NULL,'ONGOING',promo_end_date - promo_start_date)
  9  FROM promos;

PROMO_ DECODE(PROMO_END_DATE-PROMO_START_DATE,N
------ ----------------------------------------
tom    -1
jack   ONGOING
monkey ONGOING

SQL> with PROMOS as (
select 1 PROMO_ID,'tom' PROMO_NAME, to_date('2017-04-06','yyyy-mm-dd') PROMO_START_DATE,to_date('2017-04-05','yyyy-mm-dd') PROMO_END_DATE from dual
union 
select 2 PROMO_ID,'jack' PROMO_NAME, to_date('2017-04-06','yyyy-mm-dd') PROMO_START_DATE,null PROMO_END_DATE from dual
union 
  6  select 3 PROMO_ID,'monkey' PROMO_NAME, to_date('2017-04-06','yyyy-mm-dd') PROMO_START_DATE,null PROMO_END_DATE from dual
  7  )SELECT promo_name, decode(coalesce(promo_end_date,promo_start_date),null,'ONGOING',
  8  promo_end_date - promo_start_date)
  9  FROM promos;

PROMO_ DECODE(COALESCE(PROMO_END_DATE,PROMO_STA
------ ----------------------------------------
tom    -1
jack
monkey

QUESTION 105
Examine the structure of the PROMOS table:
name Null Type
PROMO_ID NOT NULL NUMBER(3)
PROMO_NAME VARCHAR2(30)
PROMO_START_DATE NOT NULL DATE
PROMO_END_DATE NOT NULL DATE
You want to display the list of promo names with the message 'Same Day' for promos that started and
ended on the same day.
Which query gives the correct output?
A. SELECT promo_name, NVL(NULLIF(promo_start_date, promo_end_date), 'Same Day')
FROM promos;
B. SELECT promo_name, NVL(TRUNC(promo_end_date - promo_start_date), 'Same Day')
FROM promos;
C. SELECT promo_name, NVL2(TO_CHAR(TRUNC(promo_end_date-promo_start_date)), NULL,'Same
Day')
FROM promos;
D. SELECT promo_name, DECODE((NULLIF(promo_start_date, promo_end_date)), NULL,'Same day')
FROM promos;
Correct Answer: D
二、题目翻译
查看PROMOS表结构:
要显示promos names，如果开始和结束为同一天的promos使用'Same Day'显示.
哪个给出正确输出？

三、题目解析
nullif的意思是，如果两个参数相等，则返回null, 如果不相等，则返回第一个参数的值。
A选项不正确，如果是同一天，则nullif的结果为null,如果不是同一天，则nullif的结果为日期类型，'Same Day'是字符类型，隐式转换成日期时报错。
B选项不正确，TRUNC的结果是数字，'Same Day'隐式转换成数值时报错。
C选项不正确，不能得到想要的结果。

QUESTION 106
Examine the data in the LIST_PRICE and MIN_PRICE columns of the PRODUCTS table:
LIST_PRICE MIN_PRICE
10000 8000
20000
30000 30000
Which two expressions give the same output? (Choose two.)
A. NVL(NULLIF(list_price, min_price), 0)  					1000/2000/0
B. NVL(COALESCE(list_price, min_price), 0)					1000/2000/30000
C. NVL2(COALESCE(list_price, min_price), min_price, 0)		8000/null/30000
D. COALESCE(NVL2(list_price, list_price, min_price), 0)		1000/2000/30000
Correct Answer: BD
二、题目翻译
下面是PRODUCTS表的LIST_PRICE和 MIN_PRICE两列的数据：
哪两个表达式结果相同？

NVL(expr1,expr2)
如果expr1和expr2的数据类型一致，则：
如果expr1的值不为空，则显示expr1
如果expr1为空(null),那么显示expr2

NVL2(expr1,expr2, expr3)
如果expr1不为NULL，返回expr2； expr1为NULL，返回expr3。
expr2和expr3类型不同的话，expr3会转换为expr2的类型，转换不了，则报错。

NULLIF(expr1,expr2)
如果expr1和expr2相等则返回空(NULL)，否则返回expr1。

coalesce(expr1, expr2, expr3….. exprn)
返回表达式中第一个非空表达式，如果都为空则返回空值。
所有表达式必须是相同类型，或者可以隐式转换为相同的类型，否则报错。
 with PRODUCTS as
 (
   select 10000 LIST_PRICE,8000 MIN_PRICE from dual
   union all
   select 20000,null from dual
  6     union all
  7     select 30000,30000 from dual
  8   )
  9   select NVL(NULLIF(list_price, min_price), 0) from products;

NVL(NULLIF(LIST_PRICE,MIN_PRICE),0)
-----------------------------------
                              10000
                              20000
                                  0
SQL>  with PRODUCTS as
  2   (
  3     select 10000 LIST_PRICE,8000 MIN_PRICE from dual
  4     union all
  5     select 20000,null from dual
  6     union all
  7     select 30000,30000 from dual
  8   )
  9   select NVL(COALESCE(list_price, min_price), 0) from products;

NVL(COALESCE(LIST_PRICE,MIN_PRICE),0)
-------------------------------------
                                10000
                                20000
                                30000
SQL>  with PRODUCTS as
  2   (
  3     select 10000 LIST_PRICE,8000 MIN_PRICE from dual
  4     union all
  5     select 20000,null from dual
  6     union all
  7     select 30000,30000 from dual
  8   )
  9   select NVL2(COALESCE(list_price, min_price), min_price, 0) from products;

NVL2(COALESCE(LIST_PRICE,MIN_PRICE),MIN_PRICE,0)
------------------------------------------------
                                            8000

                                           30000
SQL>  with PRODUCTS as
  2   (
  3     select 10000 LIST_PRICE,8000 MIN_PRICE from dual
  4     union all
  5     select 20000,null from dual
  6     union all
  7     select 30000,30000 from dual
  8   )
  9   select COALESCE(NVL2(list_price, list_price, min_price), 0) from products;

COALESCE(NVL2(LIST_PRICE,LIST_PRICE,MIN_PRICE),0)
-------------------------------------------------
                                            10000
                                            20000
                                            30000

QUESTION 107
View the Exhibit and examine the structure and data in the INVOICE table.
Which two SQL statements would execute successfully? (Choose two.)
A. SELECT AVG(inv_date )
FROM invoice;
B. SELECT MAX(inv_date),MIN(cust_id)
FROM invoice;
C. SELECT MAX(AVG(SYSDATE - inv_date))
FROM invoice;
D. SELECT AVG( inv_date - SYSDATE), AVG(inv_amt)
FROM invoice;
Correct Answer: BD
二、题目翻译
下面是INVOICE表的结构和数据：
下面哪些SQL语句执行成功（选择2个）？

三、题目解析
A选项不正确，因为AVG的参数为数值类型或能隐式转换成数值类型的，在隐式转换inv_date时会报错。
C选项不正确，嵌套组函数需要使用group by子句。
SQL>  with  INVOICE as
  2   (
  3     union all
   select 1 INV_NO,to_date('01-apr-07','dd-mon-yyyy') INV_DATE, 'a10' CUST_ID,1000 INV_AMT from dual
  4     union all
  5     select 2 INV_NO,to_date('01-oct-07','dd-mon-yyyy') INV_DATE, 'b1r' CUST_ID,2000 INV_AMT from dual
  6     union all
  7     select 3 INV_NO,to_date('01-feb-07','dd-mon-yyyy') INV_DATE, null CUST_ID,3000 INV_AMT from dual
  8   )
  9  SELECT AVG(inv_date ) FROM invoice;
SELECT AVG(inv_date ) FROM invoice
           *
ERROR at line 9:
ORA-00932: inconsistent datatypes: expected NUMBER got DATE

SQL>  with  INVOICE as
  2   (
  3     select 1 INV_NO,to_date('01-apr-07','dd-mon-yyyy') INV_DATE, 'a10' CUST_ID,1000 INV_AMT from dual
  4     union all
  5     select 2 INV_NO,to_date('01-oct-07','dd-mon-yyyy') INV_DATE, 'b1r' CUST_ID,2000 INV_AMT from dual
  6     union all
   select 3 INV_NO,to_date('01-feb-07','dd-mon-yyyy') INV_DATE, null CUST_ID,3000 INV_AMT from dual
  8   )
  9  SELECT MAX(inv_date),MIN(cust_id) FROM invoice;

MAX(INV_D MIN
--------- ---
01-OCT-07 a10

SQL>  with  INVOICE as
  2   (
   select 1 INV_NO,to_date('01-apr-07','dd-mon-yyyy') INV_DATE, 'a10' CUST_ID,1000 INV_AMT from dual
   union all
   select 2 INV_NO,to_date('01-oct-07','dd-mon-yyyy') INV_DATE, 'b1r' CUST_ID,2000 INV_AMT from dual
  6     union all
  7     select 3 INV_NO,to_date('01-feb-07','dd-mon-yyyy') INV_DATE, null CUST_ID,3000 INV_AMT from dual
  8   )
  9  SELECT MAX(AVG(SYSDATE - inv_date)) FROM invoice;
SELECT MAX(AVG(SYSDATE - inv_date)) FROM invoice
           *
ERROR at line 9:
ORA-00978: nested group function without GROUP BY

SQL>  with  INVOICE as
  2   (
   select 1 INV_NO,to_date('01-apr-07','dd-mon-yyyy') INV_DATE, 'a10' CUST_ID,1000 INV_AMT from dual
  4     union all
  5     select 2 INV_NO,to_date('01-oct-07','dd-mon-yyyy') INV_DATE, 'b1r' CUST_ID,2000 INV_AMT from dual
  6     union all
  7     select 3 INV_NO,to_date('01-feb-07','dd-mon-yyyy') INV_DATE, null CUST_ID,3000 INV_AMT from dual
  8   )
  9  SELECT AVG( inv_date - SYSDATE), AVG(inv_amt) FROM invoice;

AVG(INV_DATE-SYSDATE) AVG(INV_AMT)
--------------------- ------------
           -734104.63         2000
QUESTION 108
Which two statements are true regarding the COUNT function? (Choose two.)
A. The COUNT function can be used only for CHAR, VARCHAR2, and NUMBER data types.
B. COUNT(*) returns the number of rows including duplicate rows and rows containing NULL value in
any of the columns.
C. COUNT(cust_id) returns the number of rows including rows with duplicate customer IDs and NULL
value in the CUST_ID column.
D. COUNT(DISTINCT inv_amt)returns the number of rows excluding rows containing duplicates and
NULL values in the INV_AMT column.
E. A SELECT statement using the COUNT function with a DISTINCT keyword cannot have a
WHERE clause.
Correct Answer: BD
二、题目翻译
关于COUNT函数的描述，哪两个句子是正确的？（选择两个）
A.COUNT函数只能用于CHAR,VARCHAR2,NUMBER数据类型。
B.count(*)返回包括重复行和NULL的行。
C.COUNT(cust_id)返回包括重复行和NULL的行。
D.COUNT(DISTINCT inv_amt)返回不包括重复值和NULL的行。
E.使用带有DISTINCT关键字的COUNT函数的SELECT语句不能含有WHERE子句。

三、题目解析
A选项不正确，因为还可以为DATE型。
B选项正确，count(*)是所有的行，重复行和有null值的行也包括。
C选项不正确，同B选项，因为不包括NULL行。
D选项正确，COUNT本身就不包括null值的行，distinct已经先将重复行去掉了。
E选项不正确，DISTINCT是去重，可以用where过滤完之后再去重。
QUESTION 109
Examine the structure of the MARKS table:
name Null Type
STUDENT_ID NOT NULL VARCHAR2(4)
STUDENT_NAME VARCHAR2(25)
SUBJECT1 NUMBER(3)
SUBJECT2 NUMBER(3)
SUBJECT3 NUMBER(3)
Which two statements would execute successfully? (Choose two.)
A. SELECT student_name,subject1
FROM marks
WHERE subject1 > AVG(subject1);
B. SELECT student_name,SUM(subject1)
FROM marks
WHERE student_name LIKE 'R%';
C. SELECT SUM(subject1+subject2+subject3)
FROM marks
WHERE student_name IS NULL;
D. SELECT SUM(DISTINCT NVL(subject1,0)), MAX(subject1)
FROM marks
WHERE subject1 > subject2;
Correct Answer: CD
二、题目翻译
查看MARKS表的结构：
哪两个语句可以执行成功？（选择两个）

三、题目解析
A选项不正确，组函数不能用于WHERE子句中，如果要用，就要放在having子句中。
B选项不正确，student_name是正常列显示，sum是聚合函数，需要使用group by子句，否则报错。

QUESTION 110
View the Exhibit and examine the structure of the CUSTOMERS table.
Using the CUSTOMERS table, you need to generate a report that shows the average credit limit for
customers in WASHINGTON and NEW YORK.
Which SQL statement would produce the required result?
A. SELECT cust_city, AVG(cust_credit_limit)
FROM customers
WHERE cust_city IN ('WASHINGTON','NEW YORK')
GROUP BY cust_credit_limit, cust_city;
B. SELECT cust_city, AVG(cust_credit_limit)
FROM customers
WHERE cust_city IN ('WASHINGTON','NEW YORK')
GROUP BY cust_city,cust_credit_limit;
C. SELECT cust_city, AVG(cust_credit_limit)
FROM customers
WHERE cust_city IN ('WASHINGTON','NEW YORK')
GROUP BY cust_city;
D. SELECT cust_city, AVG(NVL(cust_credit_limit,0))
FROM customers
WHERE cust_city IN ('WASHINGTON','NEW YORK');
Correct Answer: C

二、题目翻译
查看CUSTOMERS表的结构
使用CUSTOMERS表的数据生成一个报表，显示居住在WASHINGTON和NEW YORK的客户的平均credit limit
哪条SQL语句给出所需结果？

三、题目解析
AB选项不正确，因为GROUP BY里的分组的列不对，这里应该按cust_city分组。
D选项不正确，因为要根据城市求平均值，所以需要使用GROUP BY子句分组。
QUESTION 111
View the Exhibit and examine the structure of the CUSTOMERS table.
Which statement would display the highest credit limit available in each income level in each city in the
CUSTOMERS table?
A. SELECT cust_city, cust_income_level, MAX(cust_credit_limit )
FROM customers
GROUP BY cust_city, cust_income_level, cust_credit_limit;
B. SELECT cust_city, cust_income_level, MAX(cust_credit_limit)
FROM customers
GROUP BY cust_city, cust_income_level;
C. SELECT cust_city, cust_income_level, MAX(cust_credit_limit)
FROM customers
GROUP BY cust_credit_limit, cust_income_level, cust_city ;
D. SELECT cust_city, cust_income_level, MAX(cust_credit_limit)
FROM customers
GROUP BY cust_city, cust_income_level, MAX(cust_credit_limit);
Correct Answer: B
二、题目翻译
查看CUSTOMERS表的结构，
哪条语句显示每个城市中每个收入水平的最高信用额度？

三、题目解析
AC选项不正确，按照题目，应该按城市和收入水平分组，这两个都不正确。
D选项不正确，报错，因为GROUP BY子句中不能使用MAX聚合函数。

View the Exhibit and examine the structure of the PROMOTIONS table.
Evaluate the following SQL statement:
SQL>SELECT promo_category, AVG(promo_cost) Avg_Cost, AVG(promo_cost)*.25 Avg_Overhead
FROM promotions
WHERE UPPER(promo_category) IN ('TV', 'INTERNET','POST')
GROUP BY Avg_Cost
ORDER BY Avg_Overhead;
The above query generates an error on execution.
Which clause in the above SQL statement causes the error?
A. WHERE
B. SELECT
C. GROUP BY
D. ORDER BY
Correct Answer: C
二、题目翻译
看下面PROMOTIONS表的结构:
下面的SQL语句:
上面的查询会报错,
是哪一个子句引起的错误？

三、题目解析
GROUP BY后面不能使用列别名。
QUESTION 113
Examine the structure of the ORDERS table:
Name Null Type
ORDER_ID NOT NULL NUMBER(12)
ORDER_DATE NOT NULL TIMESTAMP(6)
CUSTOMER_ID NOT NULL NUMBER(6)
ORDER_STATUS NUMBER(2)
ORDER_TOTAL NUMBER(8,2)
You want to find the total value of all the orders for each year and issue the following command:
SQL>SELECT TO_CHAR(order_date,'rr'), SUM(order_total)
FROM orders
GROUP BY TO_CHAR(order_date,'yyyy');
Which statement is true regarding the outcome?
A. It executes successfully and gives the correct output.
B. It gives an error because the TO_CHAR function is not valid.
C. It executes successfully but does not give the correct output.
D. It gives an error because the data type conversion in the SELECT list does not match the data type
conversion in the GROUP BY clause.
Correct Answer: D
二、题目翻译
下面是ORDERS表的结构：
要查找每年所有orders的total value，执行下面的命令：
关于结果，下面哪个描述是正确的？
A.执行成功给出正确结果。
B.报错,因为TO_CHAR函数无效。
C.执行成功,但是不能给出正确结果。
D.报错，因为SELECT列表中的数据类型转换与GROUP BY子句中的数据类型转换不匹配。

三、题目解析
因为select后面出现的列，必须是在GROUP BY子句出现的列、表达式，或者是聚合函数，所以，这里GROUP BY后是 TO_CHAR(order_date,'yyyy')，SELECT语句中也应该是 TO_CHAR(order_date,'yyyy')。
QUESTION 114
View the Exhibit and examine the structure of the SALES table.
The following query is written to retrieve all those product ID s from the SALES table that have more than
55000 sold and have been ordered more than 10 times.
SQL> SELECT prod_id
FROM sales
WHERE quantity_sold > 55000 AND COUNT(*)>10
GROUP BY prod_id
HAVING COUNT(*)>10;
Which statement is true regarding this SQL statement?
A. It executes successfully and generates the required result.
B. It produces an error because COUNT(*) should be specified in the SELECT clause also.
C. It produces an error because COUNT(*) should be only in the HAVING clause and not in the WHERE
clause.
D. It executes successfully but produces no result because COUNT(prod_id) should be used instead of
COUNT(*).
Correct Answer: C
二、题目翻译
查看SALES表的结构：
下面的查询用于检索那些售出了超过55000台,并且已被定购超过10次的所有产品ID。
关于查询语句的描述，正确的是？
A.执行成功,并给出正确结果。
B.报错，因为COUNT(*)也应该指定到SELECT子句中。
C.报错，因为COUNT(*)只能用在HAVING子句中，不能在WHERE子句中。
D.执行成功，但是没有返回结果，因为COUNT(prod_id)应该用COUNT(*)代替。

QUESTION 115
View the Exhibit and examine the structure of the CUSTOMERS table.
Evaluate the following SQL statement:
SQL> SELECT cust_city, COUNT(cust_last_name)
FROM customers
WHERE cust_credit_limit > 1000
GROUP BY cust_city
HAVING AVG(cust_credit_limit) BETWEEN 5000 AND 6000;
Which statement is true regarding the outcome of the above query?
A. It executes successfully.
B. It returns an error because the BETWEEN operator cannot be used in the HAVING clause.
C. It returns an error because WHERE and HAVING clauses cannot be used in the same SELECT
statement.
D. It returns an error because WHERE and HAVING clauses cannot be used to apply conditions on the
same column.
Correct Answer: A
二、题目解析
下面是CUSTOMERS表的结构
评估下面的语句：
关于结果的描述，哪句话是正确的？
A.执行成功。
B.报错，因为BETWEEN操作符不能用在HAVING子句中。
C.报错，因为WHERE and HAVING子句不能同时用于SELECT子句中。
D.报错，因为WHERE and HAVING子句不能使用同一列作为条件。

QUESTION 116
Examine the data in the ORD_ITEMS table:
ORD_NO ITEM_NO QTY
1 111 10
1 222 20
1 333 30
2 333 30
2 444 40
3 111 40
You want to find out if there is any item in the table for which the average maximum quantity is more than
50.
You issue the following query:
SQL> SELECT AVG(MAX(qty))
FROM ord_items
GROUP BY item_no
HAVING AVG(MAX(qty))>50;
Which statement is true regarding the outcome of this query?
A. It executes successfully and gives the correct output.
B. It gives an error because the HAVING clause is not valid.
C. It executes successfully but does not give the correct output.
D. It gives an error because the GROUP BY expression is not valid.
Correct Answer: B
二、题目翻译
查看ORD_ITEMS表的数据
要找到表中任意item的最大值的平均值是否大于50
执行下面的查询：
关于查询结果，下面描述正确的是?
A.执行成功并给出正确结果。
B.报错，因为HAVING子句是无效的。
C.执行成功，但是不能给出正确结果。
D.报错，因为GROUP BY表达式无效。

三、题目解析
HAVING子句后面嵌套了2个组函数，只能使用一个组函数，而且，已经是最大值了，只有一个值，再求平均值，完全没意义。
SQL> WITH  ORD_ITEMS as
 (           
select 1 ORD_NO,111 ITEM_NO,10 QTY from dual
  4     union all
  5  select 1 ORD_NO,222 ITEM_NO,20 QTY from dual
  6     union all
  7  select 1 ORD_NO,333 ITEM_NO,30 QTY from dual
  8     union all
  9  select 2 ORD_NO,333 ITEM_NO,30 QTY from dual
 10     union all
 11  select 2 ORD_NO,444 ITEM_NO,40 QTY from dual
 12     union all
 13  select 3 ORD_NO,111 ITEM_NO,40 QTY from dual
 14   )
 15  SELECT AVG(MAX(qty))
 16                FROM ord_items
 17        GROUP BY item_no
 18             HAVING AVG(MAX(qty))>50;
           HAVING AVG(MAX(qty))>50
                      *
ERROR at line 18:
ORA-00935: group function is nested too deeply

QUESTION 117
Which statements are true regarding the WHERE and HAVING clauses in a SELECT statement?
(Choose all that apply.)
A. The HAVING clause can be used with aggregate functions in subqueries.
B. The WHERE clause can be used to exclude rows after dividing them into groups.
C. The WHERE clause can be used to exclude rows before dividing them into groups.
D. The aggregate functions and columns used in the HAVING clause must be specified in the SELECT list
of the query.
E. The WHERE and HAVING clauses can be used in the same statement only if they are applied to
different columns in the table.
Correct Answer: AC
二、题目翻译
关于WHERE和HAVING子句哪句话是正确的(选择所有正确的选项）
A.HAVING子句能在子查询中使用聚合函数。
B.WHERE子句能被用于在划分组之后排除行。
C.WHERE子句能被用于在划分组之前排除行。
D.用在HAVING子句中的聚合函数和列必须被指定到SELECT语句的列表中。
E.只要应用不同的列，WHERE和HAVING子句就能用在相同的语句中。

三、题目解析
WHERE是在分组之前筛选数据，HAVING是在分组之后筛选数据。
WHERE子句中不能使用聚合函数，HAVING子句中可以使用聚合函数。
QUESTION 118
View the Exhibit and examine the structure of the PROMOTIONS table.
Examine the following two SQL statements:
Statement 1
SQL>SELECT promo_category,SUM(promo_cost)
FROM promotions
WHERE promo_end_date-promo_begin_date > 30
GROUP BY promo_category;
Statement 2
SQL>SELECT promo_category,sum(promo_cost)
FROM promotions
GROUP BY promo_category
HAVING MIN(promo_end_date-promo_begin_date)>30;
Which statement is true regarding the above two SQL statements?
A. statement 1 gives an error, statement 2 executes successfully
B. statement 2 gives an error, statement 1 executes successfully
C. statement 1 and statement 2 execute successfully and give the same output
D. statement 1 and statement 2 execute successfully and give a different output
Correct Answer: D
二、题目翻译
查看PROMOTIONS表的结构
评估下面的2个语句
关于上面两个SQL语句，哪句话是正确的？
A.语句1报错，语句2执行成功。
B.语句2报错，语句1执行成功。
C.都执行成功，并给出相同结果。
D.都执行成功，但给出不同的结果。

三、题目解析
WHERE是分组之前筛选数据，HAVING是分组之后筛选数据，所以结果是不一样的。

QUESTION 119
Examine the data in the ORD_ITEMS table:
ORD_NO ITEM_NO QTY
1 111 10
1 222 20
1 333 30
2 333 30
2 444 40
3 111 40
Evaluate the following query:
SQL>SELECT item_no, AVG(qty)
FROM ord_items
HAVING AVG(qty) > MIN(qty) * 2
GROUP BY item_no;
Which statement is true regarding the outcome of the above query?
A. It gives an error because the HAVING clause should be specified after the GROUP BY clause.
B. It gives an error because all the aggregate functions used in the HAVING clause must be specified in
the SELECT list.
C. It displays the item nos with their average quantity where the average quantity is more than double the
minimum quantity of that item in the table.
D. It displays the item nos with their average quantity where the average quantity is more than double the
overall minimum quantity of all the items in the table.
Correct Answer: C
二、题目翻译
查看下面ORD_ITEMS表的数据：
评估下面的查询:
关于上面语句的结果哪句话是正确的？
A.报错，因为HAVING子句应该放在GROUP BY子句之后。
B.报错，因为所有在HAVING子句中使用的聚合函数必须被指定到SELECT列表中。
C.显示item_nos和他们的平均数量，平均数量要大于每组item中最小数量的两倍。
D.显示item_nos和他们的平均数量，平均数量要大于所有item最小值的两倍。

三、题目解析
A选项不正确，HAVING子句可以放到GROUP BY子句前面。
B选项不正确，HAVING子句中的聚合函数，不一定要放在SELECT的列表中，这个没有关系的。
SQL> WITH  ORD_ITEMS as
  2   (           
  3  select 1 ORD_NO,111 ITEM_NO,10 QTY from dual
  4     union all
  5  select 1 ORD_NO,222 ITEM_NO,20 QTY from dual
  6     union all
  7  select 1 ORD_NO,333 ITEM_NO,30 QTY from dual
  8     union all
  9  select 2 ORD_NO,333 ITEM_NO,30 QTY from dual
 10     union all
 11  select 2 ORD_NO,444 ITEM_NO,40 QTY from dual
 12     union all
 13  select 3 ORD_NO,111 ITEM_NO,40 QTY from dual
 14   )
 15  SELECT item_no, AVG(qty)
 16              FROM ord_items
 17           HAVING AVG(qty) > MIN(qty) * 2
 18      GROUP BY item_no;

   ITEM_NO   AVG(QTY)
---------- ----------
       111         25

QUESTION 120
View the Exhibits and examine the structures of the PRODUCTS, SALES, and CUSTOMERS
tables.
You issue the following query:
SQL>SELECT p.prod_id,prod_name,prod_list_price,
quantity_sold,cust_last_name
FROM products p NATURAL JOIN sales s NATURAL JOIN customers c
WHERE prod_id =148;
Which statement is true regarding the outcome of this query?
A. It executes successfully.
B. It produces an error because the NATURAL join can be used only with two tables.
C. It produces an error because a column used in the NATURAL join cannot have a qualifier.
D. It produces an error because all columns used in the NATURAL join should have a qualifier.
Correct Answer: C

二、题目翻译
查看PRODUCTS,  SALES,  and CUSTOMERS表的结构
执行下面的语句
关于上面语句的执行结果，下面哪句描述是正确的?
A.执行成功。
B.报错，因为NATURAL连接只能连接两个表。
C.报错，因为NATURAL连接使用的一个列不能有限定词。
D.报错，因为NATURAL连接使用的所有列应该加一个限定词。

三、题目解析
因为prod_id是用于NATURAL连接，不能加限定词（即两个表中如果有相同列名的都不能加限定词，即列名前不能带表名）。而对于ORACLE自己语法的join是需要对两个表中相同的列使用限定词的。

联机文档上有详细的描述：
http://docs.oracle.com/cd/E11882_01/server.112/e41084/statements_10002.htm#BABBAGAH
The NATURAL keyword indicates that a natural join is being performed. A natural join is based on all columns in the two tables that have the same name. It selects rows from the two tables that have equal values in the relevant columns. If two columns with the same name do not have compatible data types, then an error is raised. When specifying columns that are involved in the natural join, do not qualify the column name with a table name or table alias.

QUESTION 121
Which two statements are true regarding the USING clause in table joins? (Choose two .)
A. It can be used to join a maximum of three tables.
B. It can be used to restrict the number of columns used in a NATURAL join.
C. It can be used to access data from tables through equijoins as well as nonequijoins
D. It can be used to join tables that have columns with the same name and compatible data types.
Correct Answer: BD
二、题目翻译
关于表连接中的USING子句的使用，下面的哪两个描述是正确的？(选择两项)
A.最多可以连接三张表。
B.可以用来限制NATURAL join(自然连接)中的列的数量。
C.可以用在等值连接和非等值连接。
D.可以用来连接有相同名字和一致的数据类型的列。
自然连接的详细用法，详见：
https://github.com/tomlxq/oracle-study/blob/master/ocp/2_%E8%87%AA%E7%84%B6%E8%BF%9E%E6%8E%A5%EF%BC%88NATURAL%20JOIN%EF%BC%89.sql

QUESTION 122
View the Exhibit for the structure of the STUDENT and FACULTY tables.
You need to display the faculty name followed by the number of students handled by the faculty at the
base location.
Examine the following two SQL statements:
Statement 1
SQL>SELECT faculty_name,COUNT(student_id)
FROM student JOIN faculty
USING (faculty_id, location_id)
GROUP BY faculty_name;
Statement 2
SQL>SELECT faculty_name,COUNT(student_id)
FROM student NATURAL JOIN faculty
GROUP BY faculty_name;
Which statement is true regarding the outcome?
A. Only s tatement 1 executes successfully and gives the required result.
B. Only statement 2 executes successfully and gives the required result.
C. Both statements 1 and 2 execute successfully and give different results.
D. Both statements 1 and 2 execute successfully and give the same required result.
Correct Answer: D
二、题目翻译
查看STUDENT和FACULTY表的结构
要显示全体教师的名字及该教师所在位置的学生人数。
执行下面的两个语句
关于上面的两个语句，下面描述正确的是：
A.只有语句1执行成功并给出正确结果。
B.只有语句2执行成功并给出正确结果。
C.两个都执行成功，但给出不同结果。
D.两个都执行成功并给出相同结果。

三、题目解析
虽然FACULTY_ID在两个表中的数据类型不一致，但是如果两个列的数据是可以隐式转换的话，也能执行成功。
四、测试
SQL> create table student(
  2  student_id number(2) not null,
  3  student_name varchar2(30),
  4  faculty_id varchar2(2),
  5  location_id number(2)
  6  );

Table created.

SQL> create table faculty(
  2  faculty_id number(2),
  3  faculty_name varchar2(30),
  4  location_id number(2)
  5  );

Table created.

SQL> insert into faculty values(1,'张老师',1);

1 row created.

SQL> insert into faculty values(2,'李老师',2);

1 row created.

SQL> insert into student values(1,'张同学',1,1);

1 row created.

SQL> insert into student values(2,'李同学',1,1);

1 row created.

SELECT faculty_name,COUNT(student_id)
  2  FROM student JOIN faculty
  3  USING (faculty_id, location_id)
  4  GROUP BY faculty_name;

FACULTY_NAME                   COUNT(STUDENT_ID)
------------------------------ -----------------
张老师                                         2

SQL> SELECT faculty_name,COUNT(student_id)
  2  FROM student NATURAL JOIN faculty
  3  GROUP BY faculty_name;

FACULTY_NAME                   COUNT(STUDENT_ID)
------------------------------ -----------------
张老师                                         2

QUESTION 123
View the Exhibits and examine the structures of the PRODUCTS, SALES, and CUSTOMERS
tables.
You need to generate a report that gives details of the customer's last name, name of the product, and
the quantity sold for all customers in ' Tokyo' .
Which two queries give the required result? (Choose two.)
A. SELECT c.cust_last_name,p.prod_name, s.quantity_sold
FROM sales s JOIN products p
USING(prod_id)
JOIN customers c
USING(cust_id)
WHERE c.cust_city='Tokyo';
B. SELECT c.cust_last_name, p.prod_name, s.quantity_sold
FROM products p JOIN sales s JOIN customers c
ON(p.prod_id=s.prod_id)
ON(s.cust_id=c.cust_id)
WHERE c.cust_city='Tokyo';
C. SELECT c.cust_last_name, p.prod_name, s.quantity_sold
FROM products p JOIN sales s
ON(p.prod_id=s.prod_id)
JOIN customers c
ON(s.cust_id=c.cust_id)
AND c.cust_city='Tokyo';
D. SELECT c.cust_id,c.cust_last_name,p.prod_id, p.prod_name, s.quantity_sold
FROM products p JOIN sales s
USING(prod_id)
JOIN customers c
USING(cust_id)
WHERE c.cust_city='Tokyo';
Correct Answer: AC

二、题目翻译
查看PRODUCTS、SALES和CUSTOMERS表的结构
要生成一个报表，显示在Tokyo的客户的last name,product name,和the quantity sold（销售数量）的详细信息。
哪两个给出所需结果？（选择2个）

三、题目解析
B选项不正确，语法错误。
D选项不正确，因为有USING子句，不能使用限定词。
不要对USING子句中使用的列加以限定。
USING子句中引用的那些列不能在SQL 语句的任何位置使用限定词（表名或别名），如下面的prod_id,cust_id如果要在查询中显示出来，不要再 别名.prod_id,别名.cust_id。
如果在SQL 语句的另一个位置使用了同一列，则不要对其设置别名。
四、测试
SQL> set linesize 200
SQL> SELECT c.cust_last_name,p.prod_name, s.quantity_sold
FROM sales s JOIN products p
  3  USING(prod_id)
  4  JOIN customers c
  5  USING(cust_id)
  6  WHERE c.cust_city='Tokyo' and rownum<5;

CUST_LAST_NAME                           PROD_NAME                                          QUANTITY_SOLD
---------------------------------------- -------------------------------------------------- -------------
Thomas                                   Envoy Ambassador                                               1
Thomas                                   Envoy Ambassador                                               1
Thomas                                   Envoy Ambassador                                               1
Thomas                                   Envoy Ambassador                                               1
SQL> SELECT c.cust_last_name, p.prod_name, s.quantity_sold
FROM products p JOIN sales s JOIN customers c
  3  ON(p.prod_id=s.prod_id)
  4  ON(s.cust_id=c.cust_id)
  5  WHERE c.cust_city='Tokyo';
ON(p.prod_id=s.prod_id)
   *
ERROR at line 3:
ORA-00904: "P"."PROD_ID": invalid identifier

SQL> SELECT c.cust_last_name, p.prod_name, s.quantity_sold
  2  FROM products p JOIN sales s
  3  ON(p.prod_id=s.prod_id)
  4  JOIN customers c
  5  ON(s.cust_id=c.cust_id)
  6  AND c.cust_city='Tokyo' and rownum<5;

CUST_LAST_NAME                           PROD_NAME                                          QUANTITY_SOLD
---------------------------------------- -------------------------------------------------- -------------
Thomas                                   Envoy Ambassador                                               1
Thomas                                   Envoy Ambassador                                               1
Thomas                                   Envoy Ambassador                                               1
Thomas                                   Envoy Ambassador                                               1
SQL>  SELECT c.cust_id,c.cust_last_name,p.prod_id, p.prod_name, s.quantity_sold
FROM products p JOIN sales s
USING(prod_id)
JOIN customers c
  5  USING(cust_id)
  6  WHERE c.cust_city='Tokyo';
 SELECT c.cust_id,c.cust_last_name,p.prod_id, p.prod_name, s.quantity_sold
                                   *
ERROR at line 1:
ORA-25154: column part of USING clause cannot have qualifier

QUESTION 124
View the Exhibit and examine the structure of the PROMOTIONS, SALES, and CUSTOMER tables.
You need to generate a report showing the promo name along with the customer name for all products
that were sold during their promo campaign and before 30th October 2007.
You issue the following query:
SQL> SELECT promo_name,cust_name
FROM promotions p JOIN sales s
ON(time_id BETWEEN promo_begin_date AND promo_end_date)
JOIN customer c
ON (s.cust_id = c.cust_id) AND time_id < '30-oct-2007';
Which statement is true regarding the above query?
A. It executes successfully and gives the required result.
B. It executes successfully but does not give the required result.
C. It produces an error because the join order of the tables is incorrect.
D. It produces an error because equijoin and nonequijoin conditions cannot be used in the same SELECT
statement.
Correct Answer: B
二、题目翻译
查看PROMOTIONS、SALES和 CUSTOMER表的结构:
要生成一个报表，显示所有产品的promo name和customer name，销售的产品是在促销活动期间，并且在2007年10月30日以前。
执行下面的查询
关于上面的查询哪句话是正确的？
A.执行成功，并给出正确结果。
B.执行成功，但不能给出正确结果。
C.报错，因为表的连接顺序不正确。
D.报错，因为等值连接与非等值连接不能用在同一个SELECT语句中。

三、题目解析
这个sql虽然执行成功，但是结果不正确， promotions和sales表之间应该还有一个关联条件是promo_id相等。

四、测试
drop table promotions;
drop table customer;
drop table sales;	
create table promotions(
PROMO_ID NUMBER(2) NOT NULL,
promo_name varchar2(10),
promo_cat varchar2(10),
promo_cost number(8,2),
promo_begin_date date,
promo_end_date date
);
create table sales(
prod_id number(3) not null,
promo_id number(3) not null,
time_id date,
qty_sold number(6,2),
cust_id number(2) not null
);
create table customer(
cust_id number(3) not null,
cust_name varchar2(20),
cust_address varchar(30)
);
insert into promotions values(1,'苹果','水果',500,to_date('2007-1-5','yyyy-mm-dd'),to_date('2007-1-30','yyyy-mm-dd'));
insert into promotions values(2,'电脑','数码',800,to_date('2007-10-25','yyyy-mm-dd'),to_date('2007-11-5','yyyy-mm-dd'));
insert into customer values(21,'张三','西贡');
insert into customer values(22,'李四','纽约');
insert into customer values(23,'王二','拉美');
insert into sales values(101,1,to_date('2007-1-10','yyyy-mm-dd'),2,21);
insert into sales values(102,2,to_date('2007-10-28','yyyy-mm-dd'),5,22);
insert into sales values(103,2,to_date('2007-11-2','yyyy-mm-dd'),3,23);
insert into sales values(104,3,to_date('2007-11-8','yyyy-mm-dd'),6,23);
insert into sales values(105,3,to_date('2007-10-28','yyyy-mm-dd'),4,21);

SQL> set linesize 200
SELECT promo_name,cust_name,p.promo_id,time_id,promo_begin_date,promo_end_date
    FROM promotions p JOIN sales s
    ON(time_id BETWEEN promo_begin_date AND promo_end_date)
  4      JOIN customer c
  5      ON (s.cust_id = c.cust_id) AND time_id < '30-oct-2007';

PROMO_NAME CUST_NAME              PROMO_ID TIME_ID            PROMO_BEGIN_DATE   PROMO_END_DATE
---------- -------------------- ---------- ------------------ ------------------ ------------------
电脑       张三                          2 28-OCT-07          25-OCT-07          05-NOV-07
苹果       张三                          1 10-JAN-07          05-JAN-07          30-JAN-07
电脑       李四                          2 28-OCT-07          25-OCT-07          05-NOV-07
	
SQL> SELECT promo_name,cust_name,p.promo_id,time_id,promo_begin_date,promo_end_date
    FROM promotions p JOIN sales s
    ON( p.promo_id=s.promo_id and time_id BETWEEN promo_begin_date AND promo_end_date)
    JOIN customer c
  5      ON (s.cust_id = c.cust_id) AND time_id < '30-oct-2007';

PROMO_NAME CUST_NAME              PROMO_ID TIME_ID            PROMO_BEGIN_DATE   PROMO_END_DATE
---------- -------------------- ---------- ------------------ ------------------ ------------------
苹果       张三                          1 10-JAN-07          05-JAN-07          30-JAN-07
电脑       李四                          2 28-OCT-07          25-OCT-07          05-NOV-07
QUESTION 125
Examine the structure of the CUSTOMERS table:
name Null Type
CUSTNO NOT NULL NUMBER(3)
CUSTNAME NOT NULL VARCHAR2(25)
CUSTADDRESS VARCHAR2(35)
CUST_CREDIT_LIMIT NUMBER(5)
CUSTNO is the PRIMARY KEY in the table. You want to find out if any customers' details have been
entered more than once using different CUSTNO, by listing all the duplicate names.
Which two methods can you use to get the required result? (Choose two.)
A. self-join
B. subquery
C. full outer-join with self-join
D. left outer-join with self-join
E. right outer-join with self-join
Correct Answer: AB
二、题目翻译
查看CUSTOMERS表的结构
CUSTNO是表的主键，想找到是否存在客户信息使用不同的CUSTNO录入了多次，显示所有重复的客户名称.
哪两个方法可以获取所需结果？

三、题目解析
需要用自连接查出被多次录入的客户的详细信息，
需要用子查询查出重复的客户。

答案解析：
题意：找到是否存在客户信息使用不同的CUSTNO录入了多次，显示所有重复的客户名称
自连接即是查询两次自身的表，首先根据客户信息来查看CUSTNO大于1的记录，然后再根据CUSTNO来显示客户名称。子查询也是一样。
QUESTION 126
View the Exhibit and examine the data in the PROJ_TASK_DETAILS table.
The PROJ_TASK_DETAILS table stores information about tasks involved in a project and the relation
between them.
The BASED_ON column indicates dependencies between tasks. Some tasks do not depend on the
completion of any other tasks.
You need to generate a report showing all task IDs, the corresponding task ID they are dependent on, and
the name of the employee in charge of the task it depends on.
Which query would give the required result?
A. SELECT p.task_id, p.based_on, d.task_in_charge
FROM proj_task_details p JOIN proj_task_details d
ON (p.based_on = d.task_id);
B. SELECT p.task_id, p.based_on, d.task_in_charge
FROM proj_task_details p LEFT OUTER JOIN proj_task_details d
ON (p.based_on = d.task_id);
C. SELECT p.task_id, p.based_on, d.task_in_charge
FROM proj_task_details p FULL OUTER JOIN proj_task_details d
ON (p.based_on = d.task_id);
D. SELECT p.task_id, p.based_on, d.task_in_charge
FROM proj_task_details p JOIN proj_task_details d
ON (p.task_id = d.task_id);
Correct Answer: B
二、题目翻译
查看PROJ_TASK_DETAILS表的数据
PROJ_TASK_DETAILS表存储项目相关的任务与他们之间的关系的信息
BASED_ON列代表任务之间的依赖关系，有些任务不依赖于任何其他任务的完成。
要生成一个报表，显示所有任务的ID，依赖对应任务的ID，和它依赖任务负责的员工姓名。
哪个查询给出所需结果？

三、题目解析
A选项不正确，只显示有依赖任务的task_id。
B选项正确，是LEFT OUTER JOIN也就是左连表的所有task_id全部显示出来，如果右边表没有匹配的信息，则显示空。
C选项不正确，full outer join是全匹配，也就是p表中有，但d表中没有匹配的，和d表中有，p表中没有匹配的，都会显示出来，显示为null。
D选项不正确，关联列错误。
QUESTION 127
Examine the data in the CUSTOMERS table:
CUSTNO CUSTNAME CITY
1 KING SEATTLE
2 GREEN BOSTON
3 KOCHAR SEATTLE
4 SMITH NEW YORK
You want to list all cities that have more than one customer along with the customer details.
Evaluate the following query:
SQL>SELECT c1.custname, c1.city
FROM Customers c1 __________________ Customers c2
ON (c1.city=c2.city AND c1.custname<>c2.custname);
Which two JOIN options can be used in the blank in the above query to give the correct output? (Choose
two.)
A. JOIN
B. NATURAL JOIN
C. LEFT OUTER JOIN
D. FULL OUTER JOIN
E. RIGHT OUTER JOIN
Correct Answer: AE
二、题目翻译
查看CUSTOMERS表的数据：
列出多于一个客户的城市和客户的信息。
评估下面的查询
哪两种JOIN用在上面的空白处能给出正确的结果？

三、题目解析
B选项不正确，NATURAL JOIN自然连接不需要关联条件，所以下面的ON子句会报错。
CD选项不正确，LEFT OUTER JOIN和FULL OUTER JOIN都会显示有客户但是没在某个城市的人。

四、测试
测试结果，A，E正确。
SQL> Create table customers (CUSTNO NUMBER,CUSTNAME VARCHAR2(20),CITY VARCHAR2(20));

Table created.

SQL> insert into customers values(1,'KING','SEATTLE');

1 row created.

SQL> insert into customers values(2,'GREEN','BOSTON');

1 row created.

SQL> insert into customers values(3,'KOCHAR','SEATTLE');

1 row created.

SQL> insert into customers values(4,'SMITH','NEY YORK');

1 row created.

SQL> commit;

Commit complete.

SQL> select CITY from customers 
  2      group by city
  3      having count(CUSTNAME)>1
  4      order by city;

CITY
--------------------
SEATTLE

SQL>  select c1.custname, c1.city 
  2      from Customers c1 JOIN Customers c2 
  3     ON (c1.city=c2.city AND c1.custname<>c2.custname);

CUSTNAME             CITY
-------------------- --------------------
KOCHAR               SEATTLE
KING                 SEATTLE

SQL> select c1.custname, c1.city 
  2      from Customers c1 NATURAL JOIN Customers c2 
  3      ON (c1.city=c2.city AND c1.custname<>c2.custname);
    ON (c1.city=c2.city AND c1.custname<>c2.custname)
    *
ERROR at line 3:
ORA-00933: SQL command not properly ended


SQL> select c1.custname, c1.city 
  2      from Customers c1 LEFT OUTER JOIN Customers c2 
  3      ON (c2.city=c1.city AND c2.custname<>c1.custname); 

CUSTNAME             CITY
-------------------- --------------------
KOCHAR               SEATTLE
KING                 SEATTLE
GREEN                BOSTON
SMITH                NEY YORK

SQL> select c1.custname, c1.city 
  2     from Customers c1 FULL OUTER JOIN Customers c2 
  3     ON (c2.city=c1.city AND c2.custname<>c1.custname); 

CUSTNAME             CITY
-------------------- --------------------
KOCHAR               SEATTLE
KING                 SEATTLE
GREEN                BOSTON
SMITH                NEY YORK



6 rows selected.

SQL>  select c1.custname, c1.city 
  2      from Customers c1 RIGHT OUTER JOIN Customers c2 
  3      ON (c2.city=c1.city AND c2.custname<>c1.custname); 

CUSTNAME             CITY
-------------------- --------------------
KING                 SEATTLE
KOCHAR               SEATTLE
QUESTION 128
View the Exhibits and examine the structures of the CUSTOMERS, SALES, and COUNTRIES tables.
You need to generate a report that shows all country names, with corresponding customers (if any) and
sales details (if any), for all customers.
Which FROM clause gives the required result?
A. FROM sales JOIN customers USING (cust_id)
FULL OUTER JOIN countries USING (country_id);
B. FROM sales JOIN customers USING (cust_id)
RIGHT OUTER JOIN countries USING (country_id);
C. FROM customers LEFT OUTER JOIN sales USING (cust_id)
RIGHT OUTER JOIN countries USING (country_id);
D. FROM customers LEFT OUTER JOIN sales USING (cust_id)
LEFT OUTER JOIN countries USING (country_id);
Correct Answer: C
二、题目翻译
查看 CUSTOMERS, SALES, and COUNTRIES表的结构。
要生成一个报表，显示所有客户的所有country names，对应的customers（如果有）和sales details（如果有））
下面哪个from子句，能得出所需的结果？

三、题目解析
根据题意要求，要求显示所有的用户的国家名称，而相匹配的用户名和销售信息有可能有，也有可能没有，即为null也要显示，
所以客户表和销售表左连接，显示所有的用户，不管有没有销售信息匹配，然后再用右连接，关联countries表，这样显示所有的country name,不管有没有客户匹配上，或是销售信息匹配上，都显示出来。
QUESTION 129
View the Exhibits and examine the structures of the PROMOTIONS and SALES tables.
Evaluate the following SQL statement:
SQL>SELECT p.promo_id, p.promo_name, s.prod_id
FROM sales s RIGHT OUTER JOIN promotions p
ON (s.promo_id = p.promo_id);
Which statement is true regarding the output of the above query?
A. It gives the details of promos for which there have been sales.
B. It gives the details of promos for which there have been no sales.
C. It gives details of all promos irrespective of whether they have resulted in a sale or not.
D. It gives details of product ID s that have been sold irrespective of whether they had a promo or not.
Correct Answer: C
二、题目翻译
查看PROMOTIONS and SALES表的结构
评估下面的SQL语句
关于上面查询的输出哪句话是正确的？
A.输出已经销售的promos。
B.输出没有销售的promos。
C.不管有没有销售，输出所有的promos。
D.不管有没有promos，输出所有产品ID。
三、题目解析
因为使用的是RIGHT OUTER JOIN，所以会以右表promotions为准，输出所有的促销信息,不管有没有销售，没有的话，显示为空。
QUESTION 130
View the Exhibit and examine the data in the EMPLOYEES table:
You want to display all the employee names and their corresponding manager names.
Evaluate the following query:
SQL> SELECT e.employee_name "EMP NAME", m.employee_name "MGR NAME"
FROM employees e ______________ employees m
ON e.manager_id = m.employee_id;
Which JOIN option can be used in the blank in the above query to get the required output?
A. only inner JOIN
B. only FULL OUTER JOIN
C. only LEFT OUTER JOIN
D. only RIGHT OUTER JOIN
Correct Answer: C
二、题目翻译
查看EMPLOYEES表的数据
要显示所有员工姓名和对应的经理的姓名。
评估下面的语句
哪一种JOIN操作能被用于空白处，给出所需结果？

三、题目解析
上面的SQL语句中，e代表员工表，而m代表经理表，连接条件e.manager_id = m.employee_id,也就是以员工表的员工为基准，找出他们各自的经理
QUESTION 131
View the Exhibit and examine the structure of the PRODUCT, COMPONENT, and PDT_COMP
tables.
In PRODUCT table, PDTNO is the primary key.
In COMPONENT table, COMPNO is the primary key.
In PDT_COMP table, (PDTNO,COMPNO) is the primary key, PDTNO is the foreign key referencing
PDTNO in PRODUCT table and COMPNO is the foreign key referencing the COMPNO in COMPONENT
table.
You want to generate a report listing the product names and their corresponding component names, if the
component names and product names exist.
Evaluate the following query:
SQL>SELECT pdtno,pdtname, compno,compname
FROM product _____________ pdt_comp
USING (pdtno) ____________ component USING(compno)
WHERE compname IS NOT NULL;
Which combination of joins used in the blanks in the above query gives the correct output?
A. JOIN; JOIN
B. FULL OUTER JOIN; FULL OUTER JOIN
C. RIGHT OUTER JOIN; LEFT OUTER JOIN
D. LEFT OUTER JOIN; RIGHT OUTER JOIN
Correct Answer: C
二、题目翻译
查看 PRODUCT、COMPONENT和PDT_COMP表的结构：
PDTNO是表PRODUCT的主键
COMPNO是表COMPONENT的主键
PDTNO,COMPNO是表PDT_COMP的组合主键，PDTNO是关联PRODUCT表的外键，COMPNO是关联COMPONENT表的外键
要生成一个报表，如果component names和product names存在，则显示product names和对应的component names。
评估下面的语句：
哪一个join组合填在下面的空格处能得出正确的结果?

三、题目解析
现在题目的意思是，要根据PDT_COMP表中的数据，来关联PRODUCT、 COMPONENT两张表，
如果PDT_COMP表中存在的数据，能匹配上PRODUCT、 COMPONENT表中的数据，则显示，
所以，第一次关联的时候，以右表PDT_COMP为基准，右连接，再以关联后的结果为基准，左连接，然后再去掉null值。
QUESTION 132
View the Exhibit and examine the structure of the SALES and PRODUCTS tables.
In the SALES table, PROD_ID is the foreign key referencing PROD_ID in the PRODUCTS table,
You want to list each product ID and the number of times it has been sold.
Evaluate the following query:
SQL>SELECT p.prod_id, COUNT(s.prod_id)
FROM products p _____________ sales s
ON p.prod_id = s.prod_id
GROUP BY p.prod_id;
Which two JOIN options can be used in the blank in the above query to get the required output? (Choose
two.)
A. JOIN
B. FULL OUTER JOIN
C. LEFT OUTER JOIN
D. RIGHT OUTER JOIN
Correct Answer: BC
二、题目翻译
查看SALES和PRODUCTS表的结构：
SALES表中，PROD_ID是关联PRODUCTS表的外键。
列出每一个产品ID和产品已销售的次数。
评估下面的查询：
哪两个join填在空格处能得出所需的结果？

三、题目解析
列出每一个产品ID，应该使用LEFT JOIN，C选项正确，
由于s表的prod_id是products表的外键，不会出现s表中有，而p表中匹配不上的现象，所以在这里，FULL JOIN的效果和LEFT JOIN一样的。

QUESTION 133
Which two statements are true regarding subqueries? (Choose two.)
A. A subquery can retrieve zero or more rows.
B. Only two subqueries can be placed at one level.
C. A subquery can be used only in SQL query statements.
D. A subquery can appear on either side of a comparison operator.
E. There is no limit on the number of subquery levels in the WHERE clause of a SELECT statement.
Correct Answer: AD
二、题目翻译
关于子查询哪两句话是正确的？
A.子查询能检索出0行或多行。
B.只能有两个子查询被放在同一层。
C.子查询只能在SQL查询语句中使用。
D.子查询可以出现在比较运算符的任何一边。
E.在SELECT语句中的WHERE子句里不限制子查询的数量层级。

三、题目解析
A选项正确。
B选项不正确，同一层可以放多个子查询。
C选项不正确，INSERT、UPDATE、DELETE、SELECT、CREATE TABLE等这些语句中都可以使用子查询。
D选项正确。
E选项不正确，WHERE子句中的嵌套子查询最多能嵌套255层。

联机文档中有详细说明：
        http://docs.oracle.com/cd/E11882_01/server.112/e41084/queries007.htm#SQLRF52357

摘录如下：
        A subquery can contain another subquery. Oracle Database imposes no limit on the number of subquery levels in the FROM clause of the top-level query. You can nest up to 255 levels of subqueries in the WHERE clause.
QUESTION 134
Where can subqueries be used? (Choose all that apply.)
A. field names in the SELECT statement
B. the FROM clause in the SELECT statement
C. the HAVING clause in the SELECT statement
D. the GROUP BY clause in the SELECT statement
E. the WHERE clause in only the SELECT statement
F. the WHERE clause in SELECT as well as all DML statements
Correct Answer: ABCF
二、题目翻译
子查询可以在哪里被使用?（选择所有正确的选项）
A.SELECT语句中的字段名称。
B.SELECT语句的FROM子句中。
C.SELECT语句的HAVING子句中。
D.SELECT语句的GROUP BY子句中。
E.只能用于WHERE子句。
F.SELECT与DML语句的WHERE子句中。

三、题目解析
A选项正确，标量子查询就是的。
B、C、F选项都正确，子查询可用于FROM、HAVING、WHERE等子句中，并且SELECT也可以使用在UPDATE、DELETE、INSERT等DML语句中。
对应的，D、E选项就不正确了。
四、测试
D选项测试如下：
SQL> conn scott/oracle
Connected.
SQL> select deptno,sum(sal)
  2      from emp
  3      group by (select deptno from dept);
    group by (select deptno from dept)
              *
ERROR at line 3:
ORA-22818: subquery expressions not allowed here
QUESTION 135
Which three statements are true regarding subqueries? (Choose three.)
A. Subqueries can contain GROUP BY and ORDER BY clauses.
B. Main query and subquery can get data from different tables.
C. Main query and subquery must get data from the same tables.
D. Subqueries can contain ORDER BY but not the GROUP BY clause.
E. Only one column or expression can be compared between the main query and subquery.
F. Multiple columns or expressions can be compared between the main query and subquery.
Correct Answer: ABF
二、题目翻译
关于子查询哪三个语句是正确的？(选择3项)
A.子查询可以包含GROUP BY和ORDER BY子句。
B.主查询和子查询能从不同的表里获取数据。
C.主查询和子查询必须从同一个表获取数据。
D.子查询能包含ORDER BY 子句，但是不能包含GROUP BY子句。
E.主查询与子查询之间只能比较一个列或一个表达式。
F.主查询与子查询之间可以比较多个列或多个表达式。
QUESTION 136
View the Exhibit and examine the structure of the PRODUCTS table.
Which two tasks would require subqueries? (Choose two.)
A. Display the minimum list price for each product status.
B. Display all suppliers whose list price is less than 1000.
C. Display the number of products whose list price is more than the average list price.
D. Display the total number of products supplied by supplier 102 and have product status as 'obsolete'.
E. Display all products whose minimum list price is more than the average list price of products and have
the status 'orderable'.
Correct Answer: CE
二、题目翻译
查看PRODUCTS表的结构：
哪两个任务需要使用子查询？（选择两个）
A.显示每个product status的minimum list price。
B.显示所有价格低于1000的供应商。
C.显示产品价格大于平均价格的产品数量。
D.显示102供应商供应的并且产品状态为'obsolete'的全部产品数量。
E.显示产品的最低价格大于平均价格并且产品状态是'orderable'的所有产品。

三、题目解析
A选项，不需要子查询，用GROUP BY  product status，然后min就可以了。
B选项，用where筛选出价格<1000的就可以了。
C选项，需要用子查询先查出产品的平均价格，然后才能找出比平均价格高的产品和数量。
D选项，不需要子查询，用where条件就可以了。
E选项，需要用子查询先求出产品的平均价格，然后再用where筛选出所需的产品。
QUESTION 137
View the Exhibits and examine PRODUCTS and SALES tables.
You issue the following query to display product name and the number of times the product has been
sold:
SQL>SELECT p.prod_name, i.item_cnt
FROM (SELECT prod_id, COUNT(*) item_cnt
FROM sales
GROUP BY prod_id) i RIGHT OUTER JOIN products p
ON i.prod_id = p.prod_id;
What happens when the above statement is executed?
A. The statement executes successfully and produces the required output.
B. The statement produces an error because ITEM_CNT cannot be displayed in the outer query.
C. The statement produces an error because a subquery in the FROM clause and outer-joins cannot be
used together.
D. The statement produces an error because the GROUP BY clause cannot be used in a subquery in the
FROM clause
Correct Answer: A
二、题目翻译
查看PRODUCTS和SALES两个表:
执行下面的查询，显示产品名称与产品销售的次数
执行上面的语句的结果是什么?
A.语句执行成功并给出正确结果。
B.报错，因为ITEM_CNT不能在外层查询显示。
C.报错，因为FROM子句中的子查询不能与outer-joins一起使用。
D.报错，因为FROM子句中的子查询不能使用GROUP BY子句。

三、题目解析
先通过子查询，求出prod_id和销售的次数，然后再和products表右连接，求出产品的名称和销售的次数。
SQL> conn sh/oracle
Connected.
SQL> SELECT p.prod_name, i.item_cnt
  2  FROM (SELECT prod_id, COUNT(*) item_cnt
  3  FROM sales
  4  GROUP BY prod_id) i RIGHT OUTER JOIN products p
  5  ON i.prod_id = p.prod_id;

PROD_NAME                                            ITEM_CNT
-------------------------------------------------- ----------
Envoy External Keyboard                                  3441
SIMM- 8MB PCMCIAII card                                 19557
Mouse Pad                                               29282
External 6X CD-ROM                                      13043
O/S Documentation Set - French                          12116
O/S Documentation Set - Spanish                          8340
DVD-R Discs, 4.7GB, Pack of 5                           13919
Model NM500X High Yield Toner Cartridge                  7557
256MB Memory Card                                        5541
5MP Telephoto Digital Camera                             6002
Unix/Windows 1-user pack                                16796
QUESTION 138
Which statement is true regarding subqueries?
A. The LIKE operator cannot be used with single- row subqueries.
B. The NOT IN operator is equivalent to IS NULL with single- row subqueries.
C. =ANY and =ALL operators have the same functionality in multiple- row subqueries.
D. The NOT operator can be used with IN, ANY, and ALL operators in multiple- row subqueries.
Correct Answer: D
二、题目翻译
关于子查询哪句话是正确的？
A.LIKE操作符不能用在单行子查询中。
B.NOT IN操作符相当于单选子查询的IS NULL。
C.多行子查询中的=ANY and =ALL操作符具有相同的功能。
D.NOT操作可以用在多行子查询中的IN,ANY和ALL操作符上。

三、测试
D选项，进行如下测试：
SQL> conn scott/oracle
Connected.
SQL> select ename,sal
  2      from emp
  3     where  sal not IN (select sal from emp where ename='SCOTT' or ename='FORD');

ENAME             SAL
---------- ----------
SMITH             800
BLAKE            2850
CLARK            2450
SQL> select ename,sal
  2      from emp
  3     where not sal=ANY(select sal from emp where ename='SCOTT' or ename='FORD');

ENAME             SAL
---------- ----------
SMITH             800
BLAKE            2850
SQL> select ename,sal
  2      from emp
  3     where not sal=ALL(select sal from emp where ename='SCOTT' or ename='FORD');

ENAME             SAL
---------- ----------
SMITH             800
ALLEN            1600
WARD             1250
QUESTION 139
Which three statements are true about multiple-row subqueries? (Choose three.)
A. They can contain a subquery within a subquery.
B. They can return multiple columns as well as rows.
C. They cannot contain a subquery within a subquery.
D. They can return only one column but multiple rows.
E. They can contain group functions and GROUP BY and HAVING clauses.
F. They can contain group functions and the GROUP BY clause, but not the HAVING clause.
Correct Answer: ABE
二、题目翻译
关于多行子查询哪三句话是正确的？(选择三项)
A.子查询中能包含子查询。
B.能返回多列和多行。
C.子查询中不能包含子查询。
D.只能返回一列多行。
E.可以包含组函数和GROUP BY,HAVING子句。
QUESTION 140
Examine the structure of the PRODUCTS table:
name Null Type
PROD_ID NOT NULL NUMBER(4)
PROD_NAME VARCHAR2(20)
PROD_STATUS VARCHAR2(6)
QTY_IN_HAND NUMBER(8,2)
UNIT_PRICE NUMBER(10,2)
You want to display the names of the products that have the highest total value for UNIT_PRICE *
QTY_IN_HAND.
Which SQL statement gives the required output?
A. SELECT prod_name
FROM products
WHERE (unit_price * qty_in_hand) = (SELECT MAX(unit_price * qty_in_hand)
FROM products);
B. SELECT prod_name
FROM products
WHERE (unit_price * qty_in_hand) = (SELECT MAX(unit_price * qty_in_hand)
FROM products
GROUP BY prod_name);
C. SELECT prod_name
FROM products
GROUP BY prod_name
HAVING MAX(unit_price * qty_in_hand) = (SELECT MAX(unit_price * qty_in_hand)
FROM products
GROUP BY prod_name);
D. SELECT prod_name
FROM products
WHERE (unit_price * qty_in_hand) = (SELECT MAX(SUM(unit_price * qty_in_hand))
FROM products)
GROUP BY prod_name;
Correct Answer: A
二、题目翻译
看下面PRODUCTS表的结构:
要显示UNIT_PRICE*QTY_IN_HAND的最高的总价格的产品名称。
下面哪条语句给出所需结果？

三、题目解析
B和C选项不正确，子查询使用的GROUP BY子句按产品名称分组后可能会返回多行值，如果返回多行，就会出现语法错误。
D选项不正确，子查询中，sum汇总之后就只有一条记录了，再求max没意义，所以也会报错。
QUESTION 141
View the Exhibit and examine the structure of CUSTOMERS and GRADES tables.
You need to display names and grades of customers who have the highest credit limit.
Which two SQL statements would accomplish the task? (Choose two.)
A. A. SELECT custname, grade
FROM customers, grades
WHERE (SELECT MAX(cust_credit_limit)
FROM customers) BETWEEN startval and endval;
B. SELECT custname, grade
FROM customers, grades
WHERE (SELECT MAX(cust_credit_limit)
FROM customers) BETWEEN startval and endval
AND cust_credit_limit BETWEEN startval AND endval;
C. SELECT custname, grade
FROM customers, grades
WHERE cust_credit_limit = (SELECT MAX(cust_credit_limit)
FROM customers)
AND cust_credit_limit BETWEEN startval AND endval;
D. SELECT custname, grade
FROM customers , grades
WHERE cust_credit_limit IN (SELECT MAX(cust_credit_limit)
FROM customers)
AND MAX(cust_credit_limit) BETWEEN startval AND endval;
Correct Answer: BC
二、题目翻译
看下面CUSTOMERS and GRADES表的结构
现在要显示有最高credit limit的用户的名称和等级
哪两个SQL语句能得出想要的结果?（选择两项）

三、题目解析
要判断等级，就要判断是否在表中的最高值和最低值之间，就要使用的非等值连接，这里是BETWEEN...AND
A选项不正确，不符合题目要求。
D选项不正确，有语法错误，WHERE子句里不能使用聚合函数。
QUESTION 142
View the Exhibit and examine the structure of the PRODUCTS table.
Evaluate the following query:
SQL> SELECT prod_name
FROM products
WHERE prod_id IN (SELECT prod_id FROM products
WHERE prod_list_price =
(SELECT MAX(prod_list_price)FROM products
WHERE prod_list_price <
(SELECT MAX(prod_list_price)FROM products)));
What would be the outcome of executing the above SQL statement?
A. It produces an error.
B. It shows the names of all products in the table.
C. It shows the names of products whose list price is the second highest in the table.
D. It shows the names of all products whose list price is less than the maximum list price.
Correct Answer: C
二、题目翻译
看下面PRODUCTS表的结构:
评估下面的语句
上面的SQL语句执行后会出现什么结果?
A.报错。
B.显示所有产品的名称。
C.显示表中价格第二高的产品名称。
D.显示所有小于最高价格的产品名称。

三、题目解析
先求出最里层的子查询SELECT MAX(prod_list_price) FROM products，得出的是最高的产品价格；
紧接着外面的子查询，
SELECT MAX(prod_list_price)
   FROM products
 WHERE prod_list_price < (SELECT MAX(prod_list_price) FROM products)
求出的是小于最大价格的最大价格，也就是第二高的价格；
然后再求出这个产品的ID，进一步再求出产品的名称。

QUESTION 143
View the Exhibit and examine the structure of the PROMOTIONS table.
You have to generate a report that displays the promo name and start date for all promos that started after
the last promo in the 'INTERNET' category.
Which query would give you the required output?
A. SELECT promo_name, promo_begin_date FROM promotions
WHERE promo_begin_date > ALL (SELECT MAX(promo_begin_date)
FROM promotions )AND
promo_category = 'INTERNET';
B. SELECT promo_name, promo_begin_date FROM promotions
WHERE promo_begin_date IN (SELECT promo_begin_date
FROM promotions
WHERE promo_category='INTERNET');
C. SELECT promo_name, promo_begin_date FROM promotions
WHERE promo_begin_date > ALL (SELECT promo_begin_date
FROM promotions
WHERE promo_category = 'INTERNET');
D. SELECT promo_name, promo_begin_date FROM promotions
WHERE promo_begin_date > ANY (SELECT promo_begin_date
FROM promotions
WHERE promo_category = 'INTERNET');
Correct Answer: C
二、题目翻译
查看PROMOTIONS表的结构:
要生成一个报表，显示在最后一次促销INTERNET商品之后开始的所有促销活动的promo name和start date.
下面的哪个查询能得出想要的结果?

三、题目解析
A选项不正确，没结果，促销开始日期大于最大促销日期的（所有活动中最大的），并且种类为INTERNET的商品，很明显，不存在这样的记录。
B选项不正确，求出来是种类为INTERNET的商品的信息，与题目要求不符。
C选项正确，先求出种类为INTERNET的开始日期，然后>ALL,表示大于最大的开始日期的活动信息。
D选面不正确，>ANY，表示大于最小值，不符合题目要求。
QUESTION 144
View the Exhibit and examine the structure of the PRODUCTS table.
You want to display the category with the maximum number of items.
You issue the following query:
SQL>SELECT COUNT(*),prod_category_id
FROM products
GROUP BY prod_category_id
HAVING COUNT(*) = (SELECT MAX(COUNT(*)) FROM products);
What is the outcome?
A. It executes successfully and gives the correct output.
B. It executes successfully but does not give the correct output.
C. It generates an error because the subquery does not have a GROUP BY clause.
D. It generates an error because = is not valid and should be replaced by the IN operator.
Correct Answer: C
二、题目翻译
看下面PRODUCTS表的结构
要显示产品数据最多的产品的类别.
执行下面的语句
执行结果是什么？
A.执行成功,并且能得出正确结果。
B.执行成功,但不能得出正确结果。
C.报错，因为子查询没有GROUP BY子句。
D.报错，因为=是无效的，应该使用IN操作符替换。

三、题目解析
子查询中，因为没有group by 子句，count后的结果就只有一条记录了，再用max，就没意义了，所以报错。

QUESTION 145
View the Exhibit and examine the structure of the CUSTOMERS table.
You issue the following SQL statement on the CUSTOMERS table to display the customers who are in the
same country as customers with the last name 'KING' and whose credit limit is less than the maximum
credit limit in countries that have customers with the last name 'KING':
SQL> SELECT cust_id,cust_last_name
FROM customers
WHERE country_id IN(SELECT country_id
FROM customers
WHERE cust_last_name ='King')
AND cust_credit_limit < (SELECT MAX(cust_credit_limit)
FROM customers
WHERE country_id IN(SELECT country_id
FROM customers
WHERE cust_last_name='King'));
Which statement is true regarding the outcome of the above query?
A. It executes and shows the required result.
B. It produces an error and the < operator should be replaced by < ALL to get the required output.
C. It produces an error and the < operator should be replaced by < ANY to get the required output.
D. It produces an error and the IN operator should be replaced by = in the WHERE clause of the main
query to get the required output.
Correct Answer: A
二、题目翻译
看下面的CUSTOMERS表的结构:
执行下面的SQL语句，显示用户信息：与last name为KING的客户有相同的country，并且用户的credit limit小于KING所在countries的最大的credit limit.
关于查询哪句话正确:
A.执行并显示所需结果。
B.报错，因为<操作符应该被<ALL替换才能得到所需结果。
C.报错，因为因为<操作符应该被<ANY替换才能得到所需结果。
D.报错，因为主查询中的WHERE子句中的IN操作符应该被=替换才能得到所需结果。

三、题目解析
先用子查询
SELECT country_id
   FROM customers
WHERE cust_last_name = 'King'
求出king所在的国家ID.
然后，再求出这个国家最大的credit_limit，最后求出和king国家相同，并且credit_limit小于king所在的国家的最大credit_limit的客户的相关信息。

QUESTION 146
Evaluate the following SQL statement:
SQL> SELECT cust_id, cust_last_name
FROM customers
WHERE cust_credit_limit IN
(select cust_credit_limit
FROM customers
WHERE cust_city ='Singapore');
Which statement is true regarding the above query if one of the values generated by the subquery is
NULL?
A. It produces an error.
B. It executes but returns no rows.
C. It generates output for NULL as well as the other values produced by the subquery.
D. It ignores the NULL value and generates output for the other values produced by the subquery.
Correct Answer: C
二、题目翻译
评估下面的SQL语句
关于上面的查询如果子查询返回值中其中有一个值为NULL，下面哪句话是正确的？
A.报错。
B.执行但不返回行。
C.对于NULL和子查询的其它值会有输出。
D.忽略NULL值，并且对于子查询的其它值会有输出。

三、题目解析
in后面的列表中有null值的，
比如: id in( null,200),
那么，变换一下，就变成id = null or id = 200,因为id=null是不成立的，所以相当于 false or id=200
所以说，没有输出null值，只是因为表达式不成立，并不是忽略了null值。

QUESTION 147
View the Exhibit and examine the structure of the PROMOTIONS table.
Evaluate the following SQL statement:
SQL>SELECT promo_name,CASE
WHEN promo_cost >=(SELECT AVG(promo_cost)
FROM promotions
WHERE promo_category='TV')
then 'HIGH'
else 'LOW'
END COST_REMARK
FROM promotions;
Which statement is true regarding the outcome of the above query?
A. It shows COST_REMARK for all the promos in the table.
B. It produces an error because the subquery gives an error.
C. It shows COST_REMARK for all the promos in the promo category 'TV'.
D. It produces an error because subqueries cannot be used with the CASE expression
Correct Answer: A
二、题目翻译
看下面PROMOTIONS表的结构.
评估下面的语句:
关于上面查询的结果哪句话是正确的？
A.显示所有promos 的COST_REMARK。
B.报错，因为子查询会出错。
C.显示promo category为TV的所有产品的COST_REMARK。
D.报错，因为子查询不能用于CASE表达式。

三、题目解析
子查询
SELECT AVG(promo_cost) 
    FROM promotions 
WHERE promo_category = 'TV'
显示了TV的平均促销成本
CASE..WHEN的结果是，促销成本大于TV的平均促销成本的，显示为HIGH，否则显示为LOW。

QUESTION 148
View the Exhibit and examine the structure of the PRODUCTS tables.
You want to generate a report that displays the average list price of product categories where the average
list price is less than half the maximum in each category.
Which query would give the correct output?
A. SELECT prod_category,avg(prod_list_price)
FROM products
GROUP BY prod_category
HAVING avg(prod_list_price) < ALL
(SELECT max(prod_list_price)/2
FROM products
GROUP BY prod_category);
B. SELECT prod_category,avg(prod_list_price)
FROM products
GROUP BY prod_category
HAVING avg(prod_list_price) > ANY
(SELECT max(prod_list_price)/2
FROM products
GROUP BY prod_category);
C. SELECT prod_category,avg(prod_list_price)
FROM products
HAVING avg(prod_list_price) < ALL
(SELECT max(prod_list_price)/2
FROM products
GROUP BY prod_category);
D. SELECT prod_category,avg(prod_list_price)
FROM products
GROUP BY prod_category
HAVING avg(prod_list_price) > ANY
(SELECT max(prod_list_price)/2
FROM products);
Correct Answer: A
二、题目翻译
查询PRODUCTS表的结构，
要生成一个报表，显示 平均价格小于每一个category最大值的一半 的product categories的平均价格。
哪一个查询给出正确结果？

三、题目解析
A选项正确，<ALL，小于列表中的最小的.
B选项不正确，> ANY表示大于列表中的最小值，不符合题目的要求。
C选项不正确，主查询没有使用GROUP BY子句，却使用了HAVING子句，会报错。
D选项不正确，> ANY表示大于列表中的最小值，并用any值列表子查询中，没分组，只有一个值，不符合题目的要求。
QUESTION 149
View the Exhibits and examine the structures of the COSTS and PROMOTIONS tables.
Evaluate the following SQL statement:
SQL>SELECT prod_id
      FROM costs
     WHERE promo_id IN
           (SELECT promo_id
              FROM promotions
             WHERE promo_cost < ALL
             (SELECT MAX(promo_cost)
                      FROM promotions
                     GROUP BY (promo_end_date - promo_begin_date)));
What would be the outcome of the above SQL statement?
A. It displays prod IDs in the promo with the lowest cost.
B. It displays prod IDs in the promos with the lowest cost in the same time interval.
C. It displays prod IDs in the promos with the highest cost in the same time interval.
D. It displays prod IDs in the promos with cost less than the highest cost in the same time interval.
Correct Answer: D
二、题目翻译
查看COSTS and PROMOTIONS表的结构.
评估下面的SQL语句
上面SQL的执行结果什么？
A.显示promo最低的prod IDs。
B.显示相同时间段内promo最低的prod IDs。
C.显示相同时间段内promo最高的prod IDs。
D.显示相同时间段内promo的cost小于最高的cost的prod IDs。

三、题目解析
子查询
SELECT MAX(promo_cost)
  FROM promotions
 GROUP BY (promo_end_date - promo_begin_date)
求出来的，是每个促销活动期间内的最大的成本。
然后 promo_cost < ALL(.. )，表示小于 刚子查询查出来的所有这些最大成本结果集中，最小的那个。
然后，再根据活动ID，查出产品ID。

D选项中，描述也不是太准确，但是在几个选项的描述中，D是最接近的。

QUESTION 150
View the Exhibit and examine the data in the PROMOTIONS table.
You need to display all promo categories that do not have 'discount' in their subcategory.
Which two SQL statements give the required result? (Choose two.)
A. SELECT promo_category
FROM promotions
MINUS
SELECT promo_category
FROM promotions
WHERE promo_subcategory = 'discount';
B. SELECT promo_category
FROM promotions
INTERSECT
SELECT promo_category
FROM promotions
WHERE promo_subcategory = 'discount';
C. SELECT promo_category
FROM promotions
MINUS
SELECT promo_category
FROM promotions
WHERE promo_subcategory <> 'discount';
D. SELECT promo_category
FROM promotions
INTERSECT
SELECT promo_category
FROM promotions
WHERE promo_subcategory <> 'discount';
Correct Answer: AD
二、题目翻译
查看 PROMOTIONS表的数据
要显示所有子种类中没有'discount'的促销种类.
下面哪两个SQL语句能给出正确的结果？（选择2个）

三、题目解析
MINUS 表示两个结果集相减
INTERSECT 表示两个结果集的交集，即两个结果集中共有的部分。

A选项正确，从所有种类中，减去子种类= 'discount'的，就表示没有这个子种类的。
B选项不正确，所有种类和子种类= 'discount'的交集，就是子种类= 'discount'的产品，不符合题目要求。
C选项不正确，从所有种类中，减去 子种类<> 'discount'的，就是子种类= 'discount'的产品，不符合题目要求。
D选项正确，所有种类和子种类<> 'discount'的交集，就是子种类<>'discount'的产品。
QUESTION 151
View the Exhibit and examine the structure of the CUSTOMERS and CUST_HISTORY tables.
The CUSTOMERS table contains the current location of all currently active customers. The
CUST_HISTORY table stores historical details relating to any changes in the location of all current as well
as previous customers who are no longer active with the company.
You need to find those customers who have never changed their address.
Which SET operator would you use to get the required output?
A. MINUS
B. UNION
C. INTERSECT
D. UNION ALL
Correct Answer: A
二、题目翻译
查看CUSTOMERS and CUST_HISTORY的表结构：
CUSTOMERS表包含所有当前活动客户的位置,CUST_HISTORY表存储相关的所有当前位置的改变的历史信息和公司中先前不再活动的客户。
要找到那些从来没有改变过地址的客户.
哪一个集合操作给出所需结果。

三、题目解析
一个表中是活动客户的地址信息，一个表中是客户以前地址的历史信息，两张表的差集，就是从来没有改变过地址的客户。
QUESTION 152
Which statement is true regarding the UNION operator?
A. By default, the output is not sorted.
B. NULL values are not ignored during duplicate checking.
C. Names of all columns must be identical across all SELECT statements.
D. The number of columns selected in all SELECT statements need not be the same.
Correct Answer: B
二、题目翻译
关于UNION操作符哪句话正确？
A.默认输出不排序。
B.在重复值检查时不忽略NULL值。
C.列名在所有SELECT语句中必须是相同的。
D.在所有SELECT语句中选择的列的数量不需要相同。

三、题目解析
A选项不正确，因为默认输出排序。
B选项正确，因为集合不忽略null值，并且在去重时会认为null和null是相等的，去重。
C选项不正确，因为SELECT语句中的列名不必是相同的，但是数据类型是需要匹配的。
D选项不正确，因为列的数量要相同。
SQL> create table t1(id int);
SQL> insert into t1 values(1);
SQL> insert into t1 values(null);
SQL> commit;
SQL> create table t2(id int);
SQL> insert into t2 values(2);
SQL> insert into t2 values(null);
SQL> commit;
--两行null,已经去掉了一行，表示去重时，不忽略空值。
SQL> select * from t1
  2      union
  3     select * from t2; 

        ID
----------
         1
         2
-- 列的数量和类型必须一致
SQL>  select id,null from t1
  2      union
  3      select id from t2;
 select id,null from t1
 *
ERROR at line 1:
ORA-01789: query block has incorrect number of result columns
--名字可以不一致
SQL> select id nid from t1
  2      union
  3      select id from t2;

       NID
----------
         1
         2
QUESTION 153
View the Exhibits and examine the structures of the PRODUCTS and SALES tables.
Which two SQL statements would give the same output? (Choose two.)
A. SELECT prod_id FROM products
INTERSECT
SELECT prod_id FROM sales;
B. SELECT prod_id FROM products
MINUS
SELECT prod_id FROM sales;
C. SELECT DISTINCT p.prod_id
FROM products p JOIN sales s
ON p.prod_id=s.prod_id;
D. SELECT DISTINCT p.prod_id
FROM products p JOIN sales s
ON p.prod_id <> s.prod_id;
Correct Answer: AC
二、题目翻译
查看PRODUCTS and SALES表的结构：
哪两个语句给出相同的输出？（选择2个）

三、题目解析
AC选项，结果是所有销售过的产品的ID，prod_id.
B和D答案让人容易混淆，B是显示没有销售过的产品ID，但是D答案不等于的连接会导致产品ID全显示出来。
QUESTION 154
View the Exhibit and evaluate structures of the SALES, PRODUCTS, and COSTS tables.
Evaluate the following SQL statement:
SQL>SELECT prod_id FROM products
INTERSECT
SELECT prod_id FROM sales
MINUS
SELECT prod_id FROM costs;
Which statement is true regarding the above compound query?
A. It produces an error.
B. It shows products that were sold and have a cost recorded.
C. It shows products that were sold but have no cost recorded.
D. It shows products that have a cost recorded irrespective of sales.
Correct Answer: C
二、题目翻译
查看SALES, PRODUCTS, and COSTS表的结构:
评估下面的SQL语句:
关于上面的组合查询哪句话是正确的:
A.报错。
B.显示已销售并且有cost记录的产品。
C.显示已销售但是没有cost记录的产品。
D.显示有cost recorded不管sales的产品。

三、题目解析
SELECT prod_id FROM products
INTERSECT
SELECT prod_id FROM sales
首先，交集，求出的是已经销售的产品ID
然后再和costs表和差集，表示已销售但是没有cost记录的产品。
QUESTION 155
Evaluate the following SQL statement:
SQL> SELECT promo_id, promo_category
FROM promotions
WHERE promo_category = 'Internet' ORDER BY 2 DESC
UNION
SELECT promo_id, promo_category
FROM promotions
WHERE promo_category = 'TV'
UNION
SELECT promo_id, promo_category
FROM promotions
WHERE promo_category ='Radio';
Which statement is true regarding the outcome of the above query?
A. It executes successfully and displays rows in the descending order of PROMO_CATEGORY.
B. It produces an error because positional notation cannot be used in the ORDER BY clause with SET
operators.
C. It executes successfully but ignores the ORDER BY clause because it is not located at the end of the
compound statement.
D. It produces an error because the ORDER BY clause should appear only at the end of a compound
query-that is, with the last SELECT statement.
Correct Answer: D
二、题目翻译
评估下面的SQL查询语句:
关于上面查询的结果，下面说法正确的是哪一个？
A.执行成功，并降序显示所有PROMO_CATEGORY行。
B.报错，因为位置记号不能用在带有SET操作的ORDER BY子句中。
C.执行成功，但是会忽略ORDER BY子句，因为它没有位于复合语句的最后。
D.报错，因为ORDER BY 子句只能出现在复合查询的最后-最后一个SELECT语句中。

三、题目解析
集合操作中，ORDER BY只能放在最后，前面的结果集进行集合操作之后，可以看作一个整体，然后在最后再进行排序。
SQL> SELECT promo_id, promo_category
  2  FROM promotions
  3  WHERE promo_category = 'Internet' 
  4  UNION
  5  SELECT promo_id, promo_category
  6  FROM promotions
  7  WHERE promo_category = 'TV'
  8  UNION
  9  SELECT promo_id, promo_category
 10  FROM promotions
 11  WHERE promo_category ='Radio' ORDER BY 2 DESC;

  PROMO_ID PROMO_CATEGORY
---------- ------------------------------
        35 TV
        42 TV
        47 TV
        49 TV
        54 TV
        61 TV
        66 TV
        81 TV
        82 TV
        93 TV
        94 TV
QUESTION 156
Evaluate the following SQL statement:
SQL> SELECT cust_id, cust_last_name "Last Name"
FROM customers
WHERE country_id = 10
UNION
SELECT cust_id CUST_NO, cust_last_name
FROM customers
WHERE country_id = 30;
Which ORDER BY clauses are valid for the above query? (Choose all that apply.)
A. ORDER BY 2,1
B. ORDER BY CUST_NO
C. ORDER BY 2,cust_id
D. ORDER BY "CUST_NO"
E. ORDER BY "Last Name"
Correct Answer: ACE

二、题目翻译
评估下面的语句：
哪一个ORDER BY子句是有效的(选择所有正确的选项）？

三、题目解析
ORDER BY后可以使用数字表示select语句后的第几个字段，也可以使用列名。
B和D选项不正确，因为只能使用第一个查询的列进行排序，包括别名、列名或表达式。
SQL> SELECT cust_id, cust_last_name "Last Name"
  2  FROM customers
  3  WHERE country_id = 10
  4  UNION
  5  SELECT cust_id CUST_NO, cust_last_name
  6  FROM customers
  7  WHERE country_id = 30 ORDER BY CUST_NO;
WHERE country_id = 30 ORDER BY CUST_NO
                               *
ERROR at line 7:
ORA-00904: "CUST_NO": invalid identifier 
SQL> SELECT cust_id, cust_last_name "Last Name"
  2  FROM customers
  3  WHERE country_id = 10
  4  UNION
  5  SELECT cust_id CUST_NO, cust_last_name
  6  FROM customers
  7  WHERE country_id = 30 ORDER BY "CUST_NO";
WHERE country_id = 30 ORDER BY "CUST_NO"
                               *
ERROR at line 7:
ORA-00904: "CUST_NO": invalid identifier

QUESTION 157
View the Exhibit and examine the structure of the ORDERS and CUSTOMERS tables.
Evaluate the following SQL command:
SQL> SELECT o.order_id, c.cust_name, o.order_total, c.credit_limit
FROM orders o JOIN customers c
USING (customer_id)
WHERE o.order_total > c.credit_limit
FOR UPDATE
ORDER BY o.order_id;
Which two statements are true regarding the outcome of the above query? (Choose two.)
A. It locks all the rows that satisfy the condition in the statement.
B. It locks only the columns that satisfy the condition in both the tables.
C. The locks are released only when a COMMIT or ROLLBACK is issued.
D. The locks are released after a DML statement is executed on the locked rows.
Correct Answer: AC

二、题目翻译
查看ORDERS和CUSTOMERS表的结构
评估下面的SQL命令:
关于上面查询的结果哪两句话是正确的？(选择2项)
A.锁定语句中满足条件的所有行。
B.只锁定两个表中满足条件的列。
C.只有执行COMMIT或ROLLBACK后，锁才会释放。
D.在锁定的行上执行DML语句后，锁被释放。

三、题目解析
A选项正确，select .. for update语句，就是锁定select出来的所有行，以防止其它会话变更。
B选项不正确，oracle中有行锁和表锁，没有列锁，会将相关的行都锁住。

C选项，答案中是正确，但是这个说法，个人认为不是太完整。
            commit和rollback后，锁的确可以被释放，
            但如果说只有在commit或rollback之后才能释放锁，就有些不恰当，因为只要事务结束，锁就会被释放，而事务结束，不光只有commit和rollback，比如，还有进行DDL操作的时候，或用户正常或不正常退出的时候，都会结束事务，事务结束，锁就会被释放。

D选项不正确，在当前会话中，被锁定的行上可以做DML操作，但仍然不会释放锁，如果在其它会话中在被锁定的行上做DML操作，则会被阻塞。

四、测试
关于C选项，测试如下，选择其中一种情况，DDL的时候，会自动提交事务，并释放锁。
SQL> select sid from v$mystat where rownum=1;

       SID
----------
        25
SQL> set linesize 200
SQL> select * from scott.emp where ename='SCOTT' for update;

     EMPNO ENAME      JOB              MGR HIREDATE                  SAL       COMM     DEPTNO
---------- ---------- --------- ---------- ------------------ ---------- ---------- ----------
      7788 SCOTT      ANALYST         7566 19-APR-87                3000                    20
SQL> select sid,type,id1,id2, 
  2         decode(lmode,0,'None', 
  3             1,'Null',
  4             2,'Row share',
  5             3,'Row Exclusive',
  6           4,'Share',
  7             5,'Share Row Exclusive',
  8             6,'Exclusive') lock_type,
  9         request,ctime,block 
 10     from v$lock
 11     where sid=25;

       SID TY        ID1        ID2 LOCK_TYPE              REQUEST      CTIME      BLOCK
---------- -- ---------- ---------- ------------------- ---------- ---------- ----------
        25 AE        100          0 Share                        0        118          0
        25 TM      75315          0 Row Exclusive                0         95          0
        25 TX     458779        893 Exclusive                    0         95          0

SQL> create table test_lock(id int);

Table created.

SQL> select sid,type,id1,id2, 
  2         decode(lmode,0,'None', 
  3             1,'Null',
  4             2,'Row share',
  5             3,'Row Exclusive',
  6           4,'Share',
  7             5,'Share Row Exclusive',
  8             6,'Exclusive') lock_type,
  9         request,ctime,block 
 10     from v$lock
 11     where sid=25;

       SID TY        ID1        ID2 LOCK_TYPE              REQUEST      CTIME      BLOCK
---------- -- ---------- ---------- ------------------- ---------- ---------- ----------
        25 AE        100          0 Share                        0        139          0

QUESTION 158
Which statements are true regarding the FOR UPDATE clause in a SELECT statement? (Choose all
that apply.)
A. It locks only the columns specified in the SELECT list.
B. It locks the rows that satisfy the condition in the SELECT statement.
C. It can be used only in SELECT statements that are based on a single table.
D. It can be used in SELECT statements that are based on a single or multiple tables.
E. After it is enforced by a SELECT statement, no other query can access the same rows until a
COMMIT or ROLLBACK is issued.
Correct Answer: BD
二、题目翻译
关于FOR UPDATE子句哪句话是正确的（选择所有正确的选项）
A. 只锁定SELECT列表中指定的列。
B. 锁定SELECT语句中满足条件的行。
C. 只能用于基于单个表的SELECT语句中。
D. 可以用于基于单个表或多个表的SELECT语句中。
E. 使用SELECT语句执行之后，其它查询直到执行COMMIT或ROLLBACK后才能访问相同的行。

三、题目解析
A选项不正确，oracle中有行锁和表锁，没有列锁，所以，不会只锁定相关的列。
B选项正确，for update语句，会锁定select出来的相关的行。
C选项不正确，select ... for update可以用于基于一张表，也可以基于多张表。
D选项正确。
E选项，for update语句执行之后，其它查询不能变更这些相关的行，但是不影响查询(select)。

QUESTION 159
View the Exhibit and examine the structure of the CUSTOMERS table.
NEW_CUSTOMERS is a new table with the columns CUST_ID, CUST_NAME and CUST_CITY that
have the same data types and size as the corresponding columns in the CUSTOMERS table.
Evaluate the following INSERT statement:
INSERT INTO new_customers (cust_id, cust_name, cust_city)
VALUES(SELECT cust_id,cust_first_name' 'cust_last_name,cust_city
FROM customers
WHERE cust_id > 23004);
The INSERT statement fails when executed. What could be the reason?
A. The VALUES clause cannot be used in an INSERT with a subquery.
B. Column names in the NEW_CUSTOMERS and CUSTOMERS tables do not match.
C. The WHERE clause cannot be used in a subquery embedded in an INSERT statement.
D. The total number of columns in the NEW_CUSTOMERS table does not match the total number of
columns in the CUSTOMERS table.
Correct Answer: A
二、题目翻译
查看CUSTOMERS表的结构
NEW_CUSTOMERS是一个新表，它的CUST_ID, CUST_NAME and CUST_CITY列的数据类型和大小与CUSTOMERS相同.
评估下面的INSERT语句
执行失败的原因是什么?
A.VALUES子句不能用于带有子查询的INSERT语句。
B.NEW_CUSTOMERS表中的列名与CUSTOMERS表不匹配。
C.嵌入在一个INSERT语句中的子查询不能使用WHERE子句。
D.NEW_CUSTOMERS表中列的全部数量与CUSTOMERS表中列的全部数量不匹配。

三、题目解析
values后面只能跟确定的值，如果需要使用子查询的结果集插入到表中，就不用带values关键字。

QUESTION 160
View the Exhibit and examine the structure of ORDERS and CUSTOMERS tables.
There is only one customer with the cust_last_name column having value Roberts. Which INSERT
statement should be used to add a row into the ORDERS table for the customer whose
CUST_LAST_NAME is Roberts and CREDIT_LIMIT is 600?
A. INSERT INTO orders
VALUES (1,'10-mar-2007', 'direct',
(SELECT customer_id
FROM customers
WHERE cust_last_name='Roberts' AND
credit_limit=600), 1000);
B. INSERT INTO orders (order_id,order_date,order_mode,
(SELECT customer_id
FROM customers
WHERE cust_last_name='Roberts' AND
credit_limit=600),order_total)
VALUES(1,'10-mar-2007', 'direct', &&customer_id, 1000);
C. INSERT INTO(SELECT o.order_id, o.order_date,o.order_mode,c.customer_id, o.order_total
FROM orders o, customers c
WHERE o.customer_id = c.customer_id
AND c.cust_last_name='Roberts' ANDc.credit_limit=600 )
VALUES (1,'10-mar-2007', 'direct',(SELECT customer_id
FROM customers
WHERE cust_last_name='Roberts' AND
credit_limit=600), 1000);
D. INSERT INTO orders (order_id,order_date,order_mode,
(SELECT customer_id
FROM customers
WHERE cust_last_name='Roberts' AND
credit_limit=600),order_total)
VALUES(1,'10-mar-2007', 'direct', &customer_id, 1000);
Correct Answer: A

二、题目翻译
查看ORDERS and CUSTOMERS 表的结构：
只有一个customer的cust_last_name列的值是Roberts，
哪一个INSERT语句能被用于给ORDERS添加一行，customer的cust_last_name为Roberts，并且CREDIT_LIMIT为600？

三、题目解析
A选项正确，因为题目说明了，只有一个customer的cust_last_name列的值是Roberts，所以，子查询
   SELECT customer_id
      FROM customers
     WHERE cust_last_name = 'Roberts'
       AND credit_limit = 600
只有一个返回值，这里就能插入成功。
BCD选项语法不正确，没有这样的用法。
QUESTION 161
View the exhibit and examine the description for the SALES and CHANNELS tables.
You issued the following SQL statement to insert a row in the SALES table:
INSERT INTO sales VALUES
(23, 2300, SYSDATE, (SELECT channel_id
FROM channels
WHERE channel_desc='Direct Sales'), 12, 1, 500);
Which statement is true regarding the execution of the above statement?
A. The statement will execute and the new row will be inserted in the SALES table.
B. The statement will fail because subquery cannot be used in the VALUES clause.
C. The statement will fail because the VALUES clause is not required with subquery.
D. The statement will fail because subquery in the VALUES clause is not enclosed with in single quotation
marks .
Correct Answer: A
二、题目翻译
查看SALES and CHANNELS表的结构
执行下面的SQL语句给SALES表插入一行:
关于执行上面的语句哪句话是正确的？
A.语句执行成功，并且SALES表会插入一个新行。
B.语句失败，因为子查询不能用于VALUES子句中。
C.语句失败，因为VALUES子句不需要使用子查询。
D.语句失败，因为VALUES子句中的子查询没有使用单引号引起来。

三、题目解析
A选项，答案是正确的，如果子查询中只返回一行，则这个答案正确，如果子查询中返回多行，就会报错，但相比其它答案，只有这个还算比较正确。
B选项不正确，values子句中，可以使用子查询，详见下面。
C选项不正确，需不需要使用子查询，是业务需求决定的。
D选项不正确，子查询使用括号，而不是单引号。
四、测试
SQL> conn scott/oracle
Connected.
SQL> create table emp3 as select * from emp where 1=0;

Table created.
-- values中的子查询如果返回一行，则能插入成功
SQL> insert into emp3(empno,ename,deptno) values(1234,'aaa',(select deptno from emp where ename='SCOTT'));

1 row created.
-- values中的子查询如果返回多行，则能插入失败
SQL>  insert into emp3(empno,ename,deptno) values(1234,'aaa',(select deptno from emp where deptno=10));
 insert into emp3(empno,ename,deptno) values(1234,'aaa',(select deptno from emp where deptno=10))
                                                         *
ERROR at line 1:
ORA-01427: single-row subquery returns more than one row
QUESTION 162
View the Exhibit and examine the structure of the PRODUCTS, SALES, and SALE_SUMMARY
tables.
SALE_VW is a view created using the following command :
SQL>CREATE VIEW sale_vw AS
SELECT prod_id, SUM(quantity_sold) QTY_SOLD
FROM sales GROUP BY prod_id;
You issue the following command to add a row to the SALE_SUMMARY table :
SQL>INSERT INTO sale_summary
SELECT prod_id, prod_name, qty_sold FROM sale_vw JOIN products
USING (prod_id) WHERE prod_id = 16;
What is the outcome?
A. It executes successfully.
B. It gives an error because a complex view cannot be used to add data into the SALE_SUMMARY table.
C. It gives an error because the column names in the subquery and the SALE_SUMMARY table do not
match.
D. It gives an error because the number of columns to be inserted does not match with the number of
columns in the SALE_SUMMARY table.
Correct Answer: D
二、题目翻译
查看PRODUCTS, SALES, and SALE_SUMMARY表的结构：
SALE_VW是使用下面命令建立的一个视图：
执行下面的命令给SALE_SUMMARY添加一新行：
执行上面命令的结果是什么？
A.执行成功。
B.报错，因为复杂视图不能用于向SALE_SUMMARY表里添加数据。
C.报错，因为子查询中的列名与SALE_SUMMARY表中的列名不匹配。
D.报错，因为被插入的列的数量与SALE_SUMMARY表中列的数量不匹配。

三、题目解析
通过实验使用视图也可以与表进行连接操作，此题是由于列的数量不匹配造成的，
sale_summary后面没有写列名，就表示要插入所有的列(总共4列)，但这里给的值只有3个值，所以会报值不够的错误
ORA-00947: not enough values
四、测试
SQL> conn sh/oracle
Connected.
SQL> CREATE VIEW sale_vw AS
  2  SELECT prod_id, SUM(quantity_sold) QTY_SOLD
  3  FROM sales GROUP BY prod_id;

View created.

SQL> create table sale_summary(prod_id number(4) not null,prod_name varchar2(30),total_oty_sold number(10,2),prod_category varchar2(5));

Table created.

SQL> INSERT INTO sale_summary
  2      SELECT prod_id, prod_name, qty_sold
  3        FROM sale_vw
  4        JOIN products
  5       USING (prod_id)
  6       WHERE prod_id = 16;
INSERT INTO sale_summary
            *
ERROR at line 1:
ORA-00947: not enough values

QUESTION 163
View the Exhibit and examine the description for the CUSTOMERS table.
You want to update the CUST_CREDIT_LIMIT column to NULL for all the customers, where
CUST_INCOME_LEVEL has NULL in the CUSTOMERS table. Which SQL statement will accomplish the
task?
A. UPDATE customers
SET cust_credit_limit = NULL
WHERE CUST_INCOME_LEVEL = NULL;
B. UPDATE customers
SET cust_credit_limit = NULL
WHERE cust_income_level IS NULL;
C. UPDATE customers
SET cust_credit_limit = TO_NUMBER(NULL)
WHERE cust_income_level = TO_NUMBER(NULL);
D. UPDATE customers
SET cust_credit_limit = TO_NUMBER(' ',9999)
WHERE cust_income_level IS NULL;
Correct Answer: B
二、题目翻译
查看CUSTOMERS表的结构:
要更新CUSTOMERS表中所有customers的CUST_CREDIT_LIMIT值，当CUST_INCOME_LEVEL为NULL时更新CUST_CREDIT_LIMIT为空。
哪个SQL语句能完成此上面的要求？

三、题目解析
在oracle中 ，判断列值是否为null,要用 列名 is null来判断，而设置值的时候，用等号(=)。
QUESTION 164
View the Exhibit and examine the structure of CUSTOMERS and SALES tables.
Evaluate the following SQL statement:
UPDATE (SELECT prod_id, cust_id, quantity_sold, time_id
FROM sales)
SET time_id = '22-MAR-2007'
WHERE cust_id = (SELECT cust_id
FROM customers
WHERE cust_last_name = 'Roberts' AND
credit_limit = 600);
Which statement is true regarding the execution of the above UPDATE statement?
A. It would not execute because two tables cannot be used in a single UPDATE statement.
B. It would not execute because the SELECT statement cannot be used in place of the table name.
C. It would execute and restrict modifications to only the columns specified in the SELECT statement.
D. It would not execute because a subquery cannot be used in the WHERE clause of an UPDATE
statement.
Correct Answer: C
二、题目翻译
看下面的CUSTOMERS and SALES表的结构，
评估下面的SQL语句：
关于执行上面的UPDATE语句哪句话是正确的？
A.执行失败，因为两个表不能用于一个UPDATE语句。
B.执行失败，因为SELECT语句不能用于代替表名。
C.执行成功，并限制只能修改SELECT语句指定的列。
D.失败失败，因为子查询不能用于UPDATE的WHERE子句中。

三、题目解析
UPDATE后面的SELECT语句相当于一个简单视图，也就是对这个视图进行修改，所以，只能修改select后面的的列。

SQL> UPDATE (SELECT prod_id, cust_id, quantity_sold, time_id FROM sales)
  2     SET time_id = '22-MAR-2007'
  3   WHERE cust_id = (SELECT cust_id
  4                      FROM customers
  5                     WHERE cust_last_name = 'Roberts'
  6                       AND cust_credit_limit = 600);

0 rows updated.
QUESTION 165
View the Exhibit and examine the description for the CUSTOMERS table.
You want to update the CUST_INCOME_LEVEL and CUST_CREDIT_LIMIT columns for the customer
with the CUST_ID 2360. You want the value for the CUST_INCOME_LEVEL to have the same value as
that of the customer with the CUST_ID 2560 and the CUST_CREDIT_LIMIT to have the same value as
that of the customer with CUST_ID 2566.
Which UPDATE statement will accomplish the task?
A. UPDATE customers
SET cust_income_level = (SELECT cust_income_level
FROM customers
WHERE cust_id = 2560),
cust_credit_limit = (SELECT cust_credit_limit
FROM customers
WHERE cust_id = 2566)
WHERE cust_id=2360;
B. UPDATE customers
SET (cust_income_level,cust_credit_limit) = (SELECT
cust_income_level, cust_credit_limit
FROM customers
WHERE cust_id=2560 OR cust_id=2566)
WHERE cust_id=2360;
C. UPDATE customers
SET (cust_income_level,cust_credit_limit) = (SELECT
cust_income_level, cust_credit_limit
FROM customers
WHERE cust_id IN(2560, 2566)
WHERE cust_id=2360;
D. UPDATE customers
SET (cust_income_level,cust_credit_limit) = (SELECT
cust_income_level, cust_credit_limit
FROM customers
WHERE cust_id=2560 AND cust_id=2566)
WHERE cust_id=2360;
Correct Answer: A
二、题目翻译
查看CUSTOMERS表的结构:
要更新CUST_ID为2360的CUST_INCOME_LEVEL和CUST_CREDIT_LIMIT列值,要让CUST_INCOME_LEVEL的值与CUST_ID为2560的值一样，让CUST_CREDIT_LIMIT的值与CUST_ID为2566的值一样。
哪一个UPDATE语句能完成该任务?

三、题目解析
B和C选项不正确，由于子查询里返回多行记录，而这里又是=,所以报错。
D明显子查询的条件不符合题意，这里不会返回结果。
QUESTION 166
View the Exhibit and examine the structures of the EMPLOYEES and DEPARTMENTS tables.
You want to update the EMPLOYEES table as follows:4 ? 4;
-Update only those employees who work in Boston or Seattle (locations 2900 and 2700).
-Set department_id for these employees to the department_id corresponding to London (location_id
2100).
-Set the employees' salary in location_id 2100 to 1.1 times the average salary of their department.
-Set the employees' commission in location_id 2100 to 1.5 times the average commission of their
department.
You issue the following command:
SQL>UPDATE employees
SET department_id =
(SELECT department_id
FROM departments
WHERE location_id = 2100),
(salary, commission) =
(SELECT 1.1*AVG(salary), 1.5*AVG(commission)
FROM employees, departments
WHERE departments.location_id IN(2900,2700,2100))
WHERE department_id IN
(SELECT department_id
FROM departments
WHERE location_id = 2900
OR location_id = 2700)
What is the outcome?
A. It executes successfully and gives the correct result.
B. It executes successfully but does not give the correct result.
C. It generates an error because a subquery cannot have a join condition in an UPDATE statement.
D. It generates an error because multiple columns (SALARY, COMMISION) cannot be specified together
in an UPDATE statement.
二、题目翻译
看下面EMPLOYEES和DEPARTMENTS表的结构:
要把EMPLOYEES表做如下更新:
--只更新那些在Boston或Seattle工作的employees（locations为2900和2700)。
--设置这些employees的department_id为London（location_id=2100）对应的department_id。
--设置location_id=2100的employees' salary为他们部门的平均薪水的1.1倍。
--设置location_id=2100的employees' commission为他们部门的平均提成的1.1倍。
执行下面的语句：
结果是什么?
A.执行成功并给出正确结果。
B.执行成功但不给出正确结果。
C.报错，因为UPDATE语句中的子查询不能使用连接条件。
D.报错，因为UPDATE语句中不能一起指定多个列（SALARY, COMMISION）。

三、题目解析
(salary, commission) = (SELECT 1.1 * AVG(salary),
                               1.5 * AVG(commission)
                          FROM employees, departments
                         WHERE departments.location_id IN (2900, 2700, 2100)
这个子查询，查出来的，不是题目要求的记录，
employees, departments两张表应该使用部门ID进行关联
而且，这里只需要改location_id=2100的员工的工资和提成，其它两个部门的都不需要，所以不正确。
所以，这个语句虽然能正常执行，但不是我们题目要求的结果。

QUESTION 167
Evaluate the following DELETE statement:
DELETE FROM sales;
There are no other uncommitted transactions on the SALES table.
Which statement is true about the DELETE statement?
A. It would not remove the rows if the table has a primary key.
B. It removes all the rows as well as the structure of the table.
C. It removes all the rows in the table and deleted rows can be rolled back.
D. It removes all the rows in the table and deleted rows cannot be rolled back.
Correct Answer: C

二、题目翻译
评估下面的DELETE语句:
在SALES表上没有其它未提交的事务。
关于DELETE语句哪句话是正确的？
A.如果表中有主键则不能移除行。
B.移除表中所有行及表结构。
C.移除表中所有行，并且删除的行可以回滚。
D.移除表中所有行，并且删除的行不可以回滚。

三、题目解析
DELETE FROM sales; 语句，
1.没有where子句，所以是删除表中所有的行数据。
2.delete是DML语句，在执行的时候，会记录undo信息，而且这里没有commit，所以可以用rollback回滚。
QUESTION 168
View the Exhibit and examine the description of SALES and PROMOTIONS tables.
You want to delete rows from the SALES table, where the PROMO_NAME column in the PROMOTIONS
table has either blowout sale or everyday low price as values.
Which DELETE statements are valid? (Choose all that apply.)
A. DELETE
FROM sales
WHERE promo_id = (SELECT promo_id
FROM promotions
WHERE promo_name = 'blowout sale')
AND promo_id = (SELECT promo_id
FROM promotions
WHERE promo_name = 'everyday low price');
B. DELETE
FROM sales
WHERE promo_id = (SELECT promo_id
FROM promotions
WHERE promo_name = 'blowout sale')
OR promo_id = (SELECT promo_id
FROM promotions
WHERE promo_name = 'everyday low price');
C. DELETE
FROM sales
WHERE promo_id IN (SELECT promo_id
FROM promotions
WHERE promo_name = 'blowout sale'
OR promo_name = 'everyday low price');
D. DELETE
FROM sales
WHERE promo_id IN (SELECT promo_id
FROM promotions
WHERE promo_name IN ('blowout sale','everyday low price'));
Answer: BCD
Correct Answer: BCD
二、题目翻译
看SALES和PROMOTIONS表的结构:
要从SALES表中删除行，条件为PROMOTIONS表中PROMO_NAM列的值为blowout sale或者everyday low price。
哪个DELETE语句有效?(选择所有正确的项)

三、题目解析
A选项不正确，题目要求的是PROMO_NAM列的值为blowout sale或者everyday low price，而A选项中，是用的AND,得出的结果就不是题目想要的结果。
BCD选项正确。

QUESTION 169
View the Exhibit and examine the description for the PRODUCTS and SALES table.
PROD_ID is a primary key in the PRODUCTS table and foreign key in the SALES table. You want to
remove all the rows from the PRODUCTS table for which no sale was done for the last three years.
Which is the valid DELETE statement?
A. DELETE
FROM products
WHERE prod_id = (SELECT prod_id
FROM sales
WHERE time_id - 3*365 = SYSDATE );
B. DELETE
FROM products
WHERE prod_id = (SELECT prod_id
FROM sales
WHERE SYSDATE >= time_id - 3*365 );
C. DELETE
FROM products
WHERE prod_id IN (SELECT prod_id
FROM sales
WHERE SYSDATE - 3*365 >= time_id);
D. DELETE
FROM products
WHERE prod_id IN (SELECT prod_id
FROM sales
WHERE time_id >= SYSDATE - 3*365 );
Correct Answer: C

二、题目翻译
看下面PRODUCTS and SALES表的结构:
PROD_ID是PRODUCTS表的主键，SALES表的外键.你想从PRODUCTS表移除所有过去三年没有销售过的产品行。
哪一个DELETE语句有效？

三、题目解析
子查询SELECT prod_id FROM sales WHERE SYSDATE - 3 * 365 >= time_id判断哪些产品是三年前的产品。
但是这样的判断也不够精确，比如，有可能有一年有366天,
而且这里PROD_ID是sales表的外键，如果直接这样删除，会报外键约束的错, 除非先禁用约束，或连SALES表中的数据一起删除。
不过，在这些选项中，只有C选项最接近，那就选C吧。
QUESTION 170
Which two statements are true regarding the DELETE and TRUNCATE commands? (Choose two.)
A. DELETE can be used to remove only rows from only one table at a time.
B. DELETE can be used to remove only rows from multiple tables at a time.
C. DELETE can be used only on a table that is a parent of a referential integrity constraint.
D. DELETE can be used to remove data from specific columns as well as complete rows.
E. DELETE and TRUNCATE can be used on a table that is a parent of a referential integrity constraint
having ON DELETE rule .
Correct Answer: AE
二、题目翻译
关于DELETE和TRUNCATE命令哪两个句子是正确的？(选择两个)
A.DELETE一次只能用于移除一个表的行。
B.DELETE一次只能用于移除多个表的行。
C.DELETE只能用于删除有引用完整性约束的父表。
D.DELETE可以用于删除指定列的数据以及完整的行。
E.DELETE和TRUNCATE可以用于有引用完整性约束ON DELETE规则的父表。

三、题目解析
表可以使用ON DELETE CASCADE选项（当删除父表数据时，子表数据也一起删除）或ON DELETE CASCAD SET NULL选项（当删除父表数据时，子表相关的列设置为NULL）,
有这些选项，就可以在父表中直接删除相关的行，而不会报外键约束错误。

QUESTION 171
Which three statements/commands would cause a transaction to end? (Choose three.)
A. COMMIT
B. SELECT
C. CREATE
D. ROLLBACK
E. SAVEPOINT
Correct Answer: ACD
二、题目翻译
下列哪三个语句/命令能导致一个事务结束？（选择三个）

三、题目解析
A选项正确，commit会提交事务，事务结束。
B选项不正确，select语句是DML语句，不影响事务。
C选项正确，create语句是DDL语句，DDL语句会自动提交事务，事务结束。
D选项正确，rollback回滚事务，事务结束。
E选项不正确，savepoint是保存某个点，然后在回滚的时候可以回滚到某个点，但它不影响事务。

QUESTION 172
The SQL statements executed in a user session are as follows:
SQL> CREATE TABLE product
(pcode NUMBER(2),
pname VARCHAR2(10));
SQL> INSERT INTO product VALUES (1, 'pen');
SQL> INSERT INTO product VALUES (2,'pencil');
SQL> SAVEPOINT a;
SQL> UPDATE product SET pcode = 10 WHERE pcode = 1;
SQL> SAVEPOINT b;
SQL> DELETE FROM product WHERE pcode = 2;
SQL> COMMIT;
SQL> DELETE FROM product WHERE pcode=10;
Which two statements describe the consequences of issuing the ROLLBACK TO SAVE POINT a
command in the session? (Choose two.)
A. The rollback generates an error.
B. No SQL statements are rolled back.
C. Only the DELETE statements are rolled back.
D. Only the second DELETE statement is rolled back.
E. Both the DELETE statements and the UPDATE statement are rolled back.
Correct Answer: AB
二、题目翻译
在一个user session执行如下的SQL语句:
哪两个句子可以描述执行ROLLBACK TO SAVE POINT a的影响:
A.rollback语句会报错。
B.没有SQL语句被回滚。
C.只有DELETE语句被回滚。
D.只有第二个DELETE语句被回滚。
E.两个DELETE语句和UPDATE语句被回滚。

三、题目解析
在倒数第二句，commit语句之后，前面的内容都提交了，事务就结束了.
savepoint a是这个结束事务的回滚点，这个事务结束以后，再执行ROLLBACK TO SAVE POINT a就会报错了，而且也不会回滚任何的数据。

QUESTION 173
When does a transaction complete? (Choose all that apply.)
A. when a DELETE statement is executed
B. when a ROLLBACK command is executed
C. when a PL/SQL anonymous block is executed
D. when a data definition language ( DDL) statement is executed
E. when a TRUNCATE statement is executed after the pending transaction
Correct Answer: BDE
二、题目翻译
什么时候会结束一个事务(选择所有正确的选项)?
A.当DELETE语句被执行后。
B.当ROLLBACK语句被执行后。
C.当一个PL/SQL匿名块被执行后。
D.当DLL语句被执行后。
E.在事务挂起之后执行TRUNCATE语句。

三、题目解析
A选项不正确，DELETE是DML语句，不会结束事务。
B选项正确，rollback会回滚事务，事务结束。
C选项不正确，PL/SQL匿名块，不影响事务。
D选项正确，DDL语句，会自动提交事务，事务结束。
E选项正确，TRUNCATE也是DDL语句，也会自动提交事务，所以事务结束。

QUESTION 174
Which statement is true regarding transactions? (Choose all that apply.)
A. A transaction can consist only of a set of DML and DDL statements.
B. A p art or an entire transaction can be undone by using ROLLBACK command .
C. A transaction consists of a set of DML or DCL statements.
D. A part or an entire transaction can be made permanent with a COMMIT
E. A transaction can consist of only a set of queries or DML or DDL statements.
Correct Answer: BC

二、题目翻译
下面关于事务的描述中，哪句是正确的？（选择所有正确的项）
A.一个事务只能由一组DML和DDL语句组成。
B.部分或整个事务可以使用ROLLBACK命令回滚。
C.一个事务由一组DML或DCL语句组成。
D.部分或整个事务可以使用COMMIT命令永久提交。
E.一个事务只能由一组查询或DML或DDL语句组成。

三、题目解析
A选项不正确，DDL语句就自动提交事务了，所以一组事务中不能包含DDL语句。
B选项正确，rollback可以回滚部分或整个事务。
C选项，在答案中，是选的正确，但是做过测试，是不正确的，DCL语句和DDL语句一样，会自动提交数据。
D选项不正确，commit会提交整个事务。
E选项不正确，DDL语句会自动提交事务，所以一个事务中不能包含DDL语句。

四、测试
在11g的联机文档中，DCL语句定义如下：
Data Control Language
     You can issue native data control language (DCL) statements from an Oracle environment, allowing central administration of user privileges and access levels for heterogeneous data stores.
根据描述可以知道，grant,revoke这些控制权限的语句，属于DCL语句，下面就使用grant语句来做实验。
SQL> create table t(id int);

Table created.

SQL> insert into t values(1);

1 row created.

SQL> grant select on t to hr;

Grant succeeded.

SQL> select * from t;

        ID
----------
         1

SQL> rollback;

Rollback complete.

SQL> select * from t;

        ID
----------
         1
实验证明：grant已经把事务自动提交了，所以，事务中是不能包含DCL语句的。
QUESTION 175
Which two statements are true regarding savepoints? (Choose two.)
A. Savepoints are effective only for COMMIT.
B. Savepoints may be used to ROLLBACK.
C. Savepoints can be used for only DML statements.
D. Savepoints are effective for both COMMIT and ROLLBACK.
E. Savepoints can be used for both DML and DDL statements.
Correct Answer: BC
二、题目翻译
关于savepoint的描述，下面哪两句话是正确的？(选择两个）
A.保存点只对COMMIT有效。
B.保存点可以用于ROLLBACK。
C.保存点只能用于DML语句。
D.保存点对于COMMIT和ROLLBACK都有效。
E.保存点可以用于DML和DDL语句。

三、题目解析
savepoint 表示保存某个点，可以rollback到这个点，也可以commit提交整个事务，但对于commit来说，这个savepoint没有任何意义。
所以A和D不正确，B正确。
DML语句会开始一个事务，在这事务中，可以使用savepoint保存点，但DDL不像DML那样，它不会开始一个事务，也不用提交事务，所以DDL不需要保存点。
所以，C正确，D不正确。

补充题库 第1题 TRUNCATE命令的使用
一、原题
Evaluate the SQL statement:
TRUNCATE TABLE DEPT;
Which three are true about the SQL statement? (Choose three.)
A. It releases the storage space used by the table.
B. It does not release the storage space used by the table.
C. You can roll back the deletion of rows after the statement executes.
D. You can NOT roll back the deletion of rows after the statement executes.
E. An attempt to use DESCRIBE on the DEPT table after the TRUNCATE statement executes will
display an error.
F. You must be the owner of the table or have DELETE ANY TABLE system privileges to truncate
the DEPT table

答案： A,D,F

二、题目翻译
评估下面的sql语句:
TRUNCATE TABLE DEPT;
关于上面的sql语句，哪三个描述是正确的?(选择三项)
A.会释放表使用的存储空间。
B.不会释放表使用的存储空间。
C.执行完成后，可以回滚删除的数据。
D.执行完成后，不能回滚删除的数据。
E.执行完成后，使用DESCRIBE DEPT命令显示表结构会报错。
F. 执行这个命令，需要是这张表的拥有者，或者有DELETE ANY TABLE权限。

三、题目解析
TRUNCATE命令，是删除表中所有的数据，并且释放表空间，因为在删除的过程中不会产生undo信息，所以，不能回滚。
执行这个命令，需要有相关的权限，是自己建的表，或是有DELETE ANY TABLE权限，才可以删。

一、原题
You need to design a student registration database that contains several tables storing academic
information.
The STUDENTS table stores information about a student. The STUDENT_GRADES table stores
information about the student's grades. Both of the tables have a column named STUDENT_ID.
The STUDENT_ID column in the STUDENTS table is a primary key.
You need to create a foreign key on the STUDENT_ID column of the STUDENT_GRADES table
that points to the STUDENT_ID column of the STUDENTS table. Which statement creates the
foreign key?
A.
CREATE TABLE student_grades (student_id NUMBER(12),
                             semester_end DATE, 
                             gpa NUMBER(4,3), 
                             CONSTRAINT student_id_fk REFERENCES (student_id) FOREIGN KEY students(student_id));
B.
CREATE TABLE student_grades(student_id NUMBER(12),
                            semester_end DATE, 
                            gpa NUMBER(4,3), 
                            student_id_fk FOREIGN KEY (student_id) REFERENCES students(student_id));
C.
 CREATE TABLE student_grades(student_id NUMBER(12),
                             semester_end DATE, 
                             gpa NUMBER(4,3), 
                             CONSTRAINT FOREIGN KEY (student_id) REFERENCES students(student_id));
D.
CREATE TABLE student_grades(student_id NUMBER(12),
                             semester_end DATE, 
                             gpa NUMBER(4,3),
                             CONSTRAINT student_id_fk FOREIGN KEY (student_id) REFERENCES students(student_id));


答案: D

二、题目翻译
要设计一个包含几个表的存储大学生注册信息的数据库。
STUDENTS表保存学生信息，STUDENT_GRADES表保存学生的成绩信息，这两张表都有一列STUDENT_ID,STUDENTS表中的STUDENT_ID列是主键。
现在要在STUDENT_GRADES表上建一个STUDENT_ID列的外键，下面哪个是建外键的语句?

三、题目解析
这个就是语法问题，查一下语法图，就可以了。

一、原题
Here is the structure and data of the CUST_TRANS table:

Exhibit:
Dates are stored in the default date format dd-mm-rr in the CUST_TRANS table.
Which three SQL statements would execute successfully? (Choose three.)
A. SELECT transdate + '10' FROM cust_trans;
B. SELECT * FROM cust_trans WHERE transdate = '01-01-07';
C. SELECT transamt FROM cust_trans WHERE custno > '11';
D. SELECT * FROM cust_trans WHERE transdate='01-JANUARY-07';
E. SELECT custno + 'A' FROM cust_trans WHERE transamt > 2000;

答案: A,C,D

二、题目翻译
下面是CUST_TRANS表的结构
日期被存成默认格式dd-mm-rr
下面哪几个SQL语句会执行成功?(选择三项)

三、题目解析
A选项正确，transdate列是DATE类型， + '10'，虽然是一个字符串，但它会自动转成数值类型，与DATE类型相加，所以正确。
B选项错误，transdate列是默认格式，使用transdate = '01-01-07'判断报错。
C选项正确，custno列是字符类型，字符类型比较大小，是按字母顺序，转成ASC码来比较。
D选项正确，transdate是默认的dd-mm-rr格式，可以和'01-JANUARY-07'匹配比较，所以也不需要将字符串转成日期格式。
E选项不正确，custno + 'A'，custno是字符串，两个字符串连接要使用 ||, 而不是+ 。
SQL> select case when  sysdate > '01-january-08' then 'greater' else 'others' end from dual;

CASEWHE
-------
greater

SQL> select case when  sysdate > '01-jan-08' then 'greater' else 'others' end from dual;

CASEWHE
-------
greater

SQL> select case when  sysdate > '01-jan-2008' then 'greater' else 'others' end from dual;

CASEWHE
-------
greater

SQL> select case when  sysdate > '01-january-2008' then 'greater' else 'others' end from dual;

CASEWHE
-------
greater

一、原题
See the Exhibit and examine the structure and data in the INVOICE table:
Exhibit:

Which two SQL statements would executes successfully? (Choose two.)
A. SELECT MAX(inv_date),MIN(cust_id) FROM invoice;
B. SELECT MAX(AVG(SYSDATE - inv_date)) FROM invoice;
C. SELECT AVG(inv_date) FROM invoice;
D. SELECT AVG(inv_date - SYSDATE),AVG(inv_amt) FROM invoice;

答案: A,D

二、题目翻译
看下面INVOICE表的结构：
哪两个SQL会执行成功（选择两项）?

三、题目解析
B选项不正确，SYSDATE - inv_date的结果是数字，这里AVG的结果就只有一条记录了，再求MAX，就没意义了，这句会报错。
C选面不正确，inv_date是日期类型，AVG求日期的平均值，会报错。

http://blog.csdn.net/holly2008/article/details/26983849