-- =====================================================================
-- AlagAlerta - 02 - Carga de dados de teste (mínimo 10 linhas por tabela)
-- Datas relativas a SYSDATE para os relatórios sempre mostrarem dados "recentes".
-- =====================================================================
SET SERVEROUTPUT ON

-- ---------- 10 regiões ----------
INSERT INTO GS_REGIAO (nm_regiao, nm_cidade, sg_uf, qt_populacao_risco) VALUES ('Jardim Pantanal', 'São Paulo', 'SP', 42000);
INSERT INTO GS_REGIAO (nm_regiao, nm_cidade, sg_uf, qt_populacao_risco) VALUES ('Jardim Romano', 'São Paulo', 'SP', 23000);
INSERT INTO GS_REGIAO (nm_regiao, nm_cidade, sg_uf, qt_populacao_risco) VALUES ('Vila Prudente', 'São Paulo', 'SP', 18500);
INSERT INTO GS_REGIAO (nm_regiao, nm_cidade, sg_uf, qt_populacao_risco) VALUES ('Jardim Helena', 'São Paulo', 'SP', 15800);
INSERT INTO GS_REGIAO (nm_regiao, nm_cidade, sg_uf, qt_populacao_risco) VALUES ('Vila Itaim', 'São Paulo', 'SP', 12400);
INSERT INTO GS_REGIAO (nm_regiao, nm_cidade, sg_uf, qt_populacao_risco) VALUES ('Parque Novo Mundo', 'São Paulo', 'SP', 9800);
INSERT INTO GS_REGIAO (nm_regiao, nm_cidade, sg_uf, qt_populacao_risco) VALUES ('Lapa de Baixo', 'São Paulo', 'SP', 7600);
INSERT INTO GS_REGIAO (nm_regiao, nm_cidade, sg_uf, qt_populacao_risco) VALUES ('Ipiranga', 'São Paulo', 'SP', 11200);
INSERT INTO GS_REGIAO (nm_regiao, nm_cidade, sg_uf, qt_populacao_risco) VALUES ('Centro', 'Franco da Rocha', 'SP', 9600);
INSERT INTO GS_REGIAO (nm_regiao, nm_cidade, sg_uf, qt_populacao_risco) VALUES ('Vila Esperança', 'Cubatão', 'SP', 6300);

-- ---------- 12 sensores ----------
INSERT INTO GS_SENSOR (cd_sensor, ds_localizacao, nr_nivel_alerta_cm, nr_nivel_critico_cm, st_sensor, id_regiao)
VALUES ('SNS-PANT-01', 'Córrego Três Pontes - Rua Capachós', 120, 180, 'ATIVO', (SELECT id_regiao FROM GS_REGIAO WHERE nm_regiao = 'Jardim Pantanal'));
INSERT INTO GS_SENSOR (cd_sensor, ds_localizacao, nr_nivel_alerta_cm, nr_nivel_critico_cm, st_sensor, id_regiao)
VALUES ('SNS-PANT-02', 'Rio Tietê - Ponte Jd. Helena', 250, 330, 'ATIVO', (SELECT id_regiao FROM GS_REGIAO WHERE nm_regiao = 'Jardim Pantanal'));
INSERT INTO GS_SENSOR (cd_sensor, ds_localizacao, nr_nivel_alerta_cm, nr_nivel_critico_cm, st_sensor, id_regiao)
VALUES ('SNS-ROMA-01', 'Córrego Lajeado - Rua Kumaki Aoki', 100, 160, 'ATIVO', (SELECT id_regiao FROM GS_REGIAO WHERE nm_regiao = 'Jardim Romano'));
INSERT INTO GS_SENSOR (cd_sensor, ds_localizacao, nr_nivel_alerta_cm, nr_nivel_critico_cm, st_sensor, id_regiao)
VALUES ('SNS-VPRU-01', 'Córrego da Mooca - Av. Anhaia Mello', 90, 140, 'ATIVO', (SELECT id_regiao FROM GS_REGIAO WHERE nm_regiao = 'Vila Prudente'));
INSERT INTO GS_SENSOR (cd_sensor, ds_localizacao, nr_nivel_alerta_cm, nr_nivel_critico_cm, st_sensor, id_regiao)
VALUES ('SNS-HELE-01', 'Córrego Itaquera - Rua Serra da Juruoca', 110, 170, 'ATIVO', (SELECT id_regiao FROM GS_REGIAO WHERE nm_regiao = 'Jardim Helena'));
INSERT INTO GS_SENSOR (cd_sensor, ds_localizacao, nr_nivel_alerta_cm, nr_nivel_critico_cm, st_sensor, id_regiao)
VALUES ('SNS-ITAI-01', 'Córrego Itaim - Estrada Dom João Nery', 100, 150, 'ATIVO', (SELECT id_regiao FROM GS_REGIAO WHERE nm_regiao = 'Vila Itaim'));
INSERT INTO GS_SENSOR (cd_sensor, ds_localizacao, nr_nivel_alerta_cm, nr_nivel_critico_cm, st_sensor, id_regiao)
VALUES ('SNS-PNMU-01', 'Rio Tietê - Marginal altura Ponte Vila Maria', 260, 340, 'ATIVO', (SELECT id_regiao FROM GS_REGIAO WHERE nm_regiao = 'Parque Novo Mundo'));
INSERT INTO GS_SENSOR (cd_sensor, ds_localizacao, nr_nivel_alerta_cm, nr_nivel_critico_cm, st_sensor, id_regiao)
VALUES ('SNS-LAPA-01', 'Córrego Água Preta - Rua Guaicurus', 80, 130, 'ATIVO', (SELECT id_regiao FROM GS_REGIAO WHERE nm_regiao = 'Lapa de Baixo'));
INSERT INTO GS_SENSOR (cd_sensor, ds_localizacao, nr_nivel_alerta_cm, nr_nivel_critico_cm, st_sensor, id_regiao)
VALUES ('SNS-IPIR-01', 'Córrego Ipiranga - Av. Ricardo Jafet', 150, 220, 'ATIVO', (SELECT id_regiao FROM GS_REGIAO WHERE nm_regiao = 'Ipiranga'));
INSERT INTO GS_SENSOR (cd_sensor, ds_localizacao, nr_nivel_alerta_cm, nr_nivel_critico_cm, st_sensor, id_regiao)
VALUES ('SNS-FRAN-01', 'Rio Juquery - Av. dos Expedicionários', 200, 280, 'ATIVO', (SELECT id_regiao FROM GS_REGIAO WHERE nm_regiao = 'Centro' AND nm_cidade = 'Franco da Rocha'));
INSERT INTO GS_SENSOR (cd_sensor, ds_localizacao, nr_nivel_alerta_cm, nr_nivel_critico_cm, st_sensor, id_regiao)
VALUES ('SNS-CUBA-01', 'Rio Cubatão - Ponte da Vila Esperança', 180, 250, 'MANUTENCAO', (SELECT id_regiao FROM GS_REGIAO WHERE nm_regiao = 'Vila Esperança'));
INSERT INTO GS_SENSOR (cd_sensor, ds_localizacao, nr_nivel_alerta_cm, nr_nivel_critico_cm, st_sensor, id_regiao)
VALUES ('SNS-ROMA-02', 'Córrego Tijuco Preto - Rua Itajuíba', 90, 140, 'ATIVO', (SELECT id_regiao FROM GS_REGIAO WHERE nm_regiao = 'Jardim Romano'));

-- ---------- 30 leituras (3 por sensor ativo principal, da mais antiga para a mais recente) ----------
INSERT INTO GS_LEITURA (id_sensor, nr_nivel_agua_cm, nr_chuva_mm_h, ds_nivel_risco, dt_leitura) VALUES ((SELECT id_sensor FROM GS_SENSOR WHERE cd_sensor = 'SNS-PANT-01'),  78, 18, 'NORMAL',  SYSDATE - 90/1440);
INSERT INTO GS_LEITURA (id_sensor, nr_nivel_agua_cm, nr_chuva_mm_h, ds_nivel_risco, dt_leitura) VALUES ((SELECT id_sensor FROM GS_SENSOR WHERE cd_sensor = 'SNS-PANT-01'),  95, 34, 'ATENCAO', SYSDATE - 60/1440);
INSERT INTO GS_LEITURA (id_sensor, nr_nivel_agua_cm, nr_chuva_mm_h, ds_nivel_risco, dt_leitura) VALUES ((SELECT id_sensor FROM GS_SENSOR WHERE cd_sensor = 'SNS-PANT-01'), 128, 42, 'ALERTA',  SYSDATE - 10/1440);
INSERT INTO GS_LEITURA (id_sensor, nr_nivel_agua_cm, nr_chuva_mm_h, ds_nivel_risco, dt_leitura) VALUES ((SELECT id_sensor FROM GS_SENSOR WHERE cd_sensor = 'SNS-PANT-02'), 132, 22, 'NORMAL',  SYSDATE - 90/1440);
INSERT INTO GS_LEITURA (id_sensor, nr_nivel_agua_cm, nr_chuva_mm_h, ds_nivel_risco, dt_leitura) VALUES ((SELECT id_sensor FROM GS_SENSOR WHERE cd_sensor = 'SNS-PANT-02'), 140, 34, 'ATENCAO', SYSDATE - 60/1440);
INSERT INTO GS_LEITURA (id_sensor, nr_nivel_agua_cm, nr_chuva_mm_h, ds_nivel_risco, dt_leitura) VALUES ((SELECT id_sensor FROM GS_SENSOR WHERE cd_sensor = 'SNS-PANT-02'), 150, 30, 'ATENCAO', SYSDATE - 10/1440);
INSERT INTO GS_LEITURA (id_sensor, nr_nivel_agua_cm, nr_chuva_mm_h, ds_nivel_risco, dt_leitura) VALUES ((SELECT id_sensor FROM GS_SENSOR WHERE cd_sensor = 'SNS-ROMA-01'),  40,  8, 'NORMAL',  SYSDATE - 90/1440);
INSERT INTO GS_LEITURA (id_sensor, nr_nivel_agua_cm, nr_chuva_mm_h, ds_nivel_risco, dt_leitura) VALUES ((SELECT id_sensor FROM GS_SENSOR WHERE cd_sensor = 'SNS-ROMA-01'),  55, 12, 'NORMAL',  SYSDATE - 60/1440);
INSERT INTO GS_LEITURA (id_sensor, nr_nivel_agua_cm, nr_chuva_mm_h, ds_nivel_risco, dt_leitura) VALUES ((SELECT id_sensor FROM GS_SENSOR WHERE cd_sensor = 'SNS-ROMA-01'),  72, 31, 'ATENCAO', SYSDATE - 15/1440);
INSERT INTO GS_LEITURA (id_sensor, nr_nivel_agua_cm, nr_chuva_mm_h, ds_nivel_risco, dt_leitura) VALUES ((SELECT id_sensor FROM GS_SENSOR WHERE cd_sensor = 'SNS-VPRU-01'),  28,  1, 'NORMAL',  SYSDATE - 90/1440);
INSERT INTO GS_LEITURA (id_sensor, nr_nivel_agua_cm, nr_chuva_mm_h, ds_nivel_risco, dt_leitura) VALUES ((SELECT id_sensor FROM GS_SENSOR WHERE cd_sensor = 'SNS-VPRU-01'),  30,  2, 'NORMAL',  SYSDATE - 60/1440);
INSERT INTO GS_LEITURA (id_sensor, nr_nivel_agua_cm, nr_chuva_mm_h, ds_nivel_risco, dt_leitura) VALUES ((SELECT id_sensor FROM GS_SENSOR WHERE cd_sensor = 'SNS-VPRU-01'),  35,  4, 'NORMAL',  SYSDATE - 10/1440);
INSERT INTO GS_LEITURA (id_sensor, nr_nivel_agua_cm, nr_chuva_mm_h, ds_nivel_risco, dt_leitura) VALUES ((SELECT id_sensor FROM GS_SENSOR WHERE cd_sensor = 'SNS-HELE-01'),  90, 38, 'ATENCAO', SYSDATE - 90/1440);
INSERT INTO GS_LEITURA (id_sensor, nr_nivel_agua_cm, nr_chuva_mm_h, ds_nivel_risco, dt_leitura) VALUES ((SELECT id_sensor FROM GS_SENSOR WHERE cd_sensor = 'SNS-HELE-01'), 135, 55, 'ALERTA',  SYSDATE - 60/1440);
INSERT INTO GS_LEITURA (id_sensor, nr_nivel_agua_cm, nr_chuva_mm_h, ds_nivel_risco, dt_leitura) VALUES ((SELECT id_sensor FROM GS_SENSOR WHERE cd_sensor = 'SNS-HELE-01'), 176, 61, 'EMERGENCIA', SYSDATE - 5/1440);
INSERT INTO GS_LEITURA (id_sensor, nr_nivel_agua_cm, nr_chuva_mm_h, ds_nivel_risco, dt_leitura) VALUES ((SELECT id_sensor FROM GS_SENSOR WHERE cd_sensor = 'SNS-ITAI-01'),  50, 10, 'NORMAL',  SYSDATE - 90/1440);
INSERT INTO GS_LEITURA (id_sensor, nr_nivel_agua_cm, nr_chuva_mm_h, ds_nivel_risco, dt_leitura) VALUES ((SELECT id_sensor FROM GS_SENSOR WHERE cd_sensor = 'SNS-ITAI-01'),  68, 20, 'NORMAL',  SYSDATE - 60/1440);
INSERT INTO GS_LEITURA (id_sensor, nr_nivel_agua_cm, nr_chuva_mm_h, ds_nivel_risco, dt_leitura) VALUES ((SELECT id_sensor FROM GS_SENSOR WHERE cd_sensor = 'SNS-ITAI-01'),  84, 26, 'ATENCAO', SYSDATE - 10/1440);
INSERT INTO GS_LEITURA (id_sensor, nr_nivel_agua_cm, nr_chuva_mm_h, ds_nivel_risco, dt_leitura) VALUES ((SELECT id_sensor FROM GS_SENSOR WHERE cd_sensor = 'SNS-PNMU-01'), 150,  6, 'NORMAL',  SYSDATE - 90/1440);
INSERT INTO GS_LEITURA (id_sensor, nr_nivel_agua_cm, nr_chuva_mm_h, ds_nivel_risco, dt_leitura) VALUES ((SELECT id_sensor FROM GS_SENSOR WHERE cd_sensor = 'SNS-PNMU-01'), 158,  9, 'NORMAL',  SYSDATE - 60/1440);
INSERT INTO GS_LEITURA (id_sensor, nr_nivel_agua_cm, nr_chuva_mm_h, ds_nivel_risco, dt_leitura) VALUES ((SELECT id_sensor FROM GS_SENSOR WHERE cd_sensor = 'SNS-PNMU-01'), 165, 11, 'NORMAL',  SYSDATE - 10/1440);
INSERT INTO GS_LEITURA (id_sensor, nr_nivel_agua_cm, nr_chuva_mm_h, ds_nivel_risco, dt_leitura) VALUES ((SELECT id_sensor FROM GS_SENSOR WHERE cd_sensor = 'SNS-LAPA-01'),  45, 15, 'NORMAL',  SYSDATE - 90/1440);
INSERT INTO GS_LEITURA (id_sensor, nr_nivel_agua_cm, nr_chuva_mm_h, ds_nivel_risco, dt_leitura) VALUES ((SELECT id_sensor FROM GS_SENSOR WHERE cd_sensor = 'SNS-LAPA-01'),  66, 33, 'ATENCAO', SYSDATE - 60/1440);
INSERT INTO GS_LEITURA (id_sensor, nr_nivel_agua_cm, nr_chuva_mm_h, ds_nivel_risco, dt_leitura) VALUES ((SELECT id_sensor FROM GS_SENSOR WHERE cd_sensor = 'SNS-LAPA-01'),  88, 40, 'ALERTA',  SYSDATE - 10/1440);
INSERT INTO GS_LEITURA (id_sensor, nr_nivel_agua_cm, nr_chuva_mm_h, ds_nivel_risco, dt_leitura) VALUES ((SELECT id_sensor FROM GS_SENSOR WHERE cd_sensor = 'SNS-IPIR-01'),  60,  5, 'NORMAL',  SYSDATE - 90/1440);
INSERT INTO GS_LEITURA (id_sensor, nr_nivel_agua_cm, nr_chuva_mm_h, ds_nivel_risco, dt_leitura) VALUES ((SELECT id_sensor FROM GS_SENSOR WHERE cd_sensor = 'SNS-IPIR-01'),  70,  8, 'NORMAL',  SYSDATE - 60/1440);
INSERT INTO GS_LEITURA (id_sensor, nr_nivel_agua_cm, nr_chuva_mm_h, ds_nivel_risco, dt_leitura) VALUES ((SELECT id_sensor FROM GS_SENSOR WHERE cd_sensor = 'SNS-IPIR-01'),  74,  6, 'NORMAL',  SYSDATE - 10/1440);
INSERT INTO GS_LEITURA (id_sensor, nr_nivel_agua_cm, nr_chuva_mm_h, ds_nivel_risco, dt_leitura) VALUES ((SELECT id_sensor FROM GS_SENSOR WHERE cd_sensor = 'SNS-FRAN-01'),  82,  0, 'NORMAL',  SYSDATE - 300/1440);
INSERT INTO GS_LEITURA (id_sensor, nr_nivel_agua_cm, nr_chuva_mm_h, ds_nivel_risco, dt_leitura) VALUES ((SELECT id_sensor FROM GS_SENSOR WHERE cd_sensor = 'SNS-FRAN-01'),  80,  0, 'NORMAL',  SYSDATE - 240/1440);
INSERT INTO GS_LEITURA (id_sensor, nr_nivel_agua_cm, nr_chuva_mm_h, ds_nivel_risco, dt_leitura) VALUES ((SELECT id_sensor FROM GS_SENSOR WHERE cd_sensor = 'SNS-FRAN-01'),  79,  0, 'NORMAL',  SYSDATE - 180/1440);

-- ---------- 10 alertas (ativos e histórico) ----------
INSERT INTO GS_ALERTA (id_regiao, id_sensor, ds_nivel, ds_mensagem, ds_origem, st_ativo, dt_emissao)
VALUES ((SELECT id_regiao FROM GS_REGIAO WHERE nm_regiao = 'Jardim Pantanal'), (SELECT id_sensor FROM GS_SENSOR WHERE cd_sensor = 'SNS-PANT-01'),
        'ALERTA', 'ALERTA: nível do córrego subindo rápido (128 cm) no Córrego Três Pontes. Prepare-se para deixar o local.', 'SENSOR', 'S', SYSDATE - 10/1440);
INSERT INTO GS_ALERTA (id_regiao, id_sensor, ds_nivel, ds_mensagem, ds_origem, st_ativo, dt_emissao)
VALUES ((SELECT id_regiao FROM GS_REGIAO WHERE nm_regiao = 'Jardim Helena'), (SELECT id_sensor FROM GS_SENSOR WHERE cd_sensor = 'SNS-HELE-01'),
        'EMERGENCIA', 'EMERGÊNCIA: água a 176 cm no Córrego Itaquera. Saia de áreas baixas. Defesa Civil: 199.', 'SENSOR', 'S', SYSDATE - 5/1440);
INSERT INTO GS_ALERTA (id_regiao, id_sensor, ds_nivel, ds_mensagem, ds_origem, st_ativo, dt_emissao)
VALUES ((SELECT id_regiao FROM GS_REGIAO WHERE nm_regiao = 'Jardim Romano'), (SELECT id_sensor FROM GS_SENSOR WHERE cd_sensor = 'SNS-ROMA-01'),
        'ATENCAO', 'ATENÇÃO: chuva forte (31 mm/h) e nível em elevação no Córrego Lajeado.', 'SENSOR', 'S', SYSDATE - 15/1440);
INSERT INTO GS_ALERTA (id_regiao, id_sensor, ds_nivel, ds_mensagem, ds_origem, st_ativo, dt_emissao)
VALUES ((SELECT id_regiao FROM GS_REGIAO WHERE nm_regiao = 'Lapa de Baixo'), (SELECT id_sensor FROM GS_SENSOR WHERE cd_sensor = 'SNS-LAPA-01'),
        'ALERTA', 'ALERTA: Córrego Água Preta a 88 cm. Evite a Rua Guaicurus.', 'SENSOR', 'S', SYSDATE - 10/1440);
INSERT INTO GS_ALERTA (id_regiao, id_sensor, ds_nivel, ds_mensagem, ds_origem, st_ativo, dt_emissao)
VALUES ((SELECT id_regiao FROM GS_REGIAO WHERE nm_regiao = 'Vila Prudente'), NULL,
        'ATENCAO', 'Previsão de temporal entre 16h e 20h. Mantenha o celular carregado.', 'DEFESA_CIVIL', 'S', SYSDATE - 120/1440);
INSERT INTO GS_ALERTA (id_regiao, id_sensor, ds_nivel, ds_mensagem, ds_origem, st_ativo, dt_emissao, dt_encerramento)
VALUES ((SELECT id_regiao FROM GS_REGIAO WHERE nm_regiao = 'Jardim Pantanal'), (SELECT id_sensor FROM GS_SENSOR WHERE cd_sensor = 'SNS-PANT-02'),
        'ALERTA', 'ALERTA: Rio Tietê acima do nível de alerta na Ponte Jd. Helena.', 'SENSOR', 'N', SYSDATE - 7, SYSDATE - 6.8);
INSERT INTO GS_ALERTA (id_regiao, id_sensor, ds_nivel, ds_mensagem, ds_origem, st_ativo, dt_emissao, dt_encerramento)
VALUES ((SELECT id_regiao FROM GS_REGIAO WHERE nm_regiao = 'Jardim Romano'), (SELECT id_sensor FROM GS_SENSOR WHERE cd_sensor = 'SNS-ROMA-02'),
        'EMERGENCIA', 'EMERGÊNCIA: Córrego Tijuco Preto transbordou na Rua Itajuíba.', 'SENSOR', 'N', SYSDATE - 12, SYSDATE - 11.7);
INSERT INTO GS_ALERTA (id_regiao, id_sensor, ds_nivel, ds_mensagem, ds_origem, st_ativo, dt_emissao, dt_encerramento)
VALUES ((SELECT id_regiao FROM GS_REGIAO WHERE nm_regiao = 'Ipiranga'), (SELECT id_sensor FROM GS_SENSOR WHERE cd_sensor = 'SNS-IPIR-01'),
        'ALERTA', 'ALERTA: Córrego Ipiranga próximo do limite na Av. Ricardo Jafet.', 'SENSOR', 'N', SYSDATE - 20, SYSDATE - 19.9);
INSERT INTO GS_ALERTA (id_regiao, id_sensor, ds_nivel, ds_mensagem, ds_origem, st_ativo, dt_emissao, dt_encerramento)
VALUES ((SELECT id_regiao FROM GS_REGIAO WHERE nm_regiao = 'Centro' AND nm_cidade = 'Franco da Rocha'), NULL,
        'ATENCAO', 'Abertura de comportas da barragem Paiva Castro prevista para hoje.', 'DEFESA_CIVIL', 'N', SYSDATE - 30, SYSDATE - 29.5);
INSERT INTO GS_ALERTA (id_regiao, id_sensor, ds_nivel, ds_mensagem, ds_origem, st_ativo, dt_emissao, dt_encerramento)
VALUES ((SELECT id_regiao FROM GS_REGIAO WHERE nm_regiao = 'Vila Itaim'), (SELECT id_sensor FROM GS_SENSOR WHERE cd_sensor = 'SNS-ITAI-01'),
        'ATENCAO', 'ATENÇÃO: chuva forte na bacia do Córrego Itaim.', 'SENSOR', 'N', SYSDATE - 3, SYSDATE - 2.9);

-- ---------- 10 ocorrências ----------
INSERT INTO GS_OCORRENCIA (id_regiao, ds_descricao, ds_endereco, nr_altura_agua_cm, qt_pessoas_afetadas, st_ocorrencia, dt_registro)
VALUES ((SELECT id_regiao FROM GS_REGIAO WHERE nm_regiao = 'Jardim Pantanal'), 'Água entrando nas casas, altura do joelho', 'Rua Capachós, 210', 50, 12, 'ABERTA', SYSDATE - 25/1440);
INSERT INTO GS_OCORRENCIA (id_regiao, ds_descricao, ds_endereco, nr_altura_agua_cm, qt_pessoas_afetadas, st_ocorrencia, dt_registro)
VALUES ((SELECT id_regiao FROM GS_REGIAO WHERE nm_regiao = 'Jardim Pantanal'), 'Idosa ilhada em casa térrea, precisa de ajuda', 'Travessa Três Pontes, 15', 70, 1, 'EM_ATENDIMENTO', SYSDATE - 5/1440);
INSERT INTO GS_OCORRENCIA (id_regiao, ds_descricao, ds_endereco, nr_altura_agua_cm, qt_pessoas_afetadas, st_ocorrencia, dt_registro)
VALUES ((SELECT id_regiao FROM GS_REGIAO WHERE nm_regiao = 'Jardim Romano'), 'Bueiro entupido causando alagamento na esquina', 'Rua Kumaki Aoki x Rua Itajuíba', 20, 0, 'EM_ATENDIMENTO', SYSDATE - 3/24);
INSERT INTO GS_OCORRENCIA (id_regiao, ds_descricao, ds_endereco, nr_altura_agua_cm, qt_pessoas_afetadas, st_ocorrencia, dt_registro)
VALUES ((SELECT id_regiao FROM GS_REGIAO WHERE nm_regiao = 'Jardim Helena'), 'Rua inteira alagada, carros submersos', 'Rua Serra da Juruoca, 400', 90, 40, 'ABERTA', SYSDATE - 8/1440);
INSERT INTO GS_OCORRENCIA (id_regiao, ds_descricao, ds_endereco, nr_altura_agua_cm, qt_pessoas_afetadas, st_ocorrencia, dt_registro)
VALUES ((SELECT id_regiao FROM GS_REGIAO WHERE nm_regiao = 'Jardim Helena'), 'Escola municipal com água no pátio', 'EMEF Jd. Helena', 30, 300, 'ABERTA', SYSDATE - 20/1440);
INSERT INTO GS_OCORRENCIA (id_regiao, ds_descricao, ds_endereco, nr_altura_agua_cm, qt_pessoas_afetadas, st_ocorrencia, dt_registro)
VALUES ((SELECT id_regiao FROM GS_REGIAO WHERE nm_regiao = 'Lapa de Baixo'), 'Ponto de ônibus alagado, passageiros ilhados', 'Rua Guaicurus, 1200', 40, 15, 'ABERTA', SYSDATE - 12/1440);
INSERT INTO GS_OCORRENCIA (id_regiao, ds_descricao, ds_endereco, nr_altura_agua_cm, qt_pessoas_afetadas, st_ocorrencia, dt_registro)
VALUES ((SELECT id_regiao FROM GS_REGIAO WHERE nm_regiao = 'Vila Itaim'), 'Muro de contenção com rachadura após a chuva', 'Estrada Dom João Nery, 3300', 0, 6, 'ABERTA', SYSDATE - 2/24);
INSERT INTO GS_OCORRENCIA (id_regiao, ds_descricao, ds_endereco, nr_altura_agua_cm, qt_pessoas_afetadas, st_ocorrencia, dt_registro)
VALUES ((SELECT id_regiao FROM GS_REGIAO WHERE nm_regiao = 'Ipiranga'), 'Árvore caída bloqueando o canal', 'Av. Ricardo Jafet, 2000', 0, 0, 'RESOLVIDA', SYSDATE - 2);
INSERT INTO GS_OCORRENCIA (id_regiao, ds_descricao, ds_endereco, nr_altura_agua_cm, qt_pessoas_afetadas, st_ocorrencia, dt_registro)
VALUES ((SELECT id_regiao FROM GS_REGIAO WHERE nm_regiao = 'Vila Prudente'), 'Relato duplicado do mesmo ponto', 'Av. Anhaia Mello, 500', 10, 0, 'DESCARTADA', SYSDATE - 1);
INSERT INTO GS_OCORRENCIA (id_regiao, ds_descricao, ds_endereco, nr_altura_agua_cm, qt_pessoas_afetadas, st_ocorrencia, dt_registro)
VALUES ((SELECT id_regiao FROM GS_REGIAO WHERE nm_regiao = 'Parque Novo Mundo'), 'Galeria de águas pluviais transbordando', 'Rua Curuçá, 85', 25, 8, 'ABERTA', SYSDATE - 40/1440);

COMMIT;

-- Conferência
SELECT 'GS_REGIAO' AS tabela, COUNT(*) AS linhas FROM GS_REGIAO
UNION ALL SELECT 'GS_SENSOR', COUNT(*) FROM GS_SENSOR
UNION ALL SELECT 'GS_LEITURA', COUNT(*) FROM GS_LEITURA
UNION ALL SELECT 'GS_ALERTA', COUNT(*) FROM GS_ALERTA
UNION ALL SELECT 'GS_OCORRENCIA', COUNT(*) FROM GS_OCORRENCIA;
