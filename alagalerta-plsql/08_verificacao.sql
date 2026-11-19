SET SERVEROUTPUT ON
SELECT 'GS_REGIAO' AS tabela, COUNT(*) AS quantidade FROM GS_REGIAO
UNION ALL SELECT 'GS_SENSOR', COUNT(*) FROM GS_SENSOR
UNION ALL SELECT 'GS_LEITURA', COUNT(*) FROM GS_LEITURA
UNION ALL SELECT 'GS_ALERTA', COUNT(*) FROM GS_ALERTA
UNION ALL SELECT 'GS_OCORRENCIA', COUNT(*) FROM GS_OCORRENCIA;

SELECT object_name, object_type, status
FROM user_objects
WHERE object_name IN ('PRC_REGISTRAR_LEITURA', 'PRC_PRIORIZAR_REGIOES')
ORDER BY object_name;

SELECT name, type, line, position, text
FROM user_errors
WHERE name IN ('PRC_REGISTRAR_LEITURA', 'PRC_PRIORIZAR_REGIOES')
ORDER BY name, sequence;

SELECT table_name, constraint_name, status
FROM user_constraints
WHERE constraint_type = 'R' AND table_name LIKE 'GS\_%' ESCAPE '\'
ORDER BY table_name, constraint_name;
