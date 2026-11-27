import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmjapp/api/base_api.dart';
import 'package:tmjapp/features/trip_history/data/datasources/trip_history_remote_datasource.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('maps the assigned driver profile photo from the ride history API',
      () async {
    final client = MockClient((_) async => http.Response(
          jsonEncode([
            {
              'id': 'ride-1',
              'status': 'completed',
              'driver': {
                'name': 'Mariana',
                'profile': {
                  'profilePhoto': '/uploads/drivers/mariana.jpg',
                  'averageRating': 4.8,
                },
                'activeVehicle': {
                  'manufacturer': 'Citroen',
                  'modelName': 'C3 You',
                  'year': '2026',
                  'vehiclePlate': 'ABCD122',
                  'color': 'BRANCO',
                },
              },
            },
          ]),
          200,
        ));
    final dataSource = TripHistoryRemoteDataSource(
      baseApi: BaseApi(baseUrl: 'https://api.tmj.test/api/v2', client: client),
    );

    final trips = await dataSource.fetchTrips();

    expect(trips.single.driverPhotoUrl,
        'https://api.tmj.test/uploads/drivers/mariana.jpg');
    expect(trips.single.vehicle, 'Citroen · C3 You · 2026 · BRANCO');
    expect(trips.single.plate, 'ABCD122');
    expect(trips.single.rating, 4.8);
  });

  test('uses the active vehicle from the driver collection when needed',
      () async {
    final client = MockClient((_) async => http.Response(
          jsonEncode([
            {
              'id': 'ride-1',
              'driver': {
                'activeVehicle': {'id': 'stale-reference'},
                'vehicles': [
                  {
                    'isActive': true,
                    'model': 'Veículo cadastrado',
                    'plate': 'NEW0001',
                  },
                ],
              },
            },
          ]),
          200,
        ));
    final dataSource = TripHistoryRemoteDataSource(
      baseApi: BaseApi(baseUrl: 'https://api.tmj.test/api/v2', client: client),
    );

    final trips = await dataSource.fetchTrips();

    expect(trips.single.vehicle, 'Veículo cadastrado');
    expect(trips.single.plate, 'NEW0001');
  });
}
