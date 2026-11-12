import 'package:url_launcher/url_launcher.dart';

/// Centraliza o discador usado para contato com o motorista.
///
/// O prefixo #31# solicita à operadora que o número do passageiro não seja
/// exibido. A disponibilidade pode variar conforme a operadora/região.
class DriverCallPrivacy {
  const DriverCallPrivacy._();

  static String? dialNumber(String? phone) {
    final value = phone?.trim();
    if (value == null || value.isEmpty) return null;

    final alreadyPrivate = value.startsWith('#31#');
    final rawNumber = alreadyPrivate ? value.substring(4) : value;
    final normalized = rawNumber.replaceAll(RegExp(r'[\s().-]'), '');
    if (!RegExp(r'^\+?[0-9]+$').hasMatch(normalized)) return null;

    return '#31#$normalized';
  }

  static Future<bool> launch(String? phone) {
    final number = dialNumber(phone);
    if (number == null) return Future.value(false);
    return launchUrl(Uri(scheme: 'tel', path: number));
  }
}
