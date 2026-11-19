import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';
import '../utils/formatos.dart';
import 'nivel_badge.dart';

class AlertaCard extends StatelessWidget {
  const AlertaCard({super.key, required this.alerta, required this.onTap});

  final Alerta alerta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: alerta.nivel.cor, width: 6)),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  NivelBadge(nivel: alerta.nivel, compacto: true),
                  const Spacer(),
                  Text(
                    tempoRelativo(alerta.emitidoEm),
                    style: const TextStyle(
                      color: AppColors.textoSuave,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${alerta.regiao.nome} · ${alerta.regiao.cidade}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.texto,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                alerta.mensagem,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textoSuave,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
