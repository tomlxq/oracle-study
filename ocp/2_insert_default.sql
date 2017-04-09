SQL> create table tt(id int default 2 ,name char(5));

Table created.

SQL> insert into tt values(default,'a');

1 row created.

SQL> commit;

Commit complete.

SQL> select * from tt;

        ID NAME
---------- -----
         2 a