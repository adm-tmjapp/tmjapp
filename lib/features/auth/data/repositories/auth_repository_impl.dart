import 'package:tmjapp/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:tmjapp/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:tmjapp/features/auth/data/datasources/biometric_local_datasource.dart';
import 'package:tmjapp/features/auth/domain/entities/auth_session.dart';
import 'package:tmjapp/features/auth/domain/entities/biometric_login_status.dart';
import 'package:tmjapp/features/auth/domain/entities/remembered_auth.dart';
import 'package:tmjapp/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
    required BiometricLocalDataSource biometricDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _biometricDataSource = biometricDataSource;

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final BiometricLocalDataSource _biometricDataSource;

  @override
  Future<RememberedAuth?> getRememberedAuth() {
    return _localDataSource.getRememberedAuth();
  }

  @override
  Future<BiometricLoginStatus> getBiometricStatus() async {
    final rememberedAuth = await _localDataSource.getRememberedAuth();
    final status = await _biometricDataSource.getStatus(
      isEnabled: rememberedAuth?.biometricEnabled ?? false,
    );

    return BiometricLoginStatus(
      isSupported: status.isSupported,
      isEnabled: rememberedAuth?.biometricEnabled ?? false,
      hasSavedCredentials: rememberedAuth != null,
      label: status.label,
    );
  }

  @override
  Future<BiometricLoginStatus> setBiometricEnabled(bool enabled) async {
    final rememberedAuth = await _localDataSource.getRememberedAuth();
    final status = await _biometricDataSource.getStatus(isEnabled: enabled);

    if (enabled) {
      if (rememberedAuth == null) {
        throw Exception(
          'Ative “Lembrar de mim” no próximo login para usar a biometria.',
        );
      }
      if (!status.isSupported) {
        throw Exception('A biometria não está disponível neste dispositivo.');
      }
      if (!await _biometricDataSource.authenticate()) {
        throw Exception('Não foi possível confirmar sua biometria.');
      }
    }

    await _localDataSource.setBiometricEnabled(enabled);
    return BiometricLoginStatus(
      isSupported: status.isSupported,
      isEnabled: enabled,
      hasSavedCredentials: rememberedAuth != null,
      label: status.label,
    );
  }

  @override
  Future<AuthSession> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final session = await _remoteDataSource.signUp(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );

    await _localDataSource.saveSession(
      session,
      identifier: email,
      password: password,
      rememberMe: false,
      biometricEnabled: false,
    );

    return session;
  }

  @override
  Future<AuthSession> signIn({
    required String identifier,
    required String password,
    required bool rememberMe,
  }) async {
    final session = await _remoteDataSource.signIn(
      identifier: identifier,
      password: password,
    );
    final biometricStatus = await _biometricDataSource.getStatus(
      isEnabled: rememberMe,
    );

    await _localDataSource.saveSession(
      session,
      identifier: identifier,
      password: password,
      rememberMe: rememberMe,
      biometricEnabled: rememberMe && biometricStatus.isSupported,
    );

    return session;
  }

  @override
  Future<AuthSession> signInWithBiometrics() async {
    final rememberedAuth = await _localDataSource.getRememberedAuth();
    if (rememberedAuth == null || !rememberedAuth.biometricEnabled) {
      throw Exception(
          'Não existem credenciais salvas para login por biometria.');
    }

    final authenticated = await _biometricDataSource.authenticate();
    if (!authenticated) {
      throw Exception('Autenticacao biometrica cancelada.');
    }

    final session = await _remoteDataSource.signIn(
      identifier: rememberedAuth.identifier,
      password: rememberedAuth.password,
    );

    await _localDataSource.saveSession(
      session,
      identifier: rememberedAuth.identifier,
      password: rememberedAuth.password,
      rememberMe: rememberedAuth.rememberMe,
      biometricEnabled: rememberedAuth.biometricEnabled,
    );

    return session;
  }

  @override
  Future<void> requestPasswordReset(String email) {
    return _remoteDataSource.requestPasswordReset(email);
  }

  @override
  Future<void> verifyPasswordResetCode({
    required String email,
    required String code,
  }) {
    return _remoteDataSource.verifyPasswordResetCode(
      email: email,
      code: code,
    );
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) {
    return _remoteDataSource.resetPassword(
      email: email,
      code: code,
      newPassword: newPassword,
    );
  }

  @override
  Future<void> updateRememberedPassword(String newPassword) {
    return _localDataSource.updateRememberedPassword(newPassword);
  }
}
