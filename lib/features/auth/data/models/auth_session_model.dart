import 'package:tmjapp/data_model/response_login.dart';
import 'package:tmjapp/features/auth/domain/entities/auth_session.dart';

class AuthSessionModel extends AuthSession {
  const AuthSessionModel({
    required super.token,
    required super.userId,
    required super.name,
    required super.email,
    required super.phone,
  });

  factory AuthSessionModel.fromResponse(ResponseLogin response) {
    return AuthSessionModel(
      token: response.token ?? '',
      userId: response.user.id ?? '',
      name: response.user.name ?? '',
      email: response.user.email,
      phone: response.user.phone,
    );
  }
}
