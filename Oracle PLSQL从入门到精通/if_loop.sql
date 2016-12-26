--exit/continue
DECLARE
  v_no NUMBER := 1;
BEGIN
  LOOP
    v_no := v_no + 1;
    CONTINUE WHEN v_no <= 5;
    EXIT WHEN v_no >= 10;
    dbms_output.put_line('5<x<10 ' || v_no);
  
    --dbms_output.put_line(v_no);
  END LOOP;

END;
/
