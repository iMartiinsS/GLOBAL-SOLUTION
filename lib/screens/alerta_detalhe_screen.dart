import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';
import '../utils/formatos.dart';
import '../widgets/nivel_badge.dart';
import 'sensor_detalhe_screen.dart';

/// Tela 3 — Detalhe do alerta, recebido por parâmetro.
/// Gerenciamento de estado: checklist de preparação; o contador e a barra de progresso
/// são atualizados com setState a cada item marcado.
class AlertaDetalheScreen extends StatefulWidget {
  const AlertaDetalheScreen({super.key, required this.alerta});

  final Alerta alerta;

  @override
  State<AlertaDetalheScreen> createState() => _AlertaDetalheScreenState();
}

class _AlertaDetalheScreenState extends State<AlertaDetalheScreen> {
  static const _itens = [
    'Documentos e remédios em saco plástico, no alto',
    'Celular carregado e lanterna à mão',
    'Desligar a energia elétrica se a água subir',
    'Combinar ponto de encontro com a família',
    'Retirar idosos, crianças e pets primeiro',
    'Não atravessar ruas alagadas',
  ];

  final Set<int> _marcados = {};
  bool _estouSeguro = false;

  void _alternar(int i) {
    setState(() {
      if (!_marcados.remove(i)) _marcados.add(i);
    });
  }

  void _confirmarSeguranca() {
    setState(() => _estouSeguro = !_estouSeguro);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_estouSeguro
            ? 'Obrigado! A Defesa Civil vai saber que você está em local seguro.'
            : 'Status de segurança removido.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final alerta = widget.alerta;
    final progresso = _marcados.length / _itens.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhe do alerta')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      NivelBadge(nivel: alerta.nivel),
                      const Spacer(),
                      Icon(alerta.nivel.icone, color: alerta.nivel.cor, size: 32),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(alerta.regiao.nome,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.texto)),
                  Text(alerta.regiao.cidade, style: const TextStyle(color: AppColors.textoSuave)),
                  const SizedBox(height: AppSpacing.md),
                  Text(alerta.mensagem, style: const TextStyle(fontSize: 16, height: 1.4, color: AppColors.texto)),
                  const SizedBox(height: AppSpacing.md),
                  _Info(icone: Icons.schedule, texto: 'Emitido ${dataHora(alerta.emitidoEm)}'),
                  _Info(icone: Icons.campaign_outlined, texto: 'Origem: ${alerta.origem}'),
                  _Info(
                    icone: Icons.groups_outlined,
                    texto: '${alerta.regiao.populacaoRisco} moradores em área de risco',
                  ),
                ],
              ),
            ),
          ),
          if (alerta.sensor != null) ...[
            const SizedBox(height: AppSpacing.sm + 4),
            Card(
              child: ListTile(
                leading: const Icon(Icons.sensors, color: AppColors.azul),
                title: Text('Ver sensor ${alerta.sensor!.codigo}'),
                subtitle: Text(alerta.sensor!.localizacao),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SensorDetalheScreen(sensor: alerta.sensor!)),
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              const Expanded(
                child: Text('Prepare-se',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.texto)),
              ),
              Text('Itens preparados: ${_marcados.length}/${_itens.length}',
                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.azul)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progresso,
              minHeight: 8,
              backgroundColor: AppColors.azulClaro,
              color: progresso == 1 ? AppColors.normal : AppColors.azul,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Column(
              children: [
                for (var i = 0; i < _itens.length; i++)
                  CheckboxListTile(
                    value: _marcados.contains(i),
                    onChanged: (_) => _alternar(i),
                    title: Text(_itens[i]),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: _estouSeguro ? AppColors.normal : AppColors.azul,
            ),
            onPressed: _confirmarSeguranca,
            icon: Icon(_estouSeguro ? Icons.verified_user : Icons.shield_outlined),
            label: Text(_estouSeguro ? 'Você marcou que está seguro' : 'Estou em local seguro'),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.icone, required this.texto});

  final IconData icone;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs + 2),
      child: Row(
        children: [
          Icon(icone, size: 18, color: AppColors.textoSuave),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(texto, style: const TextStyle(color: AppColors.textoSuave))),
        ],
      ),
    );
  }
}
