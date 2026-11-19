package br.com.fiap.alagalerta.dto;

import br.com.fiap.alagalerta.domain.Alerta;
import br.com.fiap.alagalerta.domain.NivelRisco;
import br.com.fiap.alagalerta.domain.OrigemAlerta;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import org.springframework.hateoas.server.core.Relation;

import java.time.LocalDateTime;

public final class AlertaDtos {

    private AlertaDtos() {
    }

    /** Alerta emitido manualmente pela Defesa Civil. */
    public record AlertaRequest(
            @NotNull(message = "regiaoId é obrigatório") Long regiaoId,
            @NotNull(message = "nivel é obrigatório") NivelRisco nivel,
            @NotBlank(message = "mensagem é obrigatória") @Size(min = 10, max = 400) String mensagem) {
    }

    public record AlertaUpdateRequest(
            @NotNull(message = "nivel é obrigatório") NivelRisco nivel,
            @NotBlank(message = "mensagem é obrigatória") @Size(min = 10, max = 400) String mensagem) {
    }

    @Relation(collectionRelation = "alertas", itemRelation = "alerta")
    public record AlertaResponse(Long id, NivelRisco nivel, String mensagem, OrigemAlerta origem, boolean ativo,
                                 LocalDateTime emitidoEm, LocalDateTime encerradoEm,
                                 Long regiaoId, String regiaoNome, Long sensorId) {
        public static AlertaResponse de(Alerta a) {
            return new AlertaResponse(a.getId(), a.getNivel(), a.getMensagem(), a.getOrigem(), a.isAtivo(),
                    a.getEmitidoEm(), a.getEncerradoEm(), a.getRegiao().getId(), a.getRegiao().getNome(),
                    a.getSensor() != null ? a.getSensor().getId() : null);
        }
    }
}
