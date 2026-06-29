import 'package:tmjapp/features/destination_search/domain/entities/route_location.dart';

class DestinationSearchResult {
  const DestinationSearchResult({
    required this.origin,
    required this.destination,
  });

  final RouteLocation origin;
  final RouteLocation destination;
}
