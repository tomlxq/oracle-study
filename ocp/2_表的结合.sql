UNION(并集)——返回两个集合去掉重复值的所有的记录。
UNION ALL (并集)——返回两个集合去掉重复值的所有的记录 。
INTERSECT (交集)——返回两个集合的所有记录，重复的只取一次。
MINUS (差集)——返回属于第一个集合，但不属于第二个集合的所有记录。

集合运算中各个集合必须有相同的列数，且类型一致，集合运算的结果将采用第一个集合的表头作为最终的表头，order by必须放在每个集合后
