-- =====================================================================
-- AlagAlerta - 07 - Execução e evidências dos procedimentos
-- Rode depois de 01 a 06. Cada bloco mostra um cenário diferente.
-- =====================================================================
SET SERVEROUTPUT ON

-- Cenário 1: leitura normal (não gera alerta)
DECLARE
    v_risco   VARCHAR2(12);
    v_alerta  NUMBER;
BEGIN
    PRC_REGISTRAR_LEITURA('SNS-IPIR-01', 60, 3, v_risco, v_alerta);
    DBMS_OUTPUT.PUT_LINE('Cenário 1 | SNS-IPIR-01 60 cm, 3 mm/h -> risco ' || v_risco
                         || ' | alerta: ' || NVL(TO_CHAR(v_alerta), 'nenhum'));
END;
/

-- Cenário 2: chuva forte em região sem alerta ativo (cria alerta ATENCAO)
DECLARE
    v_risco   VARCHAR2(12);
    v_alerta  NUMBER;
BEGIN
    PRC_REGISTRAR_LEITURA('SNS-PNMU-01', 170, 35, v_risco, v_alerta);
    DBMS_OUTPUT.PUT_LINE('Cenário 2 | SNS-PNMU-01 170 cm, 35 mm/h -> risco ' || v_risco
                         || ' | alerta criado: ' || NVL(TO_CHAR(v_alerta), 'nenhum'));
END;
/

-- Cenário 3: Jardim Romano tinha ATENCAO; água passa do crítico (eleva para EMERGENCIA)
DECLARE
    v_risco   VARCHAR2(12);
    v_alerta  NUMBER;
BEGIN
    PRC_REGISTRAR_LEITURA('SNS-ROMA-01', 165, 58, v_risco, v_alerta);
    DBMS_OUTPUT.PUT_LINE('Cenário 3 | SNS-ROMA-01 165 cm, 58 mm/h -> risco ' || v_risco
                         || ' | alerta elevado: ' || NVL(TO_CHAR(v_alerta), 'nenhum'));
END;
/

-- Cenário 4: sensor em manutenção (erro de negócio tratado)
DECLARE
    v_risco   VARCHAR2(12);
    v_alerta  NUMBER;
BEGIN
    PRC_REGISTRAR_LEITURA('SNS-CUBA-01', 100, 10, v_risco, v_alerta);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Cenário 4 | recusado como esperado: ' || SQLERRM);
END;
/

-- Cenário 5: sensor inexistente
DECLARE
    v_risco   VARCHAR2(12);
    v_alerta  NUMBER;
BEGIN
    PRC_REGISTRAR_LEITURA('SNS-NAO-EXISTE', 10, 1, v_risco, v_alerta);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Cenário 5 | recusado como esperado: ' || SQLERRM);
END;
/

-- Evidência das operações
SELECT l.id_leitura, s.cd_sensor, l.nr_nivel_agua_cm, l.nr_chuva_mm_h, l.ds_nivel_risco,
       TO_CHAR(l.dt_leitura, 'DD/MM HH24:MI') AS quando
  FROM GS_LEITURA l JOIN GS_SENSOR s ON s.id_sensor = l.id_sensor
 WHERE l.dt_leitura >= SYSDATE - 2/1440
 ORDER BY l.id_leitura;

SELECT a.id_alerta, r.nm_regiao, a.ds_nivel, a.ds_origem, a.st_ativo, SUBSTR(a.ds_mensagem, 1, 70) AS mensagem
  FROM GS_ALERTA a JOIN GS_REGIAO r ON r.id_regiao = a.id_regiao
 WHERE a.st_ativo = 'S'
 ORDER BY a.id_alerta;

-- Ranking de prioridade (somente consulta)
DECLARE
    v_qt_p1  NUMBER;
BEGIN
    PRC_PRIORIZAR_REGIOES(p_top => 10, p_emitir_alertas => 'N', p_qt_p1 => v_qt_p1);
END;
/

-- Ranking com processamento: emite alerta para regiões P1 que ainda não tinham
DECLARE
    v_qt_p1  NUMBER;
BEGIN
    PRC_PRIORIZAR_REGIOES(p_top => 5, p_emitir_alertas => 'S', p_qt_p1 => v_qt_p1);
END;
/
