package br.com.fiap.alagalerta.dto;

import br.com.fiap.alagalerta.domain.StatusOcorrencia;
import org.springframework.format.annotation.DateTimeFormat;

import java.time.LocalDateTime;

/** Parâmetros opcionais de busca de ocorrências (todos combináveis). */
public record OcorrenciaFiltro(
        StatusOcorrencia status,
        Long regiaoId,
        @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime desde,
        @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime ate,
        Integer alturaMinimaCm,
        String texto) {
}
