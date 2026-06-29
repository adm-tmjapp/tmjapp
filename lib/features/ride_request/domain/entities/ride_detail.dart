import 'package:tmjapp/features/ride_request/domain/entities/ride_driver_summary.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_vehicle_summary.dart';

class RideDetail {
  const RideDetail({
    required this.rideId,
    required this.status,
    required this.driver,
    required this.vehicle,
    required this.paymentMethod,
    required this.totalAmount,
  });

  final String rideId;
  final String status;
  final RideDriverSummary? driver;
  final RideVehicleSummary? vehicle;
  final String? paymentMethod;
  final double? totalAmount;
}
