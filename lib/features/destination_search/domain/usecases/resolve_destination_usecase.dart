import 'package:tmjapp/features/destination_search/domain/entities/place_suggestion.dart';
import 'package:tmjapp/features/destination_search/domain/entities/route_location.dart';
import 'package:tmjapp/features/destination_search/domain/repositories/destination_search_repository.dart';

class ResolveDestinationUseCase {
  const ResolveDestinationUseCase(this._repository);

  final DestinationSearchRepository _repository;

  Future<RouteLocation> execute(PlaceSuggestion suggestion) {
    return _repository.getPlaceDetails(suggestion);
  }
}
