import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmjapp/features/ride_request/presentation/utils/ride_vehicle_visuals.dart';

void main() {
  group('RideVehicleVisuals', () {
    test('usa o icone de carro para produtos de carro', () {
      expect(
        RideVehicleVisuals.iconFor('Carro'),
        Icons.directions_car_rounded,
      );
      expect(RideVehicleVisuals.isMotorcycle('Carro'), isFalse);
    });

    test('usa o icone de moto para produtos de moto', () {
      expect(RideVehicleVisuals.iconFor('Moto'), Icons.two_wheeler);
      expect(RideVehicleVisuals.isMotorcycle('Moto'), isTrue);
    });

    test('identifica nomes alternativos de motocicleta', () {
      expect(RideVehicleVisuals.isMotorcycle('Motorcycle'), isTrue);
      expect(RideVehicleVisuals.isMotorcycle('Bike Express'), isTrue);
    });
  });
}
