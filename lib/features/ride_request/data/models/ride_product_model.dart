import 'package:tmjapp/features/ride_request/domain/entities/ride_product.dart';

class RideProductModel extends RideProduct {
  const RideProductModel({
    required super.id,
    required super.name,
    required super.subtitle,
    required super.estimatedPrice,
    required super.etaLabel,
    required super.badge,
  });

  factory RideProductModel.fromJson(Map<String, dynamic> json) {
    final id =
        (json['id'] ?? json['product_id'] ?? json['type'] ?? json['name'] ?? '')
            .toString();
    final name = (json['name'] ?? json['type'] ?? json['title'] ?? 'TMJ Ride')
        .toString();
    final subtitle =
        (json['subtitle'] ?? json['description'] ?? 'Viagem disponivel')
            .toString();
    final estimatedPrice = _toDouble(
      json['price'] ?? json['amount'] ?? json['estimated_price'],
    );
    final etaLabel = (json['time'] ??
            json['eta'] ??
            json['arrival_time'] ??
            'Chegada em breve')
        .toString();
    final badge = (json['badge'] ?? '').toString();

    return RideProductModel(
      id: id,
      name: name,
      subtitle: subtitle,
      estimatedPrice: estimatedPrice,
      etaLabel: etaLabel,
      badge: badge,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
