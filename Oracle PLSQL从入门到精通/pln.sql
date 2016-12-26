--set serveroutput off;
select xplan.*
from (select max(sql_id) keep 
	(dense_rank last order by last_active_time) sql_id,
	max(child_number) keep 
	(dense_rank last order by last_active_time) child_number
	FROM V$SQL 
	WHERE UPPER(SQL_TEXT) LIKE '%&1%'
	and upper(sql_text) not like '%FROM V$SQL WHERE UPPER(SQL_TEXT) LIKE %'
) sqlinfo,
table(dbms_xplan.display_cursor(sqlinfo.sql_id, sqlinfo.child_number, 'ALLSTATS LAST')) xplan;