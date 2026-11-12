enum RidePaymentMethod {
  cash('Dinheiro'),
  card('Cartão'),
  pix('Pix');

  const RidePaymentMethod(this.label);

  final String label;

  static String? labelFromBackend(String? value) {
    final normalized = (value ?? '').trim().toUpperCase();
    switch (normalized) {
      case 'CASH':
      case 'DINHEIRO':
      case 'MONEY':
        return RidePaymentMethod.cash.label;
      case 'CARD':
      case 'CREDIT_CARD':
      case 'DEBIT_CARD':
      case 'CARTAO':
      case 'CARTÃO':
        return RidePaymentMethod.card.label;
      case 'PIX':
        return RidePaymentMethod.pix.label;
      default:
        return null;
    }
  }
}
