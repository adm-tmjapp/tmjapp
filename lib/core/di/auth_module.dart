import 'package:local_auth/local_auth.dart';
import 'package:tmjapp/api/auth_api.dart';
import 'package:tmjapp/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:tmjapp/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:tmjapp/features/auth/data/datasources/biometric_local_datasource.dart';
import 'package:tmjapp/features/auth/data/repositories/auth_repository_impl.dart';

AuthRepositoryImpl createAuthRepository() {
  return AuthRepositoryImpl(
    remoteDataSource: AuthRemoteDataSource(Authapi()),
    localDataSource: AuthLocalDataSource(),
    biometricDataSource: BiometricLocalDataSource(LocalAuthentication()),
  );
}
