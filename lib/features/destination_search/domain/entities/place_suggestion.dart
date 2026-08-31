class PlaceSuggestion {
  const PlaceSuggestion({
    required this.title,
    required this.subtitle,
    required this.placeId,
    this.query = '',
  });

  final String title;
  final String subtitle;
  final String placeId;
  final String query;
}
