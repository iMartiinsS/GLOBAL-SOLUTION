package br.com.fiap.alagalerta.service;

import br.com.fiap.alagalerta.domain.Leitura;
import br.com.fiap.alagalerta.domain.NivelRisco;
import br.com.fiap.alagalerta.domain.Sensor;
import br.com.fiap.alagalerta.domain.StatusSensor;
import br.com.fiap.alagalerta.dto.LeituraDtos.LeituraRequest;
import br.com.fiap.alagalerta.dto.LeituraDtos.LeituraResponse;
import br.com.fiap.alagalerta.dto.ResumoRegiaoResponse;
import br.com.fiap.alagalerta.exception.RecursoNaoEncontradoException;
import br.com.fiap.alagalerta.exception.RegraNegocioException;
import br.com.fiap.alagalerta.repository.LeituraRepository;
import br.com.fiap.alagalerta.repository.SensorRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class LeituraService {

    private final LeituraRepository leituras;
    private final SensorRepository sensores;
    private final ClassificadorRisco classificador;
    private final AlertaService alertaService;

    public LeituraService(LeituraRepository leituras, SensorRepository sensores,
                          ClassificadorRisco classificador, AlertaService alertaService) {
        this.leituras = leituras;
        this.sensores = sensores;
        this.classificador = classificador;
        this.alertaService = alertaService;
    }

    /**
     * Fluxo principal da solução: recebe a medição do dispositivo, classifica o risco,
     * grava a leitura e, se necessário, gera ou eleva o alerta da região.
     */
    @Transactional
    public LeituraResponse registrar(LeituraRequest req) {
        Sensor sensor = sensores.findByCodigo(req.codigoSensor())
                .orElseThrow(() -> new RecursoNaoEncontradoException("Sensor", req.codigoSensor()));
        if (sensor.getStatus() != StatusSensor.ATIVO) {
            throw new RegraNegocioException("Sensor " + sensor.getCodigo() + " está " + sensor.getStatus()
                    + " e não aceita leituras", HttpStatus.UNPROCESSABLE_ENTITY);
        }
        LocalDateTime quando = req.dataHora() != null ? req.dataHora() : LocalDateTime.now();
        NivelRisco nivel = classificador.classificar(sensor, req.nivelAguaCm(), req.chuvaMmHora());

        Leitura leitura = leituras.save(new Leitura(sensor, req.nivelAguaCm(), req.chuvaMmHora(), quando, nivel));
        if (sensor.getUltimaLeituraEm() == null || quando.isAfter(sensor.getUltimaLeituraEm())) {
            sensor.registrarLeitura(quando);
        }

        Long alertaId = alertaService
                .emitirAutomatico(sensor, nivel, classificador.mensagemPadrao(nivel, sensor, req.nivelAguaCm()))
                .orElse(null);
        return LeituraResponse.de(leitura, alertaId);
    }

    @Transactional(readOnly = true)
    public Page<LeituraResponse> historico(Long sensorId, int horas, Pageable pageable) {
        if (!sensores.existsById(sensorId)) {
            throw new RecursoNaoEncontradoException("Sensor", sensorId);
        }
        return leituras.buscarHistorico(sensorId, LocalDateTime.now().minusHours(horas), pageable)
                .map(LeituraResponse::de);
    }

    @Transactional(readOnly = true)
    public LeituraResponse buscar(Long id) {
        return leituras.findById(id).map(LeituraResponse::de)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Leitura", id));
    }

    @Transactional(readOnly = true)
    public List<ResumoRegiaoResponse> resumo(int horas) {
        return leituras.resumoPorRegiao(LocalDateTime.now().minusHours(horas));
    }

    @Transactional
    public void excluir(Long id) {
        if (!leituras.existsById(id)) {
            throw new RecursoNaoEncontradoException("Leitura", id);
        }
        leituras.deleteById(id);
    }
}
