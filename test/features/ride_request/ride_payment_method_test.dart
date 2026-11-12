import 'package:flutter_test/flutter_test.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_payment_method.dart';

void main() {
  test('normalizes backend cash payment values for display', () {
    expect(RidePaymentMethod.labelFromBackend('CASH'), 'Dinheiro');
    expect(RidePaymentMethod.labelFromBackend('cash'), 'Dinheiro');
    expect(RidePaymentMethod.labelFromBackend('Dinheiro'), 'Dinheiro');
  });

  test('normalizes card and pix payment values for display', () {
    expect(RidePaymentMethod.labelFromBackend('CARD'), 'Cartão');
    expect(RidePaymentMethod.labelFromBackend('PIX'), 'Pix');
  });

  test('returns null for an unknown backend value', () {
    expect(RidePaymentMethod.labelFromBackend('voucher'), isNull);
  });
}
