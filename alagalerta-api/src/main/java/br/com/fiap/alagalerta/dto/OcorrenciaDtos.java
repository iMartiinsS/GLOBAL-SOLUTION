package br.com.fiap.alagalerta.dto;

import br.com.fiap.alagalerta.domain.Ocorrencia;
import br.com.fiap.alagalerta.domain.StatusOcorrencia;
import jakarta.validation.constraints.*;
import org.springframework.hateoas.server.core.Relation;

import java.time.LocalDateTime;

public final class OcorrenciaDtos {

    private OcorrenciaDtos() {
    }

    public record OcorrenciaRequest(
            @NotBlank(message = "descricao é obrigatória") @Size(min = 10, max = 500) String descricao,
            @NotBlank(message = "endereco é obrigatório") @Size(max = 200) String endereco,
            @PositiveOrZero @Max(value = 500, message = "alturaAguaCm deve ser no máximo 500") Integer alturaAguaCm,
            @PositiveOrZero Integer pessoasAfetadas,
            @NotNull(message = "regiaoId é obrigatório") Long regiaoId) {
    }

    public record OcorrenciaStatusRequest(@NotNull(message = "status é obrigatório") StatusOcorrencia status) {
    }

    @Relation(collectionRelation = "ocorrencias", itemRelation = "ocorrencia")
    public record OcorrenciaResponse(Long id, String descricao, String endereco, Integer alturaAguaCm,
                                     Integer pessoasAfetadas, StatusOcorrencia status, LocalDateTime registradaEm,
                                     Long regiaoId, String regiaoNome, Long autorId, String autorNome) {
        public static OcorrenciaResponse de(Ocorrencia o) {
            return new OcorrenciaResponse(o.getId(), o.getDescricao(), o.getEndereco(), o.getAlturaAguaCm(),
                    o.getPessoasAfetadas(), o.getStatus(), o.getRegistradaEm(), o.getRegiao().getId(),
                    o.getRegiao().getNome(), o.getAutor().getId(), o.getAutor().getNome());
        }
    }
}
