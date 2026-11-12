package br.com.fiap.alagalerta.hateoas;

import br.com.fiap.alagalerta.controller.*;
import br.com.fiap.alagalerta.domain.StatusOcorrencia;
import br.com.fiap.alagalerta.dto.AlertaDtos.AlertaResponse;
import br.com.fiap.alagalerta.dto.LeituraDtos.LeituraResponse;
import br.com.fiap.alagalerta.dto.OcorrenciaDtos.OcorrenciaResponse;
import br.com.fiap.alagalerta.dto.RegiaoDtos.RegiaoResponse;
import br.com.fiap.alagalerta.dto.SensorDtos.SensorResponse;
import org.springframework.hateoas.EntityModel;
import org.springframework.hateoas.server.RepresentationModelAssembler;
import org.springframework.stereotype.Component;

import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.linkTo;
import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.methodOn;

/**
 * Montadores HATEOAS: cada recurso volta com links para si mesmo, para os recursos
 * relacionados e para as ações possíveis no estado atual (ex.: "encerrar" só aparece em alerta ativo).
 */
public final class Assemblers {

    private Assemblers() {
    }

    @Component
    public static class RegiaoAssembler implements RepresentationModelAssembler<RegiaoResponse, EntityModel<RegiaoResponse>> {
        @Override
        public EntityModel<RegiaoResponse> toModel(RegiaoResponse r) {
            return EntityModel.of(r,
                    linkTo(methodOn(RegiaoController.class).buscar(r.id())).withSelfRel(),
                    linkTo(methodOn(RegiaoController.class).listar(null, null)).withRel("regioes"),
                    linkTo(methodOn(SensorController.class).listar(r.id(), null, null)).withRel("sensores"),
                    linkTo(methodOn(AlertaController.class).pesquisar(r.id(), null, null, null)).withRel("alertas"),
                    linkTo(methodOn(OcorrenciaController.class).pesquisar(null, null)).withRel("ocorrencias"),
                    linkTo(methodOn(RegiaoController.class).atualizar(r.id(), null)).withRel("atualizar"),
                    linkTo(methodOn(RegiaoController.class).excluir(r.id())).withRel("excluir"));
        }
    }

    @Component
    public static class SensorAssembler implements RepresentationModelAssembler<SensorResponse, EntityModel<SensorResponse>> {
        @Override
        public EntityModel<SensorResponse> toModel(SensorResponse s) {
            return EntityModel.of(s,
                    linkTo(methodOn(SensorController.class).buscar(s.id())).withSelfRel(),
                    linkTo(methodOn(SensorController.class).listar(null, null, null)).withRel("sensores"),
                    linkTo(methodOn(RegiaoController.class).buscar(s.regiaoId())).withRel("regiao"),
                    linkTo(methodOn(LeituraController.class).historico(s.id(), 24, null)).withRel("leituras"),
                    linkTo(methodOn(SensorController.class).atualizar(s.id(), null)).withRel("atualizar"));
        }
    }

    @Component
    public static class LeituraAssembler implements RepresentationModelAssembler<LeituraResponse, EntityModel<LeituraResponse>> {
        @Override
        public EntityModel<LeituraResponse> toModel(LeituraResponse l) {
            EntityModel<LeituraResponse> model = EntityModel.of(l,
                    linkTo(methodOn(LeituraController.class).buscar(l.id())).withSelfRel(),
                    linkTo(methodOn(SensorController.class).buscar(l.sensorId())).withRel("sensor"),
                    linkTo(methodOn(LeituraController.class).historico(l.sensorId(), 24, null)).withRel("historico"));
            if (l.alertaGeradoId() != null) {
                model.add(linkTo(methodOn(AlertaController.class).buscar(l.alertaGeradoId())).withRel("alerta"));
            }
            return model;
        }
    }

    @Component
    public static class AlertaAssembler implements RepresentationModelAssembler<AlertaResponse, EntityModel<AlertaResponse>> {
        @Override
        public EntityModel<AlertaResponse> toModel(AlertaResponse a) {
            EntityModel<AlertaResponse> model = EntityModel.of(a,
                    linkTo(methodOn(AlertaController.class).buscar(a.id())).withSelfRel(),
                    linkTo(methodOn(AlertaController.class).ativos()).withRel("ativos"),
                    linkTo(methodOn(RegiaoController.class).buscar(a.regiaoId())).withRel("regiao"));
            if (a.sensorId() != null) {
                model.add(linkTo(methodOn(SensorController.class).buscar(a.sensorId())).withRel("sensor"));
            }
            if (a.ativo()) {
                model.add(linkTo(methodOn(AlertaController.class).atualizar(a.id(), null)).withRel("atualizar"));
                model.add(linkTo(methodOn(AlertaController.class).encerrar(a.id())).withRel("encerrar"));
            }
            return model;
        }
    }

    @Component
    public static class OcorrenciaAssembler implements RepresentationModelAssembler<OcorrenciaResponse, EntityModel<OcorrenciaResponse>> {
        @Override
        public EntityModel<OcorrenciaResponse> toModel(OcorrenciaResponse o) {
            EntityModel<OcorrenciaResponse> model = EntityModel.of(o,
                    linkTo(methodOn(OcorrenciaController.class).buscar(o.id())).withSelfRel(),
                    linkTo(methodOn(OcorrenciaController.class).pesquisar(null, null)).withRel("ocorrencias"),
                    linkTo(methodOn(RegiaoController.class).buscar(o.regiaoId())).withRel("regiao"));
            boolean finalizada = o.status() == StatusOcorrencia.RESOLVIDA || o.status() == StatusOcorrencia.DESCARTADA;
            if (!finalizada) {
                model.add(linkTo(methodOn(OcorrenciaController.class).alterarStatus(o.id(), null)).withRel("alterar-status"));
            }
            if (o.status() == StatusOcorrencia.ABERTA) {
                model.add(linkTo(methodOn(OcorrenciaController.class).atualizar(o.id(), null, null)).withRel("atualizar"));
            }
            return model;
        }
    }
}
