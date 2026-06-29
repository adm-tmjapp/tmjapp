import 'package:tmjapp/data_model/user.dart';

class ResponseLogin {
  String? token;
  User user;

  ResponseLogin({required this.token, required this.user});

  factory ResponseLogin.fromJson(Map<String, dynamic> json) {
    final resolvedToken =
        json["token"] ?? json["access_token"] ?? json["accessToken"];
    return ResponseLogin(
      token: resolvedToken?.toString(),
      user: User.fromJson(json["user"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "token": token,
        "user": user,
      };
}
