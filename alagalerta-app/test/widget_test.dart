import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alagalerta_app/main.dart';
import 'package:alagalerta_app/data/app_data.dart';

void main() {
  setUp(() {
    AppData.demo = true;
    AppData.logout();
  });
  testWidgets('login valida campos vazios e entra com usuário de teste', (
    tester,
  ) async {
    await tester.pumpWidget(const AlagAlertaApp());

    await tester.tap(find.text('Entrar'));
    await tester.pump();
    expect(find.text('Informe seu e-mail'), findsOneWidget);
    expect(find.text('Informe sua senha'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'cidadao@alagalerta.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'Teste@2026');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('Olá, Maria'), findsOneWidget);
    expect(find.textContaining('Seu bairro · Jardim Pantanal'), findsOneWidget);
  });

  testWidgets('senha errada mostra AlertDialog', (tester) async {
    await tester.pumpWidget(const AlagAlertaApp());
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'cidadao@alagalerta.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'senhaerrada1');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
  });
}
