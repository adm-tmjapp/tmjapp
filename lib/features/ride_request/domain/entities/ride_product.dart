class RideProduct {
  const RideProduct({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.estimatedPrice,
    required this.etaLabel,
    required this.badge,
  });

  final String id;
  final String name;
  final String subtitle;
  final double estimatedPrice;
  final String etaLabel;
  final String badge;
}
