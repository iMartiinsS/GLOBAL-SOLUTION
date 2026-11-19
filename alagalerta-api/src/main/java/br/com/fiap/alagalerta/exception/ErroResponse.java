package br.com.fiap.alagalerta.exception;

import com.fasterxml.jackson.annotation.JsonInclude;

import java.time.Instant;
import java.util.List;

/** Formato único de erro devolvido por toda a API. */
@JsonInclude(JsonInclude.Include.NON_EMPTY)
public record ErroResponse(Instant timestamp, int status, String erro, String mensagem, String caminho,
                           List<CampoInvalido> campos) {

    public record CampoInvalido(String campo, String mensagem) {
    }
}
