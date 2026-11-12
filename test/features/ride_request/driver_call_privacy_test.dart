import 'package:flutter_test/flutter_test.dart';
import 'package:tmjapp/features/ride_request/domain/services/driver_call_privacy.dart';

void main() {
  test('normaliza telefone e solicita ocultação do número', () {
    expect(DriverCallPrivacy.dialNumber('(81) 99999-1234'), '#31#81999991234');
  });

  test('preserva DDI e rejeita entrada inválida', () {
    expect(DriverCallPrivacy.dialNumber('+55 81 99999-1234'),
        '#31#+5581999991234');
    expect(DriverCallPrivacy.dialNumber(''), isNull);
    expect(DriverCallPrivacy.dialNumber('abc'), isNull);
  });
}
