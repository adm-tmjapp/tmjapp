import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:tmjapp/api/base_api.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tmjapp/features/payments/presentation/pages/add_card_page.dart';

// Modelo simples para o exemplo
class CreditCardModel {
  final String id;
  final String brand;
  final String last4Digits;
  final String expiry;

  CreditCardModel({
    required this.id,
    required this.brand,
    required this.last4Digits,
    required this.expiry,
  });
}

class RegisteredCardsPage extends StatefulWidget {
  const RegisteredCardsPage({super.key});

  @override
  State<RegisteredCardsPage> createState() => _RegisteredCardsPageState();
}

class _RegisteredCardsPageState extends State<RegisteredCardsPage> {
  final List<CreditCardModel> _cards = [];
  final BaseApi _api = BaseApi();

  String _selectedCardId = '1';

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    try {
      final response = await _api.get(Uri.parse('v2/passenger/payments/methods'));
      if (response.statusCode != 200 || !mounted) return;
      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final methods = (payload['methods'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .where((item) => item['type'] == 'card')
          .map((item) => CreditCardModel(
                id: item['id'].toString(),
                brand: item['brand']?.toString() ?? 'Cartão',
                last4Digits: item['last4']?.toString() ?? '',
                expiry: '',
              ))
          .where((item) => item.last4Digits.isNotEmpty)
          .toList();
      setState(() {
        _cards
          ..clear()
          ..addAll(methods);
        if (_cards.isNotEmpty) _selectedCardId = _cards.first.id;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          'Meus Cartões',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SELECIONE UM CARTÃO',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_cards.isEmpty)
                    const Text('Nenhum cartão salvo no Asaas. Adicione um cartão antes de continuar.'),
                  ..._cards.map((card) {
                    final isSelected = _selectedCardId == card.id;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          setState(() => _selectedCardId = card.id);
                        },
                        child: Ink(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFFDF2F8)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFC92D7A)
                                  : const Color(0xFFE2E8F0),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  card.brand == 'Visa'
                                      ? Icons.payment
                                      : Icons.credit_card,
                                  color: const Color(0xFF334155),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${card.brand} •••• ${card.last4Digits}',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Vence em ${card.expiry}',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle,
                                    color: Color(0xFFC92D7A)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      final result = await Navigator.of(context).push<CardFormResult>(
                        MaterialPageRoute(
                          builder: (context) => const AddCardPage(),
                        ),
                      );
                      if (result == null) return;
                      final expiryParts = result.expiry.split('/');
                      if (expiryParts.length != 2) return;
                      final response = await _api.post(
                        Uri.parse('v2/passenger/payments/methods/card-tokenize'),
                        body: {
                          'holderName': result.holderName,
                          'number': result.cardNumberDigits,
                          'expiryMonth': expiryParts[0].trim(),
                          'expiryYear': expiryParts[1].trim().length == 2
                              ? '20${expiryParts[1].trim()}'
                              : expiryParts[1].trim(),
                          'ccv': result.ccv,
                          'setAsDefault': true,
                        },
                      );
                      if (response.statusCode == 201) await _loadCards();
                    },
                    child: Ink(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child:
                                const Icon(Icons.add, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Adicionar novo cartão',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF475467),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Botão Inferior
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, bottom: 20, top: 12),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (_selectedCardId.isNotEmpty && _cards.isNotEmpty) {
                      Navigator.of(context).pop(_selectedCardId);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC92D7A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Confirmar Cartão',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
