import 'package:tmjapp/features/auth/domain/entities/auth_session.dart';
import 'package:tmjapp/features/auth/domain/repositories/auth_repository.dart';

class SignUpUseCase {
  const SignUpUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthSession> call({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) {
    return _repository.signUp(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );
  }
}
