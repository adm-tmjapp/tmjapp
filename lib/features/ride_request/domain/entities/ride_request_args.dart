import 'package:tmjapp/features/destination_search/domain/entities/route_location.dart';
import 'package:tmjapp/features/home/domain/entities/home_location.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_product.dart';

class RideRequestArgs {
  const RideRequestArgs({
    required this.userId,
    required this.origin,
    required this.destination,
    required this.routePoints,
    this.existingRideId,
    this.existingRideStatus,
    this.initialProduct,
    this.initialPaymentMethodLabel,
    this.friendDriverId,
    this.friendDriverName,
    this.friendDriverPhone,
  });

  final String userId;
  final RouteLocation origin;
  final RouteLocation destination;
  final List<HomeLocation> routePoints;
  final String? existingRideId;
  final String? existingRideStatus;
  final RideProduct? initialProduct;
  final String? initialPaymentMethodLabel;
  final String? friendDriverId;
  final String? friendDriverName;
  final String? friendDriverPhone;

  bool get isFriendRide => (friendDriverId ?? '').trim().isNotEmpty;

  bool get hasExistingRide =>
      (existingRideId ?? '').trim().isNotEmpty &&
      (existingRideStatus ?? '').trim().isNotEmpty;
}
