import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Tela 8 — Orientações de segurança (antes, durante e depois da enchente) e telefones úteis.
class DicasScreen extends StatelessWidget {
  const DicasScreen({super.key});

  static const rota = '/dicas';

  static const _secoes = [
    (
      'Antes da chuva',
      Icons.event_available,
      AppColors.azul,
      [
        'Cadastre-se para receber alertas do seu bairro.',
        'Guarde documentos e remédios em sacos plásticos, em local alto.',
        'Combine um ponto de encontro seguro com a família.',
      ],
    ),
    (
      'Durante o alagamento',
      Icons.flood,
      AppColors.emergencia,
      [
        'Não atravesse ruas alagadas a pé ou de carro: 30 cm de água arrastam um carro.',
        'Desligue a energia elétrica se a água entrar em casa.',
        'Fique longe de córregos, bueiros e fios caídos.',
      ],
    ),
    (
      'Depois que a água baixar',
      Icons.cleaning_services_outlined,
      AppColors.normal,
      [
        'Use botas e luvas na limpeza — risco de leptospirose.',
        'Descarte alimentos que tiveram contato com a água.',
        'Só religue a energia após verificar a fiação.',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Como se proteger')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Center(child: Image.asset('assets/images/logo.png', height: 90)),
          const SizedBox(height: AppSpacing.md),
          for (final (titulo, icone, cor, itens) in _secoes) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(icone, color: cor),
                        const SizedBox(width: AppSpacing.sm),
                        Text(titulo, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: cor)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    for (final item in itens)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs + 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.check, size: 18, color: cor),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(child: Text(item, style: const TextStyle(height: 1.3))),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm + 4),
          ],
          const Text('Telefones de emergência',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.texto)),
          const SizedBox(height: AppSpacing.sm),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            children: const [
              _Telefone(numero: '199', nome: 'Defesa Civil', icone: Icons.shield),
              _Telefone(numero: '193', nome: 'Bombeiros', icone: Icons.local_fire_department),
              _Telefone(numero: '192', nome: 'SAMU', icone: Icons.medical_services),
            ],
          ),
        ],
      ),
    );
  }
}

class _Telefone extends StatelessWidget {
  const _Telefone({required this.numero, required this.nome, required this.icone});

  final String numero;
  final String nome;
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icone, color: AppColors.emergencia),
          const SizedBox(height: AppSpacing.xs),
          Text(numero, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          Text(nome, style: const TextStyle(fontSize: 12, color: AppColors.textoSuave)),
        ],
      ),
    );
  }
}
