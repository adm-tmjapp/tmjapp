import 'package:tmjapp/features/destination_search/domain/entities/route_location.dart';
import 'package:tmjapp/features/destination_search/domain/repositories/destination_search_repository.dart';

class GetRecentDestinationsUseCase {
  const GetRecentDestinationsUseCase(this._repository);

  final DestinationSearchRepository _repository;

  Future<List<RouteLocation>> execute() {
    return _repository.getRecentDestinations();
  }
}
