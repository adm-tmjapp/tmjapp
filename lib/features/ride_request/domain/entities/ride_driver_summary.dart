class RideDriverSummary {
  const RideDriverSummary({
    required this.id,
    required this.name,
    required this.rating,
    required this.phoneNumber,
    required this.photoUrl,
  });

  final String? id;
  final String? name;
  final double? rating;
  final String? phoneNumber;
  final String? photoUrl;

  bool get hasData {
    return (id != null && id!.isNotEmpty) ||
        (name != null && name!.isNotEmpty) ||
        rating != null;
  }
}
