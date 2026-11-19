package br.com.fiap.alagalerta.domain;

import jakarta.persistence.*;

import java.time.LocalDateTime;

/**
 * Relato de um morador: rua alagada, água entrando em casa, pessoa ilhada etc.
 * Complementa os sensores onde não há estação instalada.
 */
@Entity
@Table(name = "TB_OCORRENCIA")
public class Ocorrencia {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 500)
    private String descricao;

    @Column(nullable = false, length = 200)
    private String endereco;

    /** Altura aproximada da água informada pelo morador (cm). */
    @Column(name = "altura_agua_cm")
    private Integer alturaAguaCm;

    @Column(name = "pessoas_afetadas")
    private Integer pessoasAfetadas;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private StatusOcorrencia status = StatusOcorrencia.ABERTA;

    @Column(name = "registrada_em", nullable = false)
    private LocalDateTime registradaEm;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "regiao_id", nullable = false)
    private Regiao regiao;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "usuario_id", nullable = false)
    private Usuario autor;

    protected Ocorrencia() {
    }

    public Ocorrencia(String descricao, String endereco, Integer alturaAguaCm, Integer pessoasAfetadas,
                      Regiao regiao, Usuario autor, LocalDateTime registradaEm) {
        this.descricao = descricao;
        this.endereco = endereco;
        this.alturaAguaCm = alturaAguaCm;
        this.pessoasAfetadas = pessoasAfetadas;
        this.regiao = regiao;
        this.autor = autor;
        this.registradaEm = registradaEm;
    }

    public void atualizar(String descricao, String endereco, Integer alturaAguaCm, Integer pessoasAfetadas, Regiao regiao) {
        this.descricao = descricao;
        this.endereco = endereco;
        this.alturaAguaCm = alturaAguaCm;
        this.pessoasAfetadas = pessoasAfetadas;
        this.regiao = regiao;
    }

    public void alterarStatus(StatusOcorrencia novo) {
        this.status = novo;
    }

    public Long getId() { return id; }
    public String getDescricao() { return descricao; }
    public String getEndereco() { return endereco; }
    public Integer getAlturaAguaCm() { return alturaAguaCm; }
    public Integer getPessoasAfetadas() { return pessoasAfetadas; }
    public StatusOcorrencia getStatus() { return status; }
    public LocalDateTime getRegistradaEm() { return registradaEm; }
    public Regiao getRegiao() { return regiao; }
    public Usuario getAutor() { return autor; }
}
