import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tmjapp/api/base_api.dart';

class RideChatMessage {
  const RideChatMessage(
      {required this.id,
      required this.content,
      required this.senderId,
      required this.senderRole,
      required this.createdAt,
      required this.isMine});
  factory RideChatMessage.fromJson(Map<String, dynamic> json) =>
      RideChatMessage(
          id: '${json['id'] ?? json['_id'] ?? ''}',
          content: '${json['content'] ?? ''}',
          senderId: '${json['senderId'] ?? ''}',
          senderRole: '${json['senderRole'] ?? 'driver'}',
          createdAt:
              DateTime.tryParse('${json['createdAt'] ?? ''}') ?? DateTime.now(),
          isMine: json['isMine'] == true);
  final String id;
  final String content;
  final String senderId;
  final String senderRole;
  final DateTime createdAt;
  final bool isMine;
}

class RideChatApi {
  RideChatApi({BaseApi? api}) : _api = api ?? BaseApi();
  final BaseApi _api;
  Future<List<RideChatMessage>> list(String rideId) async {
    final response =
        await _api.get(Uri.parse('v2/passenger/rides/$rideId/messages'));
    if (response.statusCode < 200 || response.statusCode >= 300)
      throw Exception(_errorMessage(response));
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['messages'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(RideChatMessage.fromJson)
        .toList();
  }

  Future<RideChatMessage> send(String rideId, String content) async {
    final response = await _api.post(
        Uri.parse('v2/passenger/rides/$rideId/messages'),
        body: {'content': content});
    if (response.statusCode < 200 || response.statusCode >= 300)
      throw Exception(_errorMessage(response));
    return RideChatMessage.fromJson(((jsonDecode(response.body)
        as Map<String, dynamic>)['message']) as Map<String, dynamic>);
  }

  Future<void> markRead(String rideId) async =>
      _api.patch(Uri.parse('v2/passenger/rides/$rideId/messages/read'));
  String _errorMessage(http.Response response) {
    try {
      return (jsonDecode(response.body) as Map<String, dynamic>)['message']
              ?.toString() ??
          'Não foi possível carregar o chat.';
    } catch (_) {
      return 'Não foi possível carregar o chat.';
    }
  }
}
