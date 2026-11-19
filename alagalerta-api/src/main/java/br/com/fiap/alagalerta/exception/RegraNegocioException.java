package br.com.fiap.alagalerta.exception;

import org.springframework.http.HttpStatus;

/** Violação de regra de negócio. Por padrão vira 409 Conflict; pode carregar outro status. */
public class RegraNegocioException extends RuntimeException {

    private final HttpStatus status;

    public RegraNegocioException(String mensagem) {
        this(mensagem, HttpStatus.CONFLICT);
    }

    public RegraNegocioException(String mensagem, HttpStatus status) {
        super(mensagem);
        this.status = status;
    }

    public HttpStatus getStatus() {
        return status;
    }
}
