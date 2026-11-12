import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import 'home_shell.dart';

/// Tela 1 — Login com formulário validado (`Form` + `GlobalKey<FormState>`).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const rota = '/';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _senhaVisivel = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  String? _validarEmail(String? valor) {
    final email = valor?.trim() ?? '';
    if (email.isEmpty) return 'Informe seu e-mail';
    final regex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.]+$');
    if (!regex.hasMatch(email)) return 'E-mail inválido';
    return null;
  }

  String? _validarSenha(String? valor) {
    if (valor == null || valor.isEmpty) return 'Informe sua senha';
    if (valor.length < 8) return 'A senha tem pelo menos 8 caracteres';
    return null;
  }

  void _entrar() {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim().toLowerCase();
    final ok = email == MockData.usuarioTeste.email && _senhaController.text == MockData.senhaTeste;
    if (!ok) {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.lock_outline, color: AppColors.emergencia),
          title: const Text('Não foi possível entrar'),
          content: const Text('E-mail ou senha incorretos. Confira os dados e tente novamente.'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bem-vinda, ${MockData.usuarioTeste.nome.split(' ').first}!')),
    );
    // passagem de parâmetro: o usuário logado segue para a tela principal
    Navigator.pushReplacementNamed(context, HomeShell.rota, arguments: MockData.usuarioTeste);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset('assets/images/logo.png', height: 110),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'AlagAlerta',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.azul),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  const Text(
                    'Saiba antes da água chegar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: AppColors.textoSuave),
                  ),
                  const SizedBox(height: AppSpacing.lg + 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: _validarEmail,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _senhaController,
                    obscureText: !_senhaVisivel,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _entrar(),
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        tooltip: _senhaVisivel ? 'Ocultar senha' : 'Mostrar senha',
                        icon: Icon(_senhaVisivel ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _senhaVisivel = !_senhaVisivel),
                      ),
                    ),
                    validator: _validarSenha,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton.icon(
                    onPressed: _entrar,
                    icon: const Icon(Icons.login),
                    label: const Text('Entrar'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md - 4),
                    decoration: BoxDecoration(
                      color: AppColors.azulClaro,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.azul, size: 20),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Usuário de teste: cidadao@alagalerta.com · senha Teste@2026',
                            style: TextStyle(fontSize: 13, color: AppColors.texto),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
