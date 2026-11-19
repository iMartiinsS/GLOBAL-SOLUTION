package br.com.fiap.alagalerta.dto;

import br.com.fiap.alagalerta.domain.Papel;
import br.com.fiap.alagalerta.domain.Usuario;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

import java.time.Instant;

public final class AuthDtos {

    private AuthDtos() {
    }

    /** Cadastro público: sempre cria um usuário com papel CIDADAO. */
    public record CadastroRequest(
            @NotBlank(message = "nome é obrigatório") @Size(max = 100) String nome,
            @NotBlank(message = "email é obrigatório") @Email(message = "email inválido") String email,
            @NotBlank(message = "senha é obrigatória")
            @Pattern(regexp = "^(?=.*[A-Za-z])(?=.*\\d).{8,64}$", message = "senha deve ter de 8 a 64 caracteres, com letras e números")
            String senha,
            Long regiaoId) {
    }

    public record LoginRequest(
            @NotBlank(message = "email é obrigatório") @Email(message = "email inválido") String email,
            @NotBlank(message = "senha é obrigatória") String senha) {
    }

    public record TokenResponse(String token, String tipo, Instant expiraEm, UsuarioResponse usuario) {
    }

    public record UsuarioResponse(Long id, String nome, String email, Papel papel, Long regiaoId) {
        public static UsuarioResponse de(Usuario u) {
            return new UsuarioResponse(u.getId(), u.getNome(), u.getEmail(), u.getPapel(),
                    u.getRegiao() != null ? u.getRegiao().getId() : null);
        }
    }
}
