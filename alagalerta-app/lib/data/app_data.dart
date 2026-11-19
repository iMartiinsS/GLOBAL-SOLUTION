import 'package:flutter/foundation.dart';

import '../models/models.dart';
import 'api_client.dart';
import 'mock_data.dart';

/// Sessão compartilhada pelas telas. O modo conectado nunca recorre a mocks.
class AppData {
  AppData._();
  static bool demo = const bool.fromEnvironment('DEMO_MODE');
  static ApiClient api = ApiClient(
    baseUrl: const String.fromEnvironment(
      'API_URL',
      defaultValue: 'http://10.0.2.2:8080',
    ),
  );
  static final revision = ValueNotifier<int>(0);
  static List<Regiao> _regioes = [];
  static List<Sensor> _sensores = [];
  static List<Alerta> _alertas = [];
  static List<Ocorrencia> _ocorrencias = [];
  static Usuario? usuario;
  static String? papel;

  static List<Regiao> get regioes => demo ? MockData.regioes : _regioes;
  static List<Sensor> get sensores => demo ? MockData.sensores : _sensores;
  static List<Alerta> get alertas => demo ? MockData.alertas : _alertas;
  static List<Ocorrencia> get ocorrencias =>
      demo ? MockData.ocorrencias : _ocorrencias;
  static List<Sensor> sensoresDaRegiao(Regiao r) =>
      sensores.where((s) => s.regiao.id == r.id).toList();
  static NivelRisco nivelDaRegiao(Regiao r) => alertas
      .where((a) => a.regiao.id == r.id)
      .fold(
        NivelRisco.normal,
        (nivel, alerta) =>
            alerta.nivel.index > nivel.index ? alerta.nivel : nivel,
      );

  static Future<Usuario> login(String email, String senha) async {
    logout();
    if (demo) {
      if (email != MockData.usuarioTeste.email ||
          senha != MockData.senhaTeste) {
        throw const ApiException('E-mail ou senha incorretos.');
      }
      usuario = MockData.usuarioTeste;
      papel = 'CIDADAO';
      return usuario!;
    }
    try {
      final response = await api.request('POST', '/auth/login', {
        'email': email,
        'senha': senha,
      });
      api.token = response['token'] as String;
      await refresh();
      final u = response['usuario'] as Map;
      final bairro = regioes.where((r) => r.id == u['regiaoId']).firstOrNull;
      if (bairro == null) {
        throw const ApiException(
          'Este usuário precisa de um bairro cadastrado para usar o app.',
        );
      }
      usuario = Usuario(
        nome: u['nome'] as String,
        email: u['email'] as String,
        regiao: bairro,
      );
      papel = u['papel'] as String;
      return usuario!;
    } catch (_) {
      logout();
      rethrow;
    }
  }

  static NivelRisco _nivel(dynamic value) => switch (value) {
    'NORMAL' => NivelRisco.normal,
    'ATENCAO' => NivelRisco.atencao,
    'ALERTA' => NivelRisco.alerta,
    'EMERGENCIA' => NivelRisco.emergencia,
    _ => throw const ApiException(
      'Nível de risco não reconhecido na resposta da API.',
    ),
  };

  static Future<void> refresh() async {
    if (demo) return;
    final regions = await api.collection('/api/regioes', 'regioes');
    final novosBairros = regions
        .map(
          (r) => Regiao(
            id: r['id'] as int,
            nome: r['nome'] as String,
            cidade: r['cidade'] as String,
            populacaoRisco: r['populacaoRisco'] as int? ?? 0,
          ),
        )
        .toList();
    Regiao bairro(dynamic id) => novosBairros.firstWhere((r) => r.id == id);
    final sensorRows = await api.collection('/api/sensores', 'sensores');
    final novosSensores = await Future.wait(
      sensorRows.map((s) async {
        final history = await api.collection(
          '/api/leituras/sensor/${s['id']}?horas=24',
          'leituras',
        );
        final leituras =
            history
                .map(
                  (l) => Leitura(
                    dataHora: DateTime.parse(l['dataHora'] as String),
                    nivelAguaCm: (l['nivelAguaCm'] as num).toDouble(),
                    chuvaMmHora: (l['chuvaMmHora'] as num).toDouble(),
                    nivel: _nivel(l['nivelRisco']),
                  ),
                )
                .toList()
              ..sort((a, b) => b.dataHora.compareTo(a.dataHora));
        return Sensor(
          id: s['id'] as int,
          codigo: s['codigo'] as String,
          localizacao: s['localizacao'] as String,
          regiao: bairro(s['regiaoId']),
          nivelAlertaCm: s['nivelAlertaCm'] as int,
          nivelCriticoCm: s['nivelCriticoCm'] as int,
          leituras: leituras,
        );
      }),
    );
    final alertRows = await api.collection('/api/alertas/ativos', 'alertas');
    final novosAlertas = alertRows
        .map(
          (a) => Alerta(
            id: a['id'] as int,
            nivel: _nivel(a['nivel']),
            mensagem: a['mensagem'] as String,
            regiao: bairro(a['regiaoId']),
            emitidoEm: DateTime.parse(a['emitidoEm'] as String),
            origem: a['origem'] == 'SENSOR' ? 'Sensor' : 'Defesa Civil',
            sensor: novosSensores
                .where((s) => s.id == a['sensorId'])
                .firstOrNull,
          ),
        )
        .toList();
    final occurrenceRows = await api.collection(
      '/api/ocorrencias',
      'ocorrencias',
    );
    final novasOcorrencias = occurrenceRows
        .map((o) => _ocorrencia(o, bairro(o['regiaoId'])))
        .toList();
    // Só publica o novo conjunto quando todas as requisições terminarem.
    _regioes = novosBairros;
    _sensores = novosSensores;
    _alertas = novosAlertas;
    _ocorrencias = novasOcorrencias;
    revision.value++;
  }

  static Ocorrencia _ocorrencia(Map<String, dynamic> o, Regiao regiao) =>
      Ocorrencia(
        id: o['id'] as int,
        descricao: o['descricao'] as String,
        endereco: o['endereco'] as String,
        regiao: regiao,
        registradaEm: DateTime.parse(o['registradaEm'] as String),
        alturaAguaCm: o['alturaAguaCm'] as int?,
        pessoasAfetadas: o['pessoasAfetadas'] as int?,
        status: switch (o['status']) {
          'ABERTA' => StatusOcorrencia.aberta,
          'EM_ATENDIMENTO' => StatusOcorrencia.emAtendimento,
          'RESOLVIDA' => StatusOcorrencia.resolvida,
          'DESCARTADA' => StatusOcorrencia.descartada,
          _ => throw const ApiException(
            'Status de ocorrência não reconhecido.',
          ),
        },
      );

  static Future<Ocorrencia> registrar({
    required String descricao,
    required String endereco,
    required Regiao regiao,
    int? alturaAguaCm,
    int? pessoasAfetadas,
  }) async {
    if (demo) {
      return Ocorrencia(
        id: MockData.proximoIdOcorrencia(),
        descricao: descricao,
        endereco: endereco,
        regiao: regiao,
        registradaEm: DateTime.now(),
        alturaAguaCm: alturaAguaCm,
        pessoasAfetadas: pessoasAfetadas,
      );
    }
    final result = await api.request('POST', '/api/ocorrencias', {
      'descricao': descricao,
      'endereco': endereco,
      'regiaoId': regiao.id,
      'alturaAguaCm': alturaAguaCm,
      'pessoasAfetadas': pessoasAfetadas,
    });
    return _ocorrencia(result, regiao);
  }

  static void logout() {
    api.token = null;
    usuario = null;
    papel = null;
    _regioes = [];
    _sensores = [];
    _alertas = [];
    _ocorrencias = [];
  }
}
