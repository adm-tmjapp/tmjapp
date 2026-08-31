import 'package:flutter/material.dart';

abstract final class RideVehicleVisuals {
  static bool isMotorcycle(String productName) {
    final normalized = productName.trim().toLowerCase();
    return normalized.contains('moto') ||
        normalized.contains('motorcycle') ||
        normalized.contains('bike');
  }

  static IconData iconFor(String productName) {
    if (isMotorcycle(productName)) {
      return Icons.two_wheeler;
    }

    final normalized = productName.trim().toLowerCase();
    if (normalized.contains('comfort')) {
      return Icons.airport_shuttle_rounded;
    }
    if (normalized.contains('black')) {
      return Icons.electric_car_rounded;
    }
    return Icons.directions_car_rounded;
  }
}
