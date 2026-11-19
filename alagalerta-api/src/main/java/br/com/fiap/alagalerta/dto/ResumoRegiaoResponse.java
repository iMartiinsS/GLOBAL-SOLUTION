package br.com.fiap.alagalerta.dto;

/** Projeção da consulta agregada de leituras por região. */
public record ResumoRegiaoResponse(Long regiaoId, String regiaoNome, String cidade,
                                   Double nivelMaximoCm, Double chuvaMediaMmHora, Long totalLeituras) {
}
