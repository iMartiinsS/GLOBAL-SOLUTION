import 'package:flutter/material.dart';

/// Identidade visual do AlagAlerta: azul institucional (confiança, Defesa Civil),
/// ciano (água) e a escala de cores de risco usada em todo o app.
class AppColors {
  static const azul = Color(0xFF0B3D91);
  static const azulClaro = Color(0xFFE8EEF9);
  static const ciano = Color(0xFF4DD0E1);
  static const fundo = Color(0xFFF5F7FB);
  static const texto = Color(0xFF1B2333);
  static const textoSuave = Color(0xFF5B6475);

  static const normal = Color(0xFF2E7D32);
  static const atencao = Color(0xFFF9A825);
  static const alerta = Color(0xFFEF6C00);
  static const emergencia = Color(0xFFC62828);
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.azul,
    primary: AppColors.azul,
    secondary: AppColors.ciano,
    surface: Colors.white,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.fundo,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.azul,
      foregroundColor: Colors.white,
      centerTitle: false,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
