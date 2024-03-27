VAR BRUT NUMBER;
VAR PESOS_NORMALES NUMBER;
VAR PESOS_E1 NUMBER;
VAR PESOS_E2 NUMBER;
VAR PESOS_E3 NUMBER;
VAR BANNO NUMBER;

EXEC :BRUT:=20393064;
EXEC :PESOS_NORMALES:= 1200;
EXEC :PESOS_E1:=100;
EXEC :PESOS_E2:=300;
EXEC :PESOS_E3:=550;
EXEC :BANNO:=2023;

DECLARE
V_NRO_CLIENTE CLIENTE.NRO_CLIENTE%TYPE;
V_RUT VARCHAR2(15);
V_NOMBRE VARCHAR2(50);
V_TIPO_CLIENTE VARCHAR2(50);
V_MONTO_CREDITO NUMBER(10);
V_PESOS NUMBER(10);

BEGIN

SELECT C.NRO_CLIENTE AS "NRO CLIENTE",C.NUMRUN ||'-'||C.DVRUN AS "RUT",C.PNOMBRE||' '||C.APPATERNO||' '||C.APMATERNO AS "NOMBRE CLIENTE",TC.NOMBRE_TIPO_CLIENTE AS "TIPO DE CLIENTE",SUM(CC.MONTO_SOLICITADO) AS "MONTO SOLICITADO"
INTO V_NRO_CLIENTE,V_RUT,V_NOMBRE,V_TIPO_CLIENTE,V_MONTO_CREDITO
FROM CLIENTE C
JOIN TIPO_CLIENTE TC ON (C.COD_TIPO_CLIENTE = TC.COD_TIPO_CLIENTE)
JOIN CREDITO_CLIENTE CC ON (CC.NRO_CLIENTE = C.NRO_CLIENTE)
WHERE C.NUMRUN = :BRUT AND TO_NUMBER(EXTRACT(YEAR FROM CC.FECHA_OTORGA_CRED)) = :BANNO 
GROUP BY C.NRO_CLIENTE,C.NUMRUN ||'-'||C.DVRUN,C.PNOMBRE||' '||C.APPATERNO||' '||C.APMATERNO,TC.NOMBRE_TIPO_CLIENTE;
    IF V_MONTO_CREDITO < 1000000 THEN V_PESOS:= (V_MONTO_CREDITO/100000)*:PESOS_E1;
    ELSIF V_MONTO_CREDITO > 1000001 AND V_MONTO_CREDITO < 3000000 THEN V_PESOS:= (V_MONTO_CREDITO/100000)*:PESOS_E2;
    ELSIF V_MONTO_CREDITO > 3000000 THEN V_PESOS:= (V_MONTO_CREDITO/100000)*:PESOS_E3;
    END IF;

DBMS_OUTPUT.PUT_LINE('NRO CLIENTE: '||V_NRO_CLIENTE);    
DBMS_OUTPUT.PUT_LINE('CLIENTE: '||V_NOMBRE);
DBMS_OUTPUT.PUT_LINE('TOTAL CREDITO SOLICITADO:'||V_MONTO_CREDITO);
DBMS_OUTPUT.PUT_LINE('PUNTOS: '|| V_PESOS);

EXCEPTION

WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20001, 'No hay datos para mostrar');

END;
