import 'dart:convert';

import 'package:alagalerta_app/data/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('consulta todas as páginas HAL e envia JWT', () async {
    final client = ApiClient(
      baseUrl: 'http://localhost:8080',
      client: MockClient((request) async {
        expect(request.headers['Authorization'], 'Bearer teste');
        final page = int.parse(request.url.queryParameters['page']!);
        return http.Response(
          jsonEncode({
            '_embedded': {
              'regioes': [
                {'id': page + 1},
              ],
            },
            'page': {'totalPages': 2},
          }),
          200,
        );
      }),
    )..token = 'teste';
    expect(await client.collection('/api/regioes', 'regioes'), [
      {'id': 1},
      {'id': 2},
    ]);
    client.close();
  });

  test('coleção HAL vazia e erro de autenticação são tratados', () async {
    final client = ApiClient(
      baseUrl: 'http://localhost:8080',
      client: MockClient((request) async {
        if (request.url.path == '/auth/login') return http.Response('{}', 401);
        return http.Response('{}', 200);
      }),
    );
    expect(await client.collection('/api/alertas/ativos', 'alertas'), isEmpty);
    await expectLater(
      client.request('POST', '/auth/login', {}),
      throwsA(isA<ApiException>()),
    );
    client.close();
  });
}
