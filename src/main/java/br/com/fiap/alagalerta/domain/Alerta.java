package br.com.fiap.alagalerta.domain;

import jakarta.persistence.*;

import java.time.LocalDateTime;

/**
 * Aviso enviado à população de uma região. Pode ser gerado automaticamente por uma leitura
 * ou emitido manualmente por um agente da Defesa Civil.
 */
@Entity
@Table(name = "TB_ALERTA")
public class Alerta {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private NivelRisco nivel;

    @Column(nullable = false, length = 400)
    private String mensagem;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private OrigemAlerta origem;

    @Column(nullable = false)
    private boolean ativo = true;

    @Column(name = "emitido_em", nullable = false)
    private LocalDateTime emitidoEm;

    @Column(name = "encerrado_em")
    private LocalDateTime encerradoEm;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "regiao_id", nullable = false)
    private Regiao regiao;

    /** Sensor que disparou o alerta (nulo quando emitido manualmente). */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "sensor_id")
    private Sensor sensor;

    protected Alerta() {
    }

    public Alerta(Regiao regiao, Sensor sensor, NivelRisco nivel, String mensagem, OrigemAlerta origem, LocalDateTime emitidoEm) {
        this.regiao = regiao;
        this.sensor = sensor;
        this.nivel = nivel;
        this.mensagem = mensagem;
        this.origem = origem;
        this.emitidoEm = emitidoEm;
    }

    public void atualizar(NivelRisco nivel, String mensagem) {
        this.nivel = nivel;
        this.mensagem = mensagem;
    }

    public void encerrar(LocalDateTime quando) {
        this.ativo = false;
        this.encerradoEm = quando;
    }

    public Long getId() { return id; }
    public NivelRisco getNivel() { return nivel; }
    public String getMensagem() { return mensagem; }
    public OrigemAlerta getOrigem() { return origem; }
    public boolean isAtivo() { return ativo; }
    public LocalDateTime getEmitidoEm() { return emitidoEm; }
    public LocalDateTime getEncerradoEm() { return encerradoEm; }
    public Regiao getRegiao() { return regiao; }
    public Sensor getSensor() { return sensor; }
}
