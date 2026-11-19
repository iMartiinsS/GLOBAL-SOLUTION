package br.com.fiap.alagalerta.domain;

import jakarta.persistence.*;

import java.time.LocalDateTime;

/**
 * Medição enviada pelo dispositivo IoT: nível da água e chuva acumulada na última hora.
 */
@Entity
@Table(name = "TB_LEITURA", indexes = @Index(name = "IX_LEITURA_SENSOR_DATA", columnList = "sensor_id, data_hora"))
public class Leitura {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "nivel_agua_cm", nullable = false)
    private Double nivelAguaCm;

    @Column(name = "chuva_mm_h", nullable = false)
    private Double chuvaMmHora;

    @Column(name = "data_hora", nullable = false)
    private LocalDateTime dataHora;

    @Enumerated(EnumType.STRING)
    @Column(name = "nivel_risco", nullable = false, length = 20)
    private NivelRisco nivelRisco;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "sensor_id", nullable = false)
    private Sensor sensor;

    protected Leitura() {
    }

    public Leitura(Sensor sensor, Double nivelAguaCm, Double chuvaMmHora, LocalDateTime dataHora, NivelRisco nivelRisco) {
        this.sensor = sensor;
        this.nivelAguaCm = nivelAguaCm;
        this.chuvaMmHora = chuvaMmHora;
        this.dataHora = dataHora;
        this.nivelRisco = nivelRisco;
    }

    public Long getId() { return id; }
    public Double getNivelAguaCm() { return nivelAguaCm; }
    public Double getChuvaMmHora() { return chuvaMmHora; }
    public LocalDateTime getDataHora() { return dataHora; }
    public NivelRisco getNivelRisco() { return nivelRisco; }
    public Sensor getSensor() { return sensor; }
}
