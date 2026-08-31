import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:tmjapp/api/base_api.dart';
import 'package:tmjapp/core/config/app_config.dart';
import 'package:tmjapp/features/destination_search/domain/entities/route_location.dart';
import 'package:tmjapp/features/home/domain/entities/home_active_ride.dart';
import 'package:tmjapp/features/home/domain/entities/home_driver.dart';
import 'package:tmjapp/features/home/domain/entities/home_location.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_product.dart';

class HomeRemoteDataSource {
  HomeRemoteDataSource({
    FirebaseFirestore? firestore,
    Location? location,
    http.Client? client,
    BaseApi? baseApi,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _location = location ?? Location(),
        _client = client ?? http.Client(),
        _baseApi = baseApi ?? BaseApi();

  final FirebaseFirestore _firestore;
  final Location _location;
  final http.Client _client;
  final BaseApi _baseApi;

  Future<HomeLocation> getCurrentLocation() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        throw Exception('Ative o servico de localizacao para continuar.');
      }
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
    }

    if (permissionGranted != PermissionStatus.granted) {
      throw Exception('Permissao de localizacao negada.');
    }

    final currentLocation = await _location.getLocation();
    final latitude = currentLocation.latitude;
    final longitude = currentLocation.longitude;

    if (latitude == null || longitude == null) {
      throw Exception('Não foi possível obter sua localização atual.');
    }

    return HomeLocation(latitude: latitude, longitude: longitude);
  }

  Future<List<HomeDriver>> getActiveDrivers() async {
    final snapshot = await _firestore
        .collection('drivers')
        .where('active', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) {
          final data = doc.data();
          final location = data['location'];
          final latitude = location is GeoPoint
              ? location.latitude
              : (data['lat'] as num?)?.toDouble();
          final longitude = location is GeoPoint
              ? location.longitude
              : (data['lng'] as num?)?.toDouble();

          if (latitude == null || longitude == null) {
            return null;
          }

          return HomeDriver(
            id: doc.id,
            name: (data['name'] as String?)?.trim().isNotEmpty == true
                ? data['name'] as String
                : 'Motorista parceiro',
            location: HomeLocation(latitude: latitude, longitude: longitude),
          );
        })
        .whereType<HomeDriver>()
        .toList();
  }

  Future<HomeActiveRide?> getActiveRide() async {
    try {
      final response = await _baseApi.get(Uri.parse('v2/passenger/rides'));
      if (response.statusCode != 200) {
        return null;
      }

      final data = jsonDecode(response.body);
      if (data is! List) {
        return null;
      }

      final activeRide = data.whereType<Map<String, dynamic>>().firstWhere(
        (ride) {
          final status = (ride['status'] ?? '').toString().toLowerCase();
          return status == 'pending' ||
              status == 'searching' ||
              status == 'searching_driver' ||
              status == 'requested' ||
              status == 'accepted' ||
              status == 'ongoing';
        },
        orElse: () => const <String, dynamic>{},
      );

      if (activeRide.isEmpty) {
        return null;
      }

      final origin = _mapRouteLocation(
        activeRide['pickup_location'] as Map<String, dynamic>?,
      );
      final destination = _mapRouteLocation(
        activeRide['destination_location'] as Map<String, dynamic>?,
      );
      final product = activeRide['product'] as Map<String, dynamic>?;
      if (origin == null || destination == null || product == null) {
        return null;
      }

      final route = activeRide['route'] as Map<String, dynamic>?;
      final driver = activeRide['driver'] as Map<String, dynamic>?;
      final vehicle = activeRide['vehicle'] as Map<String, dynamic>?;

      return HomeActiveRide(
        rideId: (activeRide['id'] ?? activeRide['_id'] ?? '').toString(),
        status: (activeRide['status'] ?? '').toString(),
        origin: origin,
        destination: destination,
        product: RideProduct(
          id: (product['id'] ?? '').toString(),
          name: (product['name'] ?? 'TMJ').toString(),
          subtitle: (product['description'] ?? 'Em andamento').toString(),
          estimatedPrice: _parseDouble(product['price']) ?? 0,
          etaLabel: _buildEtaLabel(route?['duration_min']),
          badge: '',
        ),
        driverName: driver?['name']?.toString(),
        driverRating: _parseDouble(driver?['rating']),
        vehicleModel: _pickFirstString(
          vehicle,
          const ['model', 'vehicle_model', 'car_model', 'name'],
        ),
        licensePlate: _pickFirstString(
          vehicle,
          const [
            'license_plate',
            'plate',
            'licensePlate',
            'car_plate',
            'carPlate'
          ],
        ),
        paymentMethodLabel: activeRide['payment_method']?.toString(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<List<HomeLocation>> getRoute({
    required HomeLocation origin,
    required HomeLocation destination,
  }) async {
    final apiKey = AppConfig.instance.googlePlacesApiKey;
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=${origin.latitude},${origin.longitude}'
      '&destination=${destination.latitude},${destination.longitude}'
      '&key=$apiKey&language=pt-br',
    );

    final response = await _client.get(url);

    if (response.statusCode != 200) {
      throw Exception('Não foi possível montar a rota.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final routes = data['routes'] as List<dynamic>? ?? const [];
    if (routes.isEmpty) {
      return const [];
    }

    final polyline =
        ((routes.first as Map<String, dynamic>)['overview_polyline']
            as Map<String, dynamic>)['points'] as String?;

    if (polyline == null || polyline.isEmpty) {
      return const [];
    }

    return _decodePolyline(polyline);
  }

  List<HomeLocation> _decodePolyline(String encoded) {
    final points = <HomeLocation>[];
    var index = 0;
    var latitude = 0;
    var longitude = 0;

    while (index < encoded.length) {
      var shift = 0;
      var result = 0;
      int byte;

      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);

      final deltaLatitude = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      latitude += deltaLatitude;

      shift = 0;
      result = 0;

      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);

      final deltaLongitude = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      longitude += deltaLongitude;

      points.add(
        HomeLocation(
          latitude: latitude / 1E5,
          longitude: longitude / 1E5,
        ),
      );
    }

    return points;
  }

  RouteLocation? _mapRouteLocation(Map<String, dynamic>? input) {
    final coordinates = input?['coordinates'] as Map<String, dynamic>?;
    final latitude = _parseDouble(coordinates?['latitude']);
    final longitude = _parseDouble(coordinates?['longitude']);
    if (latitude == null || longitude == null) {
      return null;
    }

    final title = (input?['address'] ?? '').toString().trim();
    return RouteLocation(
      title: title.isNotEmpty ? title : 'Endereco',
      subtitle: '',
      latitude: latitude,
      longitude: longitude,
    );
  }

  double? _parseDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '');
  }

  String? _pickFirstString(
    Map<String, dynamic>? source,
    List<String> keys,
  ) {
    if (source == null) {
      return null;
    }
    for (final key in keys) {
      final value = source[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return null;
  }

  String _buildEtaLabel(Object? durationMinutes) {
    final minutes = _parseDouble(durationMinutes)?.round();
    if (minutes == null || minutes <= 0) {
      return 'Em curso';
    }

    return 'Chegada em $minutes min';
  }
}
