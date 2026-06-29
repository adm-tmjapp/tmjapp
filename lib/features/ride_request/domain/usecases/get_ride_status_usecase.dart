import 'package:tmjapp/features/ride_request/domain/entities/ride_status_snapshot.dart';
import 'package:tmjapp/features/ride_request/domain/repositories/ride_request_repository.dart';

class GetRideStatusUseCase {
  const GetRideStatusUseCase(this._repository);

  final RideRequestRepository _repository;

  Future<RideStatusSnapshot> execute(String rideId) {
    return _repository.getRideStatus(rideId);
  }
}
