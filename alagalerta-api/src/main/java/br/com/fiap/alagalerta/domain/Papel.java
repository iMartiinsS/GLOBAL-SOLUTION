package br.com.fiap.alagalerta.domain;

/**
 * CIDADAO: recebe alertas e registra ocorrências.
 * AGENTE: Defesa Civil — emite/encerra alertas, atende ocorrências, envia leituras (gateway IoT).
 * ADMIN: cadastra regiões e sensores e acessa métricas.
 */
public enum Papel {
    CIDADAO,
    AGENTE,
    ADMIN
}
