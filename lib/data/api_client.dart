import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  const ApiException(this.mensagem);
  final String mensagem;
  @override
  String toString() => mensagem;
}

/// Cliente REST: JWT somente em memória e paginação HAL do Spring HATEOAS.
class ApiClient {
  ApiClient({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;
  String? token;

  Future<Map<String, dynamic>> request(
    String method,
    String path, [
    Map<String, dynamic>? body,
  ]) async {
    final request = http.Request(
      method,
      Uri.parse('${baseUrl.replaceFirst(RegExp(r'/+$'), '')}$path'),
    );
    request.headers['Accept'] = 'application/hal+json, application/json';
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }
    try {
      final response = await http.Response.fromStream(
        await _client.send(request).timeout(const Duration(seconds: 15)),
      ).timeout(const Duration(seconds: 15));
      final decoded = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        if (response.statusCode == 401) {
          throw const ApiException(
            'Sessão expirada ou e-mail/senha incorretos. Entre novamente.',
          );
        }
        throw ApiException(
          decoded is Map
              ? (decoded['mensagem'] ??
                        decoded['detail'] ??
                        'A API recusou a operação (${response.statusCode}).')
                    .toString()
              : 'A API recusou a operação (${response.statusCode}).',
        );
      }
      return Map<String, dynamic>.from(decoded as Map);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException(
        'A API demorou para responder. Tente novamente.',
      );
    } catch (_) {
      throw const ApiException(
        'Não foi possível acessar a API. Confira a conexão e o endereço configurado.',
      );
    }
  }

  Future<List<Map<String, dynamic>>> collection(
    String path,
    String relation,
  ) async {
    final result = <Map<String, dynamic>>[];
    var page = 0;
    while (true) {
      final separator = path.contains('?') ? '&' : '?';
      final data = await request('GET', '$path${separator}size=100&page=$page');
      final items = (data['_embedded'] as Map?)?[relation] as List? ?? [];
      result.addAll(
        items.map((item) => Map<String, dynamic>.from(item as Map)),
      );
      final pages = (data['page'] as Map?)?['totalPages'] as int? ?? 1;
      if (++page >= pages) return result;
    }
  }

  void close() => _client.close();
}
