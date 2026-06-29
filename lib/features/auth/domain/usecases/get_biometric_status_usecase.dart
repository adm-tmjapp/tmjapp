import 'package:tmjapp/features/auth/domain/entities/biometric_login_status.dart';
import 'package:tmjapp/features/auth/domain/repositories/auth_repository.dart';

class GetBiometricStatusUseCase {
  GetBiometricStatusUseCase(this._repository);

  final AuthRepository _repository;

  Future<BiometricLoginStatus> call() {
    return _repository.getBiometricStatus();
  }
}
