import 'package:tmjapp/features/auth/domain/entities/remembered_auth.dart';
import 'package:tmjapp/features/auth/domain/repositories/auth_repository.dart';

class GetRememberedAuthUseCase {
  GetRememberedAuthUseCase(this._repository);

  final AuthRepository _repository;

  Future<RememberedAuth?> call() {
    return _repository.getRememberedAuth();
  }
}
