import 'package:tmjapp/api/auth_api.dart';
import 'package:tmjapp/features/auth/data/models/auth_session_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._authApi);

  final Authapi _authApi;

  Future<AuthSessionModel> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await _authApi.registerPassenger(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );

    if (response.hasException) {
      throw Exception(response.exceptionMessage);
    }

    if (response.badRequest || response.result == null) {
      throw Exception('Não foi possível concluir o cadastro.');
    }

    return AuthSessionModel.fromResponse(response.result!);
  }

  Future<AuthSessionModel> signIn({
    required String identifier,
    required String password,
  }) async {
    final response = await _authApi.login(password, identifier);

    if (response.hasException) {
      throw Exception(response.exceptionMessage);
    }

    if (response.badRequest || response.result == null) {
      throw Exception(response.exceptionMessage ??
          'Não foi possível autenticar com as credenciais informadas.');
    }

    return AuthSessionModel.fromResponse(response.result!);
  }

  Future<void> requestPasswordReset(String email) async {
    final response = await _authApi.forgotPassword(email);
    if (response.hasException) {
      throw Exception(response.exceptionMessage);
    }
    if (!response.ok) {
      throw Exception('Não foi possível enviar o e-mail de recuperação.');
    }
  }

  Future<void> verifyPasswordResetCode({
    required String email,
    required String code,
  }) async {
    final response = await _authApi.verifyResetCode(email, code);
    if (response.hasException) {
      throw Exception(response.exceptionMessage);
    }
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final response = await _authApi.resetPassword(email, code, newPassword);
    if (response.hasException) {
      throw Exception(response.exceptionMessage);
    }
  }
}
