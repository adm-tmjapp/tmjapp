import 'package:tmjapp/features/ride_request/domain/entities/ride_payment_method.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_payment_option.dart';

class RidePaymentOptionsResult {
  const RidePaymentOptionsResult({
    required this.options,
    required this.selectedMethod,
  });

  final List<RidePaymentOption> options;
  final RidePaymentMethod selectedMethod;
}
