import 'dart:convert';

import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmjapp/core/config/app_config.dart';
import 'package:tmjapp/utils/strings.dart';

class BaseApi extends BaseClient {
  final String baseUrl = AppConfig.instance.apiBaseUrl;
  Client client = Client();
  SharedPreferences? _prefs;
  String? _token;

  BaseApi() {
    initData();
  }

  @override
  Future<Response> get(Uri url, {Map<String, String>? headers}) {
    return super.get(Uri.parse(baseUrl + url.toString()), headers: headers);
  }

  @override
  Future<Response> post(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    // TODO: implement post
    return super.post(Uri.parse(baseUrl + url.toString()),
        headers: headers, body: jsonEncode(body), encoding: encoding);
  }

  @override
  Future<Response> put(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    final requestBody =
        body is Map || body is List ? jsonEncode(body) : body;
    return super.put(Uri.parse(baseUrl + url.toString()),
        headers: headers, body: requestBody, encoding: encoding);
  }

  @override
  Future<Response> patch(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    final requestBody =
        body is Map || body is List ? jsonEncode(body) : body;
    return super.patch(Uri.parse(baseUrl + url.toString()),
        headers: headers, body: requestBody, encoding: encoding);
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    await initData();
    request.headers.addAll({
      if (_token != null) 'Authorization': 'Bearer $_token',
      'Content-Type': 'application/json',
    });
    return client.send(request);
  }

  Future<void> initData() async {
    _prefs = await SharedPreferences.getInstance();
    _token = _prefs?.getString(Strings.prefToken) ??
        _prefs?.getString('access_token') ??
        AppConfig.instance.apiAuthToken;
  }
}
