import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmjapp/api/base_api.dart';
import 'package:tmjapp/features/profile/data/datasources/profile_remote_datasource.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('carrega o perfil pela rota V2 autenticada', () async {
    late http.Request captured;
    final client = MockClient((request) async {
      captured = request;
      return http.Response(
        jsonEncode({
          'id': 'passenger-1',
          'name': 'Maria Silva',
          'email': 'maria@example.com',
          'phone': '81999999999',
        }),
        200,
      );
    });
    final dataSource = ProfileRemoteDataSource(
      baseApi: BaseApi(
        baseUrl: 'https://api.tmj.test/api/',
        apiAuthToken: 'token-test',
        client: client,
      ),
    );

    final profile = await dataSource.fetchProfile('passenger-1');

    expect(captured.method, 'GET');
    expect(
      captured.url.toString(),
      'https://api.tmj.test/api/v2/passenger/profile',
    );
    expect(captured.headers['authorization'], 'Bearer token-test');
    expect(profile.userId, 'passenger-1');
    expect(profile.name, 'Maria Silva');
  });

  test('atualiza o perfil pela rota V2 autenticada', () async {
    late http.Request captured;
    final client = MockClient((request) async {
      captured = request;
      return http.Response(
        jsonEncode({
          'id': 'passenger-1',
          'name': 'Maria Santos',
          'email': 'maria@example.com',
          'phone': '81888888888',
        }),
        200,
      );
    });
    final dataSource = ProfileRemoteDataSource(
      baseApi: BaseApi(
        baseUrl: 'https://api.tmj.test/api/',
        apiAuthToken: 'token-test',
        client: client,
      ),
    );

    final profile = await dataSource.updateProfile(
      userId: 'passenger-1',
      name: 'Maria Santos',
      phone: '81888888888',
    );

    expect(captured.method, 'PUT');
    expect(
      captured.url.toString(),
      'https://api.tmj.test/api/v2/passenger/profile',
    );
    expect(jsonDecode(captured.body), {
      'name': 'Maria Santos',
      'phone': '81888888888',
    });
    expect(profile.name, 'Maria Santos');
  });
}
