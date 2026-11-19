package br.com.fiap.alagalerta.dto;

import br.com.fiap.alagalerta.domain.Regiao;
import jakarta.validation.constraints.*;
import org.springframework.hateoas.server.core.Relation;

public final class RegiaoDtos {

    private RegiaoDtos() {
    }

    public record RegiaoRequest(
            @NotBlank(message = "nome é obrigatório") @Size(max = 100) String nome,
            @NotBlank(message = "cidade é obrigatória") @Size(max = 100) String cidade,
            @NotBlank(message = "uf é obrigatória") @Pattern(regexp = "[A-Z]{2}", message = "uf deve ter 2 letras maiúsculas") String uf,
            @PositiveOrZero(message = "populacaoRisco não pode ser negativa") Integer populacaoRisco) {
    }

    @Relation(collectionRelation = "regioes", itemRelation = "regiao")
    public record RegiaoResponse(Long id, String nome, String cidade, String uf, Integer populacaoRisco) {
        public static RegiaoResponse de(Regiao r) {
            return new RegiaoResponse(r.getId(), r.getNome(), r.getCidade(), r.getUf(), r.getPopulacaoRisco());
        }
    }
}
