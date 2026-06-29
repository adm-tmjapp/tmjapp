import 'package:tmjapp/features/destination_search/domain/entities/place_suggestion.dart';
import 'package:tmjapp/features/destination_search/domain/repositories/destination_search_repository.dart';

class SearchPlacesUseCase {
  const SearchPlacesUseCase(this._repository);

  final DestinationSearchRepository _repository;

  Future<List<PlaceSuggestion>> execute(String input) {
    return _repository.searchPlaces(input);
  }
}
