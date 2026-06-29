import 'dart:convert';

import 'package:tmjapp/api/base_api.dart';
import 'package:tmjapp/features/destination_search/domain/entities/route_location.dart';
import 'package:tmjapp/features/ride_request/data/models/ride_product_model.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_detail.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_driver_summary.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_eta_snapshot.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_payment_method.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_payment_option.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_payment_options_result.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_product.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_quote.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_realtime_session.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_status_snapshot.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_vehicle_summary.dart';

class RideRequestRemoteDataSource {
  RideRequestRemoteDataSource({BaseApi? baseApi})
      : _baseApi = baseApi ?? BaseApi();

  final BaseApi _baseApi;

  Future<RideQuote> createRideQuote({
    required String userId,
    required RouteLocation origin,
    required RouteLocation destination,
  }) async {
    final response = await _baseApi.post(
      Uri.parse('v2/passenger/rides'),
      body: {
        'userId': userId,
        'pickup_location': {
          'address': origin.title,
          'coordinates': {
            'latitude': origin.latitude,
            'longitude': origin.longitude,
          },
        },
        'destination_location': {
          'address': destination.title,
          'coordinates': {
            'latitude': destination.latitude,
            'longitude': destination.longitude,
          },
        },
      },
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Não foi possivel carregar as opcões de corrida.');
    }

    final responseData = jsonDecode(response.body) as Map<String, dynamic>;
    final ride = responseData['ride'] as Map<String, dynamic>? ?? const {};
    final rideId =
        (responseData['rideId'] ?? ride['id'] ?? ride['_id'] ?? '').toString();
    if (rideId.isEmpty) {
      throw Exception('Não foi possível identificar a corrida criada.');
    }

    final products = responseData['products'] ??
        ride['products'] ??
        (responseData['data'] is Map
            ? (responseData['data'] as Map<String, dynamic>)['products']
            : null);
    if (products is! List) {
      throw Exception('Nenhuma opção de veiculo foi encontrada.');
    }
    print('🔥 RESPOSTA DA API:');
    print(responseData);
    print('🚗 QUANTIDADE DE CARROS: ${(products as List).length}');

    return RideQuote(
      rideId: rideId,
      products: products
          .whereType<Map<String, dynamic>>()
          .map(RideProductModel.fromJson)
          .toList(),
    );
  }

  Future<RideStatusSnapshot> checkoutRide({
    required String rideId,
    required RideProduct product,
    required RidePaymentMethod paymentMethod,
  }) async {
    final response = await _baseApi.put(
      Uri.parse('v2/passenger/rides/$rideId/checkout'),
      body: {
        'product': {
          'id': product.id,
          'name': product.name,
          'price': product.estimatedPrice,
          'description': product.subtitle,
        },
        'payment_method': _mapPaymentMethod(paymentMethod),
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Não foi possível confirmar a solicitação da corrida.');
    }

    final responseData = jsonDecode(response.body) as Map<String, dynamic>;
    final ride = responseData['ride'] as Map<String, dynamic>? ?? const {};
    return RideStatusSnapshot(
      rideId: (ride['id'] ?? ride['_id'] ?? rideId).toString(),
      status: (ride['status'] ?? 'pending').toString(),
      updatedAt: _parseDate(
        ride['updatedAt']?.toString() ??
            ride['completed_at']?.toString() ??
            ride['accepted_at']?.toString() ??
            ride['requested_at']?.toString() ??
            ride['requestedAt']?.toString(),
      ),
    );
  }

  Future<RideStatusSnapshot> getRideStatus(String rideId) async {
    final response = await _baseApi.get(
      Uri.parse('v2/passenger/rides/$rideId/status'),
    );

    if (response.statusCode == 404) {
      final ride = await _findRideFromList(rideId);
      if (ride == null) {
        throw Exception('Não foi possível localizar a corrida atual.');
      }

      return RideStatusSnapshot(
        rideId: (ride['id'] ?? ride['_id'] ?? rideId).toString(),
        status: (ride['status'] ?? 'pending').toString(),
        updatedAt: _parseDate(
          ride['updatedAt']?.toString() ??
              ride['completed_at']?.toString() ??
              ride['accepted_at']?.toString() ??
              ride['requested_at']?.toString(),
        ),
      );
    }

    if (response.statusCode != 200) {
      throw Exception(_extractErrorMessage(
        response.body,
        fallback: 'Não foi possível atualizar o status da corrida.',
      ));
    }

    final responseData = jsonDecode(response.body) as Map<String, dynamic>;
    return RideStatusSnapshot(
      rideId: (responseData['rideId'] ?? rideId).toString(),
      status: (responseData['status'] ?? 'pending').toString(),
      updatedAt: _parseDate(responseData['updatedAt']?.toString()),
    );
  }

  Future<RidePaymentOptionsResult> getRidePaymentOptions(String rideId) async {
    try {
      final optionsResponse = await _baseApi.get(
        Uri.parse('v2/passenger/payments/options?rideId=$rideId'),
      );
      final methodsResponse = await _baseApi.get(
        Uri.parse('v2/passenger/payments/methods'),
      );

      if (optionsResponse.statusCode != 200 ||
          methodsResponse.statusCode != 200) {
        return _fallbackPaymentOptions();
      }

      final optionsData =
          jsonDecode(optionsResponse.body) as Map<String, dynamic>;
      final methodsData =
          jsonDecode(methodsResponse.body) as Map<String, dynamic>;
      final enabledMethods =
          optionsData['enabledMethods'] as List<dynamic>? ?? const [];
      final savedMethods = methodsData['methods'] as List<dynamic>? ?? const [];

      final defaultSavedCard = savedMethods
          .whereType<Map<String, dynamic>>()
          .cast<Map<String, dynamic>?>()
          .firstWhere(
            (method) =>
                method != null &&
                (method['type']?.toString().toLowerCase() == 'card') &&
                (method['status']?.toString().toUpperCase() != 'INACTIVE') &&
                (method['isDefault'] == true),
            orElse: () => null,
          );

      final options = <RidePaymentOption>[];
      for (final item in enabledMethods.whereType<Map<String, dynamic>>()) {
        if (item['enabled'] != true) {
          continue;
        }

        final type = item['type']?.toString().toUpperCase() ?? '';
        if (type == 'PIX') {
          options.add(
            const RidePaymentOption(
              method: RidePaymentMethod.pix,
              label: 'Pix',
              subtitle: 'Pagamento instantaneo pelo app',
              isDefault: false,
            ),
          );
          continue;
        }

        if (type == 'CREDIT_CARD') {
          final brand = defaultSavedCard?['brand']?.toString().trim() ?? '';
          final last4 = defaultSavedCard?['last4']?.toString().trim() ?? '';
          final label = defaultSavedCard?['label']?.toString().trim();
          final cardLabel = (label != null && label.isNotEmpty)
              ? label
              : [
                  if (brand.isNotEmpty) brand,
                  if (last4.isNotEmpty) '•••• $last4',
                ].join(' ').trim();

          options.add(
            RidePaymentOption(
              method: RidePaymentMethod.card,
              label: cardLabel.isNotEmpty ? cardLabel : 'Cartão de Crédito',
              subtitle: defaultSavedCard != null
                  ? 'Cartão salvo na plataforma'
                  : 'Pagamento com cartão pelo app',
              isDefault: defaultSavedCard?['isDefault'] == true,
            ),
          );
        }
      }

      if (options.isEmpty) {
        return _fallbackPaymentOptions();
      }

      final defaultMethodValue =
          optionsData['defaultMethod']?.toString().toUpperCase();
      RidePaymentMethod selectedMethod = options.first.method;
      if (defaultMethodValue == 'PIX' &&
          options.any((item) => item.method == RidePaymentMethod.pix)) {
        selectedMethod = RidePaymentMethod.pix;
      } else if (defaultMethodValue == 'CREDIT_CARD' &&
          options.any((item) => item.method == RidePaymentMethod.card)) {
        selectedMethod = RidePaymentMethod.card;
      }

      return RidePaymentOptionsResult(
        options: options,
        selectedMethod: selectedMethod,
      );
    } catch (_) {
      return _fallbackPaymentOptions();
    }
  }

  Future<RideDetail> getRideDetail(String rideId) async {
    final response = await _baseApi.get(
      Uri.parse('v2/passenger/rides/$rideId'),
    );

    Map<String, dynamic>? responseData;
    if (response.statusCode == 404) {
      responseData = await _findRideFromList(rideId);
      if (responseData == null) {
        throw Exception('Não foi possível carregar os detalhes da corrida.');
      }
    } else if (response.statusCode == 200) {
      responseData = jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(_extractErrorMessage(
        response.body,
        fallback: 'Não foi possível carregar os detalhes da corrida.',
      ));
    }

    final driver = responseData['driver'] as Map<String, dynamic>?;
    final vehicle = responseData['vehicle'] as Map<String, dynamic>?;
    final fare = responseData['fare'] as Map<String, dynamic>?;

    return RideDetail(
      rideId: (responseData['id'] ?? rideId).toString(),
      status: (responseData['status'] ?? 'pending').toString(),
      driver: driver == null
          ? null
          : RideDriverSummary(
              id: driver['id']?.toString(),
              name: driver['name']?.toString(),
              rating: _parseDouble(driver['rating']),
              phoneNumber: driver['phone_number']?.toString(),
              photoUrl: driver['photo_url']?.toString(),
            ),
      vehicle: vehicle == null ? null : _mapVehicle(vehicle),
      paymentMethod: responseData['payment_method']?.toString(),
      totalAmount: _parseDouble(fare?['total_amount']),
    );
  }

  Future<RideEtaSnapshot> getRideEta(String rideId) async {
    final response = await _baseApi.get(
      Uri.parse('v2/passenger/rides/$rideId/eta'),
    );

    if (response.statusCode == 404) {
      return RideEtaSnapshot(
        rideId: rideId,
        status: 'pending',
        latitude: null,
        longitude: null,
        capturedAt: null,
      );
    }

    if (response.statusCode != 200) {
      throw Exception(_extractErrorMessage(
        response.body,
        fallback: 'Não foi possível carregar a localização do motorista.',
      ));
    }

    final responseData = jsonDecode(response.body) as Map<String, dynamic>;
    final driverLocation =
        responseData['driverLocation'] as Map<String, dynamic>?;
    return RideEtaSnapshot(
      rideId: (responseData['rideId'] ?? rideId).toString(),
      status: (responseData['status'] ?? 'pending').toString(),
      latitude: _parseDouble(driverLocation?['lat']),
      longitude: _parseDouble(driverLocation?['lng']),
      capturedAt: _parseDate(driverLocation?['capturedAt']?.toString()),
    );
  }

  Future<RideRealtimeSession> issueRideRealtimeToken(String rideId) async {
    final response = await _baseApi.post(
      Uri.parse('v2/passenger/rides/$rideId/realtime-token'),
      body: const {},
    );

    if (response.statusCode == 404) {
      throw Exception(
        'O endpoint realtime da corrida ainda não está publicado no backend.',
      );
    }

    if (response.statusCode != 200) {
      throw Exception(_extractErrorMessage(
        response.body,
        fallback: 'Não foi possível preparar a sessão realtime da corrida.',
      ));
    }

    final responseData = jsonDecode(response.body) as Map<String, dynamic>;
    final firebase =
        responseData['firebase'] as Map<String, dynamic>? ?? const {};

    return RideRealtimeSession(
      dbUrl: firebase['dbUrl']?.toString() ?? '',
      customToken: firebase['customToken']?.toString() ?? '',
      expiresAt: _parseDate(firebase['expiresAt']?.toString()),
      rideId: firebase['rideId']?.toString() ?? rideId,
      role: firebase['role']?.toString() ?? 'passenger',
    );
  }

  Future<void> cancelRide({
    required String rideId,
    String? reason,
  }) async {
    final response = await _baseApi.patch(
      Uri.parse('v2/passenger/rides/$rideId/cancel'),
      body: {
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
    );

    if (response.statusCode == 404) {
      throw Exception(
        'O cancelamento da corrida ainda não está disponível neste ambiente da API.',
      );
    }

    if (response.statusCode != 200) {
      throw Exception(_extractErrorMessage(
        response.body,
        fallback: 'Não foi possível cancelar a corrida.',
      ));
    }
  }

  Future<Map<String, dynamic>?> _findRideFromList(String rideId) async {
    final response = await _baseApi.get(
      Uri.parse('v2/passenger/rides'),
    );

    if (response.statusCode != 200) {
      return null;
    }

    final responseData = jsonDecode(response.body);
    if (responseData is! List) {
      return null;
    }

    for (final item in responseData.whereType<Map<String, dynamic>>()) {
      final currentId = (item['id'] ?? item['_id'] ?? '').toString();
      if (currentId == rideId) {
        return item;
      }
    }

    return null;
  }

  DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    return DateTime.tryParse(value);
  }

  double? _parseDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '');
  }

  String _extractErrorMessage(String body, {required String fallback}) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded['message']?.toString() ??
            decoded['error']?.toString() ??
            fallback;
      }
    } catch (_) {
      // Alguns ambientes ainda devolvem HTML puro para 404.
    }

    return fallback;
  }

  RidePaymentOptionsResult _fallbackPaymentOptions() {
    return const RidePaymentOptionsResult(
      options: [
        RidePaymentOption(
          method: RidePaymentMethod.card,
          label: 'Cartão de Crédito',
          subtitle: 'Pagamento pelo app',
          isDefault: true,
        ),
        RidePaymentOption(
          method: RidePaymentMethod.pix,
          label: 'Pix',
          subtitle: 'Pagamento instantaneo',
          isDefault: false,
        ),
      ],
      selectedMethod: RidePaymentMethod.card,
    );
  }

  String _mapPaymentMethod(RidePaymentMethod paymentMethod) {
    switch (paymentMethod) {
      case RidePaymentMethod.cash:
        return 'CASH';
      case RidePaymentMethod.pix:
        return 'PIX';
      case RidePaymentMethod.card:
        return 'CARD';
    }
  }

  RideVehicleSummary _mapVehicle(Map<String, dynamic> vehicle) {
    String? _firstOrNull(List<String> keys) {
      for (final key in keys) {
        final value = vehicle[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString();
        }
      }
      return null;
    }

    return RideVehicleSummary(
      licensePlate: _firstOrNull(
        const [
          'license_plate',
          'plate',
          'licensePlate',
          'car_plate',
          'carPlate'
        ],
      ),
      model: _firstOrNull(
        const ['model', 'vehicle_model', 'car_model', 'name'],
      ),
      color: _firstOrNull(
        const ['color', 'vehicle_color', 'car_color'],
      ),
      type: _firstOrNull(const ['type', 'category']),
    );
  }
}
