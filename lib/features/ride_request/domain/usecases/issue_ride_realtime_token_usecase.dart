import 'package:tmjapp/features/ride_request/domain/entities/ride_realtime_session.dart';
import 'package:tmjapp/features/ride_request/domain/repositories/ride_request_repository.dart';

class IssueRideRealtimeTokenUseCase {
  const IssueRideRealtimeTokenUseCase(this._repository);

  final RideRequestRepository _repository;

  Future<RideRealtimeSession> execute(String rideId) {
    return _repository.issueRideRealtimeToken(rideId);
  }
}
