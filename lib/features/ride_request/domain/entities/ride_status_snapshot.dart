class RideStatusSnapshot {
  const RideStatusSnapshot({
    required this.rideId,
    required this.status,
    required this.updatedAt,
  });

  final String rideId;
  final String status;
  final DateTime? updatedAt;
}
