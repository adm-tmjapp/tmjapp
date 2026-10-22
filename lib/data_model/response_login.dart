import 'package:tmjapp/data_model/user.dart';

class ResponseLogin {
  String? token;
  User user;

  ResponseLogin({required this.token, required this.user});

  factory ResponseLogin.fromJson(Map<String, dynamic> json) {
    final resolvedToken =
        json["token"] ?? json["access_token"] ?? json["accessToken"];
    final rawUser = json['user'];
    final rootEmailVerified = json['emailVerified'] ??
        json['isEmailVerified'] ??
        json['email_verified'] ??
        json['is_email_verified'];
    final userJson = rawUser is Map<String, dynamic>
        ? <String, dynamic>{
            ...rawUser,
            if (rootEmailVerified != null) 'emailVerified': rootEmailVerified,
            if (json['email_verified_at'] != null)
              'email_verified_at': json['email_verified_at'],
            if (json['emailVerifiedAt'] != null)
              'emailVerifiedAt': json['emailVerifiedAt'],
          }
        : <String, dynamic>{};
    return ResponseLogin(
      token: resolvedToken?.toString(),
      user: User.fromJson(userJson),
    );
  }

  Map<String, dynamic> toJson() => {
        "token": token,
        "user": user,
      };
}
