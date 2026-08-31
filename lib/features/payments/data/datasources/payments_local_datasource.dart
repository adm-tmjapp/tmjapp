import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmjapp/features/payments/domain/entities/payment_method_item.dart';

class PaymentsLocalDataSource {
  static const _cardsKey = 'tmj_wallet_saved_cards_v1';
  static const _balanceKey = 'tmj_wallet_balance_v1';

  Future<List<PaymentMethodItem>> getCards() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cardsKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final values = jsonDecode(raw) as List<dynamic>;
      return values
          .whereType<Map<String, dynamic>>()
          .map((json) {
            final brand = (json['brand'] ?? 'card').toString();
            final last4 = (json['last4'] ?? '').toString();
            return PaymentMethodItem(
              id: (json['id'] ?? '').toString(),
              brand: brand,
              label: '${_brandLabel(brand)} •••• $last4',
              subtitle: (json['holderName'] ?? '').toString(),
              last4: last4,
              holderName: (json['holderName'] ?? '').toString(),
              expiry: (json['expiry'] ?? '').toString(),
              isLocal: true,
            );
          })
          .where((item) => item.id.isNotEmpty && item.last4!.isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveCard(PaymentMethodItem card) async {
    final cards = [...await getCards()];
    final index = cards.indexWhere((item) => item.id == card.id);
    if (index >= 0) {
      cards[index] = card;
    } else {
      cards.add(card);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _cardsKey,
      jsonEncode(cards
          .map((item) => {
                'id': item.id,
                'brand': item.brand,
                'last4': item.last4,
                'holderName': item.holderName,
                'expiry': item.expiry,
              })
          .toList()),
    );
  }

  Future<double> getBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_balanceKey) ?? 0;
  }

  Future<double> addBalance(double amount) async {
    final prefs = await SharedPreferences.getInstance();
    final updated = (prefs.getDouble(_balanceKey) ?? 0) + amount;
    await prefs.setDouble(_balanceKey, updated);
    return updated;
  }

  static String _brandLabel(String brand) {
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
}
