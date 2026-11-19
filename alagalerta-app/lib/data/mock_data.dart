import '../models/models.dart';

/// Dados mockados — espelham a carga de demonstração da API AlagAlerta.
/// O app desta entrega não depende de backend.
class MockData {
  MockData._();

  static const jardimPantanal = Regiao(
    id: 1,
    nome: 'Jardim Pantanal',
    cidade: 'São Paulo',
    populacaoRisco: 42000,
  );
  static const vilaPrudente = Regiao(
    id: 2,
    nome: 'Vila Prudente',
    cidade: 'São Paulo',
    populacaoRisco: 18500,
  );
  static const jardimRomano = Regiao(
    id: 3,
    nome: 'Jardim Romano',
    cidade: 'São Paulo',
    populacaoRisco: 23000,
  );
  static const francoDaRocha = Regiao(
    id: 4,
    nome: 'Centro',
    cidade: 'Franco da Rocha',
    populacaoRisco: 9600,
  );

  static const regioes = [
    jardimPantanal,
    vilaPrudente,
    jardimRomano,
    francoDaRocha,
  ];

  static final DateTime _agora = DateTime.now();

  static List<Leitura> _serie(List<(double, double, NivelRisco)> valores) {
    // valores em ordem cronológica, uma leitura a cada 30 min; devolve a mais recente primeiro
    final total = valores.length;
    return [
      for (var i = total - 1; i >= 0; i--)
        Leitura(
          dataHora: _agora.subtract(
            Duration(minutes: 30 * (total - 1 - i) + 5),
          ),
          nivelAguaCm: valores[i].$1,
          chuvaMmHora: valores[i].$2,
          nivel: valores[i].$3,
        ),
    ];
  }

  static final sensores = <Sensor>[
    Sensor(
      id: 1,
      codigo: 'SNS-PANT-01',
      localizacao: 'Córrego Três Pontes · Rua Capachós',
      regiao: jardimPantanal,
      nivelAlertaCm: 120,
      nivelCriticoCm: 180,
      leituras: _serie([
        (55, 3, NivelRisco.normal),
        (60, 5, NivelRisco.normal),
        (78, 18, NivelRisco.normal),
        (95, 34, NivelRisco.atencao),
        (112, 40, NivelRisco.atencao),
        (128, 42, NivelRisco.alerta),
      ]),
    ),
    Sensor(
      id: 2,
      codigo: 'SNS-PANT-02',
      localizacao: 'Rio Tietê · Ponte Jd. Helena',
      regiao: jardimPantanal,
      nivelAlertaCm: 250,
      nivelCriticoCm: 330,
      leituras: _serie([
        (120, 10, NivelRisco.normal),
        (132, 22, NivelRisco.normal),
        (140, 34, NivelRisco.atencao),
        (150, 30, NivelRisco.atencao),
      ]),
    ),
    Sensor(
      id: 3,
      codigo: 'SNS-VPRU-01',
      localizacao: 'Córrego da Mooca · Av. Anhaia Mello',
      regiao: vilaPrudente,
      nivelAlertaCm: 90,
      nivelCriticoCm: 140,
      leituras: _serie([
        (28, 1, NivelRisco.normal),
        (30, 2, NivelRisco.normal),
        (35, 4, NivelRisco.normal),
      ]),
    ),
    Sensor(
      id: 4,
      codigo: 'SNS-ROMA-01',
      localizacao: 'Córrego Lajeado · Rua Kumaki Aoki',
      regiao: jardimRomano,
      nivelAlertaCm: 100,
      nivelCriticoCm: 160,
      leituras: _serie([
        (40, 8, NivelRisco.normal),
        (55, 12, NivelRisco.normal),
        (72, 31, NivelRisco.atencao),
      ]),
    ),
    Sensor(
      id: 5,
      codigo: 'SNS-FRAN-01',
      localizacao: 'Rio Juquery · Av. dos Expedicionários',
      regiao: francoDaRocha,
      nivelAlertaCm: 200,
      nivelCriticoCm: 280,
      leituras: _serie([
        (82, 0, NivelRisco.normal),
        (80, 0, NivelRisco.normal),
      ]),
    ),
  ];

  static final alertas = <Alerta>[
    Alerta(
      id: 1,
      nivel: NivelRisco.alerta,
      mensagem:
          'Nível do córrego subindo rápido (128 cm) no Córrego Três Pontes. '
          'Prepare-se para deixar o local e retire documentos e remédios de áreas baixas.',
      regiao: jardimPantanal,
      emitidoEm: _agora.subtract(const Duration(minutes: 10)),
      origem: 'Sensor SNS-PANT-01',
      sensor: sensores[0],
    ),
    Alerta(
      id: 2,
      nivel: NivelRisco.atencao,
      mensagem:
          'Chuva forte (31 mm/h) e nível em elevação no Córrego Lajeado. '
          'Evite transitar pela Rua Kumaki Aoki e áreas alagáveis.',
      regiao: jardimRomano,
      emitidoEm: _agora.subtract(const Duration(minutes: 35)),
      origem: 'Sensor SNS-ROMA-01',
      sensor: sensores[3],
    ),
    Alerta(
      id: 3,
      nivel: NivelRisco.atencao,
      mensagem:
          'Previsão de temporal entre 16h e 20h. Mantenha o celular carregado '
          'e combine com a família um ponto de encontro seguro.',
      regiao: vilaPrudente,
      emitidoEm: _agora.subtract(const Duration(hours: 2)),
      origem: 'Defesa Civil',
    ),
  ];

  static final ocorrencias = <Ocorrencia>[
    Ocorrencia(
      id: 1,
      descricao: 'Água entrando nas casas da Rua Capachós, altura do joelho.',
      endereco: 'Rua Capachós, 210',
      regiao: jardimPantanal,
      registradaEm: _agora.subtract(const Duration(minutes: 25)),
      alturaAguaCm: 50,
      pessoasAfetadas: 12,
    ),
    Ocorrencia(
      id: 2,
      descricao: 'Bueiro entupido causando alagamento na esquina.',
      endereco: 'Rua Kumaki Aoki x Rua Itajuíba',
      regiao: jardimRomano,
      registradaEm: _agora.subtract(const Duration(hours: 3)),
      alturaAguaCm: 20,
      pessoasAfetadas: 0,
      status: StatusOcorrencia.emAtendimento,
    ),
    Ocorrencia(
      id: 3,
      descricao: 'Árvore caída bloqueando a passagem da água no canal.',
      endereco: 'Travessa Três Pontes, 40',
      regiao: jardimPantanal,
      registradaEm: _agora.subtract(const Duration(days: 1)),
      alturaAguaCm: 0,
      pessoasAfetadas: 0,
      status: StatusOcorrencia.resolvida,
    ),
  ];

  static const usuarioTeste = Usuario(
    nome: 'Maria Cidadã',
    email: 'cidadao@alagalerta.com',
    regiao: jardimPantanal,
  );
  static const senhaTeste = 'Teste@2026';

  static int proximoIdOcorrencia() =>
      ocorrencias.map((o) => o.id).fold(0, (a, b) => a > b ? a : b) + 1;

  static List<Sensor> sensoresDaRegiao(Regiao r) =>
      sensores.where((s) => s.regiao.id == r.id).toList();

  static NivelRisco nivelDaRegiao(Regiao r) {
    final ativos = alertas.where((a) => a.regiao.id == r.id);
    if (ativos.isEmpty) return NivelRisco.normal;
    return ativos
        .map((a) => a.nivel)
        .reduce((a, b) => a.index >= b.index ? a : b);
  }
}
