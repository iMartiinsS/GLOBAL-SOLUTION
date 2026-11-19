package br.com.fiap.alagalerta.service;

import br.com.fiap.alagalerta.domain.NivelRisco;
import br.com.fiap.alagalerta.domain.Sensor;
import org.springframework.stereotype.Component;

/**
 * Regra de negócio central do AlagAlerta: transforma uma leitura em nível de risco.
 *
 * <ul>
 *   <li>EMERGENCIA: água no nível crítico do ponto monitorado.</li>
 *   <li>ALERTA: água no nível de alerta, ou chuva muito forte (≥ 50 mm/h) com água acima de 70% do alerta.</li>
 *   <li>ATENCAO: água acima de 70% do nível de alerta, ou chuva forte (≥ 30 mm/h).</li>
 *   <li>NORMAL: demais casos.</li>
 * </ul>
 * Os limiares de chuva seguem a classificação usual de intensidade (forte acima de ~25-30 mm/h).
 */
@Component
public class ClassificadorRisco {

    static final double CHUVA_FORTE_MM_H = 30.0;
    static final double CHUVA_MUITO_FORTE_MM_H = 50.0;
    static final double FRACAO_PRE_ALERTA = 0.7;

    public NivelRisco classificar(Sensor sensor, double nivelAguaCm, double chuvaMmHora) {
        double alerta = sensor.getNivelAlertaCm();
        double critico = sensor.getNivelCriticoCm();
        boolean preAlerta = nivelAguaCm >= alerta * FRACAO_PRE_ALERTA;

        if (nivelAguaCm >= critico) {
            return NivelRisco.EMERGENCIA;
        }
        if (nivelAguaCm >= alerta || (preAlerta && chuvaMmHora >= CHUVA_MUITO_FORTE_MM_H)) {
            return NivelRisco.ALERTA;
        }
        if (preAlerta || chuvaMmHora >= CHUVA_FORTE_MM_H) {
            return NivelRisco.ATENCAO;
        }
        return NivelRisco.NORMAL;
    }

    public String mensagemPadrao(NivelRisco nivel, Sensor sensor, double nivelAguaCm) {
        String local = sensor.getLocalizacao() + " (" + sensor.getRegiao().getNome() + ")";
        return switch (nivel) {
            case EMERGENCIA -> "EMERGÊNCIA: água a %.0f cm em %s. Saia de áreas baixas e procure local seguro. Defesa Civil: 199."
                    .formatted(nivelAguaCm, local);
            case ALERTA -> "ALERTA: nível do córrego subindo rápido (%.0f cm) em %s. Prepare-se para deixar o local."
                    .formatted(nivelAguaCm, local);
            case ATENCAO -> "ATENÇÃO: chuva forte e nível em elevação em %s. Evite transitar por áreas alagáveis."
                    .formatted(local);
            case NORMAL -> "Situação normal em " + local + ".";
        };
    }
}
