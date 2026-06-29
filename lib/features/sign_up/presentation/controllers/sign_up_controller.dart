import 'package:flutter/foundation.dart';
import 'package:tmjapp/core/presentation/controllers/disposable_change_notifier.dart';
import 'package:tmjapp/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:tmjapp/features/sign_up/presentation/controllers/sign_up_state.dart';

class SignUpController extends ChangeNotifier with DisposableChangeNotifier {
  SignUpController({
    required SignUpUseCase signUpUseCase,
  }) : _signUpUseCase = signUpUseCase;

  final SignUpUseCase _signUpUseCase;

  SignUpState _state = const SignUpState();

  SignUpState get state => _state;

  void updateFullName(String value) =>
      _update(_state.copyWith(fullName: value));
  void updateEmail(String value) => _update(_state.copyWith(email: value));
  void updatePhone(String value) => _update(_state.copyWith(phone: value));
  void updatePassword(String value) =>
      _update(_state.copyWith(password: value));
  void updateConfirmPassword(String value) =>
      _update(_state.copyWith(confirmPassword: value));
  void toggleAcceptedTerms(bool value) =>
      _update(_state.copyWith(acceptedTerms: value, clearErrorMessage: true));

  Future<void> signUp() async {
    final validationError = _validate();
    if (validationError != null) {
      _update(_state.copyWith(errorMessage: validationError));
      return;
    }

    _update(
      _state.copyWith(
        isLoading: true,
        clearErrorMessage: true,
      ),
    );

    try {
      await _signUpUseCase(
        name: _state.fullName.trim(),
        email: _state.email.trim(),
        phone: _normalizedPhone,
        password: _state.password,
      );
      if (isDisposed) return;

      _update(
        _state.copyWith(
          isLoading: false,
          didSignUp: true,
          clearErrorMessage: true,
        ),
      );
    } catch (error) {
      _update(
        _state.copyWith(
          isLoading: false,
          errorMessage: error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  String get _normalizedPhone => _state.phone.replaceAll(RegExp(r'[^0-9]'), '');

  String? _validate() {
    if (_state.fullName.trim().isEmpty) {
      return 'Informe seu nome completo.';
    }
    if (_state.email.trim().isEmpty) {
      return 'Informe seu e-mail.';
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(_state.email.trim())) {
      return 'Informe um e-mail valido.';
    }
    if (_normalizedPhone.length < 10) {
      return 'Informe um telefone valido.';
    }
    if (_state.password.length < 6) {
      return 'Crie uma senha com pelo menos 6 caracteres.';
    }
    if (_state.password != _state.confirmPassword) {
      return 'As senhas não conferem.';
    }
    if (!_state.acceptedTerms) {
      return 'Voce precisa aceitar os termos para continuar.';
    }

    return null;
  }

  void _update(SignUpState value) {
    _state = value;
    notifyListeners();
  }
}
