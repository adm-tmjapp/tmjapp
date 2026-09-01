import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmjapp/features/profile/data/models/coupon.dart';

class CouponLocalDataSource {
  static const _activeKey = 'coupons.active.codes';
  static const _selectedKey = 'coupons.selected.code';

  Future<List<Coupon>> getActiveCoupons() async {
    final prefs = await SharedPreferences.getInstance();
    var codes = prefs.getStringList(_activeKey);
    if (codes == null) {
      codes = Coupon.catalog
          .take(2)
          .where((c) => !c.isExpired)
          .map((c) => c.code)
          .toList();
      await prefs.setStringList(_activeKey, codes);
    }
    final coupons = codes
        .map(Coupon.find)
        .whereType<Coupon>()
        .where((c) => !c.isExpired)
        .toList();
    await prefs.setStringList(_activeKey, coupons.map((c) => c.code).toList());
    return coupons;
  }

  Future<Coupon> addCoupon(String code) async {
    final coupon = Coupon.find(code);
    if (coupon == null) {
      throw const CouponException(
          'Cupom não encontrado. Confira o código e tente novamente.');
    }
    if (coupon.isExpired) {
      throw const CouponException('Este cupom está expirado.');
    }
    final active = await getActiveCoupons();
    if (active.any((c) => c.code == coupon.code)) {
      return coupon;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs
        .setStringList(_activeKey, [...active.map((c) => c.code), coupon.code]);
    return coupon;
  }

  Future<String?> getSelectedCode() async =>
      (await SharedPreferences.getInstance()).getString(_selectedKey);

  Future<void> selectCoupon(String code) async {
    final active = await getActiveCoupons();
    if (!active.any((c) => c.code == code)) {
      throw const CouponException('Este cupom não está mais ativo.');
    }
    await (await SharedPreferences.getInstance()).setString(_selectedKey, code);
  }

  Future<void> removeCoupon(String code) async {
    final prefs = await SharedPreferences.getInstance();
    final active = await getActiveCoupons();
    await prefs.setStringList(_activeKey,
        active.where((c) => c.code != code).map((c) => c.code).toList());
    if (prefs.getString(_selectedKey) == code) {
      await prefs.remove(_selectedKey);
    }
  }
}

class CouponException implements Exception {
  const CouponException(this.message);
  final String message;
}
