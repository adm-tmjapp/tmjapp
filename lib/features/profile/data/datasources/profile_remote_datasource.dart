import 'dart:convert';
import 'dart:io'; // Adicionado para lidar com o arquivo
import 'package:http/http.dart' as http; // Adicionado para o MultipartRequest

import 'package:tmjapp/api/base_api.dart';
import 'package:tmjapp/features/profile/domain/entities/profile_details.dart';

class ProfileRemoteDataSource {
  ProfileRemoteDataSource({BaseApi? baseApi}) : _baseApi = baseApi ?? BaseApi();

  final BaseApi _baseApi;

  // --- NOVO MÉTODO (PASSO 1) ---
  Future<String> updateProfilePhoto(File imageFile) async {
    try {
      // Nota: Verifique se o seu BaseApi expõe a URL base.
      // Se não, você pode concatenar manualmente a URL.
      final uri = Uri.parse('${_baseApi.baseUrl}passenger/profile/photo');

      var request = http.MultipartRequest('POST', uri);

      // Adiciona o arquivo binário usando a chave 'file' conforme o Swagger
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
        ),
      );

      // Se o seu BaseApi gerencia tokens de autenticação,
      // você deve buscá-los e adicioná-los aqui:
      // request.headers.addAll({'Authorization': 'Bearer ...'});

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Retorna a URL da foto vinda do JSON {"photoUrl": "..."}
        return data['photoUrl']?.toString() ?? '';
      } else {
        throw Exception(
            'Erro ao atualizar foto: Código ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Falha no upload da imagem: $e');
    }
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
