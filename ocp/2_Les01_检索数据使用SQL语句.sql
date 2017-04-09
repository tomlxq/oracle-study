--指定列
SQL> SELECT department_id, location_id FROM departments where rownum<5;

DEPARTMENT_ID LOCATION_ID
------------- -----------
           10        1700
           20        1800
           30        1700
           40        2400
--单引号转义符
SQL> SELECT department_name || q'[ Department's Manager Id: ]'
  2  || manager_id
  3  AS "Department and Manager"
  4  FROM departments;

Department and Manager
--------------------------------------------------------------------------------
Administration Department's Manager Id: 200
Marketing Department's Manager Id: 201
Purchasing Department's Manager Id: 114
Human Resources Department's Manager Id: 203
Shipping Department's Manager Id: 121
IT Department's Manager Id: 103
Public Relations Department's Manager Id: 204
Sales Department's Manager Id: 145
Executive Department's Manager Id: 100
Finance Department's Manager Id: 108
Accounting Department's Manager Id: 205

SELECT department_name || q'{ Department's Manager Id: }'
  2  || manager_id
  3  AS "Department and Manager"
  4  FROM departments;

Department and Manager
--------------------------------------------------------------------------------
Administration Department's Manager Id: 200
Marketing Department's Manager Id: 201
Purchasing Department's Manager Id: 114
Human Resources Department's Manager Id: 203
Shipping Department's Manager Id: 121
IT Department's Manager Id: 103
Public Relations Department's Manager Id: 204
Sales Department's Manager Id: 145
Executive Department's Manager Id: 100
Finance Department's Manager Id: 108
--显示表结构
SQL> describe employees;
 Name                                      Null?    Type
 ----------------------------------------- -------- ----------------------------
 EMPLOYEE_ID                               NOT NULL NUMBER(6)
 FIRST_NAME                                         VARCHAR2(20)
 LAST_NAME                                 NOT NULL VARCHAR2(25)
 EMAIL                                     NOT NULL VARCHAR2(25)
 PHONE_NUMBER                                       VARCHAR2(20)
 HIRE_DATE                                 NOT NULL DATE
 JOB_ID                                    NOT NULL VARCHAR2(10)
 SALARY                                             NUMBER(8,2)
 COMMISSION_PCT                                     NUMBER(2,2)
 MANAGER_ID                                         NUMBER(6)
 DEPARTMENT_ID                                      NUMBER(4)
--查看自己具备哪些表
 SQL> select * from tab;

TNAME                          TABTYPE  CLUSTERID
------------------------------ ------- ----------
COUNTRIES                      TABLE
DEPARTMENTS                    TABLE
EMP                            SYNONYM
EMPLOYEES                      TABLE
EMP_DETAILS_VIEW               VIEW
JOBS                           TABLE
JOB_HISTORY                    TABLE
LOCATIONS                      TABLE
REGIONS                        TABLE

9 rows selected.