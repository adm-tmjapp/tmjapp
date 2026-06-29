import 'package:tmjapp/features/ride_request/domain/entities/ride_detail.dart';
import 'package:tmjapp/features/ride_request/domain/repositories/ride_request_repository.dart';

class GetRideDetailUseCase {
  const GetRideDetailUseCase(this._repository);

  final RideRequestRepository _repository;

  Future<RideDetail> execute(String rideId) {
    return _repository.getRideDetail(rideId);
  }
}
