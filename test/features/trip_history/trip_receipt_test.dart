import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmjapp/features/trip_history/domain/entities/trip_history_item.dart';
import 'package:tmjapp/features/trip_history/presentation/pages/trip_detail_page.dart';

void main() {
  test('maps trip payment labels to their payment method icons', () {
    expect(paymentIconForLabel('Dinheiro'), Icons.payments_rounded);
    expect(paymentIconForLabel('Cartão de Crédito'), Icons.credit_card_rounded);
    expect(paymentIconForLabel('credit_card'), Icons.credit_card_rounded);
    expect(paymentIconForLabel('Google Pay'),
        Icons.account_balance_wallet_rounded);
    expect(paymentIconForLabel('google_pay'),
        Icons.account_balance_wallet_rounded);
    expect(paymentIconForLabel('Pix'), Icons.pix_rounded);
  });

  test('buildTripReceiptText includes the trip receipt details', () {
    const item = TripHistoryItem(
      id: 'trip-123',
      title: 'Viagem para o Centro',
      driverName: 'Ana Silva',
      vehicle: 'Toyota Corolla',
      dateLabel: '02/09/2026 às 10:30',
      status: 'Concluída',
      price: 42.5,
      mapColorHex: 0xFFFFFFFF,
      originTitle: 'Casa',
      originSubtitle: 'Rua A, 10',
      destinationTitle: 'Centro',
      destinationSubtitle: 'Avenida B, 20',
      distanceLabel: '12 km',
      durationLabel: '25 min',
      paymentLabel: 'Cartão de crédito',
      plate: 'ABC1D23',
      rating: 4.9,
      latitude: -23.55,
      longitude: -46.63,
    );

    final receipt = buildTripReceiptText(item);

    expect(receipt, contains('Recibo de viagem - TMJ'));
    expect(receipt, contains('02/09/2026 às 10:30'));
    expect(receipt, contains('Casa - Rua A, 10'));
    expect(receipt, contains('Centro - Avenida B, 20'));
    expect(receipt, contains('Ana Silva'));
    expect(receipt, contains('Cartão de crédito'));
    expect(receipt, contains(r'Total: R$ 42,50'));
    expect(receipt, contains('Código da viagem: trip-123'));
  });
}
