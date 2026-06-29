import 'dart:convert';

import 'package:http/http.dart';
import 'package:tmjapp/api/base_api.dart';
import 'package:tmjapp/data_model/api_response.dart';
import 'package:tmjapp/data_model/response_login.dart';

class Authapi {
  BaseApi baseApi = BaseApi();

  String? _parseMessage(Response response) {
    try {
      final decodedBody = jsonDecode(response.body);
      if (decodedBody is Map<String, dynamic>) {
        final message = decodedBody["message"];
        if (message is String && message.isNotEmpty) {
          return message;
        }
      }
    } catch (_) {}

    return response.reasonPhrase;
  }

  Future<ApiResponseModel<ResponseLogin?>> login(
      String password, String identifier) async {
    try {
      final cleanedPhone = identifier.contains('@')
          ? null
          : identifier.replaceAll(RegExp(r'[^0-9]'), '');

      final body = {
        // Alguns backends aceitam "identifier" (email ou telefone). Para
        // compatibilidade, enviamos também "email" quando for um e-mail.
        "identifier": identifier,
        "email": identifier.contains('@') ? identifier : null,
        "phone": cleanedPhone != null && cleanedPhone.length >= 10
            ? cleanedPhone
            : null,
        "password": password,
      }..removeWhere((key, value) => value == null);

      Response response =
          await baseApi.post(Uri.parse("v2/auth/login"), body: body);

      if (response.statusCode == 200) {
        final decodedBody = jsonDecode(response.body);
        final loginPayload = decodedBody is Map<String, dynamic>
            ? (decodedBody["data"] is Map<String, dynamic>
                ? decodedBody["data"]
                : decodedBody)
            : null;
        if (loginPayload == null || !loginPayload.containsKey("token")) {
          return ApiResponseModel(response, null);
        }
        ResponseLogin responseLogin = ResponseLogin.fromJson(loginPayload);
        return ApiResponseModel(response, responseLogin);
      } else {
        final message =
            _parseMessage(response) ?? "Não foi possível autenticar.";
        throw Exception(message);
      }
    } catch (error, stackTrace) {
      return ApiResponseModel.fromException(error, stackTrace, null);
    }
  }

  Future<ApiResponseModel<Map<String, dynamic>?>> forgotPassword(
      String email) async {
    try {
      final response = await baseApi.post(
        Uri.parse("v2/auth/forgot-password"),
        body: {"email": email},
      );

      if (response.statusCode == 200) {
        return ApiResponseModel(response, jsonDecode(response.body));
      }

      throw Exception(_parseMessage(response) ?? "Falha ao solicitar reset.");
    } catch (error, stackTrace) {
      return ApiResponseModel.fromException(error, stackTrace, null);
    }
  }

  Future<ApiResponseModel<Map<String, dynamic>?>> verifyResetCode(
      String email, String code) async {
    try {
      final response = await baseApi.post(
        Uri.parse("v2/auth/forgot-password/verify"),
        body: {
          "email": email,
          "code": code,
        },
      );

      if (response.statusCode == 200) {
        return ApiResponseModel(response, jsonDecode(response.body));
      }

      throw Exception(_parseMessage(response) ?? "Codigo invalido.");
    } catch (error, stackTrace) {
      return ApiResponseModel.fromException(error, stackTrace, null);
    }
  }

  Future<ApiResponseModel<Map<String, dynamic>?>> resetPassword(
      String email, String code, String newPassword) async {
    try {
      final response = await baseApi.post(
        Uri.parse("v2/auth/reset-password"),
        body: {
          "email": email,
          "code": code,
          "newPassword": newPassword,
        },
      );

      if (response.statusCode == 200) {
        return ApiResponseModel(response, jsonDecode(response.body));
      }

      throw Exception(_parseMessage(response) ?? "Falha ao redefinir senha.");
    } catch (error, stackTrace) {
      return ApiResponseModel.fromException(error, stackTrace, null);
    }
  }

  Future<ApiResponseModel<ResponseLogin?>> getUser(
      String password, String email) async {
    try {
      Response response = await baseApi.get(
        Uri.parse("users/1"),
      );

      if (response.statusCode == 200) {
        ResponseLogin responseLogin =
            ResponseLogin.fromJson(jsonDecode(response.body));
        return ApiResponseModel(response, responseLogin);
      } else {
        return ApiResponseModel(response, null);
      }
    } catch (error, stackTrace) {
      return ApiResponseModel.fromException(error, stackTrace, null);
    }
  }

  Future<ApiResponseModel<ResponseLogin?>> loginWithPhone(String phone) async {
    try {
      var body = {"phone": phone};
      Response response =
          await baseApi.post(Uri.parse("users/auth-phone"), body: body);

      if (response.statusCode == 200) {
        ResponseLogin responseLogin =
            ResponseLogin.fromJson(jsonDecode(response.body));
        return ApiResponseModel(response, responseLogin);
      } else {
        return ApiResponseModel(response, null);
      }
    } catch (error, stackTrace) {
      return ApiResponseModel.fromException(error, stackTrace, null);
    }
  }

  Future<ApiResponseModel<ResponseLogin?>> signUp(String phone, String name,
      String lastName, String gender, String email, String password) async {
    try {
      var body = {
        "name": "$name $lastName",
        "email": email,
        "password": password,
        "phone": phone,
        "role": "passenger"
      };

      Response response =
          await baseApi.post(Uri.parse("v2/auth/register"), body: body);

      if (response.statusCode == 201) {
        final decodedBody = jsonDecode(response.body);
        final signupPayload = decodedBody is Map<String, dynamic>
            ? (decodedBody["data"] is Map<String, dynamic>
                ? decodedBody["data"]
                : decodedBody)
            : null;

        if (signupPayload == null || !signupPayload.containsKey("token")) {
          return ApiResponseModel(response, null);
        }
        ResponseLogin responseSignUp = ResponseLogin.fromJson(signupPayload);
        return ApiResponseModel(response, responseSignUp);
      } else {
        return ApiResponseModel(response, null);
      }
    } catch (error, stackTrace) {
      return ApiResponseModel.fromException(error, stackTrace, null);
    }
  }

  Future<ApiResponseModel<ResponseLogin?>> registerPassenger({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final body = {
        "name": name,
        "email": email,
        "password": password,
        "phone": phone,
        "role": "passenger",
      };

      final response =
          await baseApi.post(Uri.parse("v2/auth/register"), body: body);

      if (response.statusCode == 201) {
        final decodedBody = jsonDecode(response.body);
        final signupPayload = decodedBody is Map<String, dynamic>
            ? (decodedBody["data"] is Map<String, dynamic>
                ? decodedBody["data"]
                : decodedBody)
            : null;

        if (signupPayload == null || !signupPayload.containsKey("token")) {
          return ApiResponseModel(response, null);
        }

        final responseSignUp = ResponseLogin.fromJson(signupPayload);
        return ApiResponseModel(response, responseSignUp);
      }

      throw Exception(_parseMessage(response) ?? "Falha ao cadastrar usuario.");
    } catch (error, stackTrace) {
      return ApiResponseModel.fromException(error, stackTrace, null);
    }
  }

  Future<ApiResponseModel<Map<String, String>?>> verifyEmail(
      int id, String email) async {
    try {
      var body = {
        "id": "$id",
        "email": email,
      };

      Response response =
          await baseApi.post(Uri.parse("users/verify-email"), body: body);

      if (response.statusCode == 200) {
        Map<String, String>? responseVerifyEmail = jsonDecode(response.body);
        return ApiResponseModel(response, responseVerifyEmail);
      } else {
        return ApiResponseModel(response, null);
      }
    } catch (error, stackTrace) {
      return ApiResponseModel.fromException(error, stackTrace, null);
    }
  }

  Future<ApiResponseModel<Map<String, String>?>> updateUsers(String phone,
      String name, String lastName, String email, String password) async {
    try {
      var body = {
        "name": "$name $lastName",
        "email": email,
        "password": password,
        "phone": phone,
        "role": "passenger"
      };

      Response response = await baseApi.patch(Uri.parse("users/1"), body: body);

      if (response.statusCode == 200) {
        Map<String, String>? responseUpdate = jsonDecode(response.body);
        return ApiResponseModel(response, responseUpdate);
      } else {
        return ApiResponseModel(response, null);
      }
    } catch (error, stackTrace) {
      return ApiResponseModel.fromException(error, stackTrace, null);
    }
  }

  Future<ApiResponseModel<void>> updateProfilePhoto(
      String base64Image, String token, String userId) async {
    try {
      var body = {
        "profilePhoto": base64Image,
      };

      Response response = await baseApi.post(
        Uri.parse("users/$userId/update-profile"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: body,
      );

      if (response.statusCode == 200) {
        return ApiResponseModel(response, null);
      } else {
        return ApiResponseModel(response, null);
      }
    } catch (error, stackTrace) {
      return ApiResponseModel.fromException(error, stackTrace, null);
    }
  }

  Future<ApiResponseModel<void>> sendNewCode(
      String token, String userId) async {
    try {
      Response response = await baseApi.post(
        Uri.parse("users/newcode-phone"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: {"userId": userId},
      );

      if (response.statusCode == 200) {
        return ApiResponseModel(response, null);
      } else {
        return ApiResponseModel(response, null);
      }
    } catch (error, stackTrace) {
      return ApiResponseModel.fromException(error, stackTrace, null);
    }
  }

  Future<ApiResponseModel<void>> verifyPhone(
      String token, String userId, String code) async {
    try {
      Response response = await baseApi.post(
        Uri.parse("users/verify-phone"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: {"userId": userId, "code": code},
      );

      if (response.statusCode == 200) {
        return ApiResponseModel(response, null);
      } else {
        return ApiResponseModel(response, null);
      }
    } catch (error, stackTrace) {
      return ApiResponseModel.fromException(error, stackTrace, null);
    }
  }

  Future<ApiResponseModel<void>> changePhone(
      String token, String userId, String newPhone) async {
    try {
      var body = {
        "userId": userId,
        "newPhone": newPhone,
      };

      Response response = await baseApi.post(
        Uri.parse("users/change-phone"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return ApiResponseModel(response, null);
      } else {
        return ApiResponseModel(response, null);
      }
    } catch (error, stackTrace) {
      return ApiResponseModel.fromException(error, stackTrace, null);
    }
  }

  Future<ApiResponseModel<Map<String, dynamic>?>> createRide(
      String userId,
      Map<String, dynamic> pickupLocation,
      Map<String, dynamic> destinationLocation) async {
    try {
      var body = {
        "userId": userId,
        "pickup_location": pickupLocation,
        "destination_location": destinationLocation,
      };

      Response response = await baseApi.post(
        Uri.parse("rides/create"),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic>? responseData = jsonDecode(response.body);
        return ApiResponseModel(response, responseData);
      } else {
        return ApiResponseModel(response, null);
      }
    } catch (error, stackTrace) {
      return ApiResponseModel.fromException(error, stackTrace, null);
    }
  }
}
