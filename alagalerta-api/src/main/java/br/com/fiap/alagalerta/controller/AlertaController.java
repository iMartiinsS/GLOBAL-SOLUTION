package br.com.fiap.alagalerta.controller;

import br.com.fiap.alagalerta.domain.NivelRisco;
import br.com.fiap.alagalerta.dto.AlertaDtos.AlertaRequest;
import br.com.fiap.alagalerta.dto.AlertaDtos.AlertaResponse;
import br.com.fiap.alagalerta.dto.AlertaDtos.AlertaUpdateRequest;
import br.com.fiap.alagalerta.hateoas.Assemblers.AlertaAssembler;
import br.com.fiap.alagalerta.service.AlertaService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.data.web.PagedResourcesAssembler;
import org.springframework.hateoas.CollectionModel;
import org.springframework.hateoas.EntityModel;
import org.springframework.hateoas.PagedModel;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.linkTo;
import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.methodOn;

@RestController
@RequestMapping("/api/alertas")
@Tag(name = "Alertas", description = "Avisos de risco de enchente à população")
public class AlertaController {

    private final AlertaService service;
    private final AlertaAssembler assembler;
    private final PagedResourcesAssembler<AlertaResponse> pagedAssembler;

    public AlertaController(AlertaService service, AlertaAssembler assembler,
                            PagedResourcesAssembler<AlertaResponse> pagedAssembler) {
        this.service = service;
        this.assembler = assembler;
        this.pagedAssembler = pagedAssembler;
    }

    @GetMapping("/ativos")
    @Operation(summary = "Alertas em vigor — público e em cache (tela inicial do app)")
    public ResponseEntity<CollectionModel<EntityModel<AlertaResponse>>> ativos() {
        return ResponseEntity.ok(assembler.toCollectionModel(service.listarAtivos())
                .add(linkTo(methodOn(AlertaController.class).ativos()).withSelfRel()));
    }

    @GetMapping
    @Operation(summary = "Pesquisa alertas por região, nível mínimo e situação (paginado)")
    public ResponseEntity<PagedModel<EntityModel<AlertaResponse>>> pesquisar(
            @RequestParam(required = false) Long regiaoId,
            @RequestParam(required = false) NivelRisco nivelMinimo,
            @RequestParam(required = false) Boolean ativo,
            @PageableDefault(size = 10, sort = "emitidoEm", direction = Sort.Direction.DESC) Pageable pageable) {
        return ResponseEntity.ok(pagedAssembler.toModel(service.buscar(regiaoId, nivelMinimo, ativo, pageable), assembler));
    }

    @GetMapping("/{id}")
    public ResponseEntity<EntityModel<AlertaResponse>> buscar(@PathVariable Long id) {
        return ResponseEntity.ok(assembler.toModel(service.buscar(id)));
    }

    @PostMapping
    @Operation(summary = "Emite alerta manual [AGENTE, ADMIN]")
    public ResponseEntity<EntityModel<AlertaResponse>> emitir(@RequestBody @Valid AlertaRequest req) {
        AlertaResponse criado = service.emitirManual(req);
        return ResponseEntity.created(linkTo(methodOn(AlertaController.class).buscar(criado.id())).toUri())
                .body(assembler.toModel(criado));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Altera nível/mensagem de alerta ativo [AGENTE, ADMIN]")
    public ResponseEntity<EntityModel<AlertaResponse>> atualizar(@PathVariable Long id, @RequestBody @Valid AlertaUpdateRequest req) {
        return ResponseEntity.ok(assembler.toModel(service.atualizar(id, req)));
    }

    @PatchMapping("/{id}/encerrar")
    @Operation(summary = "Encerra alerta (situação normalizada) [AGENTE, ADMIN]")
    public ResponseEntity<EntityModel<AlertaResponse>> encerrar(@PathVariable Long id) {
        return ResponseEntity.ok(assembler.toModel(service.encerrar(id)));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Exclui alerta emitido por engano [ADMIN]")
    public ResponseEntity<Void> excluir(@PathVariable Long id) {
        service.excluir(id);
        return ResponseEntity.noContent().build();
    }
}
