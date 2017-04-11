Les19_报表高级分组函数
--rollup操作符可产生累积聚合，如分类汇总
按照n, n-1, n-2, … 0 进行分组滚动汇总
比如group by rollup(a,b,c)
则按照group by(a,b,c) group by(a,b) group by(a) group by(0) 分别分组汇总
rollup产生n+1种组合
SQL> SELECT department_id, job_id, SUM(salary)
  2  FROM employees
  3  WHERE department_id < 60
  4  GROUP BY ROLLUP(department_id, job_id);

DEPARTMENT_ID JOB_ID     SUM(SALARY)
------------- ---------- -----------
           10 AD_ASST           4400
           10                   4400
           20 MK_MAN           13000
           20 MK_REP            6000
           20                  19000
           30 PU_MAN           11000
           30 PU_CLERK         13900
           30                  24900
           40 HR_REP            6500
           40                   6500
           50 ST_MAN           36400

DEPARTMENT_ID JOB_ID     SUM(SALARY)
------------- ---------- -----------
           50 SH_CLERK         64300
           50 ST_CLERK         55700
           50                 156400
                              211200

15 rows selected.
--用cube操作符产生简单交叉报表汇总
按照交叉列进行分组立方汇总比如group by cube(a,b,c)
则按照
group by(a,b,c) 
group by(a,b) 
group by(a,c) 
group by(b,c) 
group by (a) 
group by (b) 
group by (c) 
group by (0) 
分别分组汇总
cube产生2的n次方结果
--group by(department_id, job_id) group by(department_id) group by(job_id) group by(0)
SQL> SELECT department_id, job_id, SUM(salary) 
  2  FROM employees
  3  WHERE department_id < 60
  4  GROUP BY CUBE (department_id, job_id) ;

DEPARTMENT_ID JOB_ID     SUM(SALARY)
------------- ---------- -----------
                              211200
              HR_REP            6500
              MK_MAN           13000
              MK_REP            6000
              PU_MAN           11000
              ST_MAN           36400
              AD_ASST           4400
              PU_CLERK         13900
              SH_CLERK         64300
              ST_CLERK         55700
           10                   4400

DEPARTMENT_ID JOB_ID     SUM(SALARY)
------------- ---------- -----------
           10 AD_ASST           4400
           20                  19000
           20 MK_MAN           13000
           20 MK_REP            6000
           30                  24900
           30 PU_MAN           11000
           30 PU_CLERK         13900
           40                   6500
           40 HR_REP            6500
           50                 156400
           50 ST_MAN           36400

DEPARTMENT_ID JOB_ID     SUM(SALARY)
------------- ---------- -----------
           50 SH_CLERK         64300
           50 ST_CLERK         55700

24 rows selected.

grouping函数
	能用于cube或rollup操作符
	能辨别一条记录是否由小计组成
	能区别是库中存储的null还是rollup或cube产生的null
	返回0或1
SQL> SELECT department_id DEPTID, job_id JOB,
  2  SUM(salary),
  3  GROUPING(department_id) GRP_DEPT,
  4  GROUPING(job_id) GRP_JOB
  5  FROM employees
  6  WHERE department_id < 50
  7  GROUP BY ROLLUP(department_id, job_id);

    DEPTID JOB        SUM(SALARY)   GRP_DEPT    GRP_JOB
---------- ---------- ----------- ---------- ----------
        10 AD_ASST           4400          0          0
        10                   4400          0          1
        20 MK_MAN           13000          0          0
        20 MK_REP            6000          0          0
        20                  19000          0          1
        30 PU_MAN           11000          0          0
        30 PU_CLERK         13900          0          0
        30                  24900          0          1
        40 HR_REP            6500          0          0
        40                   6500          0          1
                            54800          1          1

11 rows selected.
--grouping sets
SQL> conn hr/oracle
Connected.
SQL> SELECT department_id, job_id,
  2  manager_id,AVG(salary)
  3  FROM employees
  4  GROUP BY GROUPING SETS ((department_id,job_id), (job_id,manager_id));

DEPARTMENT_ID JOB_ID     MANAGER_ID AVG(SALARY)
------------- ---------- ---------- -----------
              AC_MGR            101       12008
              SH_CLERK          122        3200
              SH_CLERK          124        2825
              MK_MAN            100       13000
              ST_MAN            100        7280
              ST_CLERK          121        2675
              SA_REP            148        8650
              SH_CLERK          120        2900
              AD_ASST           101        4400
              AD_PRES                     24000
              FI_MGR            101       12008

DEPARTMENT_ID JOB_ID     MANAGER_ID AVG(SALARY)
------------- ---------- ---------- -----------
              SA_REP            146        8500
              SH_CLERK          123        3475
              IT_PROG           102        9000
              IT_PROG           103        4950
              FI_ACCOUNT        108        7920
              PU_MAN            100       11000
              AC_ACCOUNT        205        8300
              ST_CLERK          122        2700
              SA_REP            145        8500
              HR_REP            101        6500
              PR_REP            101       10000

DEPARTMENT_ID JOB_ID     MANAGER_ID AVG(SALARY)
------------- ---------- ---------- -----------
              AD_VP             100       17000
              ST_CLERK          120        2625
              ST_CLERK          124        2925
              SA_REP            147  7766.66667
              SA_REP            149  8333.33333
              ST_CLERK          123        3000
              SH_CLERK          121        3675
              MK_REP            201        6000
              PU_CLERK          114        2780
              SA_MAN            100       12200
          110 AC_ACCOUNT                   8300

DEPARTMENT_ID JOB_ID     MANAGER_ID AVG(SALARY)
------------- ---------- ---------- -----------
           90 AD_VP                       17000
           50 ST_CLERK                     2785
           80 SA_REP                 8396.55172
          110 AC_MGR                      12008
           50 ST_MAN                       7280
           80 SA_MAN                      12200
           50 SH_CLERK                     3215
           20 MK_MAN                      13000
           90 AD_PRES                     24000
           60 IT_PROG                      5760
          100 FI_MGR                      12008

DEPARTMENT_ID JOB_ID     MANAGER_ID AVG(SALARY)
------------- ---------- ---------- -----------
           30 PU_CLERK                     2780
          100 FI_ACCOUNT                   7920
           70 PR_REP                      10000
              SA_REP                       7000
           10 AD_ASST                      4400
           20 MK_REP                       6000
           40 HR_REP                       6500
           30 PU_MAN                      11000

52 rows selected.
--复合列
SQL> SELECT department_id, job_id, manager_id,
  2  SUM(salary)
  3  FROM employees GROUP BY ROLLUP( department_id,(job_id, manager_id));

DEPARTMENT_ID JOB_ID     MANAGER_ID SUM(SALARY)
------------- ---------- ---------- -----------
              SA_REP            149        7000
                                           7000
           10 AD_ASST           101        4400
           10                              4400
           20 MK_MAN            100       13000
           20 MK_REP            201        6000
           20                             19000
           30 PU_MAN            100       11000
           30 PU_CLERK          114       13900
           30                             24900
           40 HR_REP            101        6500

DEPARTMENT_ID JOB_ID     MANAGER_ID SUM(SALARY)
------------- ---------- ---------- -----------
           40                              6500
           50 ST_MAN            100       36400
           50 SH_CLERK          120       11600
           50 SH_CLERK          121       14700
           50 SH_CLERK          122       12800
           50 SH_CLERK          123       13900
           50 SH_CLERK          124       11300
           50 ST_CLERK          120       10500
           50 ST_CLERK          121       10700
           50 ST_CLERK          122       10800
           50 ST_CLERK          123       12000

DEPARTMENT_ID JOB_ID     MANAGER_ID SUM(SALARY)
------------- ---------- ---------- -----------
           50 ST_CLERK          124       11700
           50                            156400
           60 IT_PROG           102        9000
           60 IT_PROG           103       19800
           60                             28800
           70 PR_REP            101       10000
           70                             10000
           80 SA_MAN            100       61000
           80 SA_REP            145       51000
           80 SA_REP            146       51000
           80 SA_REP            147       46600

DEPARTMENT_ID JOB_ID     MANAGER_ID SUM(SALARY)
------------- ---------- ---------- -----------
           80 SA_REP            148       51900
           80 SA_REP            149       43000
           80                            304500
           90 AD_VP             100       34000
           90 AD_PRES                     24000
           90                             58000
          100 FI_MGR            101       12008
          100 FI_ACCOUNT        108       39600
          100                             51608
          110 AC_MGR            101       12008
          110 AC_ACCOUNT        205        8300

DEPARTMENT_ID JOB_ID     MANAGER_ID SUM(SALARY)
------------- ---------- ---------- -----------
          110                             20308
                                         691416

46 rows selected.
--连接分组
SQL> SELECT department_id, job_id, manager_id,
  2  SUM(salary)
  3  FROM employees GROUP BY department_id,
  4  ROLLUP(job_id),
  5  CUBE(manager_id);

DEPARTMENT_ID JOB_ID     MANAGER_ID SUM(SALARY)
------------- ---------- ---------- -----------
              SA_REP            149        7000
           10 AD_ASST           101        4400
           20 MK_MAN            100       13000
           20 MK_REP            201        6000
           30 PU_MAN            100       11000
           30 PU_CLERK          114       13900
           40 HR_REP            101        6500
           50 ST_MAN            100       36400
           50 SH_CLERK          120       11600
           50 SH_CLERK          121       14700
           50 SH_CLERK          122       12800

DEPARTMENT_ID JOB_ID     MANAGER_ID SUM(SALARY)
------------- ---------- ---------- -----------
           50 SH_CLERK          123       13900
           50 SH_CLERK          124       11300
           50 ST_CLERK          120       10500
           50 ST_CLERK          121       10700
           50 ST_CLERK          122       10800
           50 ST_CLERK          123       12000
           50 ST_CLERK          124       11700
           60 IT_PROG           102        9000
           60 IT_PROG           103       19800
           70 PR_REP            101       10000
           80 SA_MAN            100       61000

DEPARTMENT_ID JOB_ID     MANAGER_ID SUM(SALARY)
------------- ---------- ---------- -----------
           80 SA_REP            145       51000
           80 SA_REP            146       51000
           80 SA_REP            147       46600
           80 SA_REP            148       51900
           80 SA_REP            149       43000
           90 AD_VP             100       34000
           90 AD_PRES                     24000
          100 FI_MGR            101       12008
          100 FI_ACCOUNT        108       39600
          110 AC_MGR            101       12008
          110 AC_ACCOUNT        205        8300

DEPARTMENT_ID JOB_ID     MANAGER_ID SUM(SALARY)
------------- ---------- ---------- -----------
              SA_REP                       7000
           10 AD_ASST                      4400
           20 MK_MAN                      13000
           20 MK_REP                       6000
           30 PU_MAN                      11000
           30 PU_CLERK                    13900
           40 HR_REP                       6500
           50 ST_MAN                      36400
           50 SH_CLERK                    64300
           50 ST_CLERK                    55700
           60 IT_PROG                     28800

DEPARTMENT_ID JOB_ID     MANAGER_ID SUM(SALARY)
------------- ---------- ---------- -----------
           70 PR_REP                      10000
           80 SA_MAN                      61000
           80 SA_REP                     243500
           90 AD_VP                       34000
           90 AD_PRES                     24000
          100 FI_MGR                      12008
          100 FI_ACCOUNT                  39600
          110 AC_MGR                      12008
          110 AC_ACCOUNT                   8300
                                149        7000
                                           7000

DEPARTMENT_ID JOB_ID     MANAGER_ID SUM(SALARY)
------------- ---------- ---------- -----------
           10                   101        4400
           10                              4400
           20                   100       13000
           20                   201        6000
           20                             19000
           30                   100       11000
           30                   114       13900
           30                             24900
           40                   101        6500
           40                              6500
           50                   100       36400

DEPARTMENT_ID JOB_ID     MANAGER_ID SUM(SALARY)
------------- ---------- ---------- -----------
           50                   120       22100
           50                   121       25400
           50                   122       23600
           50                   123       25900
           50                   124       23000
           50                            156400
           60                   102        9000
           60                   103       19800
           60                             28800
           70                   101       10000
           70                             10000

DEPARTMENT_ID JOB_ID     MANAGER_ID SUM(SALARY)
------------- ---------- ---------- -----------
           80                   100       61000
           80                   145       51000
           80                   146       51000
           80                   147       46600
           80                   148       51900
           80                   149       43000
           80                            304500
           90                             24000
           90                   100       34000
           90                             58000
          100                   101       12008

DEPARTMENT_ID JOB_ID     MANAGER_ID SUM(SALARY)
------------- ---------- ---------- -----------
          100                   108       39600
          100                             51608
          110                   101       12008
          110                   205        8300
          110                             20308

93 rows selected.