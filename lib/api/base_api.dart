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

  @override
  Future<Response> get(Uri url, {Map<String, String>? headers}) {
    return super.get(Uri.parse(baseUrl + url.toString()), headers: headers);
  }

  @override
  Future<Response> post(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    return super.post(Uri.parse(baseUrl + url.toString()),
        headers: headers, body: jsonEncode(body), encoding: encoding);
  }

  @override
  Future<Response> put(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    final requestBody = body is Map || body is List ? jsonEncode(body) : body;
    return super.put(Uri.parse(baseUrl + url.toString()),
        headers: headers, body: requestBody, encoding: encoding);
  }

  @override
  Future<Response> patch(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    final requestBody = body is Map || body is List ? jsonEncode(body) : body;
    return super.patch(Uri.parse(baseUrl + url.toString()),
        headers: headers, body: requestBody, encoding: encoding);
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    await initData();
    if (_token != null) {
      request.headers['Authorization'] = 'Bearer $_token';
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
    _token = _prefs?.getString(Strings.prefToken) ??
        _prefs?.getString('access_token') ??
        _apiAuthToken;
  }
}
