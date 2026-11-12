import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/nivel_agua_bar.dart';
import '../widgets/nivel_badge.dart';
import 'sensor_detalhe_screen.dart';

/// Tela 4 — Sensores em grade (GridView), com filtro por região mantido em estado.
class SensoresScreen extends StatefulWidget {
  const SensoresScreen({super.key});

  @override
  State<SensoresScreen> createState() => _SensoresScreenState();
}

class _SensoresScreenState extends State<SensoresScreen> {
  Regiao? _filtro; // null = todas

  @override
  Widget build(BuildContext context) {
    final lista = _filtro == null ? MockData.sensores : MockData.sensoresDaRegiao(_filtro!);

    return Scaffold(
      appBar: AppBar(title: const Text('Sensores')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              children: [
                _chip('Todas', _filtro == null, () => setState(() => _filtro = null)),
                for (final r in MockData.regioes)
                  _chip(r.nome, _filtro?.id == r.id, () => setState(() => _filtro = r)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text('${lista.length} sensores exibidos',
                style: const TextStyle(color: AppColors.textoSuave)),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 260,
                mainAxisSpacing: AppSpacing.sm + 4,
                crossAxisSpacing: AppSpacing.sm + 4,
                childAspectRatio: 0.92,
              ),
              itemCount: lista.length,
              itemBuilder: (context, i) => _SensorCard(sensor: lista[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String rotulo, bool selecionado, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: ChoiceChip(label: Text(rotulo), selected: selecionado, onSelected: (_) => onTap()),
    );
  }
}

class _SensorCard extends StatelessWidget {
  const _SensorCard({required this.sensor});

  final Sensor sensor;

  @override
  Widget build(BuildContext context) {
    final ultima = sensor.ultimaLeitura;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SensorDetalheScreen(sensor: sensor)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm + 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.water_drop, color: AppColors.azul, size: 20),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(sensor.codigo,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(sensor.regiao.nome, style: const TextStyle(color: AppColors.textoSuave, fontSize: 12)),
              const Spacer(),
              Text('${ultima.nivelAguaCm.toStringAsFixed(0)} cm',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: ultima.nivel.cor)),
              Text('crítico em ${sensor.nivelCriticoCm} cm',
                  style: const TextStyle(color: AppColors.textoSuave, fontSize: 11)),
              const SizedBox(height: AppSpacing.sm),
              NivelAguaBar(sensor: sensor, altura: 8),
              const SizedBox(height: AppSpacing.sm),
              NivelBadge(nivel: ultima.nivel, compacto: true),
            ],
          ),
        ),
      ),
    );
  }
}
