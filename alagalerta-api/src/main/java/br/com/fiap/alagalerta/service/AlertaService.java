package br.com.fiap.alagalerta.service;

import br.com.fiap.alagalerta.domain.*;
import br.com.fiap.alagalerta.dto.AlertaDtos.AlertaRequest;
import br.com.fiap.alagalerta.dto.AlertaDtos.AlertaResponse;
import br.com.fiap.alagalerta.dto.AlertaDtos.AlertaUpdateRequest;
import br.com.fiap.alagalerta.exception.RecursoNaoEncontradoException;
import br.com.fiap.alagalerta.exception.RegraNegocioException;
import br.com.fiap.alagalerta.repository.AlertaRepository;
import br.com.fiap.alagalerta.repository.spec.AlertaSpecs;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class AlertaService {

    private final AlertaRepository alertas;
    private final RegiaoService regiaoService;

    public AlertaService(AlertaRepository alertas, RegiaoService regiaoService) {
        this.alertas = alertas;
        this.regiaoService = regiaoService;
    }

    /**
     * Cache: é a rota mais acessada (tela inicial do app de todos os moradores, pública).
     * Durante uma chuva forte milhares de pessoas consultam ao mesmo tempo; o cache evita
     * bater no banco a cada abertura do app. Toda escrita em alertas invalida este cache.
     */
    @Cacheable("alertasAtivos")
    @Transactional(readOnly = true)
    public List<AlertaResponse> listarAtivos() {
        return alertas.findByAtivoTrueOrderByEmitidoEmDesc().stream().map(AlertaResponse::de).toList();
    }

    @Transactional(readOnly = true)
    public Page<AlertaResponse> buscar(Long regiaoId, NivelRisco nivelMinimo, Boolean ativo, Pageable pageable) {
        return alertas.findAll(AlertaSpecs.comFiltro(regiaoId, nivelMinimo, ativo), pageable).map(AlertaResponse::de);
    }

    @Transactional(readOnly = true)
    public AlertaResponse buscar(Long id) {
        return AlertaResponse.de(entidade(id));
    }

    @CacheEvict(value = "alertasAtivos", allEntries = true)
    @Transactional
    public AlertaResponse emitirManual(AlertaRequest req) {
        if (req.nivel() == NivelRisco.NORMAL) {
            throw new RegraNegocioException("Não é possível emitir alerta com nível NORMAL", HttpStatus.UNPROCESSABLE_ENTITY);
        }
        Regiao regiao = regiaoService.entidade(req.regiaoId());
        Alerta alerta = new Alerta(regiao, null, req.nivel(), req.mensagem().trim(), OrigemAlerta.DEFESA_CIVIL, LocalDateTime.now());
        return AlertaResponse.de(alertas.save(alerta));
    }

    /**
     * Chamado pelo processamento de leituras. Se já existe alerta ativo na região, só eleva o nível
     * (nunca rebaixa automaticamente — quem encerra é a Defesa Civil). Devolve o id do alerta afetado.
     */
    @CacheEvict(value = "alertasAtivos", allEntries = true)
    @Transactional
    public Optional<Long> emitirAutomatico(Sensor sensor, NivelRisco nivel, String mensagem) {
        if (nivel == NivelRisco.NORMAL) {
            return Optional.empty();
        }
        Optional<Alerta> vigente = alertas.findFirstByRegiaoIdAndAtivoTrueOrderByEmitidoEmDesc(sensor.getRegiao().getId());
        if (vigente.isPresent()) {
            Alerta atual = vigente.get();
            if (nivel.maiorQue(atual.getNivel())) {
                atual.atualizar(nivel, mensagem);
                return Optional.of(atual.getId());
            }
            return Optional.empty();
        }
        Alerta novo = new Alerta(sensor.getRegiao(), sensor, nivel, mensagem, OrigemAlerta.SENSOR, LocalDateTime.now());
        return Optional.of(alertas.save(novo).getId());
    }

    @CacheEvict(value = "alertasAtivos", allEntries = true)
    @Transactional
    public AlertaResponse atualizar(Long id, AlertaUpdateRequest req) {
        Alerta alerta = entidade(id);
        if (!alerta.isAtivo()) {
            throw new RegraNegocioException("Alerta já encerrado não pode ser alterado");
        }
        if (req.nivel() == NivelRisco.NORMAL) {
            throw new RegraNegocioException("Para normalizar a situação, encerre o alerta", HttpStatus.UNPROCESSABLE_ENTITY);
        }
        alerta.atualizar(req.nivel(), req.mensagem().trim());
        return AlertaResponse.de(alerta);
    }

    @CacheEvict(value = "alertasAtivos", allEntries = true)
    @Transactional
    public AlertaResponse encerrar(Long id) {
        Alerta alerta = entidade(id);
        if (!alerta.isAtivo()) {
            throw new RegraNegocioException("Alerta já está encerrado");
        }
        alerta.encerrar(LocalDateTime.now());
        return AlertaResponse.de(alerta);
    }

    @CacheEvict(value = "alertasAtivos", allEntries = true)
    @Transactional
    public void excluir(Long id) {
        alertas.delete(entidade(id));
    }

    private Alerta entidade(Long id) {
        return alertas.findById(id).orElseThrow(() -> new RecursoNaoEncontradoException("Alerta", id));
    }
}
