import 'package:tmjapp/features/ride_request/domain/entities/ride_payment_method.dart';

class RidePaymentOption {
  const RidePaymentOption({
    required this.method,
    required this.label,
    required this.subtitle,
    required this.isDefault,
  });

  final RidePaymentMethod method;
  final String label;
  final String subtitle;
  final bool isDefault;
}
