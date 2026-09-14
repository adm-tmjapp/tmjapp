import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmjapp/features/forgot_password/data/password_reset_local_data_source.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('stores a normalized pending password reset email', () async {
    final dataSource = PasswordResetLocalDataSource();

    await dataSource.savePendingEmail('  USER@Example.COM ');

    expect(await dataSource.getPendingEmail(), 'user@example.com');
  });

  test('clears a completed or abandoned password reset', () async {
    final dataSource = PasswordResetLocalDataSource();
    await dataSource.savePendingEmail('user@example.com');

    await dataSource.clear();

    expect(await dataSource.getPendingEmail(), isNull);
  });
}
