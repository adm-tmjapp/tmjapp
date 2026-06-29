import 'package:tmjapp/features/ride_request/domain/entities/ride_payment_options_result.dart';
import 'package:tmjapp/features/ride_request/domain/repositories/ride_request_repository.dart';

class GetRidePaymentOptionsUseCase {
  const GetRidePaymentOptionsUseCase(this._repository);

  final RideRequestRepository _repository;

  Future<RidePaymentOptionsResult> execute(String rideId) {
    return _repository.getRidePaymentOptions(rideId);
  }
}
