import 'package:tmjapp/features/ride_request/domain/repositories/ride_request_repository.dart';

class CancelRideUseCase {
  const CancelRideUseCase(this._repository);

  final RideRequestRepository _repository;

  Future<void> execute({
    required String rideId,
    String? reason,
  }) {
    return _repository.cancelRide(
      rideId: rideId,
      reason: reason,
    );
  }
}
