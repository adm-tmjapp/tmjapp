import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmjapp/api/auth_api.dart';
import 'package:tmjapp/data_model/api_response.dart';
import 'package:tmjapp/data_model/response_login.dart';
import 'package:tmjapp/utils/strings.dart';

class AuthRepository {
  Authapi auth = Authapi();
  SharedPreferences? prefs;

  AuthRepository() {
    initData();
  }

  Future<void> _ensurePrefs() async {
    if (prefs == null) {
      await initData();
    }
  }

  Future<ResponseLogin?>? login(String email, String password) async {
    await _ensurePrefs();
    ApiResponseModel<ResponseLogin?> response =
        await auth.login(password, email);
    if (response.badRequest) {
      return null;
    } else {
      final result = response.result;
      if (result?.token != null && result!.token!.isNotEmpty) {
        prefs?.setString(Strings.prefToken, result.token!);
      }
      prefs?.setString(Strings.prefName, result?.user.name ?? '');
      prefs?.setString(Strings.prefNumber, result?.user.phone ?? '');
      return response.result;
    }
  }

  Future<ResponseLogin?>? loginWithPhone(String phone) async {
    await _ensurePrefs();
    ApiResponseModel<ResponseLogin?> response =
        await auth.loginWithPhone(phone);
    if (response.badRequest) {
      return null;
    } else {
      final result = response.result;
      if (result?.token != null && result!.token!.isNotEmpty) {
        prefs?.setString(Strings.prefToken, result.token!);
      }
      prefs?.setString(Strings.prefName, result?.user.name ?? '');
      prefs?.setString(Strings.prefNumber, result?.user.phone ?? '');
      return response.result;
    }
  }

  Future<void> initData() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<ResponseLogin?>? signUp(String phone, String name, String lastName,
      String gender, String email, String password) async {
    await _ensurePrefs();
    prefs?.setString(Strings.prefName, name);
    prefs?.setString(Strings.prefNumber, phone);
    ApiResponseModel<ResponseLogin?> response =
        await auth.signUp(phone, name, lastName, gender, email, password);
    if (response.badRequest) {
      return null;
    } else {
      //prefs?.setString(Strings.prefToken, response.result!.token!);
      return response.result;
    }
  }

  Future<ResponseLogin?>? getUser(String phone, String name, String lastName,
      String gender, String email, String password) async {
    ApiResponseModel<ResponseLogin?> response =
        await auth.signUp(phone, name, lastName, gender, email, password);
    if (response.badRequest) {
      return null;
    } else {
      return response.result;
    }
  }
}
