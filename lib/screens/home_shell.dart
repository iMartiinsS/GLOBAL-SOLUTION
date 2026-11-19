import 'package:flutter/material.dart';

import '../data/app_data.dart';
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
  @override
  void initState() {
    super.initState();
    AppData.revision.addListener(_atualizar);
  }

  void _atualizar() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    AppData.revision.removeListener(_atualizar);
    super.dispose();
  }

  void _irPara(int aba) => setState(() => _abaAtual = aba);

  @override
  Widget build(BuildContext context) {
    // parâmetro recebido da tela de login via Navigator.pushReplacementNamed.
    // A sessão permanece em memória enquanto o app estiver aberto.
    final usuario =
        ModalRoute.of(context)?.settings.arguments as Usuario? ??
        AppData.usuario!;

    final abas = <Widget>[
      InicioScreen(usuario: usuario, onAbrirAba: _irPara),
      const SensoresScreen(),
      OcorrenciasScreen(usuario: usuario),
      PerfilScreen(usuario: usuario),
    ];

    // O botão "voltar" não desloga: fora da aba Início ele volta para o Início; no Início ele não faz nada.
    // Para sair, use Perfil → Sair.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _abaAtual != 0) _irPara(0);
      },
      child: Scaffold(
        body: IndexedStack(index: _abaAtual, children: abas),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _abaAtual,
          onDestinationSelected: _irPara,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Início',
            ),
            NavigationDestination(
              icon: Icon(Icons.sensors_outlined),
              selectedIcon: Icon(Icons.sensors),
              label: 'Sensores',
            ),
            NavigationDestination(
              icon: Icon(Icons.report_outlined),
              selectedIcon: Icon(Icons.report),
              label: 'Ocorrências',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
