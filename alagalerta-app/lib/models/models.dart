import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Escala de risco — a mesma usada pela API Java/.NET e pelo PL/SQL.
enum NivelRisco {
  normal('Normal', AppColors.normal, Icons.check_circle),
  atencao('Atenção', AppColors.atencao, Icons.info),
  alerta('Alerta', AppColors.alerta, Icons.warning_amber_rounded),
  emergencia('Emergência', AppColors.emergencia, Icons.crisis_alert);

  const NivelRisco(this.rotulo, this.cor, this.icone);

  final String rotulo;
  final Color cor;
  final IconData icone;
}

enum StatusOcorrencia {
  aberta('Aberta', Icons.mark_email_unread_outlined),
  emAtendimento('Em atendimento', Icons.engineering_outlined),
  resolvida('Resolvida', Icons.task_alt),
  descartada('Descartada', Icons.cancel_outlined);

  const StatusOcorrencia(this.rotulo, this.icone);

  final String rotulo;
  final IconData icone;
}

class Regiao {
  const Regiao({
    required this.id,
    required this.nome,
    required this.cidade,
    required this.populacaoRisco,
  });

  final int id;
  final String nome;
  final String cidade;
  final int populacaoRisco;
}

class Leitura {
  const Leitura({
    required this.dataHora,
    required this.nivelAguaCm,
    required this.chuvaMmHora,
    required this.nivel,
  });

  final DateTime dataHora;
  final double nivelAguaCm;
  final double chuvaMmHora;
  final NivelRisco nivel;
}

class Sensor {
  const Sensor({
    required this.id,
    required this.codigo,
    required this.localizacao,
    required this.regiao,
    required this.nivelAlertaCm,
    required this.nivelCriticoCm,
    required this.leituras,
  });

  final int id;
  final String codigo;
  final String localizacao;
  final Regiao regiao;
  final int nivelAlertaCm;
  final int nivelCriticoCm;

  /// Mais recente primeiro.
  final List<Leitura> leituras;

  Leitura get ultimaLeitura => leituras.first;

  /// Fração do nível crítico já atingida (0 a 1), usada nas barras de nível.
  double get ocupacao =>
      (ultimaLeitura.nivelAguaCm / nivelCriticoCm).clamp(0.0, 1.0);
}

class Alerta {
  const Alerta({
    required this.id,
    required this.nivel,
    required this.mensagem,
    required this.regiao,
    required this.emitidoEm,
    required this.origem,
    this.sensor,
  });

  final int id;
  final NivelRisco nivel;
  final String mensagem;
  final Regiao regiao;
  final DateTime emitidoEm;
  final String origem;
  final Sensor? sensor;
}

class Ocorrencia {
  Ocorrencia({
    required this.id,
    required this.descricao,
    required this.endereco,
    required this.regiao,
    required this.registradaEm,
    this.alturaAguaCm,
    this.pessoasAfetadas,
    this.status = StatusOcorrencia.aberta,
  });

  final int id;
  final String descricao;
  final String endereco;
  final Regiao regiao;
  final DateTime registradaEm;
  final int? alturaAguaCm;
  final int? pessoasAfetadas;
  StatusOcorrencia status;
}

class Usuario {
  const Usuario({
    required this.nome,
    required this.email,
    required this.regiao,
  });

  final String nome;
  final String email;
  final Regiao regiao;
}
