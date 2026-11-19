package br.com.fiap.alagalerta.service;

import br.com.fiap.alagalerta.domain.Papel;
import br.com.fiap.alagalerta.domain.Regiao;
import br.com.fiap.alagalerta.domain.Usuario;
import br.com.fiap.alagalerta.dto.AuthDtos.*;
import br.com.fiap.alagalerta.exception.RecursoNaoEncontradoException;
import br.com.fiap.alagalerta.exception.RegraNegocioException;
import br.com.fiap.alagalerta.repository.RegiaoRepository;
import br.com.fiap.alagalerta.repository.UsuarioRepository;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthService {

    private final UsuarioRepository usuarios;
    private final RegiaoRepository regioes;
    private final PasswordEncoder passwordEncoder;
    private final TokenService tokenService;

    public AuthService(UsuarioRepository usuarios, RegiaoRepository regioes,
                       PasswordEncoder passwordEncoder, TokenService tokenService) {
        this.usuarios = usuarios;
        this.regioes = regioes;
        this.passwordEncoder = passwordEncoder;
        this.tokenService = tokenService;
    }

    @Transactional
    public UsuarioResponse cadastrar(CadastroRequest req) {
        if (usuarios.existsByEmailIgnoreCase(req.email())) {
            throw new RegraNegocioException("Já existe um usuário com este e-mail");
        }
        Regiao regiao = null;
        if (req.regiaoId() != null) {
            regiao = regioes.findById(req.regiaoId())
                    .orElseThrow(() -> new RecursoNaoEncontradoException("Região", req.regiaoId()));
        }
        Usuario novo = new Usuario(req.nome().trim(), req.email().trim().toLowerCase(),
                passwordEncoder.encode(req.senha()), Papel.CIDADAO, regiao);
        return UsuarioResponse.de(usuarios.save(novo));
    }

    @Transactional(readOnly = true)
    public TokenResponse login(LoginRequest req) {
        Usuario usuario = usuarios.findByEmailIgnoreCase(req.email().trim())
                .filter(u -> passwordEncoder.matches(req.senha(), u.getSenhaHash()))
                .orElseThrow(() -> new BadCredentialsException("credenciais inválidas"));
        TokenService.TokenGerado token = tokenService.gerar(usuario);
        return new TokenResponse(token.valor(), "Bearer", token.expiraEm(), UsuarioResponse.de(usuario));
    }

    @Transactional(readOnly = true)
    public Usuario usuarioLogado(Authentication auth) {
        return usuarios.findByEmailIgnoreCase(auth.getName())
                .orElseThrow(() -> new RecursoNaoEncontradoException("Usuário", auth.getName()));
    }
}
