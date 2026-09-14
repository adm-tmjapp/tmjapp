import 'package:tmjapp/features/splash/data/datasources/splash_local_datasource.dart';
import 'package:tmjapp/features/splash/domain/repositories/splash_repository.dart';
import 'package:tmjapp/features/forgot_password/data/password_reset_local_data_source.dart';

class SplashRepositoryImpl implements SplashRepository {
  SplashRepositoryImpl(this._localDataSource);

  final SplashLocalDataSource _localDataSource;

  @override
  Future<bool> hasSavedSession() async {
    final token = await _localDataSource.getSavedToken();
    return token != null && token.trim().isNotEmpty;
  }

  @override
  Future<bool> hasPendingPasswordReset() async {
    return await PasswordResetLocalDataSource().getPendingEmail() != null;
  }
}
