import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class RideBackgroundNotification {
  static const _channel = MethodChannel('tmjapp/ride_notification');

  bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<void> requestPermission() async {
    if (!_isAndroid) return;
    try {
      await _channel.invokeMethod<void>('requestPermission');
    } on PlatformException {
      // A corrida continua normalmente se a permissão for recusada.
    }
  }

  Future<void> show({
    required String title,
    required String message,
  }) async {
    if (!_isAndroid) return;
    try {
      await _channel.invokeMethod<void>('show', {
        'title': title,
        'message': message,
      });
    } on PlatformException {
      // Não interrompe o fluxo principal por uma falha de notificação.
    }
  }

  Future<void> cancel() async {
    if (!_isAndroid) return;
    try {
      await _channel.invokeMethod<void>('cancel');
    } on PlatformException {
      // A sincronização do estado da corrida permanece independente.
    }
  }
}
