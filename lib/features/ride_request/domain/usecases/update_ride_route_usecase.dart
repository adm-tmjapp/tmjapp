import 'package:tmjapp/features/destination_search/domain/entities/route_location.dart';
import 'package:tmjapp/features/ride_request/domain/repositories/ride_request_repository.dart';

class UpdateRideRouteUseCase {
  const UpdateRideRouteUseCase(this._repository);

  final RideRequestRepository _repository;

  Future<void> execute({
    required String rideId,
    RouteLocation? origin,
    RouteLocation? destination,
    List<RouteLocation>? stops,
  }) {
    return _repository.updateRideRoute(
      rideId: rideId,
      origin: origin,
      destination: destination,
      stops: stops,
    );
  }
}
