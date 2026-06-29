import 'package:tmjapp/features/auth/domain/entities/auth_session.dart';
import 'package:tmjapp/features/auth/domain/repositories/auth_repository.dart';

class SignInWithBiometricsUseCase {
  SignInWithBiometricsUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthSession> call() {
    return _repository.signInWithBiometrics();
  }
}
