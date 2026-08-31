import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmjapp/api/auth_api.dart';
import 'package:tmjapp/api/base_api.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Authapi createApi(
    Future<http.Response> Function(http.Request request) handler,
  ) {
    return Authapi(
      baseApi: BaseApi(
        baseUrl: 'https://api.example.com/api/',
        client: MockClient(handler),
      ),
    );
  }

  test('accepts a queued password reset with an empty 202 response', () async {
    final api = createApi((request) async {
      expect(request.method, 'POST');
      expect(request.url.toString(),
          'https://api.example.com/api/v2/auth/forgot-password');
      expect(jsonDecode(request.body), {'email': 'user@example.com'});
      return http.Response('', 202);
    });

    final response = await api.forgotPassword('user@example.com');

    expect(response.ok, isTrue);
    expect(response.hasException, isFalse);
  });

  test('does not report success when the API says the email was not sent',
      () async {
    final api = createApi((request) async {
      return http.Response(
        jsonEncode({
          'emailSent': false,
          'message': 'Falha ao conectar ao servidor de e-mail.',
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final response = await api.forgotPassword('user@example.com');

    expect(response.hasException, isTrue);
    expect(response.exceptionMessage, contains('servidor de e-mail'));
  });

  test('preserves the API error message when delivery fails', () async {
    final api = createApi((request) async {
      return http.Response(
        jsonEncode({'message': 'SMTP indisponível'}),
        503,
        headers: {'content-type': 'application/json'},
      );
    });

    final response = await api.forgotPassword('user@example.com');

    expect(response.hasException, isTrue);
    expect(response.exceptionMessage, contains('SMTP indisponível'));
  });
}
