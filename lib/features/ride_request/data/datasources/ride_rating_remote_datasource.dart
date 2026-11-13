import 'dart:convert';

import 'package:tmjapp/api/base_api.dart';

/// Persiste a avaliação do passageiro para uma corrida concluída.
///
/// O backend é responsável por associar a corrida ao motorista e recalcular a
/// média pública do perfil dele de forma atômica.
class RideRatingRemoteDataSource {
  RideRatingRemoteDataSource({BaseApi? baseApi})
      : _baseApi = baseApi ?? BaseApi();

  final BaseApi _baseApi;

  Future<void> submitDriverRating({
    required String rideId,
    required int rating,
  }) async {
    if (rideId.trim().isEmpty) {
      throw Exception('Não foi possível identificar a corrida avaliada.');
    }
    if (rating < 1 || rating > 5) {
      throw Exception('Selecione uma avaliação entre 1 e 5 estrelas.');
    }

    final response = await _baseApi.post(
      Uri.parse('v2/passenger/rides/$rideId/rating'),
      body: {'rating': rating},
    );
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    throw Exception(_errorMessage(response.body));
  }

  String _errorMessage(String body) {
    try {
      final payload = jsonDecode(body);
      if (payload is Map) {
        final message = payload['message'] ?? payload['error'];
        if (message != null && message.toString().trim().isNotEmpty) {
          return message.toString().trim();
        }
      }
    } catch (_) {
      // Mantém uma mensagem segura caso a API não retorne JSON.
    }
    return 'Não foi possível enviar sua avaliação. Tente novamente.';
  }
}
