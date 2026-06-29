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
    final vehicle = json['vehicle'] as Map<String, dynamic>?;
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

    return TripHistoryItem(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: destination?['address']?.toString() ?? 'Viagem TMJ',
      driverName: driver?['name']?.toString() ?? 'Motorista a definir',
      vehicle: vehicle?['model']?.toString() ??
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
      plate: vehicle?['license_plate']?.toString() ?? '--',
      rating: (driver?['rating'] as num?)?.toDouble() ?? 5,
      latitude: (pickup?['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (pickup?['longitude'] as num?)?.toDouble() ?? 0.0,
    );
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
