/*
索引组织表(IOT)不仅可以存储数据，还可以存储为表建立的索引。索引组织表的数据是根据主键排序后的顺序进行排列的，这样就提高了访问的速度。
但是这是由牺牲插入和更新性能为代价的(每次写入和更新后都要重新进行重新排序)。
注意两点：
􀁺 创建IOT 时，必须要设定主键，否则报错。
􀁺 索引组织表实际上将所有数据都放入了索引中。
*/
create table t_index(
id number,
name varchar2(30),
constraint pk_t_index_id primary key(id)
) organization index;
