class SignInState {
  const SignInState({
    this.identifier = '',
    this.password = '',
    this.rememberMe = false,
    this.isLoading = false,
    this.canUseBiometrics = false,
    this.biometricLabel = 'Entrar com biometria',
    this.errorMessage,
    this.didLogin = false,
  });

  final String identifier;
  final String password;
  final bool rememberMe;
  final bool isLoading;
  final bool canUseBiometrics;
  final String biometricLabel;
  final String? errorMessage;
  final bool didLogin;

  SignInState copyWith({
    String? identifier,
    String? password,
    bool? rememberMe,
    bool? isLoading,
    bool? canUseBiometrics,
    String? biometricLabel,
    String? errorMessage,
    bool clearError = false,
    bool? didLogin,
  }) {
    return SignInState(
      identifier: identifier ?? this.identifier,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
      isLoading: isLoading ?? this.isLoading,
      canUseBiometrics: canUseBiometrics ?? this.canUseBiometrics,
      biometricLabel: biometricLabel ?? this.biometricLabel,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      didLogin: didLogin ?? this.didLogin,
    );
  }
}
