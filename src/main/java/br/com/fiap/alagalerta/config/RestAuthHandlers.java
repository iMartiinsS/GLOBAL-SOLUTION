package br.com.fiap.alagalerta.config;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.security.web.access.AccessDeniedHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.time.Instant;

/**
 * Devolve 401/403 no mesmo formato JSON do GlobalExceptionHandler
 * (erros de segurança acontecem no filtro, antes de chegar ao controller).
 */
@Component
public class RestAuthHandlers implements AuthenticationEntryPoint, AccessDeniedHandler {

    @Override
    public void commence(HttpServletRequest req, HttpServletResponse res, AuthenticationException ex) throws IOException {
        escrever(res, HttpStatus.UNAUTHORIZED, "Token ausente, inválido ou expirado", req.getRequestURI());
    }

    @Override
    public void handle(HttpServletRequest req, HttpServletResponse res, AccessDeniedException ex) throws IOException {
        escrever(res, HttpStatus.FORBIDDEN, "Seu papel não tem permissão para esta operação", req.getRequestURI());
    }

    private void escrever(HttpServletResponse res, HttpStatus status, String mensagem, String caminho) throws IOException {
        res.setStatus(status.value());
        res.setContentType(MediaType.APPLICATION_JSON_VALUE);
        res.setCharacterEncoding("UTF-8");
        String json = """
                {"timestamp":"%s","status":%d,"erro":"%s","mensagem":"%s","caminho":"%s"}"""
                .formatted(Instant.now(), status.value(), status.getReasonPhrase(), mensagem, caminho.replace("\"", ""));
        res.getWriter().write(json);
    }
}
