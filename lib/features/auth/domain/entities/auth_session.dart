class AuthSession {
  const AuthSession({
    required this.token,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
  });

  final String token;
  final String userId;
  final String name;
  final String? email;
  final String? phone;
}
