import 'package:tmjapp/features/auth/domain/entities/auth_session.dart';
import 'package:tmjapp/features/auth/domain/entities/biometric_login_status.dart';
import 'package:tmjapp/features/auth/domain/entities/remembered_auth.dart';

abstract class AuthRepository {
  Future<RememberedAuth?> getRememberedAuth();
  Future<BiometricLoginStatus> getBiometricStatus();
  Future<BiometricLoginStatus> setBiometricEnabled(bool enabled);
  Future<AuthSession> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  });
  Future<AuthSession> signIn({
    required String identifier,
    required String password,
    required bool rememberMe,
  });
  Future<AuthSession> signInWithBiometrics();
  Future<void> requestPasswordReset(String email);
  Future<void> verifyPasswordResetCode({
    required String email,
    required String code,
  });
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });
  Future<void> updateRememberedPassword(String newPassword);
}
