import 'package:shared_preferences/shared_preferences.dart';

class PasswordResetLocalDataSource {
  static const _pendingEmailKey = 'auth.password_reset.pending_email';

  Future<void> savePendingEmail(String email) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_pendingEmailKey, email.trim().toLowerCase());
  }

  Future<String?> getPendingEmail() async {
    final preferences = await SharedPreferences.getInstance();
    final email = preferences.getString(_pendingEmailKey)?.trim();
    return email == null || email.isEmpty ? null : email;
  }

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_pendingEmailKey);
  }
}
