import 'package:tmjapp/features/destination_search/domain/entities/place_suggestion.dart';
import 'package:tmjapp/features/destination_search/domain/entities/route_location.dart';

abstract class DestinationSearchRepository {
  Future<RouteLocation> getCurrentLocation();

  Future<List<PlaceSuggestion>> searchPlaces(String input);

  Future<RouteLocation> getPlaceDetails(PlaceSuggestion suggestion);

  Future<List<RouteLocation>> getRecentDestinations();

  Future<void> saveRecentDestination(RouteLocation location);
}
