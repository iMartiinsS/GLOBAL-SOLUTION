import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../utils/formatos.dart';
import 'reportar_screen.dart';

/// Tela 7 — Lista de ocorrências com filtro por status (estado) e inclusão de novos relatos.
/// Ao voltar do formulário com uma ocorrência, setState atualiza a lista e o contador.
class OcorrenciasScreen extends StatefulWidget {
  const OcorrenciasScreen({super.key, required this.usuario});

  final Usuario usuario;

  @override
  State<OcorrenciasScreen> createState() => _OcorrenciasScreenState();
}

class _OcorrenciasScreenState extends State<OcorrenciasScreen> {
  StatusOcorrencia? _filtro;

  Future<void> _novoRelato() async {
    final criada = await Navigator.push<Ocorrencia>(
      context,
      MaterialPageRoute(
        builder: (_) => ReportarScreen(regiaoInicial: widget.usuario.regiao),
      ),
    );
    if (criada != null) {
      setState(() => MockData.ocorrencias.insert(0, criada));
    }
  }

  void _remover(Ocorrencia o) {
    setState(() => MockData.ocorrencias.remove(o));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Relato #${o.id} removido'),
        action: SnackBarAction(
          label: 'Desfazer',
          onPressed: () => setState(() => MockData.ocorrencias.insert(0, o)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todas = MockData.ocorrencias;
    final lista = _filtro == null
        ? todas
        : todas.where((o) => o.status == _filtro).toList();
    final abertas = todas
        .where((o) => o.status == StatusOcorrencia.aberta)
        .length;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Ocorrências'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _novoRelato,
        icon: const Icon(Icons.add),
        label: const Text('Novo relato'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            color: AppColors.azulClaro,
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                const Icon(Icons.pending_actions, color: AppColors.azul),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Ocorrências abertas: $abertas',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.azul,
                  ),
                ),
                const Spacer(),
                Text(
                  'Total: ${todas.length}',
                  style: const TextStyle(color: AppColors.textoSuave),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: FilterChip(
                    label: const Text('Todas'),
                    selected: _filtro == null,
                    onSelected: (_) => setState(() => _filtro = null),
                  ),
                ),
                for (final s in StatusOcorrencia.values)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: FilterChip(
                      avatar: Icon(s.icone, size: 18),
                      label: Text(s.rotulo),
                      selected: _filtro == s,
                      onSelected: (_) => setState(() => _filtro = s),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: lista.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhuma ocorrência neste filtro.',
                      style: TextStyle(color: AppColors.textoSuave),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      0,
                      AppSpacing.md,
                      90,
                    ),
                    itemCount: lista.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, i) => _OcorrenciaCard(
                      ocorrencia: lista[i],
                      onRemover: lista[i].status == StatusOcorrencia.aberta
                          ? () => _remover(lista[i])
                          : null,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _OcorrenciaCard extends StatelessWidget {
  const _OcorrenciaCard({required this.ocorrencia, this.onRemover});

  final Ocorrencia ocorrencia;
  final VoidCallback? onRemover;

  Color get _corStatus => switch (ocorrencia.status) {
    StatusOcorrencia.aberta => AppColors.alerta,
    StatusOcorrencia.emAtendimento => AppColors.azul,
    StatusOcorrencia.resolvida => AppColors.normal,
  };

  @override
  Widget build(BuildContext context) {
    final o = ocorrencia;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md - 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(o.status.icone, color: _corStatus, size: 20),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  o.status.rotulo,
                  style: TextStyle(
                    color: _corStatus,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  '#${o.id} · ${tempoRelativo(o.registradaEm)}',
                  style: const TextStyle(
                    color: AppColors.textoSuave,
                    fontSize: 12,
                  ),
                ),
                if (onRemover != null)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Remover relato',
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: onRemover,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              o.descricao,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.texto,
                height: 1.3,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(
                  Icons.place_outlined,
                  size: 16,
                  color: AppColors.textoSuave,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    '${o.endereco} · ${o.regiao.nome}',
                    style: const TextStyle(
                      color: AppColors.textoSuave,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            if ((o.alturaAguaCm ?? 0) > 0 || (o.pessoasAfetadas ?? 0) > 0) ...[
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  if ((o.alturaAguaCm ?? 0) > 0) ...[
                    const Icon(
                      Icons.height,
                      size: 16,
                      color: AppColors.textoSuave,
                    ),
                    Text(
                      ' ${o.alturaAguaCm} cm   ',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                  if ((o.pessoasAfetadas ?? 0) > 0) ...[
                    const Icon(
                      Icons.groups_outlined,
                      size: 16,
                      color: AppColors.textoSuave,
                    ),
                    Text(
                      ' ${o.pessoasAfetadas} pessoas',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
