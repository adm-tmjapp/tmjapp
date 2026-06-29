enum RidePaymentMethod {
  cash('Dinheiro'),
  card('Cartão'),
  pix('Pix');

  const RidePaymentMethod(this.label);

  final String label;
}
