class RideEtaSnapshot {
  const RideEtaSnapshot({
    required this.rideId,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.capturedAt,
  });

  final String rideId;
  final String status;
  final double? latitude;
  final double? longitude;
  final DateTime? capturedAt;

  bool get hasDriverLocation => latitude != null && longitude != null;
}
