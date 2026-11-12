package br.com.fiap.alagalerta.dto;

import br.com.fiap.alagalerta.domain.Leitura;
import br.com.fiap.alagalerta.domain.NivelRisco;
import jakarta.validation.constraints.*;
import org.springframework.hateoas.server.core.Relation;

import java.time.LocalDateTime;

public final class LeituraDtos {

    private LeituraDtos() {
    }

    /** Payload enviado pelo gateway IoT. dataHora é opcional: se vier vazio, usa o horário do servidor. */
    public record LeituraRequest(
            @NotBlank(message = "codigoSensor é obrigatório") String codigoSensor,
            @NotNull(message = "nivelAguaCm é obrigatório") @PositiveOrZero @Max(value = 2000, message = "nivelAguaCm acima do alcance do sensor") Double nivelAguaCm,
            @NotNull(message = "chuvaMmHora é obrigatório") @PositiveOrZero @Max(value = 500, message = "chuvaMmHora fora da faixa física") Double chuvaMmHora,
            @PastOrPresent(message = "dataHora não pode estar no futuro") LocalDateTime dataHora) {
    }

    @Relation(collectionRelation = "leituras", itemRelation = "leitura")
    public record LeituraResponse(Long id, Long sensorId, String codigoSensor, Double nivelAguaCm, Double chuvaMmHora,
                                  LocalDateTime dataHora, NivelRisco nivelRisco, Long alertaGeradoId) {
        public static LeituraResponse de(Leitura l, Long alertaGeradoId) {
            return new LeituraResponse(l.getId(), l.getSensor().getId(), l.getSensor().getCodigo(), l.getNivelAguaCm(),
                    l.getChuvaMmHora(), l.getDataHora(), l.getNivelRisco(), alertaGeradoId);
        }

        public static LeituraResponse de(Leitura l) {
            return de(l, null);
        }
    }
}
