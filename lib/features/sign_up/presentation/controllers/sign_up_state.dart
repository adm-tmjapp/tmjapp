import 'package:tmjapp/features/auth/domain/entities/auth_session.dart';

class SignUpState {
  const SignUpState({
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.password = '',
    this.confirmPassword = '',
    this.acceptedTerms = false,
    this.isLoading = false,
    this.didSignUp = false,
    this.verificationSession,
    this.errorMessage,
  });

  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String confirmPassword;
  final bool acceptedTerms;
  final bool isLoading;
  final bool didSignUp;
  final AuthSession? verificationSession;
  final String? errorMessage;

  SignUpState copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? password,
    String? confirmPassword,
    bool? acceptedTerms,
    bool? isLoading,
    bool? didSignUp,
    AuthSession? verificationSession,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return SignUpState(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      acceptedTerms: acceptedTerms ?? this.acceptedTerms,
      isLoading: isLoading ?? this.isLoading,
      didSignUp: didSignUp ?? this.didSignUp,
      verificationSession: verificationSession ?? this.verificationSession,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
