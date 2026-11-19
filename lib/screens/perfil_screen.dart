import 'package:flutter/material.dart';

import '../models/models.dart';
import '../data/app_data.dart';
import '../theme/app_theme.dart';
import 'dicas_screen.dart';
import 'login_screen.dart';

/// Tela 9 — Perfil e preferências de notificação (estado local com setState).
class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key, required this.usuario});

  final Usuario usuario;

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  bool _notificacoes = true;
  bool _somAlto = true;
  bool _soMeuBairro = false;
  NivelRisco _nivelMinimo = NivelRisco.atencao;

  void _sair() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair do AlagAlerta?'),
        content: const Text(
          'Você deixará de receber alertas neste aparelho até entrar novamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              AppData.logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                LoginScreen.rota,
                (_) => false,
              );
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.usuario;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Perfil'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.azul,
                    child: Text(
                      u.nome[0],
                      style: const TextStyle(color: Colors.white, fontSize: 26),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          u.nome,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          u.email,
                          style: const TextStyle(color: AppColors.textoSuave),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            const Icon(
                              Icons.home_outlined,
                              size: 16,
                              color: AppColors.azul,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              '${u.regiao.nome} · ${u.regiao.cidade}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Notificações',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  value: _notificacoes,
                  onChanged: (v) => setState(() => _notificacoes = v),
                  title: const Text('Receber alertas'),
                  secondary: const Icon(Icons.notifications_active_outlined),
                ),
                SwitchListTile(
                  value: _somAlto,
                  onChanged: _notificacoes
                      ? (v) => setState(() => _somAlto = v)
                      : null,
                  title: const Text('Tocar alarme mesmo no silencioso'),
                  subtitle: const Text('Somente para Emergência'),
                  secondary: const Icon(Icons.volume_up_outlined),
                ),
                SwitchListTile(
                  value: _soMeuBairro,
                  onChanged: _notificacoes
                      ? (v) => setState(() => _soMeuBairro = v)
                      : null,
                  title: const Text('Somente do meu bairro'),
                  secondary: const Icon(Icons.my_location),
                ),
                ListTile(
                  enabled: _notificacoes,
                  leading: const Icon(Icons.tune),
                  title: const Text('Avisar a partir de'),
                  trailing: DropdownButton<NivelRisco>(
                    value: _nivelMinimo,
                    underline: const SizedBox.shrink(),
                    onChanged: _notificacoes
                        ? (n) => setState(() => _nivelMinimo = n!)
                        : null,
                    items: [
                      for (final n in NivelRisco.values.skip(1))
                        DropdownMenuItem(
                          value: n,
                          child: Text(n.rotulo, style: TextStyle(color: n.cor)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _notificacoes
                ? 'Você será avisado de alertas de ${_nivelMinimo.rotulo.toLowerCase()} ou mais graves'
                      '${_soMeuBairro ? ' no ${u.regiao.nome}' : ' em todas as regiões'}.'
                : 'Alertas desativados. Você só verá avisos ao abrir o app.',
            style: TextStyle(
              color: _notificacoes
                  ? AppColors.textoSuave
                  : AppColors.emergencia,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.health_and_safety_outlined),
                  title: const Text('Como se proteger'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(context, DicasScreen.rota),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.public),
                  title: Text('ODS 11 e 13 da ONU'),
                  subtitle: Text(
                    'Cidades sustentáveis e ação contra a mudança do clima',
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.logout,
                    color: AppColors.emergencia,
                  ),
                  title: const Text(
                    'Sair',
                    style: TextStyle(color: AppColors.emergencia),
                  ),
                  onTap: _sair,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
