package br.com.fiap.alagalerta.controller;

import br.com.fiap.alagalerta.dto.LeituraDtos.LeituraRequest;
import br.com.fiap.alagalerta.dto.LeituraDtos.LeituraResponse;
import br.com.fiap.alagalerta.dto.ResumoRegiaoResponse;
import br.com.fiap.alagalerta.hateoas.Assemblers.LeituraAssembler;
import br.com.fiap.alagalerta.service.LeituraService;
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

import java.util.List;

import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.linkTo;
import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.methodOn;

@RestController
@RequestMapping("/api/leituras")
@Tag(name = "Leituras", description = "Medições enviadas pelos dispositivos IoT")
public class LeituraController {

    private final LeituraService service;
    private final LeituraAssembler assembler;
    private final PagedResourcesAssembler<LeituraResponse> pagedAssembler;

    public LeituraController(LeituraService service, LeituraAssembler assembler,
                             PagedResourcesAssembler<LeituraResponse> pagedAssembler) {
        this.service = service;
        this.assembler = assembler;
        this.pagedAssembler = pagedAssembler;
    }

    @PostMapping
    @Operation(summary = "Registra leitura e gera/eleva alerta automaticamente [AGENTE, ADMIN — gateway IoT]")
    public ResponseEntity<EntityModel<LeituraResponse>> registrar(@RequestBody @Valid LeituraRequest req) {
        LeituraResponse criada = service.registrar(req);
        return ResponseEntity.created(linkTo(methodOn(LeituraController.class).buscar(criada.id())).toUri())
                .body(assembler.toModel(criada));
    }

    @GetMapping("/{id}")
    public ResponseEntity<EntityModel<LeituraResponse>> buscar(@PathVariable Long id) {
        return ResponseEntity.ok(assembler.toModel(service.buscar(id)));
    }

    @GetMapping("/sensor/{sensorId}")
    @Operation(summary = "Histórico de um sensor nas últimas N horas (paginado)")
    public ResponseEntity<PagedModel<EntityModel<LeituraResponse>>> historico(
            @PathVariable Long sensorId,
            @RequestParam(defaultValue = "24") int horas,
            @PageableDefault(size = 50, sort = "dataHora", direction = Sort.Direction.DESC) Pageable pageable) {
        return ResponseEntity.ok(pagedAssembler.toModel(service.historico(sensorId, horas, pageable), assembler));
    }

    @GetMapping("/resumo")
    @Operation(summary = "Nível máximo, chuva média e total de leituras por região (painel da Defesa Civil)")
    public ResponseEntity<List<ResumoRegiaoResponse>> resumo(@RequestParam(defaultValue = "24") int horas) {
        return ResponseEntity.ok(service.resumo(horas));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Remove leitura espúria [ADMIN]")
    public ResponseEntity<Void> excluir(@PathVariable Long id) {
        service.excluir(id);
        return ResponseEntity.noContent().build();
    }
}
