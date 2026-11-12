-- =====================================================================
-- AlagAlerta - 05 - Cursor explícito
--
-- Requisito: cursor explícito para percorrer e apresentar dados do projeto.
--
-- Painel de alertas ativos: o cursor percorre os alertas em vigor, do mais grave para o
-- menos grave, com região, sensor de origem, tempo desde a emissão e quantas ocorrências
-- os moradores abriram na região. Usa OPEN / FETCH / %NOTFOUND / %ROWCOUNT / CLOSE.
-- =====================================================================
SET SERVEROUTPUT ON

DECLARE
    CURSOR c_alertas_ativos IS
        SELECT a.id_alerta,
               a.ds_nivel,
               a.ds_origem,
               a.ds_mensagem,
               r.nm_regiao,
               r.nm_cidade,
               r.qt_populacao_risco,
               NVL(s.cd_sensor, '-') AS cd_sensor,
               ROUND((SYSDATE - a.dt_emissao) * 1440) AS minutos_desde_emissao,
               (SELECT COUNT(*)
                  FROM GS_OCORRENCIA o
                 WHERE o.id_regiao = a.id_regiao
                   AND o.st_ocorrencia IN ('ABERTA', 'EM_ATENDIMENTO')) AS ocorrencias_abertas
          FROM GS_ALERTA a
          JOIN GS_REGIAO r ON r.id_regiao = a.id_regiao
          LEFT JOIN GS_SENSOR s ON s.id_sensor = a.id_sensor
         WHERE a.st_ativo = 'S'
         ORDER BY CASE a.ds_nivel WHEN 'EMERGENCIA' THEN 1 WHEN 'ALERTA' THEN 2 ELSE 3 END,
                  a.dt_emissao DESC;

    v_alerta             c_alertas_ativos%ROWTYPE;
    v_populacao_total    NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=========== PAINEL DE ALERTAS ATIVOS ===========');

    OPEN c_alertas_ativos;
    LOOP
        FETCH c_alertas_ativos INTO v_alerta;
        EXIT WHEN c_alertas_ativos%NOTFOUND;

        v_populacao_total := v_populacao_total + v_alerta.qt_populacao_risco;

        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('#' || c_alertas_ativos%ROWCOUNT || ' [' || v_alerta.ds_nivel || '] '
                             || v_alerta.nm_regiao || ' - ' || v_alerta.nm_cidade);
        DBMS_OUTPUT.PUT_LINE('   Alerta ' || v_alerta.id_alerta || ' | origem: ' || v_alerta.ds_origem
                             || ' | sensor: ' || v_alerta.cd_sensor
                             || ' | emitido há ' || v_alerta.minutos_desde_emissao || ' min');
        DBMS_OUTPUT.PUT_LINE('   ' || v_alerta.ds_mensagem);
        DBMS_OUTPUT.PUT_LINE('   Ocorrências abertas na região: ' || v_alerta.ocorrencias_abertas
                             || ' | moradores em risco: ' || TO_CHAR(v_alerta.qt_populacao_risco, 'FM999G999G999'));
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('');
    IF c_alertas_ativos%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Nenhum alerta ativo no momento.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Total: ' || c_alertas_ativos%ROWCOUNT || ' alertas ativos, '
                             || TO_CHAR(v_populacao_total, 'FM999G999G999') || ' moradores nas regiões afetadas.');
    END IF;
    CLOSE c_alertas_ativos;
EXCEPTION
    WHEN OTHERS THEN
        IF c_alertas_ativos%ISOPEN THEN
            CLOSE c_alertas_ativos;
        END IF;
        RAISE;
END;
/
