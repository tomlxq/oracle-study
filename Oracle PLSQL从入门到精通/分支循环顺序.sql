--循环中的跳转exit/continue
DECLARE
  v_no NUMBER := 1;
BEGIN
  LOOP
    v_no := v_no + 1;
    CONTINUE WHEN v_no <= 5;
    EXIT WHEN v_no >= 10;
    dbms_output.put_line('5<x<10 ' || v_no);
  END LOOP;
END;
/

--for loop循环
DECLARE
  v_count NUMBER := 5;
  v_total NUMBER := 0;
BEGIN
  FOR i IN 1 .. v_count LOOP
    dbms_output.put_line('当前计数到 ' || i);
    v_total := v_total + i;
  END LOOP;
  dbms_output.put_line(CHR(10) || '当前累加数到 ' || v_total || CHR(10));
  FOR i IN REVERSE 1 .. v_count LOOP
    dbms_output.put_line('当前反计数到 ' || i);
  END LOOP;
END;
/
/*
END CASE; 后一定要加分号
*/
--case
SELECT DISTINCT sal,empno  FROM scott.emp 
DECLARE
  v_empNo NUMBER := &empNo;
  v_sal   NUMBER := 0;
BEGIN
  SELECT e.sal INTO v_sal FROM scott.emp e WHERE e.empno = v_empNo;
  CASE
    WHEN v_sal BETWEEN 0 AND 5000 THEN
      dbms_output.put_line('初级工程师');
    WHEN v_sal BETWEEN 5000 AND 10000 THEN
      dbms_output.put_line('中级工程师');
    WHEN v_sal BETWEEN 10000 AND 50000 THEN
      dbms_output.put_line('高级工程师');
    ELSE
      dbms_output.put_line('未知级别');
  END CASE;
END;

--while loop
DECLARE
  v_count NUMBER := 0;
BEGIN
  WHILE v_count < 5 LOOP
    dbms_output.put_line('while循环,当前计数值为' || +v_count);
    v_count := v_count + 1;
  END LOOP;
END;
/

--GO to label
/*
ROUND(SQRT(n)) 平方后取整
n MOD i = 0表示能够整除,是不是素数
*/
DECLARE
  p VARCHAR2(30);
  n PLS_INTEGER := 37;
BEGIN
  dbms_output.put_line(ROUND(SQRT(n)));
  FOR i IN 2 .. ROUND(SQRT(n)) LOOP
    IF n MOD i = 0 THEN
      p := '不是素数';
      GOTO print_now;
    END IF;
    p := '是素数';
  END LOOP;
  <<print_now>>
  dbms_output.put_line(to_CHAR(n) || p);
END;
/
--利用标签进行循环
DECLARE
  v_count NUMBER := 0;
BEGIN
  <<outer_p>>
  dbms_output.put_line(v_count);
  v_count := v_count + 1;
  IF v_count < 5 THEN
    GOTO outer_p;
  END IF;
END;
/

