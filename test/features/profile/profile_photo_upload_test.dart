import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmjapp/api/base_api.dart';
import 'package:tmjapp/features/profile/data/datasources/profile_remote_datasource.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('envia foto para a rota v2 autenticada como multipart', () async {
    SharedPreferences.setMockInitialValues({});
    late http.Request captured;
    final client = MockClient((request) async {
      captured = request;
      return http.Response('{"photoUrl":"/uploads/profile.jpg"}', 201);
    });
    final dataSource = ProfileRemoteDataSource(
      baseApi: BaseApi(
        baseUrl: 'https://api.tmj.test/api/',
        apiAuthToken: 'token-test',
        client: client,
      ),
    );
    final directory = await Directory.systemTemp.createTemp('tmj-profile-');
    final image = File('${directory.path}/profile.jpg');
    await image.writeAsBytes([0xFF, 0xD8, 0xFF, 0xD9]);

    try {
      final photoUrl = await dataSource.updateProfilePhoto(image);

      expect(captured.method, 'POST');
      expect(
        captured.url.toString(),
        'https://api.tmj.test/api/v2/passenger/profile/photo',
      );
      expect(captured.headers['authorization'], 'Bearer token-test');
      expect(
          captured.headers['content-type'], startsWith('multipart/form-data;'));
      expect(captured.bodyBytes, isNotEmpty);
      expect(photoUrl, 'https://api.tmj.test/uploads/profile.jpg');
    } finally {
      await directory.delete(recursive: true);
    }
  });
}
