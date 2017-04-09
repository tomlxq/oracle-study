Data Dictionary Structure
	user
		用户自己的视图，是自己的对象
		DICTIONARY
		USER_OBJECTS
		USER_TABLES
		USER_TAB_COLUMNS
		USER_CONSTRAINTS
		USER_CONS_COLUMNS
		USER_VIEWS
		USER_SEQUENCES
		USER_INDEXES
		user_ind_columns
		USER_SYNONYMS
	all
		所有你权限访问的视图
	dba
		dba视图，能访问所有的视图
	v$
		性能相关的数据
		
表与列注释		
	SQL> COMMENT ON TABLE employees IS 'Employee Information';
	SQL> comment on column employees.first_name is 'the first name of the employee';
views: 注释信息查看
	ALL_COL_COMMENTS
	USER_COL_COMMENTS
	ALL_TAB_COMMENTS
	USER_TAB_COMMENTS
	

	
SQL> col OBJECT_NAME for a30
SQL> SELECT *
  2  FROM dictionary
  3  WHERE table_name = 'USER_OBJECTS';

TABLE_NAME                     COMMENTS
------------------------------ --------------------------------------------------
USER_OBJECTS                   Objects owned by the user

SQL> SELECT object_name, object_type, created, status
  2  FROM user_objects
  3  ORDER BY object_type;

OBJECT_NAME                    OBJECT_TYPE         CREATED            STATUS
------------------------------ ------------------- ------------------ -------
REG_ID_PK                      INDEX               28-MAR-17          VALID
LOC_CITY_IX                    INDEX               28-MAR-17          VALID
LOC_ID_PK                      INDEX               28-MAR-17          VALID
LOC_COUNTRY_IX                 INDEX               28-MAR-17          VALID
EMP_JOB_IX                     INDEX               28-MAR-17          VALID
JHIST_EMPLOYEE_IX              INDEX               28-MAR-17          VALID
JHIST_JOB_IX                   INDEX               28-MAR-17          VALID
DEPT2_ID_PK                    INDEX               09-APR-17          VALID
EMP_ID_IDX                     INDEX               09-APR-17          VALID
JHIST_DEPARTMENT_IX            INDEX               28-MAR-17          VALID
JHIST_EMP_ID_ST_DATE_PK        INDEX               28-MAR-17          VALID


