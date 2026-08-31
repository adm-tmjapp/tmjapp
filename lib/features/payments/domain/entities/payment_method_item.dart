class PaymentMethodItem {
  const PaymentMethodItem({
    required this.id,
    required this.brand,
    required this.label,
    required this.subtitle,
    this.last4,
    this.holderName,
    this.expiry,
    this.isLocal = false,
  });

  final String id;
  final String brand;
  final String label;
  final String subtitle;
  final String? last4;
  final String? holderName;
  final String? expiry;
  final bool isLocal;
}
