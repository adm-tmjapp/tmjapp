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

  Future<List<PaymentMethodItem>> fetchSavedCards() async {
    final response = await _baseApi.get(
      Uri.parse('v2/passenger/payments/methods?type=card&status=ACTIVE'),
    );

    if (response.statusCode != 200) {
      throw Exception('Não foi possível carregar seus cartões salvos.');
    }

    final payload = jsonDecode(response.body);
    final methods = payload is Map<String, dynamic> ? payload['methods'] : null;

    return (methods is List ? methods : const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .where((item) =>
            item['type']?.toString().toLowerCase() == 'card' &&
            item['status']?.toString().toUpperCase() != 'INACTIVE')
        .map(_mapSavedCard)
        .where((card) => card.id.isNotEmpty && (card.last4 ?? '').isNotEmpty)
        .toList(growable: false);
  }

  Future<PaymentMethodItem> tokenizeCard({
    required String holderName,
    required String number,
    required String expiryMonth,
    required String expiryYear,
    required String ccv,
  }) async {
    final response = await _baseApi.post(
      Uri.parse('v2/passenger/payments/methods/card-tokenize'),
      body: {
        'holderName': holderName,
        'number': number,
        'expiryMonth': expiryMonth,
        'expiryYear': expiryYear,
        'ccv': ccv,
        'setAsDefault': true,
      },
    );

    if (response.statusCode != 201) {
      throw Exception(
          _errorMessage(response.body, 'Não foi possível salvar o cartão.'));
    }

    return _mapSavedCard(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> payWithSavedCard({
    required String rideId,
    required String paymentMethodId,
  }) async {
    final response = await _baseApi.post(
      Uri.parse('v2/passenger/rides/$rideId/payments/card/saved'),
      body: {'paymentMethodId': paymentMethodId},
    );

    if (response.statusCode != 201) {
      throw Exception(
        _errorMessage(
          response.body,
          'Não foi possível processar o cartão salvo.',
        ),
      );
    }
  }

  PaymentMethodItem _mapSavedCard(Map<String, dynamic> item) {
    final brand = item['brand']?.toString().toLowerCase() ?? 'card';
    final last4 = item['last4']?.toString() ?? '';
    final holderName = item['holderName']?.toString() ?? '';
    return PaymentMethodItem(
      id: item['id']?.toString() ?? '',
      brand: brand,
      label: '${_brandLabel(brand)} •••• $last4',
      subtitle: holderName,
      last4: last4,
      holderName: holderName,
      expiry: item['expiry']?.toString() ?? '',
      isLocal: false,
    );
  }

  String _errorMessage(String body, String fallback) {
    try {
      final payload = jsonDecode(body);
      if (payload is Map<String, dynamic> && payload['message'] != null) {
        return payload['message'].toString();
      }
    } catch (_) {
      // Retorna a mensagem padrão quando a API não envia JSON.
    }
    return fallback;
  }

  String _brandLabel(String brand) {
    switch (brand.toLowerCase()) {
      case 'visa':
        return 'Visa';
      case 'mastercard':
        return 'Mastercard';
      case 'elo':
        return 'Elo';
      default:
        return 'Cartão';
    }
  }

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
