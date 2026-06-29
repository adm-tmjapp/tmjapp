import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:tmjapp/features/auth/domain/entities/biometric_login_status.dart';

class BiometricLocalDataSource {
  BiometricLocalDataSource(this._localAuth);

  final LocalAuthentication _localAuth;

  Future<BiometricLoginStatus> getStatus({required bool isEnabled}) async {
    try {
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final availableBiometrics = await _localAuth.getAvailableBiometrics();

      final isSupported = isDeviceSupported &&
          canCheckBiometrics &&
          availableBiometrics.isNotEmpty;

      return BiometricLoginStatus(
        isSupported: isSupported,
        isEnabled: isEnabled,
        hasSavedCredentials: false,
        label: _resolveLabel(availableBiometrics),
      );
    } on PlatformException {
      return const BiometricLoginStatus(
        isSupported: false,
        isEnabled: false,
        hasSavedCredentials: false,
        label: 'Entrar com biometria',
      );
    }
  }

  Future<bool> authenticate() async {
    try {
      return _localAuth.authenticate(
        localizedReason: 'Confirme sua identidade para entrar no TMJApp',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }

  String _resolveLabel(List<BiometricType> biometrics) {
    if (biometrics.contains(BiometricType.face)) {
      return 'Entrar com Face ID';
    }
    if (biometrics.contains(BiometricType.fingerprint) ||
        biometrics.contains(BiometricType.strong) ||
        biometrics.contains(BiometricType.weak)) {
      return 'Entrar com biometria';
    }
    return 'Entrar com biometria';
  }
}
