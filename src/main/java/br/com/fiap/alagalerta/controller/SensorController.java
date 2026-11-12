package br.com.fiap.alagalerta.controller;

import br.com.fiap.alagalerta.domain.StatusSensor;
import br.com.fiap.alagalerta.dto.SensorDtos.SensorRequest;
import br.com.fiap.alagalerta.dto.SensorDtos.SensorResponse;
import br.com.fiap.alagalerta.hateoas.Assemblers.SensorAssembler;
import br.com.fiap.alagalerta.service.SensorService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.data.domain.Pageable;
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
@RequestMapping("/api/sensores")
@Tag(name = "Sensores", description = "Estações IoT de nível de água e chuva")
public class SensorController {

    private final SensorService service;
    private final SensorAssembler assembler;
    private final PagedResourcesAssembler<SensorResponse> pagedAssembler;

    public SensorController(SensorService service, SensorAssembler assembler,
                            PagedResourcesAssembler<SensorResponse> pagedAssembler) {
        this.service = service;
        this.assembler = assembler;
        this.pagedAssembler = pagedAssembler;
    }

    @GetMapping
    @Operation(summary = "Lista sensores (filtros opcionais: regiaoId, status)")
    public ResponseEntity<PagedModel<EntityModel<SensorResponse>>> listar(
            @RequestParam(required = false) Long regiaoId,
            @RequestParam(required = false) StatusSensor status,
            @PageableDefault(size = 10, sort = "codigo") Pageable pageable) {
        return ResponseEntity.ok(pagedAssembler.toModel(service.listar(regiaoId, status, pageable), assembler));
    }

    @GetMapping("/{id}")
    public ResponseEntity<EntityModel<SensorResponse>> buscar(@PathVariable Long id) {
        return ResponseEntity.ok(assembler.toModel(service.buscar(id)));
    }

    @GetMapping("/silenciosos")
    @Operation(summary = "Sensores ativos sem enviar dados há N minutos (manutenção)")
    public ResponseEntity<CollectionModel<EntityModel<SensorResponse>>> silenciosos(
            @RequestParam(defaultValue = "30") int minutos) {
        return ResponseEntity.ok(assembler.toCollectionModel(service.silenciosos(minutos))
                .add(linkTo(methodOn(SensorController.class).silenciosos(minutos)).withSelfRel()));
    }

    @PostMapping
    @Operation(summary = "Cadastra sensor [ADMIN]")
    public ResponseEntity<EntityModel<SensorResponse>> criar(@RequestBody @Valid SensorRequest req) {
        SensorResponse criado = service.criar(req);
        return ResponseEntity.created(linkTo(methodOn(SensorController.class).buscar(criado.id())).toUri())
                .body(assembler.toModel(criado));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Atualiza sensor, inclusive status [ADMIN]")
    public ResponseEntity<EntityModel<SensorResponse>> atualizar(@PathVariable Long id, @RequestBody @Valid SensorRequest req) {
        return ResponseEntity.ok(assembler.toModel(service.atualizar(id, req)));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Exclui sensor sem histórico [ADMIN]")
    public ResponseEntity<Void> excluir(@PathVariable Long id) {
        service.excluir(id);
        return ResponseEntity.noContent().build();
    }
}
