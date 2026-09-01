import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmjapp/features/auth/domain/entities/auth_session.dart';
import 'package:tmjapp/features/auth/domain/entities/remembered_auth.dart';
import 'package:tmjapp/utils/strings.dart';

class AuthLocalDataSource {
  static const _biometricEnabledKey = 'auth.biometric.enabled';

  Future<RememberedAuth?> getRememberedAuth() async {
    final preferences = await SharedPreferences.getInstance();
    final identifier = preferences.getString(Strings.prefEmail);
    final password = preferences.getString(Strings.prefPassword);
    final biometricEnabled = preferences.getBool(_biometricEnabledKey) ?? false;

    if (identifier == null ||
        identifier.trim().isEmpty ||
        password == null ||
        password.isEmpty) {
      return null;
    }

    return RememberedAuth(
      identifier: identifier,
      password: password,
      rememberMe: true,
      biometricEnabled: biometricEnabled,
    );
  }

  Future<void> saveSession(
    AuthSession session, {
    required String identifier,
    required String password,
    required bool rememberMe,
    required bool biometricEnabled,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(Strings.prefToken, session.token);
    await preferences.setString(Strings.prefName, session.name);
    await preferences.setString(Strings.prefNumber, session.phone ?? '');
    await preferences.setString(Strings.prefUserId, session.userId);

    if (rememberMe) {
      await preferences.setString(Strings.prefEmail, identifier);
      await preferences.setString(Strings.prefPassword, password);
      await preferences.setBool(_biometricEnabledKey, biometricEnabled);
    } else {
      await preferences.remove(Strings.prefEmail);
      await preferences.remove(Strings.prefPassword);
      await preferences.setBool(_biometricEnabledKey, false);
    }
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_biometricEnabledKey, enabled);
  }

  Future<void> updateRememberedPassword(String newPassword) async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.containsKey(Strings.prefPassword)) {
      await preferences.setString(Strings.prefPassword, newPassword);
    }
  }
}
