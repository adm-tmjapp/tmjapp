import 'dart:convert';

import 'package:tmjapp/api/base_api.dart';
import 'package:tmjapp/features/payments/domain/entities/payment_method_item.dart';

class PaymentsOverview {
  const PaymentsOverview({
    required this.totalSpent,
    required this.completedRides,
    required this.methods,
  });

  final double totalSpent;
  final int completedRides;
  final List<PaymentMethodItem> methods;
}

class PaymentsRemoteDataSource {
  PaymentsRemoteDataSource({BaseApi? baseApi})
      : _baseApi = baseApi ?? BaseApi();

  final BaseApi _baseApi;

  Future<PaymentsOverview> fetchOverview() async {
    final response = await _baseApi.get(Uri.parse('v2/passenger/rides'));

    if (response.statusCode != 200) {
      throw Exception('Não foi possível carregar seus pagamentos.');
    }

    final payload = jsonDecode(response.body);
    if (payload is! List) {
      return const PaymentsOverview(
          totalSpent: 0, completedRides: 0, methods: []);
    }

    double totalSpent = 0;
    int completedRides = 0;
    final methods = <String, PaymentMethodItem>{};

    for (final ride in payload.whereType<Map<String, dynamic>>()) {
      final status = (ride['status'] ?? '').toString().toLowerCase();
      final paymentMethod = (ride['payment_method'] ?? '').toString();
      final product = ride['product'] as Map<String, dynamic>?;
      final fare = ride['fare'] as Map<String, dynamic>?;

      final amount = (product?['price'] as num?)?.toDouble() ??
          (fare?['total_amount'] as num?)?.toDouble() ??
          (ride['fare'] as num?)?.toDouble() ??
          0;

      if (status == 'completed' || status == 'ongoing') {
        totalSpent += amount;
      }
      if (status == 'completed') {
        completedRides += 1;
      }

      if (paymentMethod.isEmpty) {
        continue;
      }

      methods.putIfAbsent(
        paymentMethod,
        () => _mapMethod(paymentMethod),
      );
    }

    return PaymentsOverview(
      totalSpent: totalSpent,
      completedRides: completedRides,
      methods: methods.values.toList(growable: false),
    );
  }

  PaymentMethodItem _mapMethod(String paymentMethod) {
    final normalized = paymentMethod.toLowerCase();
    if (normalized == 'pix') {
      return const PaymentMethodItem(
        id: 'pix',
        brand: 'pix',
        label: 'Pix',
        subtitle: 'Pagamento instantaneo usado no app',
      );
    }

    if (normalized == 'cash') {
      return const PaymentMethodItem(
        id: 'cash',
        brand: 'cash',
        label: 'Dinheiro',
        subtitle: 'Pagamento feito em especie',
      );
    }

    if (normalized == 'debit_card' || normalized == 'debit') {
      return const PaymentMethodItem(
        id: 'debit_card',
        brand: 'card',
        label: 'Cartão de Debito',
        subtitle: 'Metodo usado em corridas recentes',
      );
    }

    return const PaymentMethodItem(
      id: 'credit_card',
      brand: 'card',
      label: 'Cartão de Crédito',
      subtitle: 'Metodo usado em corridas recentes',
    );
  }
}
