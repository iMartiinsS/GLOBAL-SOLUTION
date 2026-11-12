import 'package:flutter/material.dart';

import '../models/models.dart';

/// Etiqueta colorida com o nível de risco (mesma cor em todo o app).
class NivelBadge extends StatelessWidget {
  const NivelBadge({super.key, required this.nivel, this.compacto = false});

  final NivelRisco nivel;
  final bool compacto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compacto ? 8 : 10, vertical: compacto ? 3 : 5),
      decoration: BoxDecoration(
        color: nivel.cor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: nivel.cor.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(nivel.icone, size: compacto ? 14 : 16, color: nivel.cor),
          const SizedBox(width: 4),
          Text(
            nivel.rotulo.toUpperCase(),
            style: TextStyle(
              color: nivel.cor,
              fontWeight: FontWeight.w700,
              fontSize: compacto ? 11 : 12,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
