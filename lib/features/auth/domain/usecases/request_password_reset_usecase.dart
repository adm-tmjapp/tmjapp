import 'package:tmjapp/features/auth/domain/repositories/auth_repository.dart';

class RequestPasswordResetUseCase {
  RequestPasswordResetUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call(String email) {
    return _repository.requestPasswordReset(email);
  }
}
