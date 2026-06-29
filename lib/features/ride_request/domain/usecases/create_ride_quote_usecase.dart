import 'package:tmjapp/features/destination_search/domain/entities/route_location.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_quote.dart';
import 'package:tmjapp/features/ride_request/domain/repositories/ride_request_repository.dart';

class CreateRideQuoteUseCase {
  const CreateRideQuoteUseCase(this._repository);

  final RideRequestRepository _repository;

  Future<RideQuote> execute({
    required String userId,
    required RouteLocation origin,
    required RouteLocation destination,
  }) {
    return _repository.createRideQuote(
      userId: userId,
      origin: origin,
      destination: destination,
    );
  }
}
