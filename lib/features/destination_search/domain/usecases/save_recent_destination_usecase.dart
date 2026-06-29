import 'package:tmjapp/features/destination_search/domain/entities/route_location.dart';
import 'package:tmjapp/features/destination_search/domain/repositories/destination_search_repository.dart';

class SaveRecentDestinationUseCase {
  const SaveRecentDestinationUseCase(this._repository);

  final DestinationSearchRepository _repository;

  Future<void> execute(RouteLocation location) {
    return _repository.saveRecentDestination(location);
  }
}
