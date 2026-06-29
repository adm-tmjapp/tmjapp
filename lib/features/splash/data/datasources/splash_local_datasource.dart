import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmjapp/utils/strings.dart';

class SplashLocalDataSource {
  Future<String?> getSavedToken() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(Strings.prefToken);
  }
}
