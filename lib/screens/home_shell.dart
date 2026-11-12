import 'package:flutter/material.dart';

import '../models/models.dart';
import 'inicio_screen.dart';
import 'ocorrencias_screen.dart';
import 'perfil_screen.dart';
import 'sensores_screen.dart';

/// Estrutura principal com barra de navegação inferior.
/// A aba selecionada é estado local (StatefulWidget + setState).
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  static const rota = '/home';

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _abaAtual = 0;

  void _irPara(int aba) => setState(() => _abaAtual = aba);

  @override
  Widget build(BuildContext context) {
    // parâmetro recebido da tela de login via Navigator.pushReplacementNamed
    final usuario = ModalRoute.of(context)!.settings.arguments as Usuario;

    final abas = <Widget>[
      InicioScreen(usuario: usuario, onAbrirAba: _irPara),
      const SensoresScreen(),
      OcorrenciasScreen(usuario: usuario),
      PerfilScreen(usuario: usuario),
    ];

    return Scaffold(
      body: IndexedStack(index: _abaAtual, children: abas),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _abaAtual,
        onDestinationSelected: _irPara,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Início'),
          NavigationDestination(icon: Icon(Icons.sensors_outlined), selectedIcon: Icon(Icons.sensors), label: 'Sensores'),
          NavigationDestination(icon: Icon(Icons.report_outlined), selectedIcon: Icon(Icons.report), label: 'Ocorrências'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
