import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';

/// Barra horizontal com o nível atual da água e as marcas de alerta e crítico.
class NivelAguaBar extends StatelessWidget {
  const NivelAguaBar({super.key, required this.sensor, this.altura = 14});

  final Sensor sensor;
  final double altura;

  @override
  Widget build(BuildContext context) {
    final nivel = sensor.ultimaLeitura.nivel;
    final marcaAlerta = sensor.nivelAlertaCm / sensor.nivelCriticoCm;
    return LayoutBuilder(
      builder: (context, constraints) {
        final largura = constraints.maxWidth;
        return SizedBox(
          height: altura + 4,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: altura,
                decoration: BoxDecoration(
                  color: AppColors.azulClaro,
                  borderRadius: BorderRadius.circular(altura),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: altura,
                width: largura * sensor.ocupacao,
                decoration: BoxDecoration(
                  color: nivel.cor,
                  borderRadius: BorderRadius.circular(altura),
                ),
              ),
              Positioned(
                left: largura * marcaAlerta - 1,
                child: Container(
                  width: 2,
                  height: altura + 4,
                  color: AppColors.alerta,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
