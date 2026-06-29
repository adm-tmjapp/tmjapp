class ForgotPasswordState {
  const ForgotPasswordState({
    this.email = '',
    this.isLoading = false,
    this.didSend = false,
    this.errorMessage,
  });

  final String email;
  final bool isLoading;
  final bool didSend;
  final String? errorMessage;

  ForgotPasswordState copyWith({
    String? email,
    bool? isLoading,
    bool? didSend,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ForgotPasswordState(
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
      didSend: didSend ?? this.didSend,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
