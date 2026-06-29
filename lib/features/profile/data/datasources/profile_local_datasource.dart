import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmjapp/features/profile/domain/entities/profile_details.dart';
import 'package:tmjapp/utils/strings.dart';

class ProfileLocalDataSource {
  Future<String?> getUserId() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(Strings.prefUserId);
  }

  Future<void> saveBasicProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(Strings.prefName, name);
    await preferences.setString(Strings.prefEmail, email);
    await preferences.setString(Strings.prefNumber, phone);
  }

  Future<ProfileDetails?> getCachedProfile() async {
    final preferences = await SharedPreferences.getInstance();
    final name = preferences.getString(Strings.prefName) ?? '';
    final email = preferences.getString(Strings.prefEmail) ?? '';
    final phone = preferences.getString(Strings.prefNumber) ?? '';
    final userId = preferences.getString(Strings.prefUserId) ?? '';

    if (name.isEmpty && email.isEmpty && phone.isEmpty && userId.isEmpty) {
      return null;
    }

    return ProfileDetails(
      userId: userId,
      name: name,
      email: email,
      phone: phone,
      profilePhotoUrl: null,
    );
  }

  Future<void> clearSession() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(Strings.prefToken);
    await preferences.remove(Strings.prefUserId);
    await preferences.remove(Strings.prefName);
    await preferences.remove(Strings.prefNumber);
  }
}
