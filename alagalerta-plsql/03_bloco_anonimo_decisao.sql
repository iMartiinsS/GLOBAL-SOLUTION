-- =====================================================================
-- AlagAlerta - 03 - Bloco anônimo + decisão IF/ELSIF/ELSE
--
-- Requisitos atendidos:
--   * Bloco anônimo com variáveis, SELECT INTO e saída DBMS_OUTPUT
--   * Decisão IF/ELSIF/ELSE aplicada a uma regra de negócio
--
-- Regra de negócio (recomendação de ação para a Defesa Civil em uma região):
--   - EVACUAR      : algum sensor atingiu o nível crítico OU há pessoa em risco
--                    (ocorrência aberta com água >= 60 cm)
--   - PREPARAR     : algum sensor passou do nível de alerta OU há >= 2 ocorrências abertas
--   - MONITORAR    : algum sensor passou de 70% do nível de alerta OU chuva >= 30 mm/h
--   - SITUAÇÃO NORMAL nos demais casos
-- O percentual usado é o da leitura mais recente de cada sensor em relação aos limites dele,
-- porque cada córrego transborda em uma altura diferente.
-- =====================================================================
SET SERVEROUTPUT ON

DECLARE
    -- troque a região para testar os outros ramos da decisão:
    -- 'Jardim Pantanal' ou 'Jardim Helena' (evacuar), 'Lapa de Baixo' (preparar),
    -- 'Jardim Romano' (monitorar), 'Ipiranga' (normal)
    v_nm_regiao            GS_REGIAO.nm_regiao%TYPE := 'Jardim Pantanal';

    v_id_regiao            GS_REGIAO.id_regiao%TYPE;
    v_cidade               GS_REGIAO.nm_cidade%TYPE;
    v_populacao            GS_REGIAO.qt_populacao_risco%TYPE;
    v_qt_sensores          NUMBER;
    v_pct_alerta_max       NUMBER;   -- maior % do nível de alerta entre os sensores
    v_pct_critico_max      NUMBER;   -- maior % do nível crítico entre os sensores
    v_chuva_max            NUMBER;
    v_ocorr_abertas        NUMBER;
    v_pessoas_em_risco     NUMBER;
    v_recomendacao         VARCHAR2(30);
    v_justificativa        VARCHAR2(200);
BEGIN
    -- SELECT INTO 1: dados da região
    SELECT id_regiao, nm_cidade, qt_populacao_risco
      INTO v_id_regiao, v_cidade, v_populacao
      FROM GS_REGIAO
     WHERE nm_regiao = v_nm_regiao;

    -- SELECT INTO 2: situação dos sensores, usando apenas a leitura mais recente de cada um
    SELECT COUNT(*),
           NVL(MAX(ult.nr_nivel_agua_cm / s.nr_nivel_alerta_cm * 100), 0),
           NVL(MAX(ult.nr_nivel_agua_cm / s.nr_nivel_critico_cm * 100), 0),
           NVL(MAX(ult.nr_chuva_mm_h), 0)
      INTO v_qt_sensores, v_pct_alerta_max, v_pct_critico_max, v_chuva_max
      FROM GS_SENSOR s
      JOIN GS_LEITURA ult ON ult.id_sensor = s.id_sensor
     WHERE s.id_regiao = v_id_regiao
       AND s.st_sensor = 'ATIVO'
       AND ult.dt_leitura = (SELECT MAX(l2.dt_leitura) FROM GS_LEITURA l2 WHERE l2.id_sensor = s.id_sensor);

    -- SELECT INTO 3: relatos dos moradores ainda não resolvidos
    SELECT COUNT(*),
           NVL(SUM(CASE WHEN nr_altura_agua_cm >= 60 THEN 1 ELSE 0 END), 0)
      INTO v_ocorr_abertas, v_pessoas_em_risco
      FROM GS_OCORRENCIA
     WHERE id_regiao = v_id_regiao
       AND st_ocorrencia IN ('ABERTA', 'EM_ATENDIMENTO');

    -- Decisão
    IF v_pct_critico_max >= 100 OR v_pessoas_em_risco > 0 THEN
        v_recomendacao  := 'EVACUAR';
        v_justificativa := 'nível crítico atingido ou relato de água acima de 60 cm';
    ELSIF v_pct_alerta_max >= 100 OR v_ocorr_abertas >= 2 THEN
        v_recomendacao  := 'PREPARAR EVACUAÇÃO';
        v_justificativa := 'nível de alerta ultrapassado ou vários relatos de alagamento';
    ELSIF v_pct_alerta_max >= 70 OR v_chuva_max >= 30 THEN
        v_recomendacao  := 'MONITORAR';
        v_justificativa := 'nível acima de 70% do alerta ou chuva forte';
    ELSE
        v_recomendacao  := 'SITUAÇÃO NORMAL';
        v_justificativa := 'nenhum indicador de risco relevante';
    END IF;

    DBMS_OUTPUT.PUT_LINE('==================================================');
    DBMS_OUTPUT.PUT_LINE(' ANÁLISE DE RISCO - ' || UPPER(v_nm_regiao) || ' (' || v_cidade || ')');
    DBMS_OUTPUT.PUT_LINE('==================================================');
    DBMS_OUTPUT.PUT_LINE('Moradores em área de risco : ' || TO_CHAR(v_populacao, 'FM999G999G999'));
    DBMS_OUTPUT.PUT_LINE('Sensores ativos com leitura: ' || v_qt_sensores);
    DBMS_OUTPUT.PUT_LINE('Maior % do nível de alerta : ' || ROUND(v_pct_alerta_max, 1) || '%');
    DBMS_OUTPUT.PUT_LINE('Maior % do nível crítico   : ' || ROUND(v_pct_critico_max, 1) || '%');
    DBMS_OUTPUT.PUT_LINE('Maior chuva registrada     : ' || v_chuva_max || ' mm/h');
    DBMS_OUTPUT.PUT_LINE('Ocorrências em aberto      : ' || v_ocorr_abertas || ' (com água >= 60 cm: ' || v_pessoas_em_risco || ')');
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('RECOMENDAÇÃO: ' || v_recomendacao);
    DBMS_OUTPUT.PUT_LINE('Motivo      : ' || v_justificativa);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Região "' || v_nm_regiao || '" não cadastrada.');
END;
/
