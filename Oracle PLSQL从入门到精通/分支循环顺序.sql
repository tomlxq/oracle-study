--ѭ���е���תexit/continue
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

--for loopѭ��
DECLARE
  v_count NUMBER := 5;
  v_total NUMBER := 0;
BEGIN
  FOR i IN 1 .. v_count LOOP
    dbms_output.put_line('��ǰ������ ' || i);
    v_total := v_total + i;
  END LOOP;
  dbms_output.put_line(CHR(10) || '��ǰ�ۼ����� ' || v_total || CHR(10));
  FOR i IN REVERSE 1 .. v_count LOOP
    dbms_output.put_line('��ǰ�������� ' || i);
  END LOOP;
END;
/
/*
END CASE; ��һ��Ҫ�ӷֺ�
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
      dbms_output.put_line('��������ʦ');
    WHEN v_sal BETWEEN 5000 AND 10000 THEN
      dbms_output.put_line('�м�����ʦ');
    WHEN v_sal BETWEEN 10000 AND 50000 THEN
      dbms_output.put_line('�߼�����ʦ');
    ELSE
      dbms_output.put_line('δ֪����');
  END CASE;
END;

--while loop
DECLARE
  v_count NUMBER := 0;
BEGIN
  WHILE v_count < 5 LOOP
    dbms_output.put_line('whileѭ��,��ǰ����ֵΪ' || +v_count);
    v_count := v_count + 1;
  END LOOP;
END;
/

--GO to label
/*
ROUND(SQRT(n)) ƽ����ȡ��
n MOD i = 0��ʾ�ܹ�����,�ǲ�������
*/
DECLARE
  p VARCHAR2(30);
  n PLS_INTEGER := 37;
BEGIN
  dbms_output.put_line(ROUND(SQRT(n)));
  FOR i IN 2 .. ROUND(SQRT(n)) LOOP
    IF n MOD i = 0 THEN
      p := '��������';
      GOTO print_now;
    END IF;
    p := '������';
  END LOOP;
  <<print_now>>
  dbms_output.put_line(to_CHAR(n) || p);
END;
/
--���ñ�ǩ����ѭ��
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

