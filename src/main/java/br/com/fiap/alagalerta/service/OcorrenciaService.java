package br.com.fiap.alagalerta.service;

import br.com.fiap.alagalerta.domain.Ocorrencia;
import br.com.fiap.alagalerta.domain.Papel;
import br.com.fiap.alagalerta.domain.Regiao;
import br.com.fiap.alagalerta.domain.StatusOcorrencia;
import br.com.fiap.alagalerta.domain.Usuario;
import br.com.fiap.alagalerta.dto.OcorrenciaDtos.OcorrenciaRequest;
import br.com.fiap.alagalerta.dto.OcorrenciaDtos.OcorrenciaResponse;
import br.com.fiap.alagalerta.dto.OcorrenciaFiltro;
import br.com.fiap.alagalerta.exception.RecursoNaoEncontradoException;
import br.com.fiap.alagalerta.exception.RegraNegocioException;
import br.com.fiap.alagalerta.repository.OcorrenciaRepository;
import br.com.fiap.alagalerta.repository.spec.OcorrenciaSpecs;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
public class OcorrenciaService {

    private final OcorrenciaRepository ocorrencias;
    private final RegiaoService regiaoService;
    private final AuthService authService;

    public OcorrenciaService(OcorrenciaRepository ocorrencias, RegiaoService regiaoService, AuthService authService) {
        this.ocorrencias = ocorrencias;
        this.regiaoService = regiaoService;
        this.authService = authService;
    }

    @Transactional(readOnly = true)
    public Page<OcorrenciaResponse> buscar(OcorrenciaFiltro filtro, Pageable pageable) {
        if (filtro.desde() != null && filtro.ate() != null && filtro.desde().isAfter(filtro.ate())) {
            throw new RegraNegocioException("'desde' deve ser anterior a 'ate'", HttpStatus.BAD_REQUEST);
        }
        return ocorrencias.findAll(OcorrenciaSpecs.comFiltro(filtro), pageable).map(OcorrenciaResponse::de);
    }

    @Transactional(readOnly = true)
    public OcorrenciaResponse buscar(Long id) {
        return OcorrenciaResponse.de(entidade(id));
    }

    @Transactional
    public OcorrenciaResponse registrar(OcorrenciaRequest req, Authentication auth) {
        Usuario autor = authService.usuarioLogado(auth);
        Regiao regiao = regiaoService.entidade(req.regiaoId());
        Ocorrencia nova = new Ocorrencia(req.descricao().trim(), req.endereco().trim(), req.alturaAguaCm(),
                req.pessoasAfetadas(), regiao, autor, LocalDateTime.now());
        return OcorrenciaResponse.de(ocorrencias.save(nova));
    }

    /** O próprio autor pode corrigir o relato enquanto ele estiver ABERTO; agentes podem sempre. */
    @Transactional
    public OcorrenciaResponse atualizar(Long id, OcorrenciaRequest req, Authentication auth) {
        Ocorrencia ocorrencia = entidade(id);
        Usuario usuario = authService.usuarioLogado(auth);
        boolean agente = usuario.getPapel() != Papel.CIDADAO;
        boolean autor = ocorrencia.getAutor().getId().equals(usuario.getId());
        if (!agente && !autor) {
            throw new AccessDeniedException("somente o autor ou a Defesa Civil podem alterar");
        }
        if (!agente && ocorrencia.getStatus() != StatusOcorrencia.ABERTA) {
            throw new RegraNegocioException("Ocorrência já está em atendimento e não pode mais ser editada pelo morador");
        }
        ocorrencia.atualizar(req.descricao().trim(), req.endereco().trim(), req.alturaAguaCm(),
                req.pessoasAfetadas(), regiaoService.entidade(req.regiaoId()));
        return OcorrenciaResponse.de(ocorrencia);
    }

    @Transactional
    public OcorrenciaResponse alterarStatus(Long id, StatusOcorrencia novo) {
        Ocorrencia ocorrencia = entidade(id);
        StatusOcorrencia atual = ocorrencia.getStatus();
        boolean finalizada = atual == StatusOcorrencia.RESOLVIDA || atual == StatusOcorrencia.DESCARTADA;
        if (finalizada) {
            throw new RegraNegocioException("Ocorrência já finalizada como " + atual);
        }
        if (novo == StatusOcorrencia.ABERTA) {
            throw new RegraNegocioException("Não é possível voltar uma ocorrência para ABERTA", HttpStatus.UNPROCESSABLE_ENTITY);
        }
        ocorrencia.alterarStatus(novo);
        return OcorrenciaResponse.de(ocorrencia);
    }

    @Transactional
    public void excluir(Long id) {
        ocorrencias.delete(entidade(id));
    }

    private Ocorrencia entidade(Long id) {
        return ocorrencias.findById(id).orElseThrow(() -> new RecursoNaoEncontradoException("Ocorrência", id));
    }
}
