import 'package:tmjapp/features/ride_request/domain/entities/ride_payment_method.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_product.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_status_snapshot.dart';
import 'package:tmjapp/features/ride_request/domain/repositories/ride_request_repository.dart';

class CheckoutRideUseCase {
  const CheckoutRideUseCase(this._repository);

  final RideRequestRepository _repository;

  Future<RideStatusSnapshot> execute({
    required String rideId,
    required RideProduct product,
    required RidePaymentMethod paymentMethod,
  }) {
    return _repository.checkoutRide(
      rideId: rideId,
      product: product,
      paymentMethod: paymentMethod,
    );
  }
}
