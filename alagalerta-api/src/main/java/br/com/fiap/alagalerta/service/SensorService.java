package br.com.fiap.alagalerta.service;

import br.com.fiap.alagalerta.domain.Regiao;
import br.com.fiap.alagalerta.domain.Sensor;
import br.com.fiap.alagalerta.domain.StatusSensor;
import br.com.fiap.alagalerta.dto.SensorDtos.SensorRequest;
import br.com.fiap.alagalerta.dto.SensorDtos.SensorResponse;
import br.com.fiap.alagalerta.exception.RecursoNaoEncontradoException;
import br.com.fiap.alagalerta.exception.RegraNegocioException;
import br.com.fiap.alagalerta.repository.AlertaRepository;
import br.com.fiap.alagalerta.repository.LeituraRepository;
import br.com.fiap.alagalerta.repository.SensorRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class SensorService {

    private final SensorRepository sensores;
    private final LeituraRepository leituras;
    private final AlertaRepository alertas;
    private final RegiaoService regiaoService;

    public SensorService(SensorRepository sensores, LeituraRepository leituras,
                         AlertaRepository alertas, RegiaoService regiaoService) {
        this.sensores = sensores;
        this.leituras = leituras;
        this.alertas = alertas;
        this.regiaoService = regiaoService;
    }

    @Transactional(readOnly = true)
    public Page<SensorResponse> listar(Long regiaoId, StatusSensor status, Pageable pageable) {
        Page<Sensor> pagina;
        if (regiaoId != null && status != null) {
            pagina = sensores.findByRegiaoIdAndStatus(regiaoId, status, pageable);
        } else if (regiaoId != null) {
            pagina = sensores.findByRegiaoId(regiaoId, pageable);
        } else {
            pagina = sensores.findAll(pageable);
        }
        return pagina.map(SensorResponse::de);
    }

    @Transactional(readOnly = true)
    public SensorResponse buscar(Long id) {
        return SensorResponse.de(entidade(id));
    }

    @Transactional(readOnly = true)
    public List<SensorResponse> silenciosos(int minutos) {
        return sensores.buscarSensoresSilenciosos(LocalDateTime.now().minusMinutes(minutos))
                .stream().map(SensorResponse::de).toList();
    }

    @Transactional
    public SensorResponse criar(SensorRequest req) {
        if (sensores.existsByCodigo(req.codigo())) {
            throw new RegraNegocioException("Já existe sensor com o código " + req.codigo());
        }
        Regiao regiao = regiaoService.entidade(req.regiaoId());
        Sensor sensor = new Sensor(req.codigo(), req.localizacao().trim(), req.latitude(), req.longitude(),
                req.nivelAlertaCm(), req.nivelCriticoCm(), regiao);
        if (req.status() != null) {
            sensor.atualizar(req.codigo(), req.localizacao().trim(), req.latitude(), req.longitude(),
                    req.nivelAlertaCm(), req.nivelCriticoCm(), req.status(), regiao);
        }
        return SensorResponse.de(sensores.save(sensor));
    }

    @Transactional
    public SensorResponse atualizar(Long id, SensorRequest req) {
        Sensor sensor = entidade(id);
        if (!sensor.getCodigo().equals(req.codigo()) && sensores.existsByCodigo(req.codigo())) {
            throw new RegraNegocioException("Já existe sensor com o código " + req.codigo());
        }
        Regiao regiao = regiaoService.entidade(req.regiaoId());
        sensor.atualizar(req.codigo(), req.localizacao().trim(), req.latitude(), req.longitude(),
                req.nivelAlertaCm(), req.nivelCriticoCm(), req.status(), regiao);
        return SensorResponse.de(sensor);
    }

    @Transactional
    public void excluir(Long id) {
        Sensor sensor = entidade(id);
        if (leituras.existsBySensorId(id) || alertas.existsBySensorId(id)) {
            throw new RegraNegocioException("Sensor possui histórico de leituras/alertas. Altere o status para INATIVO em vez de excluir");
        }
        sensores.delete(sensor);
    }

    private Sensor entidade(Long id) {
        return sensores.findById(id).orElseThrow(() -> new RecursoNaoEncontradoException("Sensor", id));
    }
}
