import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmjapp/features/destination_search/domain/entities/route_location.dart';
import 'package:tmjapp/features/home/domain/entities/home_active_ride.dart';
import 'package:tmjapp/features/home/presentation/widgets/home_active_ride_card.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_product.dart';

void main() {
  testWidgets('shows an active-search card for a pending ride', (tester) async {
    var didTap = false;
    const activeRide = HomeActiveRide(
      rideId: 'ride-1',
      status: 'pending',
      origin: RouteLocation(
        title: 'Origem',
        subtitle: '',
        latitude: 0,
        longitude: 0,
      ),
      destination: RouteLocation(
        title: 'Destino',
        subtitle: '',
        latitude: 1,
        longitude: 1,
      ),
      product: RideProduct(
        id: 'car',
        name: 'Carro',
        subtitle: '',
        estimatedPrice: 14.05,
        etaLabel: 'Chegada em breve',
        badge: '',
      ),
      driverName: null,
      driverRating: null,
      vehicleModel: null,
      licensePlate: null,
      paymentMethodLabel: 'Pix',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeActiveRideCard(
            activeRide: activeRide,
            onTap: () => didTap = true,
          ),
        ),
      ),
    );

    expect(find.text('Buscando motorista'), findsOneWidget);
    expect(find.text('ACOMPANHAR BUSCA'), findsOneWidget);
    expect(find.text('Motorista parceiro'), findsNothing);
    expect(find.text('5.0'), findsNothing);

    await tester.tap(find.text('ACOMPANHAR BUSCA'));
    expect(didTap, isTrue);
  });
}
