import 'package:tmjapp/features/destination_search/domain/entities/route_location.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_product.dart';

class HomeActiveRide {
  const HomeActiveRide({
    required this.rideId,
    required this.status,
    required this.origin,
    required this.destination,
    required this.product,
    required this.driverName,
    required this.driverRating,
    required this.vehicleModel,
    required this.licensePlate,
    required this.paymentMethodLabel,
  });

  final String rideId;
  final String status;
  final RouteLocation origin;
  final RouteLocation destination;
  final RideProduct product;
  final String? driverName;
  final double? driverRating;
  final String? vehicleModel;
  final String? licensePlate;
  final String? paymentMethodLabel;

  bool get isOngoing => status.trim().toLowerCase() == 'ongoing';

  String get statusLabel => isOngoing ? 'Em curso' : 'A caminho';

  String? get vehicleSummary {
    final model = vehicleModel?.trim();
    final plate = licensePlate?.trim();
    if ((model ?? '').isEmpty && (plate ?? '').isEmpty) {
      return null;
    }

    if ((model ?? '').isNotEmpty && (plate ?? '').isNotEmpty) {
      return '$model • $plate';
    }

    return (model ?? plate)!;
  }
}
