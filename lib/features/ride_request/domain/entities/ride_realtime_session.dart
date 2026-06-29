class RideRealtimeSession {
  const RideRealtimeSession({
    required this.dbUrl,
    required this.customToken,
    required this.expiresAt,
    required this.rideId,
    required this.role,
  });

  final String dbUrl;
  final String customToken;
  final DateTime? expiresAt;
  final String rideId;
  final String role;
}
