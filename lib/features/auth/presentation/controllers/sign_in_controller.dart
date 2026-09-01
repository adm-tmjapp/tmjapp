import 'package:flutter/foundation.dart';
import 'package:tmjapp/core/presentation/controllers/disposable_change_notifier.dart';
import 'package:tmjapp/features/auth/domain/usecases/get_biometric_status_usecase.dart';
import 'package:tmjapp/features/auth/domain/usecases/get_remembered_auth_usecase.dart';
import 'package:tmjapp/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:tmjapp/features/auth/domain/usecases/sign_in_with_biometrics_usecase.dart';

import 'sign_in_state.dart';

class SignInController extends ChangeNotifier with DisposableChangeNotifier {
  SignInController({
    required GetRememberedAuthUseCase getRememberedAuthUseCase,
    required GetBiometricStatusUseCase getBiometricStatusUseCase,
    required SignInUseCase signInUseCase,
    required SignInWithBiometricsUseCase signInWithBiometricsUseCase,
  })  : _getRememberedAuthUseCase = getRememberedAuthUseCase,
        _getBiometricStatusUseCase = getBiometricStatusUseCase,
        _signInUseCase = signInUseCase,
        _signInWithBiometricsUseCase = signInWithBiometricsUseCase;

  final GetRememberedAuthUseCase _getRememberedAuthUseCase;
  final GetBiometricStatusUseCase _getBiometricStatusUseCase;
  final SignInUseCase _signInUseCase;
  final SignInWithBiometricsUseCase _signInWithBiometricsUseCase;

  SignInState _state = const SignInState();
  SignInState get state => _state;

  Future<void> initialize() async {
    final rememberedAuth = await _getRememberedAuthUseCase();
    if (isDisposed) return;
    final biometricStatus = await _getBiometricStatusUseCase();
    if (isDisposed) return;

    _state = _state.copyWith(
      identifier: rememberedAuth?.identifier ?? '',
      password: rememberedAuth?.password ?? '',
      rememberMe: rememberedAuth?.rememberMe ?? false,
      canUseBiometrics: biometricStatus.canLogin,
      biometricLabel: biometricStatus.label,
      isInitialized: true,
      clearError: true,
    );
    notifyListeners();
  }

  void updateIdentifier(String value) {
    _state = _state.copyWith(
      identifier: value,
      clearError: true,
      didLogin: false,
    );
    notifyListeners();
  }

  void updatePassword(String value) {
    _state = _state.copyWith(
      password: value,
      clearError: true,
      didLogin: false,
    );
    notifyListeners();
  }

  void toggleRememberMe(bool value) {
    _state = _state.copyWith(
      rememberMe: value,
      clearError: true,
      didLogin: false,
    );
    notifyListeners();
  }

  Future<void> signIn() async {
    final identifier = _state.identifier.trim();
    if (identifier.isEmpty || _state.password.isEmpty) {
      _state = _state.copyWith(
        errorMessage: 'Informe seu e-mail ou telefone e sua senha.',
      );
      notifyListeners();
      return;
    }

    _state = _state.copyWith(
      isLoading: true,
      clearError: true,
      didLogin: false,
    );
    notifyListeners();

    try {
      await _signInUseCase(
        identifier: identifier,
        password: _state.password,
        rememberMe: _state.rememberMe,
      );
      if (isDisposed) return;
      final biometricStatus = await _getBiometricStatusUseCase();
      if (isDisposed) return;
      _state = _state.copyWith(
        isLoading: false,
        didLogin: true,
        canUseBiometrics: biometricStatus.canLogin,
        biometricLabel: biometricStatus.label,
      );
    } catch (error) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: error.toString().replaceFirst('Exception: ', ''),
      );
    }
    notifyListeners();
  }

  Future<void> signInWithBiometrics() async {
    _state = _state.copyWith(
      isLoading: true,
      clearError: true,
      didLogin: false,
    );
    notifyListeners();

    try {
      await _signInWithBiometricsUseCase();
      if (isDisposed) return;
      _state = _state.copyWith(
        isLoading: false,
        didLogin: true,
      );
    } catch (error) {
      final message = error.toString().replaceFirst('Exception: ', '');
      _state = _state.copyWith(
        isLoading: false,
        errorMessage:
            message == 'Autenticacao biometrica cancelada.' ? null : message,
      );
    }
    notifyListeners();
  }
}
