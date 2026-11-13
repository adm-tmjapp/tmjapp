import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmjapp/api/base_api.dart';
import 'package:tmjapp/features/ride_request/data/datasources/ride_request_remote_datasource.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('uses the active vehicle fields from the TMJ Driver contract', () async {
    final client = MockClient((_) async => http.Response(
          jsonEncode({
            'id': 'ride-1',
            'status': 'accepted',
            'driver': {
              'id': 'driver-1',
              'name': 'Leopoldo Silva Santos',
              'activeVehicle': {
                'manufacturer': 'Citroen',
                'modelName': 'C3 You',
                'year': '2026',
                'vehiclePlate': 'ABCD122',
                'color': 'BRANCO',
                'vehicleType': 'CAR',
              },
            },
          }),
          200,
        ));
    final dataSource = RideRequestRemoteDataSource(
      baseApi: BaseApi(baseUrl: 'https://api.tmj.test/api/v2', client: client),
    );

    final detail = await dataSource.getRideDetail('ride-1');

    expect(detail.vehicle?.model, 'Citroen C3 You 2026');
    expect(detail.vehicle?.licensePlate, 'ABCD122');
    expect(detail.vehicle?.color, 'BRANCO');
  });
}
