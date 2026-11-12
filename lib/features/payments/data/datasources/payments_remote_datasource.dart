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
    if (payload is! Map<String, dynamic> || payload['methods'] is! List) {
      throw Exception('Resposta inválida ao carregar seus cartões.');
    }
    final methods = payload['methods'];

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

    if (!_isSuccess(response.statusCode)) {
      throw Exception(
        _errorMessage(
          response.body,
          response.statusCode,
          'Não foi possível salvar o cartão.',
        ),
      );
    }

    final payload = _asMap(jsonDecode(response.body));
    final card = _asMap(
      payload['card'] ??
          payload['paymentMethod'] ??
          payload['payment_method'] ??
          _asMap(payload['data'])['card'] ??
          _asMap(payload['data'])['paymentMethod'] ??
          payload['data'] ??
          payload,
    );
    final savedCard = _mapSavedCard(card);
    if (savedCard.id.isEmpty || (savedCard.last4 ?? '').isEmpty) {
      throw Exception(
        'O pagamento foi aceito, mas a API não retornou os dados seguros do cartão.',
      );
    }
    return savedCard;
  }

  Future<void> payWithSavedCard({
    required String rideId,
    required String paymentMethodId,
  }) async {
    final response = await _baseApi.post(
      Uri.parse('v2/passenger/rides/$rideId/payments/card/saved'),
      body: {'paymentMethodId': paymentMethodId},
    );

    if (!_isSuccess(response.statusCode)) {
      throw Exception(
        _errorMessage(
          response.body,
          response.statusCode,
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

  bool _isSuccess(int statusCode) => statusCode >= 200 && statusCode < 300;

  Map<String, dynamic> _asMap(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : const {};

  String _errorMessage(String body, int statusCode, String fallback) {
    try {
      final payload = jsonDecode(body);
      final map = _asMap(payload);
      final message = map['message'] ?? map['error'] ?? map['detail'];
      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }
    } catch (_) {
      // Retorna a mensagem padrão quando a API não envia JSON.
    }
    if (statusCode == 401 || statusCode == 403) {
      return 'Sua sessão expirou. Entre novamente para cadastrar o cartão.';
    }
    if (statusCode == 400 || statusCode == 422) {
      return 'Confira os dados do cartão e tente novamente.';
    }
    if (statusCode >= 500) {
      return 'O serviço de pagamentos está indisponível. Tente novamente em alguns minutos.';
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

      if (status == 'completed' &&
          (ride['payment_status'] ?? '').toString().toUpperCase() != 'FAILED') {
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
