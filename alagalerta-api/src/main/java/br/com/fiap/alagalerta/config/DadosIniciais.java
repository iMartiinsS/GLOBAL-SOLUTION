package br.com.fiap.alagalerta.config;

import br.com.fiap.alagalerta.domain.*;
import br.com.fiap.alagalerta.repository.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Carga de demonstração: regiões reais de São Paulo com histórico de alagamento,
 * sensores, algumas leituras, um alerta e ocorrências, além de um usuário por papel.
 * Só roda com o banco vazio. Desative com SEED_ENABLED=false.
 */
@Component
@ConditionalOnProperty(name = "app.seed.enabled", havingValue = "true", matchIfMissing = true)
public class DadosIniciais implements ApplicationRunner {

    private static final Logger log = LoggerFactory.getLogger(DadosIniciais.class);

    /** Senha dos usuários de TESTE (documentada no README). Não é credencial real. */
    private static final String SENHA_TESTE = "Teste@2026";

    private final RegiaoRepository regioes;
    private final SensorRepository sensores;
    private final LeituraRepository leituras;
    private final AlertaRepository alertas;
    private final OcorrenciaRepository ocorrencias;
    private final UsuarioRepository usuarios;
    private final PasswordEncoder encoder;

    public DadosIniciais(RegiaoRepository regioes, SensorRepository sensores, LeituraRepository leituras,
                         AlertaRepository alertas, OcorrenciaRepository ocorrencias, UsuarioRepository usuarios,
                         PasswordEncoder encoder) {
        this.regioes = regioes;
        this.sensores = sensores;
        this.leituras = leituras;
        this.alertas = alertas;
        this.ocorrencias = ocorrencias;
        this.usuarios = usuarios;
        this.encoder = encoder;
    }

    @Override
    @Transactional
    public void run(ApplicationArguments args) {
        if (regioes.count() > 0) {
            return;
        }
        Regiao jardimPantanal = regioes.save(new Regiao("Jardim Pantanal", "São Paulo", "SP", 42000));
        Regiao vilaPrudente = regioes.save(new Regiao("Vila Prudente", "São Paulo", "SP", 18500));
        Regiao jardimRomano = regioes.save(new Regiao("Jardim Romano", "São Paulo", "SP", 23000));
        Regiao centroFranco = regioes.save(new Regiao("Centro", "Franco da Rocha", "SP", 9600));

        Sensor s1 = sensores.save(new Sensor("SNS-PANT-01", "Córrego Três Pontes - Rua Capachós", -23.4925, -46.4136, 120, 180, jardimPantanal));
        Sensor s2 = sensores.save(new Sensor("SNS-PANT-02", "Rio Tietê - Ponte Jd. Helena", -23.4889, -46.4202, 250, 330, jardimPantanal));
        Sensor s3 = sensores.save(new Sensor("SNS-VPRU-01", "Córrego da Mooca - Av. Prof. Luiz Inácio de Anhaia Mello", -23.5850, -46.5800, 90, 140, vilaPrudente));
        Sensor s4 = sensores.save(new Sensor("SNS-ROMA-01", "Córrego Lajeado - Rua Kumaki Aoki", -23.4997, -46.3994, 100, 160, jardimRomano));
        Sensor s5 = sensores.save(new Sensor("SNS-FRAN-01", "Rio Juquery - Av. dos Expedicionários", -23.3222, -46.7269, 200, 280, centroFranco));

        LocalDateTime agora = LocalDateTime.now();
        record L(Sensor s, double nivel, double chuva, int minAtras, NivelRisco risco) {
        }
        List<L> carga = List.of(
                new L(s1, 60, 5, 180, NivelRisco.NORMAL), new L(s1, 78, 18, 120, NivelRisco.NORMAL),
                new L(s1, 95, 34, 60, NivelRisco.ATENCAO), new L(s1, 128, 42, 10, NivelRisco.ALERTA),
                new L(s2, 140, 34, 60, NivelRisco.ATENCAO), new L(s2, 150, 30, 10, NivelRisco.ATENCAO),
                new L(s3, 30, 2, 60, NivelRisco.NORMAL), new L(s3, 35, 4, 10, NivelRisco.NORMAL),
                new L(s4, 55, 12, 60, NivelRisco.NORMAL), new L(s5, 80, 0, 300, NivelRisco.NORMAL));
        for (L l : carga) {
            LocalDateTime quando = agora.minusMinutes(l.minAtras());
            leituras.save(new Leitura(l.s(), l.nivel(), l.chuva(), quando, l.risco()));
            if (l.s().getUltimaLeituraEm() == null || quando.isAfter(l.s().getUltimaLeituraEm())) {
                l.s().registrarLeitura(quando);
            }
        }

        alertas.save(new Alerta(jardimPantanal, s1, NivelRisco.ALERTA,
                "ALERTA: nível do córrego subindo rápido (128 cm) em Córrego Três Pontes - Rua Capachós (Jardim Pantanal). Prepare-se para deixar o local.",
                OrigemAlerta.SENSOR, agora.minusMinutes(10)));

        String hash = encoder.encode(SENHA_TESTE);
        Usuario cidadao = usuarios.save(new Usuario("Maria Cidadã", "cidadao@alagalerta.com", hash, Papel.CIDADAO, jardimPantanal));
        Usuario agente = usuarios.save(new Usuario("Carlos Defesa Civil", "agente@alagalerta.com", hash, Papel.AGENTE, null));
        usuarios.save(new Usuario("Admin AlagAlerta", "admin@alagalerta.com", hash, Papel.ADMIN, null));
        usuarios.save(new Usuario("Gateway IoT", "gateway@alagalerta.com", hash, Papel.AGENTE, null));

        ocorrencias.save(new Ocorrencia("Água entrando nas casas da Rua Capachós, altura do joelho", "Rua Capachós, 210",
                50, 12, jardimPantanal, cidadao, agora.minusMinutes(25)));
        Ocorrencia o2 = ocorrencias.save(new Ocorrencia("Bueiro entupido causando alagamento na esquina", "Rua Kumaki Aoki x Rua Itajuíba",
                20, 0, jardimRomano, cidadao, agora.minusHours(3)));
        o2.alterarStatus(StatusOcorrencia.EM_ATENDIMENTO);
        ocorrencias.save(new Ocorrencia("Idosa ilhada em casa térrea, precisa de ajuda para sair", "Travessa Três Pontes, 15",
                70, 1, jardimPantanal, agente, agora.minusMinutes(5)));

        log.info("Carga inicial concluída: {} regiões, {} sensores, {} leituras, {} usuários de teste",
                regioes.count(), sensores.count(), leituras.count(), usuarios.count());
    }
}
