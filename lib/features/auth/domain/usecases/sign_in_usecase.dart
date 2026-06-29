import 'package:tmjapp/features/auth/domain/entities/auth_session.dart';
import 'package:tmjapp/features/auth/domain/repositories/auth_repository.dart';

class SignInUseCase {
  SignInUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthSession> call({
    required String identifier,
    required String password,
    required bool rememberMe,
  }) {
    return _repository.signIn(
      identifier: identifier,
      password: password,
      rememberMe: rememberMe,
    );
  }
}
