import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmjapp/api/auth_api.dart';
import 'package:tmjapp/api/base_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('envia a confirmação de senha exigida pelo cadastro v2', () async {
    SharedPreferences.setMockInitialValues({});
    late http.Request captured;
    final client = MockClient((request) async {
      captured = request;
      return http.Response(
        jsonEncode({
          'token': 'token-test',
          'user': {
            'id': 'user-1',
            'name': 'Maria Silva',
            'email': 'maria@example.com',
            'phone': '11999999999',
            'role': 'passenger',
          },
        }),
        201,
      );
    });
    final api = Authapi(
      baseApi: BaseApi(
        baseUrl: 'https://api.tmj.test/api/',
        client: client,
      ),
    );

    final result = await api.registerPassenger(
      name: 'Maria Silva',
      email: 'maria@example.com',
      phone: '11999999999',
      password: 'senha123',
      confirmPassword: 'senha123',
    );

    final body = jsonDecode(captured.body) as Map<String, dynamic>;
    expect(captured.url.path, '/api/v2/auth/register');
    expect(captured.headers['content-type'], startsWith('application/json'));
    expect(body['password'], 'senha123');
    expect(body['password_confirmation'], 'senha123');
    expect(result.hasException, isFalse);
    expect(result.result, isNotNull);
  });
}
