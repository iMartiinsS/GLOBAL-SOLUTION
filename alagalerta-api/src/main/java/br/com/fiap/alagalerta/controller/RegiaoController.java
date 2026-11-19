package br.com.fiap.alagalerta.controller;

import br.com.fiap.alagalerta.dto.RegiaoDtos.RegiaoRequest;
import br.com.fiap.alagalerta.dto.RegiaoDtos.RegiaoResponse;
import br.com.fiap.alagalerta.hateoas.Assemblers.RegiaoAssembler;
import br.com.fiap.alagalerta.service.RegiaoService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.data.web.PagedResourcesAssembler;
import org.springframework.hateoas.EntityModel;
import org.springframework.hateoas.PagedModel;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.linkTo;
import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.methodOn;

@RestController
@RequestMapping("/api/regioes")
@Tag(name = "Regiões", description = "Bairros/áreas monitoradas")
public class RegiaoController {

    private final RegiaoService service;
    private final RegiaoAssembler assembler;
    private final PagedResourcesAssembler<RegiaoResponse> pagedAssembler;

    public RegiaoController(RegiaoService service, RegiaoAssembler assembler,
                            PagedResourcesAssembler<RegiaoResponse> pagedAssembler) {
        this.service = service;
        this.assembler = assembler;
        this.pagedAssembler = pagedAssembler;
    }

    @GetMapping
    @Operation(summary = "Lista regiões (paginado, filtro opcional por cidade)")
    public ResponseEntity<PagedModel<EntityModel<RegiaoResponse>>> listar(
            @RequestParam(required = false) String cidade,
            @PageableDefault(size = 10, sort = "nome", direction = Sort.Direction.ASC) Pageable pageable) {
        return ResponseEntity.ok(pagedAssembler.toModel(service.listar(cidade, pageable), assembler));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Busca região por id (resultado em cache)")
    public ResponseEntity<EntityModel<RegiaoResponse>> buscar(@PathVariable Long id) {
        return ResponseEntity.ok(assembler.toModel(service.buscar(id)));
    }

    @PostMapping
    @Operation(summary = "Cadastra região [ADMIN]")
    public ResponseEntity<EntityModel<RegiaoResponse>> criar(@RequestBody @Valid RegiaoRequest req) {
        RegiaoResponse criada = service.criar(req);
        return ResponseEntity.created(linkTo(methodOn(RegiaoController.class).buscar(criada.id())).toUri())
                .body(assembler.toModel(criada));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Atualiza região [ADMIN]")
    public ResponseEntity<EntityModel<RegiaoResponse>> atualizar(@PathVariable Long id, @RequestBody @Valid RegiaoRequest req) {
        return ResponseEntity.ok(assembler.toModel(service.atualizar(id, req)));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Exclui região sem vínculos [ADMIN]")
    public ResponseEntity<Void> excluir(@PathVariable Long id) {
        service.excluir(id);
        return ResponseEntity.noContent().build();
    }
}
