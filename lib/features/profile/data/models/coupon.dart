class Coupon {
  const Coupon(
      {required this.code,
      required this.title,
      required this.description,
      required this.expiryDate});
  final String code;
  final String title;
  final String description;
  final DateTime expiryDate;
  bool get isExpired => expiryDate.isBefore(DateTime.now());

  static final catalog = <Coupon>[
    Coupon(
        code: 'TMJ10',
        title: 'R\$ 10 OFF na próxima corrida',
        description: 'Válido para qualquer categoria de viagem.',
        expiryDate: DateTime(2026, 12, 31, 23, 59)),
    Coupon(
        code: 'BEMVINDO15',
        title: '15% de desconto',
        description: 'Desconto máximo de R\$ 15. Apenas pagamentos com cartão.',
        expiryDate: DateTime(2026, 9, 30, 23, 59)),
    Coupon(
        code: 'TESTE',
        title: 'Cupom promocional',
        description: '10% de desconto na próxima corrida.',
        expiryDate: DateTime(2026, 12, 31, 23, 59)),
  ];

  static Coupon? find(String rawCode) {
    final code = rawCode.trim().toUpperCase();
    for (final coupon in catalog) {
      if (coupon.code == code) return coupon;
    }
    return null;
  }
}
