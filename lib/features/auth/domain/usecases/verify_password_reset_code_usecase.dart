import 'package:tmjapp/features/auth/domain/repositories/auth_repository.dart';

class VerifyPasswordResetCodeUseCase {
  VerifyPasswordResetCodeUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({
    required String email,
    required String code,
  }) {
    return _repository.verifyPasswordResetCode(
      email: email,
      code: code,
    );
  }
}
