-- =====================================================================
-- AlagAlerta - Global Solution 2026/2 (CitizenTech)
-- Mastering Relational and Non-Relational Database
-- 01 - Criação das tabelas (Oracle 19c+)
-- =====================================================================
SET SERVEROUTPUT ON

-- Remove as tabelas se já existirem (permite rodar o script mais de uma vez)
BEGIN
    FOR t IN (SELECT table_name
                FROM user_tables
               WHERE table_name IN ('GS_OCORRENCIA', 'GS_ALERTA', 'GS_LEITURA', 'GS_SENSOR', 'GS_REGIAO')) LOOP
        EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS PURGE';
        DBMS_OUTPUT.PUT_LINE('Tabela removida: ' || t.table_name);
    END LOOP;
END;
/

-- Bairro/área monitorada
CREATE TABLE GS_REGIAO (
    id_regiao           NUMBER GENERATED ALWAYS AS IDENTITY,
    nm_regiao           VARCHAR2(100) NOT NULL,
    nm_cidade           VARCHAR2(100) NOT NULL,
    sg_uf               CHAR(2)       NOT NULL,
    qt_populacao_risco  NUMBER(9)     DEFAULT 0 NOT NULL,
    CONSTRAINT pk_gs_regiao PRIMARY KEY (id_regiao),
    CONSTRAINT uk_gs_regiao UNIQUE (nm_regiao, nm_cidade),
    CONSTRAINT ck_gs_regiao_pop CHECK (qt_populacao_risco >= 0)
);

-- Estação IoT instalada em um córrego (1 região : N sensores)
CREATE TABLE GS_SENSOR (
    id_sensor            NUMBER GENERATED ALWAYS AS IDENTITY,
    cd_sensor            VARCHAR2(30)  NOT NULL,
    ds_localizacao       VARCHAR2(150) NOT NULL,
    nr_nivel_alerta_cm   NUMBER(5)     NOT NULL,
    nr_nivel_critico_cm  NUMBER(5)     NOT NULL,
    st_sensor            VARCHAR2(12)  DEFAULT 'ATIVO' NOT NULL,
    id_regiao            NUMBER        NOT NULL,
    CONSTRAINT pk_gs_sensor PRIMARY KEY (id_sensor),
    CONSTRAINT uk_gs_sensor_cd UNIQUE (cd_sensor),
    CONSTRAINT fk_gs_sensor_regiao FOREIGN KEY (id_regiao) REFERENCES GS_REGIAO (id_regiao),
    CONSTRAINT ck_gs_sensor_status CHECK (st_sensor IN ('ATIVO', 'MANUTENCAO', 'INATIVO')),
    CONSTRAINT ck_gs_sensor_limites CHECK (nr_nivel_critico_cm > nr_nivel_alerta_cm AND nr_nivel_alerta_cm > 0)
);

-- Medição enviada pelo sensor (1 sensor : N leituras)
CREATE TABLE GS_LEITURA (
    id_leitura        NUMBER GENERATED ALWAYS AS IDENTITY,
    id_sensor         NUMBER       NOT NULL,
    nr_nivel_agua_cm  NUMBER(7,2)  NOT NULL,
    nr_chuva_mm_h     NUMBER(6,2)  DEFAULT 0 NOT NULL,
    ds_nivel_risco    VARCHAR2(12) NOT NULL,
    dt_leitura        DATE         DEFAULT SYSDATE NOT NULL,
    CONSTRAINT pk_gs_leitura PRIMARY KEY (id_leitura),
    CONSTRAINT fk_gs_leitura_sensor FOREIGN KEY (id_sensor) REFERENCES GS_SENSOR (id_sensor),
    CONSTRAINT ck_gs_leitura_nivel CHECK (nr_nivel_agua_cm >= 0 AND nr_chuva_mm_h >= 0),
    CONSTRAINT ck_gs_leitura_risco CHECK (ds_nivel_risco IN ('NORMAL', 'ATENCAO', 'ALERTA', 'EMERGENCIA'))
);

-- Alerta emitido para a população de uma região (automático por sensor ou manual pela Defesa Civil)
CREATE TABLE GS_ALERTA (
    id_alerta        NUMBER GENERATED ALWAYS AS IDENTITY,
    id_regiao        NUMBER        NOT NULL,
    id_sensor        NUMBER,
    ds_nivel         VARCHAR2(12)  NOT NULL,
    ds_mensagem      VARCHAR2(400) NOT NULL,
    ds_origem        VARCHAR2(12)  NOT NULL,
    st_ativo         CHAR(1)       DEFAULT 'S' NOT NULL,
    dt_emissao       DATE          DEFAULT SYSDATE NOT NULL,
    dt_encerramento  DATE,
    CONSTRAINT pk_gs_alerta PRIMARY KEY (id_alerta),
    CONSTRAINT fk_gs_alerta_regiao FOREIGN KEY (id_regiao) REFERENCES GS_REGIAO (id_regiao),
    CONSTRAINT fk_gs_alerta_sensor FOREIGN KEY (id_sensor) REFERENCES GS_SENSOR (id_sensor),
    CONSTRAINT ck_gs_alerta_nivel CHECK (ds_nivel IN ('ATENCAO', 'ALERTA', 'EMERGENCIA')),
    CONSTRAINT ck_gs_alerta_origem CHECK (ds_origem IN ('SENSOR', 'DEFESA_CIVIL')),
    CONSTRAINT ck_gs_alerta_ativo CHECK (st_ativo IN ('S', 'N'))
);

-- Relato de alagamento enviado por morador
CREATE TABLE GS_OCORRENCIA (
    id_ocorrencia        NUMBER GENERATED ALWAYS AS IDENTITY,
    id_regiao            NUMBER        NOT NULL,
    ds_descricao         VARCHAR2(500) NOT NULL,
    ds_endereco          VARCHAR2(200) NOT NULL,
    nr_altura_agua_cm    NUMBER(4)     DEFAULT 0,
    qt_pessoas_afetadas  NUMBER(6)     DEFAULT 0,
    st_ocorrencia        VARCHAR2(15)  DEFAULT 'ABERTA' NOT NULL,
    dt_registro          DATE          DEFAULT SYSDATE NOT NULL,
    CONSTRAINT pk_gs_ocorrencia PRIMARY KEY (id_ocorrencia),
    CONSTRAINT fk_gs_ocorrencia_regiao FOREIGN KEY (id_regiao) REFERENCES GS_REGIAO (id_regiao),
    CONSTRAINT ck_gs_ocorrencia_status CHECK (st_ocorrencia IN ('ABERTA', 'EM_ATENDIMENTO', 'RESOLVIDA', 'DESCARTADA'))
);

CREATE INDEX ix_gs_leitura_sensor_data ON GS_LEITURA (id_sensor, dt_leitura);
CREATE INDEX ix_gs_alerta_regiao_ativo ON GS_ALERTA (id_regiao, st_ativo);

BEGIN
    DBMS_OUTPUT.PUT_LINE('Tabelas do AlagAlerta criadas com sucesso.');
END;
/
