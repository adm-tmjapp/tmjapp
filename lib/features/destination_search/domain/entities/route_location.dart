class RouteLocation {
  const RouteLocation({
    required this.title,
    required this.subtitle,
    required this.latitude,
    required this.longitude,
  });

  final String title;
  final String subtitle;
  final double latitude;
  final double longitude;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory RouteLocation.fromJson(Map<String, dynamic> json) {
    return RouteLocation(
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
    );
  }
}
