import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';
import '../utils/formatos.dart';
import '../widgets/nivel_agua_bar.dart';
import '../widgets/nivel_badge.dart';

/// Tela 5 — Detalhe do sensor (parâmetro), com mini gráfico e histórico de leituras.
class SensorDetalheScreen extends StatelessWidget {
  const SensorDetalheScreen({super.key, required this.sensor});

  final Sensor sensor;

  @override
  Widget build(BuildContext context) {
    final ultima = sensor.ultimaLeitura;
    final cronologico = sensor.leituras.reversed.toList();

    return Scaffold(
      appBar: AppBar(title: Text(sensor.codigo)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sensor.localizacao,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.texto,
                    ),
                  ),
                  Text(
                    '${sensor.regiao.nome} · ${sensor.regiao.cidade}',
                    style: const TextStyle(color: AppColors.textoSuave),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${ultima.nivelAguaCm.toStringAsFixed(0)} cm',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          color: ultima.nivel.cor,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: NivelBadge(nivel: ultima.nivel),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  NivelAguaBar(sensor: sensor),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      _Limite(
                        cor: AppColors.alerta,
                        texto: 'Alerta ${sensor.nivelAlertaCm} cm',
                      ),
                      const SizedBox(width: AppSpacing.md),
                      _Limite(
                        cor: AppColors.emergencia,
                        texto: 'Crítico ${sensor.nivelCriticoCm} cm',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      const Icon(Icons.grain, color: AppColors.azul, size: 20),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Chuva agora: ${ultima.chuvaMmHora.toStringAsFixed(0)} mm/h',
                      ),
                      const Spacer(),
                      Text(
                        tempoRelativo(ultima.dataHora),
                        style: const TextStyle(
                          color: AppColors.textoSuave,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Evolução do nível',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.texto,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: SizedBox(
                height: 150,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final l in cronologico)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                l.nivelAguaCm.toStringAsFixed(0),
                                style: const TextStyle(fontSize: 11),
                              ),
                              const SizedBox(height: 2),
                              Container(
                                height:
                                    110 *
                                    (l.nivelAguaCm / sensor.nivelCriticoCm)
                                        .clamp(0.04, 1.0),
                                decoration: BoxDecoration(
                                  color: l.nivel.cor,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(6),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                horaMinuto(l.dataHora),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textoSuave,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Leituras recentes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.texto,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sensor.leituras.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final l = sensor.leituras[i];
                return ListTile(
                  leading: Icon(l.nivel.icone, color: l.nivel.cor),
                  title: Text(
                    '${l.nivelAguaCm.toStringAsFixed(0)} cm · ${l.chuvaMmHora.toStringAsFixed(0)} mm/h',
                  ),
                  subtitle: Text(dataHora(l.dataHora)),
                  trailing: NivelBadge(nivel: l.nivel, compacto: true),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Limite extends StatelessWidget {
  const _Limite({required this.cor, required this.texto});

  final Color cor;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          texto,
          style: const TextStyle(fontSize: 12, color: AppColors.textoSuave),
        ),
      ],
    );
  }
}
