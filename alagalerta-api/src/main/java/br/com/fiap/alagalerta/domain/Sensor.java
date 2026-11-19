package br.com.fiap.alagalerta.domain;

import jakarta.persistence.*;

import java.time.LocalDateTime;

/**
 * Estação de medição instalada em um córrego ou ponto de alagamento (Arduino + sensor ultrassônico + pluviômetro).
 */
@Entity
@Table(name = "TB_SENSOR")
public class Sensor {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 30)
    private String codigo;

    @Column(nullable = false, length = 150)
    private String localizacao;

    private Double latitude;
    private Double longitude;

    /** Nível da água (cm) a partir do qual a situação vira ALERTA. */
    @Column(name = "nivel_alerta_cm", nullable = false)
    private Integer nivelAlertaCm;

    /** Nível da água (cm) a partir do qual a situação vira EMERGÊNCIA. */
    @Column(name = "nivel_critico_cm", nullable = false)
    private Integer nivelCriticoCm;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private StatusSensor status = StatusSensor.ATIVO;

    @Column(name = "ultima_leitura_em")
    private LocalDateTime ultimaLeituraEm;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "regiao_id", nullable = false)
    private Regiao regiao;

    protected Sensor() {
    }

    public Sensor(String codigo, String localizacao, Double latitude, Double longitude,
                  Integer nivelAlertaCm, Integer nivelCriticoCm, Regiao regiao) {
        this.codigo = codigo;
        this.localizacao = localizacao;
        this.latitude = latitude;
        this.longitude = longitude;
        this.nivelAlertaCm = nivelAlertaCm;
        this.nivelCriticoCm = nivelCriticoCm;
        this.regiao = regiao;
    }

    public void atualizar(String codigo, String localizacao, Double latitude, Double longitude,
                          Integer nivelAlertaCm, Integer nivelCriticoCm, StatusSensor status, Regiao regiao) {
        this.codigo = codigo;
        this.localizacao = localizacao;
        this.latitude = latitude;
        this.longitude = longitude;
        this.nivelAlertaCm = nivelAlertaCm;
        this.nivelCriticoCm = nivelCriticoCm;
        if (status != null) {
            this.status = status;
        }
        this.regiao = regiao;
    }

    public void registrarLeitura(LocalDateTime quando) {
        this.ultimaLeituraEm = quando;
    }

    public Long getId() { return id; }
    public String getCodigo() { return codigo; }
    public String getLocalizacao() { return localizacao; }
    public Double getLatitude() { return latitude; }
    public Double getLongitude() { return longitude; }
    public Integer getNivelAlertaCm() { return nivelAlertaCm; }
    public Integer getNivelCriticoCm() { return nivelCriticoCm; }
    public StatusSensor getStatus() { return status; }
    public LocalDateTime getUltimaLeituraEm() { return ultimaLeituraEm; }
    public Regiao getRegiao() { return regiao; }
}
