import 'package:tmjapp/features/destination_search/domain/entities/route_location.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_detail.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_eta_snapshot.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_payment_method.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_payment_options_result.dart';
import 'package:tmjapp/features/ride_request/data/datasources/ride_request_remote_datasource.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_product.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_quote.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_realtime_session.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_status_snapshot.dart';
import 'package:tmjapp/features/ride_request/domain/repositories/ride_request_repository.dart';

class RideRequestRepositoryImpl implements RideRequestRepository {
  RideRequestRepositoryImpl({
    required RideRequestRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final RideRequestRemoteDataSource _remoteDataSource;

  @override
  Future<RideQuote> createRideQuote({
    required String userId,
    required RouteLocation origin,
    required RouteLocation destination,
  }) {
    return _remoteDataSource.createRideQuote(
      userId: userId,
      origin: origin,
      destination: destination,
    );
  }

  @override
  Future<RideStatusSnapshot> checkoutRide({
    required String rideId,
    required RideProduct product,
    required RidePaymentMethod paymentMethod,
  }) {
    return _remoteDataSource.checkoutRide(
      rideId: rideId,
      product: product,
      paymentMethod: paymentMethod,
    );
  }

  @override
  Future<RideStatusSnapshot> getRideStatus(String rideId) {
    return _remoteDataSource.getRideStatus(rideId);
  }

  @override
  Future<RidePaymentOptionsResult> getRidePaymentOptions(String rideId) {
    return _remoteDataSource.getRidePaymentOptions(rideId);
  }

  @override
  Future<RideDetail> getRideDetail(String rideId) {
    return _remoteDataSource.getRideDetail(rideId);
  }

  @override
  Future<RideEtaSnapshot> getRideEta(String rideId) {
    return _remoteDataSource.getRideEta(rideId);
  }

  @override
  Future<RideRealtimeSession> issueRideRealtimeToken(String rideId) {
    return _remoteDataSource.issueRideRealtimeToken(rideId);
  }

  @override
  Future<void> cancelRide({
    required String rideId,
    String? reason,
  }) {
    return _remoteDataSource.cancelRide(
      rideId: rideId,
      reason: reason,
    );
  }
}
