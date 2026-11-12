import 'package:flutter/material.dart';

import 'screens/dicas_screen.dart';
import 'screens/home_shell.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const AlagAlertaApp());
}

class AlagAlertaApp extends StatelessWidget {
  const AlagAlertaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AlagAlerta',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      initialRoute: LoginScreen.rota,
      routes: {
        LoginScreen.rota: (_) => const LoginScreen(),
        HomeShell.rota: (_) => const HomeShell(),
        DicasScreen.rota: (_) => const DicasScreen(),
      },
    );
  }
}
