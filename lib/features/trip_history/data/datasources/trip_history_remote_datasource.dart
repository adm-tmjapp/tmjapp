import 'dart:convert';

import 'package:tmjapp/api/base_api.dart';
import 'package:tmjapp/features/trip_history/domain/entities/trip_history_item.dart';

class TripHistoryRemoteDataSource {
  TripHistoryRemoteDataSource({BaseApi? baseApi})
      : _baseApi = baseApi ?? BaseApi();

  final BaseApi _baseApi;

  Future<List<TripHistoryItem>> fetchTrips() async {
    final response = await _baseApi.get(Uri.parse('v2/passenger/rides'));

    if (response.statusCode != 200) {
      throw Exception('Não foi possível carregar o histórico.');
    }

    final payload = jsonDecode(response.body);
    if (payload is! List) {
      return const [];
    }

    return payload
        .whereType<Map<String, dynamic>>()
        .map(_mapRideToTrip)
        .toList(growable: false);
  }

  TripHistoryItem _mapRideToTrip(Map<String, dynamic> json) {
    final driver = json['driver'] as Map<String, dynamic>?;
    final vehicle = _vehicleFromRide(json, driver);
    final pickup = json['pickup_location'] as Map<String, dynamic>?;
    final destination = json['destination_location'] as Map<String, dynamic>?;
    final route = json['route'] as Map<String, dynamic>?;
    final product = json['product'] as Map<String, dynamic>?;
    final fare = json['fare'] as Map<String, dynamic>?;

    final rawDate = json['completedAt'] ??
        json['requestedAt'] ??
        json['requested_at'] ??
        json['acceptedAt'];
    final date = DateTime.tryParse((rawDate ?? '').toString())?.toLocal();
    final distanceKm = (route?['distance_km'] as num?)?.toDouble() ?? 0;
    final durationMin = (route?['duration_min'] as num?)?.toDouble() ?? 0;
    final totalPrice = (product?['price'] as num?)?.toDouble() ??
        (fare?['total_amount'] as num?)?.toDouble() ??
        (json['fare'] as num?)?.toDouble() ??
        0;
    final status = _mapStatus(json['status']?.toString());
    final payment = _mapPaymentMethod(json['payment_method']?.toString());
    final acceptedAt = json['acceptedAt'] ?? json['accepted_at'];
    final hasDriverAccepted = (driver != null && driver.isNotEmpty) ||
        (acceptedAt != null && acceptedAt.toString().isNotEmpty);

    return TripHistoryItem(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: destination?['address']?.toString() ?? 'Viagem TMJ',
      driverName: driver?['name']?.toString() ?? 'Motorista a definir',
      vehicle: _vehicleDisplayName(vehicle) ??
          product?['name']?.toString() ??
          'TMJ Ride',
      dateLabel: _formatDate(date),
      status: status,
      price: totalPrice,
      mapColorHex: _statusColor(status),
      originTitle: 'Origem',
      originSubtitle: pickup?['address']?.toString() ?? 'Não informado',
      destinationTitle: 'Destino',
      destinationSubtitle:
          destination?['address']?.toString() ?? 'Não informado',
      distanceLabel:
          distanceKm > 0 ? '${distanceKm.toStringAsFixed(1)} km' : '--',
      durationLabel: durationMin > 0 ? '${durationMin.round()} min' : '--',
      paymentLabel: payment,
      plate: _vehiclePlate(vehicle) ?? '--',
      rating: _driverRating(driver) ?? 5,
      passengerRating: _parsePassengerRating(json),
      driverPhotoUrl: _driverPhotoUrl(driver),
      latitude: (pickup?['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (pickup?['longitude'] as num?)?.toDouble() ?? 0.0,
      hasDriverAccepted: hasDriverAccepted,
    );
  }

  int? _parsePassengerRating(Map<String, dynamic> json) {
    final rating = json['passengerRating'] ??
        json['passenger_rating'] ??
        json['ratingByPassenger'] ??
        json['rating_by_passenger'];
    final value = rating is num ? rating.toInt() : int.tryParse('$rating');
    return value != null && value >= 1 && value <= 5 ? value : null;
  }

  Map<String, dynamic>? _vehicleFromRide(
    Map<String, dynamic> ride,
    Map<String, dynamic>? driver,
  ) {
    for (final value in [
      driver?['activeVehicle'],
      driver?['vehicle'],
      ride['activeVehicle'],
      ride['vehicle'],
    ]) {
      if (value is Map) return Map<String, dynamic>.from(value);
    }
    return null;
  }

  String? _vehicleDisplayName(Map<String, dynamic>? vehicle) {
    if (vehicle == null) return null;
    String? valueFor(List<String> keys) {
      for (final key in keys) {
        final value = vehicle[key]?.toString().trim();
        if (value != null && value.isNotEmpty) return value;
      }
      return null;
    }

    final text = [
      valueFor(const ['manufacturer', 'brand', 'make']),
      valueFor(const ['modelName', 'model_name', 'model', 'name']),
      valueFor(const ['year', 'modelYear', 'model_year']),
      valueFor(const ['color', 'vehicle_color', 'car_color']),
    ].whereType<String>().join(' · ');
    return text.isEmpty ? null : text;
  }

  String? _vehiclePlate(Map<String, dynamic>? vehicle) {
    if (vehicle == null) return null;
    for (final key in const [
      'vehiclePlate',
      'vehicle_plate',
      'licensePlate',
      'license_plate',
      'plate',
      'carPlate',
    ]) {
      final value = vehicle[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  String? _driverPhotoUrl(Map<String, dynamic>? driver) {
    if (driver == null) return null;
    final profile = driver['profile'] is Map
        ? Map<String, dynamic>.from(driver['profile'] as Map)
        : const <String, dynamic>{};
    final value = driver['profilePhotoUrl'] ??
        driver['profile_photo_url'] ??
        driver['profilePhoto'] ??
        driver['profile_photo'] ??
        driver['photoUrl'] ??
        driver['photo_url'] ??
        driver['avatarUrl'] ??
        driver['avatar'] ??
        profile['profilePhotoUrl'] ??
        profile['profile_photo_url'] ??
        profile['profilePhoto'] ??
        profile['profile_photo'] ??
        profile['photoUrl'] ??
        profile['photo_url'];
    final url = value?.toString().trim();
    if (url == null || url.isEmpty) return null;
    final parsed = Uri.tryParse(url);
    if (parsed == null) return null;
    if (parsed.hasScheme) return parsed.toString();
    final apiBase = Uri.parse(_baseApi.baseUrl);
    final origin = apiBase.replace(path: '/', query: null, fragment: null);
    return origin.resolve(url.startsWith('/') ? url : '/$url').toString();
  }

  double? _driverRating(Map<String, dynamic>? driver) {
    if (driver == null) return null;
    final profile = driver['profile'] is Map
        ? Map<String, dynamic>.from(driver['profile'] as Map)
        : const <String, dynamic>{};
    final value = driver['rating'] ??
        driver['averageRating'] ??
        driver['average_rating'] ??
        profile['rating'] ??
        profile['averageRating'] ??
        profile['average_rating'];
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  String _mapStatus(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'completed':
        return 'Concluida';
      case 'accepted':
        return 'Aceita';
      case 'ongoing':
        return 'Em andamento';
      case 'pending':
        return 'Agendada';
      case 'canceled':
        return 'Cancelada';
      default:
        return 'Em andamento';
    }
  }

  String _mapPaymentMethod(String? paymentMethod) {
    switch ((paymentMethod ?? '').toLowerCase()) {
      case 'cash':
        return 'Dinheiro';
      case 'pix':
        return 'Pix';
      case 'google_pay':
      case 'googlepay':
      case 'gpay':
        return 'Google Pay';
      case 'debit_card':
      case 'debit':
        return 'Cartão de Debito';
      case 'credit_card':
      case 'credit':
      case 'cartao':
        return 'Cartão de Crédito';
      default:
        return 'Pagamento no app';
    }
  }

  int _statusColor(String status) {
    switch (status) {
      case 'Concluida':
        return 0xFF16A34A;
      case 'Cancelada':
        return 0xFFEF4444;
      case 'Agendada':
        return 0xFF3B82F6;
      default:
        return 0xFFC92D7A;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Data indisponivel';
    }

    const months = [
      'jan',
      'fev',
      'mar',
      'abr',
      'mai',
      'jun',
      'jul',
      'ago',
      'set',
      'out',
      'nov',
      'dez',
    ];

    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day $month • $hour:$minute';
  }
}
