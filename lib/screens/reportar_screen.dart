import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

/// Tela 6 — Formulário de relato de alagamento.
/// `Form` + `GlobalKey<FormState>` + `TextFormField` com validação; confirmação com AlertDialog
/// e retorno do objeto criado para a tela anterior (Navigator.pop com resultado).
class ReportarScreen extends StatefulWidget {
  const ReportarScreen({super.key, required this.regiaoInicial});

  final Regiao regiaoInicial;

  @override
  State<ReportarScreen> createState() => _ReportarScreenState();
}

class _ReportarScreenState extends State<ReportarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descricao = TextEditingController();
  final _endereco = TextEditingController();
  final _altura = TextEditingController();
  final _pessoas = TextEditingController();
  late Regiao _regiao = widget.regiaoInicial;
  bool _pessoaIlhada = false;

  @override
  void dispose() {
    _descricao.dispose();
    _endereco.dispose();
    _altura.dispose();
    _pessoas.dispose();
    super.dispose();
  }

  String? _obrigatorio(String? v, String campo, {int minimo = 1}) {
    final texto = v?.trim() ?? '';
    if (texto.isEmpty) return 'Informe $campo';
    if (texto.length < minimo) return '$campo: mínimo de $minimo caracteres';
    return null;
  }

  String? _inteiro(String? v, {required int max, required String campo}) {
    if (v == null || v.trim().isEmpty) return null; // opcional
    final n = int.tryParse(v.trim());
    if (n == null) return 'Use apenas números';
    if (n < 0) return '$campo não pode ser negativo';
    if (n > max) return '$campo deve ser no máximo $max';
    return null;
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Corrija os campos destacados antes de enviar.'),
        ),
      );
      return;
    }

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.send_outlined, color: AppColors.azul),
        title: const Text('Enviar relato?'),
        content: Text(
          'Seu relato sobre "${_endereco.text.trim()}" será enviado à Defesa Civil de ${_regiao.cidade}.'
          '${_pessoaIlhada ? '\n\nComo há pessoa ilhada, ligue também para 193 (Bombeiros).' : ''}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Revisar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(100, 40)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
    if (confirmado != true || !mounted) return;

    final descricao = _descricao.text.trim();
    final ocorrencia = Ocorrencia(
      id: MockData.proximoIdOcorrencia(),
      descricao: _pessoaIlhada ? '[PESSOA ILHADA] $descricao' : descricao,
      endereco: _endereco.text.trim(),
      regiao: _regiao,
      registradaEm: DateTime.now(),
      alturaAguaCm: int.tryParse(_altura.text.trim()),
      pessoasAfetadas: int.tryParse(_pessoas.text.trim()),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.normal,
        content: Text(
          'Relato #${ocorrencia.id} enviado. Obrigado por ajudar seu bairro!',
        ),
      ),
    );
    Navigator.pop(context, ocorrencia);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reportar alagamento')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            const Text(
              'Conte o que está acontecendo. Seu relato ajuda a Defesa Civil onde ainda não há sensor.',
              style: TextStyle(color: AppColors.textoSuave),
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<Regiao>(
              initialValue: _regiao,
              decoration: const InputDecoration(
                labelText: 'Bairro',
                prefixIcon: Icon(Icons.location_city),
              ),
              items: [
                for (final r in MockData.regioes)
                  DropdownMenuItem(
                    value: r,
                    child: Text('${r.nome} · ${r.cidade}'),
                  ),
              ],
              onChanged: (r) => setState(() => _regiao = r!),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _endereco,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Endereço ou ponto de referência',
                prefixIcon: Icon(Icons.place_outlined),
              ),
              validator: (v) => _obrigatorio(v, 'o endereço', minimo: 5),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _descricao,
              maxLines: 3,
              maxLength: 300,
              decoration: const InputDecoration(
                labelText: 'O que está acontecendo?',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.edit_note),
              ),
              validator: (v) => _obrigatorio(v, 'a descrição', minimo: 10),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _altura,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Água (cm)',
                      prefixIcon: Icon(Icons.height),
                    ),
                    validator: (v) => _inteiro(v, max: 500, campo: 'Altura'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm + 4),
                Expanded(
                  child: TextFormField(
                    controller: _pessoas,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Pessoas',
                      prefixIcon: Icon(Icons.groups),
                    ),
                    validator: (v) => _inteiro(v, max: 10000, campo: 'Pessoas'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _pessoaIlhada,
              onChanged: (v) => setState(() => _pessoaIlhada = v),
              title: const Text('Há pessoa ilhada ou em risco imediato'),
              secondary: Icon(
                Icons.sos,
                color: _pessoaIlhada
                    ? AppColors.emergencia
                    : AppColors.textoSuave,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: _enviar,
              icon: const Icon(Icons.send),
              label: const Text('Enviar relato'),
            ),
          ],
        ),
      ),
    );
  }
}
