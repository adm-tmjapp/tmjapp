class BiometricLoginStatus {
  const BiometricLoginStatus({
    required this.isSupported,
    required this.isEnabled,
    required this.hasSavedCredentials,
    required this.label,
  });

  const BiometricLoginStatus.unavailable()
      : isSupported = false,
        isEnabled = false,
        hasSavedCredentials = false,
        label = 'Biometria indisponível';

  final bool isSupported;
  final bool isEnabled;
  final bool hasSavedCredentials;
  final String label;

  bool get canLogin => isSupported && isEnabled && hasSavedCredentials;
}
