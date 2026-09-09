class FriendDriver {
  const FriendDriver({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.rating,
    this.vehicle,
    this.licensePlate,
  });

  final String id;
  final String name;
  final String phoneNumber;
  final double? rating;
  final String? vehicle;
  final String? licensePlate;
}
