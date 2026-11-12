package br.com.fiap.alagalerta.controller;

import br.com.fiap.alagalerta.dto.AuthDtos.*;
import br.com.fiap.alagalerta.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirements;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@Tag(name = "Autenticação", description = "Cadastro de moradores e login com JWT")
public class AuthController {

    private final AuthService service;

    public AuthController(AuthService service) {
        this.service = service;
    }

    @PostMapping("/auth/cadastro")
    @SecurityRequirements
    @Operation(summary = "Cadastro público de morador (papel CIDADAO)")
    public ResponseEntity<UsuarioResponse> cadastrar(@RequestBody @Valid CadastroRequest req) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.cadastrar(req));
    }

    @PostMapping("/auth/login")
    @SecurityRequirements
    @Operation(summary = "Login: devolve o token JWT (use em Authorization: Bearer <token>)")
    public ResponseEntity<TokenResponse> login(@RequestBody @Valid LoginRequest req) {
        return ResponseEntity.ok(service.login(req));
    }

    @GetMapping("/api/usuarios/me")
    @Operation(summary = "Dados do usuário do token")
    public ResponseEntity<UsuarioResponse> me(Authentication auth) {
        return ResponseEntity.ok(UsuarioResponse.de(service.usuarioLogado(auth)));
    }
}
