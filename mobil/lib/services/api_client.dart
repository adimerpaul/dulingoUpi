import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/app_config.dart';
import 'session_service.dart';

class ApiException implements Exception {
  const ApiException(this.message, [this.statusCode]);

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient(this._session);

  final SessionService _session;

  Future<Map<String, dynamic>> get(String path) {
    return _request('GET', path);
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) {
    return _request('POST', path, body: body);
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final token = await _session.getToken();
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$path');
    final headers = {
      'Content-Type': 'application/json',
      'bypass-tunnel-reminder': 'true',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = switch (method) {
      'POST' => await http.post(uri, headers: headers, body: jsonEncode(body)),
      _ => await http.get(uri, headers: headers),
    };

    final decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 401) {
      await _session.clear();
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        '${decoded['message'] ?? 'Error de servidor'}',
        response.statusCode,
      );
    }

    return decoded;
  }
}
