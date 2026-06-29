import 'package:tmjapp/features/destination_search/domain/entities/route_location.dart';
import 'package:tmjapp/features/destination_search/domain/repositories/destination_search_repository.dart';

class GetCurrentRouteOriginUseCase {
  const GetCurrentRouteOriginUseCase(this._repository);

  final DestinationSearchRepository _repository;

  Future<RouteLocation> execute() {
    return _repository.getCurrentLocation();
  }
}
