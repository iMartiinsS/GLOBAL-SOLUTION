package br.com.fiap.alagalerta.controller;

import br.com.fiap.alagalerta.dto.OcorrenciaDtos.OcorrenciaRequest;
import br.com.fiap.alagalerta.dto.OcorrenciaDtos.OcorrenciaResponse;
import br.com.fiap.alagalerta.dto.OcorrenciaDtos.OcorrenciaStatusRequest;
import br.com.fiap.alagalerta.dto.OcorrenciaFiltro;
import br.com.fiap.alagalerta.hateoas.Assemblers.OcorrenciaAssembler;
import br.com.fiap.alagalerta.service.OcorrenciaService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.data.web.PagedResourcesAssembler;
import org.springframework.hateoas.EntityModel;
import org.springframework.hateoas.PagedModel;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.linkTo;
import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.methodOn;

@RestController
@RequestMapping("/api/ocorrencias")
@Tag(name = "Ocorrências", description = "Relatos de alagamento enviados pelos moradores")
public class OcorrenciaController {

    private final OcorrenciaService service;
    private final OcorrenciaAssembler assembler;
    private final PagedResourcesAssembler<OcorrenciaResponse> pagedAssembler;

    public OcorrenciaController(OcorrenciaService service, OcorrenciaAssembler assembler,
                                PagedResourcesAssembler<OcorrenciaResponse> pagedAssembler) {
        this.service = service;
        this.assembler = assembler;
        this.pagedAssembler = pagedAssembler;
    }

    @GetMapping
    @Operation(summary = "Pesquisa com filtros dinâmicos (Specification): status, regiaoId, desde, ate, alturaMinimaCm, texto")
    public ResponseEntity<PagedModel<EntityModel<OcorrenciaResponse>>> pesquisar(
            @Parameter(description = "Filtros opcionais, combináveis") OcorrenciaFiltro filtro,
            @PageableDefault(size = 10, sort = "registradaEm", direction = Sort.Direction.DESC) Pageable pageable) {
        return ResponseEntity.ok(pagedAssembler.toModel(service.buscar(filtro, pageable), assembler));
    }

    @GetMapping("/{id}")
    public ResponseEntity<EntityModel<OcorrenciaResponse>> buscar(@PathVariable Long id) {
        return ResponseEntity.ok(assembler.toModel(service.buscar(id)));
    }

    @PostMapping
    @Operation(summary = "Registra ocorrência (qualquer usuário logado)")
    public ResponseEntity<EntityModel<OcorrenciaResponse>> registrar(@RequestBody @Valid OcorrenciaRequest req,
                                                                     Authentication auth) {
        OcorrenciaResponse criada = service.registrar(req, auth);
        return ResponseEntity.created(linkTo(methodOn(OcorrenciaController.class).buscar(criada.id())).toUri())
                .body(assembler.toModel(criada));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Corrige relato (autor enquanto ABERTA, ou agente)")
    public ResponseEntity<EntityModel<OcorrenciaResponse>> atualizar(@PathVariable Long id,
                                                                     @RequestBody @Valid OcorrenciaRequest req,
                                                                     Authentication auth) {
        return ResponseEntity.ok(assembler.toModel(service.atualizar(id, req, auth)));
    }

    @PatchMapping("/{id}/status")
    @Operation(summary = "Muda status do atendimento [AGENTE, ADMIN]")
    public ResponseEntity<EntityModel<OcorrenciaResponse>> alterarStatus(@PathVariable Long id,
                                                                         @RequestBody @Valid OcorrenciaStatusRequest req) {
        return ResponseEntity.ok(assembler.toModel(service.alterarStatus(id, req.status())));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Exclui ocorrência [ADMIN]")
    public ResponseEntity<Void> excluir(@PathVariable Long id) {
        service.excluir(id);
        return ResponseEntity.noContent().build();
    }
}
