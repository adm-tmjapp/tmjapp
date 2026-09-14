import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import 'package:tmjapp/api/base_api.dart';
import 'package:tmjapp/features/profile/domain/entities/profile_details.dart';

class ProfileRemoteDataSource {
  ProfileRemoteDataSource({BaseApi? baseApi}) : _baseApi = baseApi ?? BaseApi();

  final BaseApi _baseApi;

  Future<String> updateProfilePhoto(File imageFile) async {
    try {
      if (!await imageFile.exists()) {
        throw Exception('O arquivo selecionado não está mais disponível.');
      }
      if (await imageFile.length() == 0) {
        throw Exception('A imagem selecionada está vazia.');
      }

      final uri = Uri.parse('${_baseApi.baseUrl}v2/passenger/profile/photo');
      final request = http.MultipartRequest('POST', uri);
      final mimeType = lookupMimeType(
            imageFile.path,
            headerBytes: await imageFile.openRead(0, 16).first,
          ) ??
          'image/jpeg';
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          contentType: MediaType.parse(mimeType),
        ),
      );

      // BaseApi injeta Authorization e Content-Type com o boundary correto.
      final streamedResponse = await _baseApi.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(_extractUploadError(response));
      }

      final payload = response.body.trim().isEmpty
          ? const <String, dynamic>{}
          : jsonDecode(response.body) as Map<String, dynamic>;
      final data = payload['data'] as Map<String, dynamic>?;
      final user = (payload['user'] ?? data?['user']) as Map<String, dynamic>?;
      final rawUrl = (payload['photoUrl'] ??
              payload['profilePhoto'] ??
              payload['profile_photo'] ??
              data?['photoUrl'] ??
              data?['profilePhoto'] ??
              data?['profile_photo'] ??
              user?['photoUrl'] ??
              user?['profilePhoto'] ??
              user?['profile_photo'])
          ?.toString()
          .trim();
      if (rawUrl == null || rawUrl.isEmpty) {
        throw Exception('A API não retornou a URL da foto atualizada.');
      }
      return _absolutePhotoUrl(rawUrl);
    } catch (error) {
      final message = error.toString().replaceFirst('Exception: ', '');
      if (message.startsWith('Falha no upload da imagem:')) {
        throw Exception(message);
      }
      throw Exception('Falha no upload da imagem: $message');
    }
  }

  String _absolutePhotoUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri != null && uri.hasScheme) return value;
    return Uri.parse(_baseApi.baseUrl).resolve(value).toString();
  }

  String _extractUploadError(http.Response response) {
    try {
      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final message = payload['message'] ?? payload['error'];
      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }
    } catch (_) {
      // A API pode retornar texto simples ou corpo vazio.
    }
    return 'Erro ao atualizar foto (código ${response.statusCode}).';
  }

  // --- FUNÇÕES ORIGINAIS MANTIDAS ---

  Future<ProfileDetails> fetchProfile(String userId) async {
    final response = await _baseApi.get(Uri.parse('users/users/$userId'));

    if (response.statusCode != 200) {
      throw Exception('Não foi possível carregar seu perfil.');
    }

    final payload = jsonDecode(response.body);
    final json = payload is Map<String, dynamic>
        ? (payload['user'] is Map<String, dynamic> ? payload['user'] : payload)
        : <String, dynamic>{};

    return ProfileDetails(
      userId: (json['id'] ?? json['_id'] ?? userId).toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      profilePhotoUrl: json['profilePhoto']?.toString(),
    );
  }

  Future<ProfileDetails> updateProfile({
    required String userId,
    required String name,
    required String phone,
  }) async {
    final response = await _baseApi.put(
      Uri.parse('users/users/$userId'),
      body: {
        'name': name,
        'phone': phone,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Não foi possível atualizar seu perfil.');
    }

    final payload = jsonDecode(response.body);
    final json = payload is Map<String, dynamic>
        ? (payload['user'] is Map<String, dynamic> ? payload['user'] : payload)
        : <String, dynamic>{};

    return ProfileDetails(
      userId: (json['id'] ?? json['_id'] ?? userId).toString(),
      name: (json['name'] ?? name).toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? phone).toString(),
      profilePhotoUrl: json['profilePhoto']?.toString(),
    );
  }
}
