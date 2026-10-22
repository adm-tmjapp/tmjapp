import 'dart:convert';

import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmjapp/core/config/app_config.dart';
import 'package:tmjapp/utils/strings.dart';

class BaseApi extends BaseClient {
  BaseApi({String? baseUrl, Client? client, String? apiAuthToken})
      : baseUrl = baseUrl ?? AppConfig.instance.apiBaseUrl,
        client = client ?? Client(),
        _apiAuthToken = apiAuthToken ??
            (baseUrl == null ? AppConfig.instance.apiAuthToken : null) {
    initData();
  }

  final String baseUrl;
  final Client client;
  final String? _apiAuthToken;
  SharedPreferences? _prefs;
  String? _token;

  Uri resolveUri(Uri url) {
    if (url.hasScheme) return url;

    final base = Uri.parse(baseUrl);
    final basePath = base.path.replaceFirst(RegExp(r'/+$'), '');
    var relativePath = url.path.replaceFirst(RegExp(r'^/+'), '');
    if (basePath.endsWith('/api/v2') && relativePath.startsWith('v2/')) {
      relativePath = relativePath.substring(3);
    }

    final path =
        [basePath, relativePath].where((part) => part.isNotEmpty).join('/');
    return base.replace(
      path: path,
      query: url.hasQuery ? url.query : null,
      fragment: url.hasFragment ? url.fragment : null,
    );
  }

  @override
  Future<Response> get(Uri url, {Map<String, String>? headers}) {
    return super.get(resolveUri(url), headers: headers);
  }

  @override
  Future<Response> post(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    final requestHeaders = <String, String>{...?headers};
    requestHeaders.putIfAbsent('Content-Type', () => 'application/json');
    return super.post(resolveUri(url),
        headers: requestHeaders, body: jsonEncode(body), encoding: encoding);
  }

  @override
  Future<Response> put(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    final requestBody = body is Map || body is List ? jsonEncode(body) : body;
    final requestHeaders = <String, String>{...?headers};
    requestHeaders.putIfAbsent('Content-Type', () => 'application/json');
    return super.put(resolveUri(url),
        headers: requestHeaders, body: requestBody, encoding: encoding);
  }

  @override
  Future<Response> patch(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    final requestBody = body is Map || body is List ? jsonEncode(body) : body;
    final requestHeaders = <String, String>{...?headers};
    requestHeaders.putIfAbsent('Content-Type', () => 'application/json');
    return super.patch(resolveUri(url),
        headers: requestHeaders, body: requestBody, encoding: encoding);
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    await initData();
    final existingAuthorization = request.headers['Authorization'];
    final token = _token?.trim();
    if ((existingAuthorization == null || existingAuthorization.isEmpty) &&
        token != null &&
        token.isNotEmpty) {
      // Alguns fluxos legados podem persistir o esquema junto com o token.
      // Evita enviar "Bearer Bearer <token>", que a API rejeita com 401.
      final normalizedToken = token
          .replaceFirst(RegExp(r'^Bearer\s+', caseSensitive: false), '')
          .trim();
      if (normalizedToken.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $normalizedToken';
      }
    }
    // MultipartRequest cria seu próprio Content-Type com boundary. Sobrescrevê-lo
    // com application/json torna o arquivo ilegível para o servidor.
    if (request is! MultipartRequest) {
      request.headers.putIfAbsent('Content-Type', () => 'application/json');
    }
    return client.send(request);
  }

  Future<void> initData() async {
    _prefs = await SharedPreferences.getInstance();
    final candidates = [
      _prefs?.getString(Strings.prefToken),
      _prefs?.getString('access_token'),
      _apiAuthToken,
    ];
    _token = candidates
        .whereType<String>()
        .map((value) => value.trim())
        .firstWhere((value) => value.isNotEmpty, orElse: () => '');
  }
}
