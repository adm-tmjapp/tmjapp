abstract class SplashRepository {
  Future<bool> hasSavedSession();
  Future<bool> hasPendingPasswordReset();
}
