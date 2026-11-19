package br.com.fiap.alagalerta.service;

import br.com.fiap.alagalerta.domain.NivelRisco;
import br.com.fiap.alagalerta.domain.Regiao;
import br.com.fiap.alagalerta.domain.Sensor;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class ClassificadorRiscoTest {

    private final ClassificadorRisco classificador = new ClassificadorRisco();
    // alerta em 100 cm, crítico em 160 cm
    private final Sensor sensor = new Sensor("SNS-T", "Córrego Teste", null, null, 100, 160,
            new Regiao("Bairro", "Cidade", "SP", 100));

    @Test
    void normalComAguaBaixaESemChuva() {
        assertEquals(NivelRisco.NORMAL, classificador.classificar(sensor, 40, 5));
    }

    @Test
    void atencaoComChuvaForteMesmoComAguaBaixa() {
        assertEquals(NivelRisco.ATENCAO, classificador.classificar(sensor, 40, 30));
    }

    @Test
    void atencaoAcimaDe70PorCentoDoAlerta() {
        assertEquals(NivelRisco.ATENCAO, classificador.classificar(sensor, 70, 0));
    }

    @Test
    void alertaNoNivelDeAlerta() {
        assertEquals(NivelRisco.ALERTA, classificador.classificar(sensor, 100, 0));
    }

    @Test
    void alertaAntecipadoComChuvaMuitoForte() {
        assertEquals(NivelRisco.ALERTA, classificador.classificar(sensor, 75, 55));
    }

    @Test
    void emergenciaNoNivelCritico() {
        assertEquals(NivelRisco.EMERGENCIA, classificador.classificar(sensor, 160, 0));
    }
}
