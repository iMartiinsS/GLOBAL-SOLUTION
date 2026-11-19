package br.com.fiap.alagalerta.service;

import br.com.fiap.alagalerta.domain.Regiao;
import br.com.fiap.alagalerta.dto.RegiaoDtos.RegiaoRequest;
import br.com.fiap.alagalerta.dto.RegiaoDtos.RegiaoResponse;
import br.com.fiap.alagalerta.exception.RecursoNaoEncontradoException;
import br.com.fiap.alagalerta.exception.RegraNegocioException;
import br.com.fiap.alagalerta.repository.AlertaRepository;
import br.com.fiap.alagalerta.repository.OcorrenciaRepository;
import br.com.fiap.alagalerta.repository.RegiaoRepository;
import br.com.fiap.alagalerta.repository.SensorRepository;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.cache.annotation.Caching;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class RegiaoService {

    private final RegiaoRepository regioes;
    private final SensorRepository sensores;
    private final AlertaRepository alertas;
    private final OcorrenciaRepository ocorrencias;

    public RegiaoService(RegiaoRepository regioes, SensorRepository sensores,
                         AlertaRepository alertas, OcorrenciaRepository ocorrencias) {
        this.regioes = regioes;
        this.sensores = sensores;
        this.alertas = alertas;
        this.ocorrencias = ocorrencias;
    }

    @Transactional(readOnly = true)
    public Page<RegiaoResponse> listar(String cidade, Pageable pageable) {
        Page<Regiao> pagina = (cidade == null || cidade.isBlank())
                ? regioes.findAll(pageable)
                : regioes.findByCidadeIgnoreCase(cidade.trim(), pageable);
        return pagina.map(RegiaoResponse::de);
    }

    /**
     * Cache: regiões quase nunca mudam e são lidas o tempo todo (cada alerta, sensor e
     * ocorrência exibe a região). O cache é invalidado em atualizar/excluir.
     */
    @Cacheable(value = "regioes", key = "#id")
    @Transactional(readOnly = true)
    public RegiaoResponse buscar(Long id) {
        return RegiaoResponse.de(entidade(id));
    }

    @Transactional
    public RegiaoResponse criar(RegiaoRequest req) {
        validarDuplicidade(req, null);
        Regiao nova = new Regiao(req.nome().trim(), req.cidade().trim(), req.uf(), req.populacaoRisco());
        return RegiaoResponse.de(regioes.save(nova));
    }

    @Caching(evict = {
            @CacheEvict(value = "regioes", key = "#id"),
            @CacheEvict(value = "alertasAtivos", allEntries = true)})
    @Transactional
    public RegiaoResponse atualizar(Long id, RegiaoRequest req) {
        Regiao regiao = entidade(id);
        validarDuplicidade(req, regiao);
        regiao.atualizar(req.nome().trim(), req.cidade().trim(), req.uf(), req.populacaoRisco());
        return RegiaoResponse.de(regiao);
    }

    @CacheEvict(value = "regioes", key = "#id")
    @Transactional
    public void excluir(Long id) {
        Regiao regiao = entidade(id);
        if (sensores.existsByRegiaoId(id) || alertas.existsByRegiaoId(id) || ocorrencias.existsByRegiaoId(id)) {
            throw new RegraNegocioException("Região possui sensores, alertas ou ocorrências vinculados e não pode ser excluída");
        }
        regioes.delete(regiao);
    }

    @Transactional(readOnly = true)
    public Regiao entidade(Long id) {
        return regioes.findById(id).orElseThrow(() -> new RecursoNaoEncontradoException("Região", id));
    }

    private void validarDuplicidade(RegiaoRequest req, Regiao atual) {
        boolean mesmoNome = atual != null
                && atual.getNome().equalsIgnoreCase(req.nome().trim())
                && atual.getCidade().equalsIgnoreCase(req.cidade().trim());
        if (!mesmoNome && regioes.existsByNomeIgnoreCaseAndCidadeIgnoreCase(req.nome().trim(), req.cidade().trim())) {
            throw new RegraNegocioException("Já existe a região '" + req.nome() + "' em " + req.cidade());
        }
    }
}
