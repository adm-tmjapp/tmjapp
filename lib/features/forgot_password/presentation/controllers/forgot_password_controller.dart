import 'package:flutter/foundation.dart';
import 'package:tmjapp/core/presentation/controllers/disposable_change_notifier.dart';
import 'package:tmjapp/features/auth/domain/usecases/request_password_reset_usecase.dart';

import 'forgot_password_state.dart';

class ForgotPasswordController extends ChangeNotifier
    with DisposableChangeNotifier {
  ForgotPasswordController(this._requestPasswordResetUseCase);

  final RequestPasswordResetUseCase _requestPasswordResetUseCase;

  ForgotPasswordState _state = const ForgotPasswordState();
  ForgotPasswordState get state => _state;

  void updateEmail(String value) {
    _state = _state.copyWith(
      email: value,
      didSend: false,
      clearError: true,
    );
    notifyListeners();
  }

  Future<void> submit() async {
    if (_state.email.trim().isEmpty) {
      _state = _state.copyWith(
        errorMessage: 'Informe o e-mail cadastrado.',
      );
      notifyListeners();
      return;
    }

    _state = _state.copyWith(
      isLoading: true,
      didSend: false,
      clearError: true,
    );
    notifyListeners();

    try {
      await _requestPasswordResetUseCase(_state.email.trim());
      if (isDisposed) return;
      _state = _state.copyWith(
        isLoading: false,
        didSend: true,
      );
    } catch (error) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: error.toString().replaceFirst('Exception: ', ''),
      );
    }
    notifyListeners();
  }
}
