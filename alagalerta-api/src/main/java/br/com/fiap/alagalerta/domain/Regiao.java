package br.com.fiap.alagalerta.domain;

import jakarta.persistence.*;

import java.util.ArrayList;
import java.util.List;

/**
 * Bairro ou área monitorada. Uma região tem vários sensores e recebe alertas e ocorrências.
 */
@Entity
@Table(name = "TB_REGIAO", uniqueConstraints = @UniqueConstraint(columnNames = {"nome", "cidade"}))
public class Regiao {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100)
    private String nome;

    @Column(nullable = false, length = 100)
    private String cidade;

    @Column(nullable = false, length = 2)
    private String uf;

    /** Quantidade estimada de moradores em área de risco — base para medir impacto. */
    @Column(name = "populacao_risco")
    private Integer populacaoRisco;

    /*
     * Sem cascade de remoção de propósito: sensores carregam histórico de leituras e alertas.
     * Excluir uma região com sensores é bloqueado na camada de serviço (409).
     */
    @OneToMany(mappedBy = "regiao")
    private List<Sensor> sensores = new ArrayList<>();

    protected Regiao() {
    }

    public Regiao(String nome, String cidade, String uf, Integer populacaoRisco) {
        this.nome = nome;
        this.cidade = cidade;
        this.uf = uf;
        this.populacaoRisco = populacaoRisco;
    }

    public void atualizar(String nome, String cidade, String uf, Integer populacaoRisco) {
        this.nome = nome;
        this.cidade = cidade;
        this.uf = uf;
        this.populacaoRisco = populacaoRisco;
    }

    public Long getId() { return id; }
    public String getNome() { return nome; }
    public String getCidade() { return cidade; }
    public String getUf() { return uf; }
    public Integer getPopulacaoRisco() { return populacaoRisco; }
    public List<Sensor> getSensores() { return sensores; }
}
