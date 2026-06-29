class TripHistoryItem {
  const TripHistoryItem({
    required this.id,
    required this.title,
    required this.driverName,
    required this.vehicle,
    required this.dateLabel,
    required this.status,
    required this.price,
    required this.mapColorHex,
    required this.originTitle,
    required this.originSubtitle,
    required this.destinationTitle,
    required this.destinationSubtitle,
    required this.distanceLabel,
    required this.durationLabel,
    required this.paymentLabel,
    required this.plate,
    required this.rating,
    required this.latitude, // <-- Adicionado
    required this.longitude, // <-- Adicionado
  });

  final String id;
  final String title;
  final String driverName;
  final String vehicle;
  final String dateLabel;
  final String status;
  final double price;
  final int mapColorHex;
  final String originTitle;
  final String originSubtitle;
  final String destinationTitle;
  final String destinationSubtitle;
  final String distanceLabel;
  final String durationLabel;
  final String paymentLabel;
  final String plate;
  final double rating;
  final double latitude; // <-- Adicionado
  final double longitude; // <-- Adicionado
}
