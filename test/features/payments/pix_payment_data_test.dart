import 'package:flutter_test/flutter_test.dart';
import 'package:tmjapp/features/payments/domain/pix_payment_data.dart';

void main() {
  test('interpreta resposta PIX direta', () {
    final payment = PixPaymentData.fromJson({
      'paymentId': 'pay-1',
      'status': 'PENDING',
      'paymentExpiresAt': '2026-09-16T15:00:00Z',
      'pix': {'payload': '000201-pix', 'encodedImage': 'YWJj'},
    });

    expect(payment.paymentId, 'pay-1');
    expect(payment.copyPasteCode, '000201-pix');
    expect(payment.encodedImage, 'YWJj');
    expect(payment.isPaid, isFalse);
  });

  test('interpreta data, payment e nomes snake_case', () {
    final payment = PixPaymentData.fromJson({
      'data': {
        'payment': {
          'payment_id': 'pay-2',
          'payment_status': 'approved',
          'expires_at': '2026-09-16T15:00:00Z',
        },
        'qr_code': {
          'copy_paste': '000201-outro-pix',
          'encoded_image': 'data:image/png;base64,YWJj',
        },
      },
    });

    expect(payment.paymentId, 'pay-2');
    expect(payment.copyPasteCode, '000201-outro-pix');
    expect(payment.isPaid, isTrue);
    expect(normalizedPixBase64(payment.encodedImage), 'YWJj');
  });

  test('normaliza estados finais e expirados', () {
    expect(isPixPaidStatus(' confirmed '), isTrue);
    expect(isPixPaidStatus('succeeded'), isTrue);
    expect(isPixClosedStatus('expired'), isTrue);
    expect(isPixClosedStatus('cancelled'), isTrue);
  });
}
