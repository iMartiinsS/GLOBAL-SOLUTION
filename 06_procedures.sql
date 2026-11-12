-- =====================================================================
-- AlagAlerta - 06 - Procedimentos armazenados
--
-- Requisito: 2 procedimentos armazenados, um de OPERAÇÃO e outro de CONSULTA/PROCESSAMENTO.
--
--   PRC_REGISTRAR_LEITURA   (operação)   recebe a medição do sensor IoT, classifica o risco,
--                                        grava a leitura e cria/eleva o alerta da região.
--   PRC_PRIORIZAR_REGIOES   (consulta/   calcula um índice de prioridade por região e apresenta
--                            processamento) o ranking de atendimento da Defesa Civil.
-- =====================================================================
SET SERVEROUTPUT ON

-- ---------------------------------------------------------------------
-- 1) OPERAÇÃO: registrar leitura do sensor
-- Mesma regra de classificação usada pelas APIs Java/.NET:
--   EMERGENCIA: água >= nível crítico do sensor
--   ALERTA    : água >= nível de alerta, ou água >= 70% do alerta com chuva >= 50 mm/h
--   ATENCAO   : água >= 70% do alerta, ou chuva >= 30 mm/h
--   NORMAL    : demais casos
-- Se o risco não for NORMAL: cria alerta na região, ou eleva o alerta ativo se o novo nível
-- for mais grave (nunca rebaixa automaticamente — quem encerra é a Defesa Civil).
-- ---------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE PRC_REGISTRAR_LEITURA (
    p_cd_sensor    IN  GS_SENSOR.cd_sensor%TYPE,
    p_nivel_cm     IN  NUMBER,
    p_chuva_mm_h   IN  NUMBER,
    p_nivel_risco  OUT VARCHAR2,
    p_id_alerta    OUT NUMBER
) IS
    v_sensor            GS_SENSOR%ROWTYPE;
    v_id_alerta_ativo   GS_ALERTA.id_alerta%TYPE;
    v_nivel_ativo       GS_ALERTA.ds_nivel%TYPE;
    v_mensagem          GS_ALERTA.ds_mensagem%TYPE;

    FUNCTION peso (p_nivel IN VARCHAR2) RETURN NUMBER IS
    BEGIN
        RETURN CASE p_nivel
                   WHEN 'NORMAL'     THEN 0
                   WHEN 'ATENCAO'    THEN 1
                   WHEN 'ALERTA'     THEN 2
                   WHEN 'EMERGENCIA' THEN 3
                   ELSE 0
               END;
    END peso;
BEGIN
    IF p_nivel_cm IS NULL OR p_chuva_mm_h IS NULL OR p_nivel_cm < 0 OR p_chuva_mm_h < 0 THEN
        RAISE_APPLICATION_ERROR(-20010, 'Nível e chuva são obrigatórios e não podem ser negativos');
    END IF;

    BEGIN
        SELECT * INTO v_sensor FROM GS_SENSOR WHERE cd_sensor = p_cd_sensor;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20011, 'Sensor ' || p_cd_sensor || ' não cadastrado');
    END;

    IF v_sensor.st_sensor <> 'ATIVO' THEN
        RAISE_APPLICATION_ERROR(-20012, 'Sensor ' || p_cd_sensor || ' está em ' || v_sensor.st_sensor
                                        || ' e não aceita leituras');
    END IF;

    -- classificação do risco
    IF p_nivel_cm >= v_sensor.nr_nivel_critico_cm THEN
        p_nivel_risco := 'EMERGENCIA';
    ELSIF p_nivel_cm >= v_sensor.nr_nivel_alerta_cm
       OR (p_nivel_cm >= v_sensor.nr_nivel_alerta_cm * 0.7 AND p_chuva_mm_h >= 50) THEN
        p_nivel_risco := 'ALERTA';
    ELSIF p_nivel_cm >= v_sensor.nr_nivel_alerta_cm * 0.7 OR p_chuva_mm_h >= 30 THEN
        p_nivel_risco := 'ATENCAO';
    ELSE
        p_nivel_risco := 'NORMAL';
    END IF;

    INSERT INTO GS_LEITURA (id_sensor, nr_nivel_agua_cm, nr_chuva_mm_h, ds_nivel_risco, dt_leitura)
    VALUES (v_sensor.id_sensor, p_nivel_cm, p_chuva_mm_h, p_nivel_risco, SYSDATE);

    p_id_alerta := NULL;

    IF p_nivel_risco <> 'NORMAL' THEN
        -- alerta ativo mais recente da região (se houver)
        BEGIN
            SELECT id_alerta, ds_nivel
              INTO v_id_alerta_ativo, v_nivel_ativo
              FROM (SELECT id_alerta, ds_nivel
                      FROM GS_ALERTA
                     WHERE id_regiao = v_sensor.id_regiao
                       AND st_ativo = 'S'
                     ORDER BY dt_emissao DESC)
             WHERE ROWNUM = 1;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_id_alerta_ativo := NULL;
        END;

        v_mensagem := p_nivel_risco || ': água a ' || TO_CHAR(p_nivel_cm) || ' cm e chuva de '
                      || TO_CHAR(p_chuva_mm_h) || ' mm/h em ' || v_sensor.ds_localizacao || '.';

        IF v_id_alerta_ativo IS NULL THEN
            INSERT INTO GS_ALERTA (id_regiao, id_sensor, ds_nivel, ds_mensagem, ds_origem, st_ativo, dt_emissao)
            VALUES (v_sensor.id_regiao, v_sensor.id_sensor, p_nivel_risco, v_mensagem, 'SENSOR', 'S', SYSDATE)
            RETURNING id_alerta INTO p_id_alerta;
        ELSIF peso(p_nivel_risco) > peso(v_nivel_ativo) THEN
            UPDATE GS_ALERTA
               SET ds_nivel    = p_nivel_risco,
                   ds_mensagem = v_mensagem,
                   id_sensor   = v_sensor.id_sensor
             WHERE id_alerta = v_id_alerta_ativo;
            p_id_alerta := v_id_alerta_ativo;
        END IF;
    END IF;

    COMMIT;
END PRC_REGISTRAR_LEITURA;
/

-- ---------------------------------------------------------------------
-- 2) CONSULTA/PROCESSAMENTO: priorizar regiões para a Defesa Civil
--
-- Índice de prioridade (0 a 120) por região:
--   + até 50 pts : % do nível crítico na leitura mais recente (maior entre os sensores) x 0,5
--   + até 30 pts : gravidade do alerta ativo (ATENCAO 10, ALERTA 20, EMERGENCIA 30)
--   + até 20 pts : ocorrências em aberto (4 pts cada, máx. 5)
--   + até 10 pts : pessoas afetadas nos relatos (0,05 pt por pessoa, máx. 200)
--   + até 10 pts : população em área de risco (1 pt a cada 2.000 moradores)
-- Faixas: P1 >= 70 | P2 >= 45 | P3 >= 25 | P4 abaixo disso.
-- Com p_emitir_alertas = 'S', regiões P1 sem alerta ativo recebem um alerta da Defesa Civil.
-- ---------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE PRC_PRIORIZAR_REGIOES (
    p_top             IN  NUMBER DEFAULT 10,
    p_emitir_alertas  IN  CHAR   DEFAULT 'N',
    p_qt_p1           OUT NUMBER
) IS
    CURSOR c_prioridade IS
        SELECT x.*,
               ROUND(LEAST(x.pct_critico, 100) * 0.5
                     + x.peso_alerta * 10
                     + LEAST(x.ocorr_abertas, 5) * 4
                     + LEAST(x.pessoas_afetadas, 200) * 0.05
                     + LEAST(x.qt_populacao_risco / 2000, 10), 1) AS indice
          FROM (SELECT r.id_regiao, r.nm_regiao, r.nm_cidade, r.qt_populacao_risco,
                       NVL((SELECT MAX(l.nr_nivel_agua_cm / s.nr_nivel_critico_cm * 100)
                              FROM GS_SENSOR s
                              JOIN GS_LEITURA l ON l.id_sensor = s.id_sensor
                             WHERE s.id_regiao = r.id_regiao
                               AND s.st_sensor = 'ATIVO'
                               AND l.dt_leitura = (SELECT MAX(l2.dt_leitura)
                                                     FROM GS_LEITURA l2
                                                    WHERE l2.id_sensor = s.id_sensor)), 0) AS pct_critico,
                       NVL((SELECT MAX(CASE a.ds_nivel WHEN 'EMERGENCIA' THEN 3 WHEN 'ALERTA' THEN 2 ELSE 1 END)
                              FROM GS_ALERTA a
                             WHERE a.id_regiao = r.id_regiao AND a.st_ativo = 'S'), 0) AS peso_alerta,
                       (SELECT COUNT(*)
                          FROM GS_OCORRENCIA o
                         WHERE o.id_regiao = r.id_regiao
                           AND o.st_ocorrencia IN ('ABERTA', 'EM_ATENDIMENTO')) AS ocorr_abertas,
                       NVL((SELECT SUM(o.qt_pessoas_afetadas)
                              FROM GS_OCORRENCIA o
                             WHERE o.id_regiao = r.id_regiao
                               AND o.st_ocorrencia IN ('ABERTA', 'EM_ATENDIMENTO')), 0) AS pessoas_afetadas
                  FROM GS_REGIAO r) x
         ORDER BY indice DESC, x.qt_populacao_risco DESC;

    v_prioridade   VARCHAR2(15);
    v_posicao      NUMBER := 0;
    v_emitidos     NUMBER := 0;
BEGIN
    p_qt_p1 := 0;

    DBMS_OUTPUT.PUT_LINE('============ PRIORIDADE DE ATENDIMENTO - DEFESA CIVIL ============');
    DBMS_OUTPUT.PUT_LINE(RPAD('#', 4) || RPAD('REGIÃO', 28) || RPAD('ÍNDICE', 8) || RPAD('% CRÍT', 8)
                         || RPAD('OCORR', 7) || 'PRIORIDADE');
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 70, '-'));

    FOR reg IN c_prioridade LOOP
        v_posicao := v_posicao + 1;
        EXIT WHEN v_posicao > p_top;

        IF reg.indice >= 70 THEN
            v_prioridade := 'P1 - IMEDIATA';
            p_qt_p1 := p_qt_p1 + 1;
        ELSIF reg.indice >= 45 THEN
            v_prioridade := 'P2 - ALTA';
        ELSIF reg.indice >= 25 THEN
            v_prioridade := 'P3 - MODERADA';
        ELSE
            v_prioridade := 'P4 - MONITORAR';
        END IF;

        DBMS_OUTPUT.PUT_LINE(RPAD(v_posicao, 4)
                             || RPAD(SUBSTR(reg.nm_regiao || ' (' || reg.nm_cidade || ')', 1, 27), 28)
                             || RPAD(TO_CHAR(reg.indice, 'FM990.0'), 8)
                             || RPAD(ROUND(reg.pct_critico) || '%', 8)
                             || RPAD(reg.ocorr_abertas, 7)
                             || v_prioridade);

        -- processamento: região em P1 sem alerta ativo recebe alerta manual da Defesa Civil
        IF p_emitir_alertas = 'S' AND reg.indice >= 70 AND reg.peso_alerta = 0 THEN
            INSERT INTO GS_ALERTA (id_regiao, id_sensor, ds_nivel, ds_mensagem, ds_origem, st_ativo, dt_emissao)
            VALUES (reg.id_regiao, NULL, 'ALERTA',
                    'ALERTA: região priorizada pela Defesa Civil (índice ' || TO_CHAR(reg.indice, 'FM990.0')
                    || '). Equipes a caminho; siga as orientações oficiais.', 'DEFESA_CIVIL', 'S', SYSDATE);
            v_emitidos := v_emitidos + 1;
        END IF;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(RPAD('-', 70, '-'));
    DBMS_OUTPUT.PUT_LINE('Regiões em P1 (atendimento imediato): ' || p_qt_p1);
    IF p_emitir_alertas = 'S' THEN
        DBMS_OUTPUT.PUT_LINE('Alertas emitidos automaticamente: ' || v_emitidos);
        COMMIT;
    END IF;
END PRC_PRIORIZAR_REGIOES;
/

SHOW ERRORS PROCEDURE PRC_REGISTRAR_LEITURA
SHOW ERRORS PROCEDURE PRC_PRIORIZAR_REGIOES
