import 'package:flutter_test/flutter_test.dart';
import 'package:tmjapp/features/payments/presentation/pages/add_card_page.dart';

void main() {
  test('rejects invalid card data before sending it to the payment API', () {
    expect(CardFormValidators.isValidNumber('0000000000000000'), isFalse);
    expect(CardFormValidators.isValidNumber('4111111111111111'), isTrue);
    expect(CardFormValidators.isValidCvv('12'), isFalse);
    expect(CardFormValidators.isValidCvv('123'), isTrue);
    expect(CardFormValidators.isValidExpiry('13/27'), isFalse);
    expect(CardFormValidators.isValidExpiry('12/27'), isTrue);
  });
}
