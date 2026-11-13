import 'package:tmjapp/features/auth/domain/entities/biometric_login_status.dart';
import 'package:tmjapp/features/auth/domain/repositories/auth_repository.dart';

class SetBiometricEnabledUseCase {
  SetBiometricEnabledUseCase(this._repository);

  final AuthRepository _repository;

  Future<BiometricLoginStatus> call(bool enabled) {
    return _repository.setBiometricEnabled(enabled);
  }
}
