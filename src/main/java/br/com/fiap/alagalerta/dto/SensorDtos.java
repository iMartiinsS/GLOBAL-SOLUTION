package br.com.fiap.alagalerta.dto;

import br.com.fiap.alagalerta.domain.Sensor;
import br.com.fiap.alagalerta.domain.StatusSensor;
import jakarta.validation.constraints.*;
import org.springframework.hateoas.server.core.Relation;

import java.time.LocalDateTime;

public final class SensorDtos {

    private SensorDtos() {
    }

    public record SensorRequest(
            @NotBlank(message = "codigo é obrigatório") @Pattern(regexp = "[A-Z0-9-]{3,30}", message = "codigo deve ter de 3 a 30 caracteres A-Z, 0-9 ou hífen") String codigo,
            @NotBlank(message = "localizacao é obrigatória") @Size(max = 150) String localizacao,
            @DecimalMin("-90.0") @DecimalMax("90.0") Double latitude,
            @DecimalMin("-180.0") @DecimalMax("180.0") Double longitude,
            @NotNull(message = "nivelAlertaCm é obrigatório") @Positive Integer nivelAlertaCm,
            @NotNull(message = "nivelCriticoCm é obrigatório") @Positive Integer nivelCriticoCm,
            StatusSensor status,
            @NotNull(message = "regiaoId é obrigatório") Long regiaoId) {

        @AssertTrue(message = "nivelCriticoCm deve ser maior que nivelAlertaCm")
        public boolean isLimitesCoerentes() {
            return nivelAlertaCm == null || nivelCriticoCm == null || nivelCriticoCm > nivelAlertaCm;
        }
    }

    @Relation(collectionRelation = "sensores", itemRelation = "sensor")
    public record SensorResponse(Long id, String codigo, String localizacao, Double latitude, Double longitude,
                                 Integer nivelAlertaCm, Integer nivelCriticoCm, StatusSensor status,
                                 LocalDateTime ultimaLeituraEm, Long regiaoId, String regiaoNome) {
        public static SensorResponse de(Sensor s) {
            return new SensorResponse(s.getId(), s.getCodigo(), s.getLocalizacao(), s.getLatitude(), s.getLongitude(),
                    s.getNivelAlertaCm(), s.getNivelCriticoCm(), s.getStatus(), s.getUltimaLeituraEm(),
                    s.getRegiao().getId(), s.getRegiao().getNome());
        }
    }
}
