class RememberedAuth {
  const RememberedAuth({
    required this.identifier,
    required this.password,
    required this.rememberMe,
    required this.biometricEnabled,
  });

  final String identifier;
  final String password;
  final bool rememberMe;
  final bool biometricEnabled;
}
