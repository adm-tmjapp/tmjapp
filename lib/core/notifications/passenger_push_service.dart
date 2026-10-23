import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:tmjapp/api/base_api.dart';

class PassengerPushService {
  PassengerPushService._();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(alert: true, badge: true, sound: true);
      final token = await messaging.getToken();
      if (token != null && token.trim().isNotEmpty) await _register(token);
      messaging.onTokenRefresh.listen(_register);
    } catch (_) {
      // Push é opcional; falha de permissão não deve impedir o uso do app.
    }
  }

  static Future<void> _register(String token) async {
    try {
      final api = BaseApi();
      await api.post(Uri.parse('v2/passenger/device-token'), body: {
        'provider': 'fcm',
        'token': token,
        'platform': Platform.isIOS ? 'ios' : 'android',
      });
    } catch (_) {}
  }
}
