import 'package:tmjapp/features/ride_request/domain/entities/ride_product.dart';

class RideQuote {
  const RideQuote({
    required this.rideId,
    required this.products,
  });

  final String rideId;
  final List<RideProduct> products;
}
