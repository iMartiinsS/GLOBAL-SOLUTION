import 'package:alagalerta_app/data/api_client.dart';
import 'package:alagalerta_app/data/app_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'login, alertas, sensores, envio e consulta de ocorrência na API real',
    () async {
      AppData.demo = false;
      AppData.api = ApiClient(
        baseUrl: const String.fromEnvironment(
          'TEST_API_URL',
          defaultValue: 'http://127.0.0.1:8080',
        ),
      );
      try {
        final usuario = await AppData.login(
          'cidadao@alagalerta.com',
          'Teste@2026',
        );
        expect(usuario.email, 'cidadao@alagalerta.com');
        expect(AppData.regioes, isNotEmpty);
        expect(AppData.sensores, isNotEmpty);
        expect(AppData.alertas, isNotEmpty);
        final descricao =
            'Teste Flutter integrado ${DateTime.now().millisecondsSinceEpoch}';
        final criada = await AppData.registrar(
          descricao: descricao,
          endereco: 'Rua de teste, 123',
          regiao: usuario.regiao,
          alturaAguaCm: 25,
          pessoasAfetadas: 2,
        );
        expect(criada.id, greaterThan(0));
        await AppData.refresh();
        expect(
          AppData.ocorrencias.any(
            (o) => o.id == criada.id && o.descricao == descricao,
          ),
          isTrue,
        );
        AppData.logout();
        expect(AppData.api.token, isNull);
        await expectLater(
          AppData.login(usuario.email, 'senhaerrada1'),
          throwsA(isA<ApiException>()),
        );
        expect(AppData.ocorrencias, isEmpty);
      } finally {
        AppData.logout();
        AppData.api.close();
      }
    },
    skip: !const bool.fromEnvironment('RUN_LIVE_API'),
  );
}
