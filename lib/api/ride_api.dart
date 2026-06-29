import 'dart:convert';

import 'package:http/http.dart';
import 'package:tmjapp/api/base_api.dart';
import 'package:tmjapp/data_model/api_response.dart';

class RideApi {
  BaseApi baseApi = BaseApi();

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

  // Adicione outros métodos relacionados a "rides" aqui, se necessário.
}
