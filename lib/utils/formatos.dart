String doisDigitos(int n) => n.toString().padLeft(2, '0');

String horaMinuto(DateTime d) => '${doisDigitos(d.hour)}:${doisDigitos(d.minute)}';

String dataHora(DateTime d) => '${doisDigitos(d.day)}/${doisDigitos(d.month)} às ${horaMinuto(d)}';

/// "há 5 min", "há 2 h", "há 1 dia".
String tempoRelativo(DateTime d) {
  final diff = DateTime.now().difference(d);
  if (diff.inMinutes < 1) return 'agora';
  if (diff.inMinutes < 60) return 'há ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'há ${diff.inHours} h';
  final dias = diff.inDays;
  return 'há $dias ${dias == 1 ? 'dia' : 'dias'}';
}
