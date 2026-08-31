import 'package:tmjapp/features/destination_search/domain/entities/route_location.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_detail.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_eta_snapshot.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_payment_method.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_payment_options_result.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_product.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_quote.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_realtime_session.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_status_snapshot.dart';

abstract class RideRequestRepository {
  Future<RideQuote> createRideQuote({
    required String userId,
    required RouteLocation origin,
    required RouteLocation destination,
  });

  Future<RideStatusSnapshot> checkoutRide({
    required String rideId,
    required RideProduct product,
    required RidePaymentMethod paymentMethod,
  });

  Future<RideStatusSnapshot> getRideStatus(String rideId);

  Future<void> updateRideRoute({
    required String rideId,
    RouteLocation? origin,
    RouteLocation? destination,
    List<RouteLocation>? stops,
  });

  Future<RidePaymentOptionsResult> getRidePaymentOptions(String rideId);

  Future<RideDetail> getRideDetail(String rideId);

  Future<RideEtaSnapshot> getRideEta(String rideId);

  Future<RideRealtimeSession> issueRideRealtimeToken(String rideId);

  Future<void> cancelRide({
    required String rideId,
    String? reason,
  });
}
