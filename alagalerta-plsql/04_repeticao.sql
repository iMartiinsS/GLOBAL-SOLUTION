-- =====================================================================
-- AlagAlerta - 04 - Estruturas de repetição (FOR e WHILE)
--
-- Requisito: repetição FOR, WHILE ou LOOP para processamento de registros.
--
-- Processamento: para cada sensor ativo (laço FOR sobre os registros), calcula a
-- velocidade de subida da água entre as duas últimas leituras e, com um laço WHILE,
-- projeta em quantos ciclos de 30 minutos o córrego atinge o nível crítico se a
-- tendência continuar. Isso dá à Defesa Civil uma estimativa de "tempo até transbordar".
-- =====================================================================
SET SERVEROUTPUT ON

DECLARE
    c_ciclo_min        CONSTANT NUMBER := 30;  -- minutos por ciclo de projeção
    c_max_ciclos       CONSTANT NUMBER := 48;  -- horizonte de 24 h
    v_nivel_anterior   NUMBER;
    v_minutos_entre    NUMBER;
    v_taxa_cm_ciclo    NUMBER;
    v_nivel_projetado  NUMBER;
    v_ciclos           NUMBER;
    v_total            NUMBER := 0;
    v_em_risco         NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE(RPAD('SENSOR', 13) || RPAD('REGIÃO', 20) || RPAD('ATUAL', 8) || RPAD('CRÍTICO', 9)
                         || RPAD('cm/30min', 10) || 'PREVISÃO');
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 80, '-'));

    -- Laço FOR: percorre cada sensor ativo com a leitura mais recente
    FOR s IN (SELECT se.id_sensor, se.cd_sensor, se.nr_nivel_critico_cm, r.nm_regiao,
                     l.nr_nivel_agua_cm AS nivel_atual, l.dt_leitura AS dt_atual
                FROM GS_SENSOR se
                JOIN GS_REGIAO r  ON r.id_regiao = se.id_regiao
                JOIN GS_LEITURA l ON l.id_sensor = se.id_sensor
               WHERE se.st_sensor = 'ATIVO'
                 AND l.dt_leitura = (SELECT MAX(l2.dt_leitura) FROM GS_LEITURA l2 WHERE l2.id_sensor = se.id_sensor)
               ORDER BY r.nm_regiao, se.cd_sensor)
    LOOP
        v_total := v_total + 1;

        -- leitura imediatamente anterior para calcular a tendência
        BEGIN
            SELECT nr_nivel_agua_cm, (s.dt_atual - dt_leitura) * 1440
              INTO v_nivel_anterior, v_minutos_entre
              FROM (SELECT nr_nivel_agua_cm, dt_leitura
                      FROM GS_LEITURA
                     WHERE id_sensor = s.id_sensor AND dt_leitura < s.dt_atual
                     ORDER BY dt_leitura DESC)
             WHERE ROWNUM = 1;
            IF v_minutos_entre > 0 THEN
                v_taxa_cm_ciclo := (s.nivel_atual - v_nivel_anterior) / v_minutos_entre * c_ciclo_min;
            ELSE
                v_taxa_cm_ciclo := 0;
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_taxa_cm_ciclo := 0;  -- só uma leitura: sem tendência
        END;

        -- Laço WHILE: simula a subida ciclo a ciclo até atingir o crítico ou o horizonte de 24 h
        v_nivel_projetado := s.nivel_atual;
        v_ciclos := 0;
        WHILE v_taxa_cm_ciclo > 0
          AND v_nivel_projetado < s.nr_nivel_critico_cm
          AND v_ciclos < c_max_ciclos
        LOOP
            v_nivel_projetado := v_nivel_projetado + v_taxa_cm_ciclo;
            v_ciclos := v_ciclos + 1;
        END LOOP;

        DBMS_OUTPUT.PUT(RPAD(s.cd_sensor, 13) || RPAD(SUBSTR(s.nm_regiao, 1, 19), 20)
                        || RPAD(s.nivel_atual, 8) || RPAD(s.nr_nivel_critico_cm, 9)
                        || RPAD(TO_CHAR(ROUND(v_taxa_cm_ciclo, 1), 'FM990.0'), 10));

        IF s.nivel_atual >= s.nr_nivel_critico_cm THEN
            DBMS_OUTPUT.PUT_LINE('JÁ NO NÍVEL CRÍTICO');
            v_em_risco := v_em_risco + 1;
        ELSIF v_taxa_cm_ciclo <= 0 THEN
            DBMS_OUTPUT.PUT_LINE('estável ou descendo');
        ELSIF v_nivel_projetado >= s.nr_nivel_critico_cm THEN
            DBMS_OUTPUT.PUT_LINE('crítico em ~' || (v_ciclos * c_ciclo_min) || ' min');
            IF v_ciclos * c_ciclo_min <= 120 THEN
                v_em_risco := v_em_risco + 1;
            END IF;
        ELSE
            DBMS_OUTPUT.PUT_LINE('não atinge o crítico em 24 h');
        END IF;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(RPAD('-', 80, '-'));
    DBMS_OUTPUT.PUT_LINE(v_total || ' sensores processados; ' || v_em_risco
                         || ' no nível crítico ou com previsão de atingi-lo em até 2 h.');
END;
/
