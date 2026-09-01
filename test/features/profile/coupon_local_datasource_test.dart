import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmjapp/features/profile/data/datasources/coupon_local_datasource.dart';

void main() {
  late CouponLocalDataSource source;

  setUp(() {
    SharedPreferences.setMockInitialValues(
        {'coupons.active.codes': <String>[]});
    source = CouponLocalDataSource();
  });

  test('rejects a coupon that does not exist', () async {
    expect(
        () => source.addCoupon('INEXISTENTE'), throwsA(isA<CouponException>()));
    expect(await source.getActiveCoupons(), isEmpty);
  });

  test('persists the TESTE coupon entered on the screen', () async {
    await source.addCoupon('teste');
    expect((await source.getActiveCoupons()).single.code, 'TESTE');
  });

  test('persists, selects and removes a valid coupon', () async {
    await source.addCoupon('tmj10');
    expect((await source.getActiveCoupons()).single.code, 'TMJ10');

    await source.selectCoupon('TMJ10');
    expect(await source.getSelectedCode(), 'TMJ10');

    await source.removeCoupon('TMJ10');
    expect(await source.getActiveCoupons(), isEmpty);
    expect(await source.getSelectedCode(), isNull);
  });

  test('keeps only one entry when applying the same coupon twice', () async {
    await source.addCoupon('TMJ10');
    await source.addCoupon('TMJ10');
    expect((await source.getActiveCoupons()).length, 1);
  });
}
