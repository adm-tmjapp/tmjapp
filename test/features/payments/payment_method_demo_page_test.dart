import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmjapp/features/payments/presentation/pages/payment_method_demo_page.dart';

void main() {
  for (final testCase in <(PaymentMethodDemo, String, String)>[
    (
      PaymentMethodDemo.pix,
      'Pagamento via PIX',
      'Rápido, seguro e instantâneo'
    ),
    (
      PaymentMethodDemo.cash,
      'Pagamento em dinheiro',
      'Pague ao final da corrida'
    ),
    (
      PaymentMethodDemo.googlePay,
      'Google Pay',
      'Pague com sua carteira digital'
    ),
  ]) {
    testWidgets('shows ${testCase.$2} demonstration', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PaymentMethodDemoPage(method: testCase.$1),
        ),
      );

      expect(find.text(testCase.$2), findsOneWidget);
      expect(find.text(testCase.$3), findsOneWidget);
      expect(find.text('COMO FUNCIONA'), findsOneWidget);
      expect(find.text('ENTENDI'), findsOneWidget);
    });
  }

  testWidgets('closes the demonstration from the action button',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const PaymentMethodDemoPage(
                  method: PaymentMethodDemo.pix,
                ),
              ),
            ),
            child: const Text('Abrir'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('payment-method-demo-close')));
    await tester.pumpAndSettle();

    expect(find.text('Abrir'), findsOneWidget);
    expect(find.text('Pagamento via PIX'), findsNothing);
  });
}
