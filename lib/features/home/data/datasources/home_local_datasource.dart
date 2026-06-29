import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmjapp/features/home/domain/entities/home_profile.dart';
import 'package:tmjapp/utils/strings.dart';

class HomeLocalDataSource {
  Future<HomeProfile> getProfile() async {
    final preferences = await SharedPreferences.getInstance();

    return HomeProfile(
      name: preferences.getString(Strings.prefName) ?? '',
      phone: preferences.getString(Strings.prefNumber) ?? '',
      userId: preferences.getString(Strings.prefUserId) ?? '',
    );
  }
}
