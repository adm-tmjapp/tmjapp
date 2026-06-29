import 'package:tmjapp/features/ride_request/domain/entities/ride_eta_snapshot.dart';
import 'package:tmjapp/features/ride_request/domain/repositories/ride_request_repository.dart';

class GetRideEtaUseCase {
  const GetRideEtaUseCase(this._repository);

  final RideRequestRepository _repository;

  Future<RideEtaSnapshot> execute(String rideId) {
    return _repository.getRideEta(rideId);
  }
}
