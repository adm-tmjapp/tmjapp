import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmjapp/features/destination_search/domain/entities/route_location.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_payment_method.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_payment_option.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_product.dart';
import 'package:tmjapp/features/ride_request/presentation/widgets/ride_confirm_sheet.dart';

void main() {
  testWidgets('highlights the complete selected vehicle card', (tester) async {
    var selectedIndex = 0;
    const products = [
      RideProduct(
        id: 'car',
        name: 'Carro',
        subtitle: 'Descrição',
        estimatedPrice: 14.05,
        etaLabel: 'Chegada em breve',
        badge: '',
      ),
      RideProduct(
        id: 'motorcycle',
        name: 'Moto',
        subtitle: 'Descrição',
        estimatedPrice: 10,
        etaLabel: 'Chegada em breve',
        badge: '',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => RideConfirmSheet(
              origin: const RouteLocation(
                title: 'Origem',
                subtitle: '',
                latitude: 0,
                longitude: 0,
              ),
              destination: const RouteLocation(
                title: 'Destino',
                subtitle: '',
                latitude: 1,
                longitude: 1,
              ),
              isLoading: false,
              products: products,
              selectedProductIndex: selectedIndex,
              selectedPaymentMethod: RidePaymentMethod.pix,
              paymentOptions: const [
                RidePaymentOption(
                  method: RidePaymentMethod.pix,
                  label: 'Pix',
                  subtitle: '',
                  isDefault: true,
                ),
              ],
              onSelectProduct: (index) {
                setState(() => selectedIndex = index);
              },
              onSelectPaymentMethod: (_) {},
              onEditOrigin: () {},
              onEditDestination: () {},
              onRequestRide: () {},
            ),
          ),
        ),
      ),
    );

    BoxDecoration decorationFor(String id) {
      final card = tester.widget<AnimatedContainer>(
        find.byKey(ValueKey('ride-product-$id')),
      );
      return card.decoration! as BoxDecoration;
    }

    expect(decorationFor('car').color, const Color(0xFFFDF2F8));
    expect(decorationFor('motorcycle').color, const Color(0xFFF8FAFC));

    final motorcycleCard =
        find.byKey(const ValueKey('ride-product-motorcycle'));
    await tester.ensureVisible(motorcycleCard);
    await tester.pumpAndSettle();
    await tester.tap(motorcycleCard);
    await tester.pumpAndSettle();

    expect(selectedIndex, 1);
    expect(decorationFor('motorcycle').color, const Color(0xFFFDF2F8));
    expect(
      (decorationFor('motorcycle').border! as Border).top.color,
      const Color(0xFFC92D7A),
    );
    expect(decorationFor('car').color, const Color(0xFFF8FAFC));
  });
}
