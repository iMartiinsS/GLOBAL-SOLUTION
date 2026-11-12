import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/alerta_card.dart';
import 'alerta_detalhe_screen.dart';
import 'dicas_screen.dart';
import 'reportar_screen.dart';

/// Tela 2 — Início: situação do bairro do usuário, atalhos (GridView) e alertas ativos (ListView).
class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key, required this.usuario, required this.onAbrirAba});

  final Usuario usuario;
  final ValueChanged<int> onAbrirAba;

  @override
  Widget build(BuildContext context) {
    final nivelBairro = MockData.nivelDaRegiao(usuario.regiao);
    final alertas = [...MockData.alertas]
      ..sort((a, b) {
        // alertas do bairro do usuário primeiro, depois por gravidade
        final meuA = a.regiao.id == usuario.regiao.id ? 0 : 1;
        final meuB = b.regiao.id == usuario.regiao.id ? 0 : 1;
        if (meuA != meuB) return meuA - meuB;
        return b.nivel.index - a.nivel.index;
      });

    final atalhos = <_Atalho>[
      _Atalho('Reportar alagamento', Icons.add_location_alt_outlined, AppColors.emergencia, () async {
        final criada = await Navigator.push<Ocorrencia>(
          context,
          MaterialPageRoute(builder: (_) => ReportarScreen(regiaoInicial: usuario.regiao)),
        );
        if (criada != null) {
          MockData.ocorrencias.insert(0, criada);
          onAbrirAba(2); // setState no HomeShell redesenha a aba de ocorrências já com o novo relato
        }
      }),
      _Atalho('Sensores do córrego', Icons.sensors, AppColors.azul, () => onAbrirAba(1)),
      _Atalho('Minhas ocorrências', Icons.list_alt, AppColors.alerta, () => onAbrirAba(2)),
      _Atalho('Como se proteger', Icons.health_and_safety_outlined, AppColors.normal,
          () => Navigator.pushNamed(context, DicasScreen.rota)),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 30),
            const SizedBox(width: AppSpacing.sm),
            const Text('AlagAlerta'),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text('Olá, ${usuario.nome.split(' ').first}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.texto)),
          const SizedBox(height: AppSpacing.md),
          _SituacaoBairro(regiao: usuario.regiao, nivel: nivelBairro),
          const SizedBox(height: AppSpacing.md),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.sm + 4,
            crossAxisSpacing: AppSpacing.sm + 4,
            childAspectRatio: 1.6,
            children: [for (final a in atalhos) _AtalhoCard(atalho: a)],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              const Text('Alertas ativos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.texto)),
              const SizedBox(width: AppSpacing.sm),
              CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.azul,
                child: Text('${alertas.length}', style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: alertas.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm + 4),
            itemBuilder: (context, i) => AlertaCard(
              alerta: alertas[i],
              // passagem de parâmetro pelo construtor da próxima tela
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AlertaDetalheScreen(alerta: alertas[i])),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SituacaoBairro extends StatelessWidget {
  const _SituacaoBairro({required this.regiao, required this.nivel});

  final Regiao regiao;
  final NivelRisco nivel;

  @override
  Widget build(BuildContext context) {
    final sensores = MockData.sensoresDaRegiao(regiao);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [nivel.cor, nivel.cor.withValues(alpha: 0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(nivel.icone, color: Colors.white, size: 44),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Seu bairro · ${regiao.nome}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 2),
                Text(
                  nivel == NivelRisco.normal ? 'Situação normal' : 'Situação de ${nivel.rotulo.toLowerCase()}',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text('${sensores.length} sensores monitorando agora',
                    style: const TextStyle(color: Colors.white, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Atalho {
  const _Atalho(this.titulo, this.icone, this.cor, this.acao);

  final String titulo;
  final IconData icone;
  final Color cor;
  final VoidCallback acao;
}

class _AtalhoCard extends StatelessWidget {
  const _AtalhoCard({required this.atalho});

  final _Atalho atalho;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: atalho.acao,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm + 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: atalho.cor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(atalho.icone, color: atalho.cor),
              ),
              Text(atalho.titulo,
                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.texto, height: 1.2)),
            ],
          ),
        ),
      ),
    );
  }
}
