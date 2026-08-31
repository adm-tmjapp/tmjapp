import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmjapp/features/destination_search/domain/entities/route_location.dart';
import 'package:tmjapp/features/home/domain/entities/home_location.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_request_args.dart';

class RideConfirmationDraftLocalDataSource {
  static const _key = 'ride_request.confirmation_draft';

  Future<void> save(RideRequestArgs args) async {
    final preferences = await SharedPreferences.getInstance();
    final didSave = await preferences.setString(
      _key,
      jsonEncode({
        'userId': args.userId,
        'origin': args.origin.toJson(),
        'destination': args.destination.toJson(),
        'routePoints': args.routePoints
            .map((point) => {
                  'latitude': point.latitude,
                  'longitude': point.longitude,
                })
            .toList(),
      }),
    );
    if (!didSave) {
      throw Exception('Não foi possível guardar a confirmação da corrida.');
    }
  }

  Future<RideRequestArgs?> load() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_key);
    if (encoded == null || encoded.isEmpty) return null;

    try {
      final json = jsonDecode(encoded) as Map<String, dynamic>;
      final userId = (json['userId'] ?? '').toString().trim();
      final origin = RouteLocation.fromJson(
        json['origin'] as Map<String, dynamic>,
      );
      final destination = RouteLocation.fromJson(
        json['destination'] as Map<String, dynamic>,
      );
      final routePoints = (json['routePoints'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(
            (point) => HomeLocation(
              latitude: (point['latitude'] as num).toDouble(),
              longitude: (point['longitude'] as num).toDouble(),
            ),
          )
          .toList();
      if (userId.isEmpty) return null;
      return RideRequestArgs(
        userId: userId,
        origin: origin,
        destination: destination,
        routePoints: routePoints,
      );
    } catch (_) {
      await clear();
      return null;
    }
  }

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_key);
  }
}
