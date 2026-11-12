package br.com.fiap.alagalerta.domain;

import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "TB_USUARIO")
public class Usuario {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100)
    private String nome;

    @Column(nullable = false, unique = true, length = 120)
    private String email;

    /** Hash BCrypt — a senha em texto puro nunca é gravada. */
    @Column(name = "senha_hash", nullable = false, length = 100)
    private String senhaHash;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private Papel papel;

    /** Região onde o morador vive — usada para filtrar os alertas no app. */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "regiao_id")
    private Regiao regiao;

    @Column(name = "criado_em", nullable = false)
    private LocalDateTime criadoEm;

    protected Usuario() {
    }

    public Usuario(String nome, String email, String senhaHash, Papel papel, Regiao regiao) {
        this.nome = nome;
        this.email = email;
        this.senhaHash = senhaHash;
        this.papel = papel;
        this.regiao = regiao;
        this.criadoEm = LocalDateTime.now();
    }

    public Long getId() { return id; }
    public String getNome() { return nome; }
    public String getEmail() { return email; }
    public String getSenhaHash() { return senhaHash; }
    public Papel getPapel() { return papel; }
    public Regiao getRegiao() { return regiao; }
    public LocalDateTime getCriadoEm() { return criadoEm; }
}
