import 'package:flutter_test/flutter_test.dart';
import 'package:tmjapp/features/splash/domain/entities/splash_destination.dart';
import 'package:tmjapp/features/splash/domain/repositories/splash_repository.dart';
import 'package:tmjapp/features/splash/domain/usecases/resolve_splash_destination_usecase.dart';

class _SplashRepositoryStub implements SplashRepository {
  _SplashRepositoryStub({
    required this.savedSession,
    required this.pendingPasswordReset,
  });

  final bool savedSession;
  final bool pendingPasswordReset;

  @override
  Future<bool> hasSavedSession() async => savedSession;

  @override
  Future<bool> hasPendingPasswordReset() async => pendingPasswordReset;
}

void main() {
  test('resumes a pending password reset for a signed-out user', () async {
    final useCase = ResolveSplashDestinationUseCase(
      _SplashRepositoryStub(
        savedSession: false,
        pendingPasswordReset: true,
      ),
    );

    expect(await useCase(), SplashDestination.resetPassword);
  });

  test('keeps an authenticated session as the highest priority', () async {
    final useCase = ResolveSplashDestinationUseCase(
      _SplashRepositoryStub(
        savedSession: true,
        pendingPasswordReset: true,
      ),
    );

    expect(await useCase(), SplashDestination.dashboard);
  });

  test('opens sign in when there is no session or pending reset', () async {
    final useCase = ResolveSplashDestinationUseCase(
      _SplashRepositoryStub(
        savedSession: false,
        pendingPasswordReset: false,
      ),
    );

    expect(await useCase(), SplashDestination.signIn);
  });
}
