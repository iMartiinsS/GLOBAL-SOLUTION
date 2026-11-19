package br.com.fiap.alagalerta.config;

import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import io.swagger.v3.oas.annotations.enums.SecuritySchemeType;
import io.swagger.v3.oas.annotations.info.Info;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.security.SecurityScheme;
import org.springframework.context.annotation.Configuration;

@Configuration
@OpenAPIDefinition(
        info = @Info(
                title = "AlagAlerta API",
                version = "1.0",
                description = """
                        CitizenTech de alerta de enchentes. Sensores IoT em córregos enviam nível da água e chuva;
                        a API classifica o risco, gera alertas para os moradores da região e recebe relatos de alagamento.
                        Faça login em /auth/login e clique em Authorize com o token."""),
        security = @SecurityRequirement(name = "bearerAuth"))
@SecurityScheme(name = "bearerAuth", type = SecuritySchemeType.HTTP, scheme = "bearer", bearerFormat = "JWT")
public class OpenApiConfig {
}
