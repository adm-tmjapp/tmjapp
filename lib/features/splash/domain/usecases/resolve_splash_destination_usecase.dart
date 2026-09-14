import 'package:tmjapp/features/splash/domain/entities/splash_destination.dart';
import 'package:tmjapp/features/splash/domain/repositories/splash_repository.dart';

class ResolveSplashDestinationUseCase {
  ResolveSplashDestinationUseCase(this._repository);

  final SplashRepository _repository;

  Future<SplashDestination> call() async {
    final hasSavedSession = await _repository.hasSavedSession();
    if (hasSavedSession) return SplashDestination.dashboard;
    final hasPendingPasswordReset = await _repository.hasPendingPasswordReset();
    return hasPendingPasswordReset
        ? SplashDestination.resetPassword
        : SplashDestination.signIn;
  }
}
