import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmjapp/api/base_api.dart';
import 'package:tmjapp/features/destination_search/domain/entities/route_location.dart';
import 'package:tmjapp/features/ride_request/data/datasources/ride_request_remote_datasource.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('atualiza o destino da corrida existente sem criar outra corrida',
      () async {
    SharedPreferences.setMockInitialValues({});
    late http.Request capturedRequest;
    final client = MockClient((request) async {
      capturedRequest = request;
      return http.Response('', 204);
    });
    final dataSource = RideRequestRemoteDataSource(
      baseApi: BaseApi(baseUrl: 'https://api.tmj.test/', client: client),
    );

    await dataSource.updateRideRoute(
      rideId: 'ride-123',
      destination: const RouteLocation(
        title: 'Av. Brasil, 1000',
        subtitle: 'Rio de Janeiro',
        latitude: -22.9,
        longitude: -43.2,
      ),
      stops: const [
        RouteLocation(
          title: 'Praça XV, 10',
          subtitle: 'Centro',
          latitude: -22.90,
          longitude: -43.17,
        ),
      ],
    );

    expect(capturedRequest.method, 'PATCH');
    expect(
      capturedRequest.url.toString(),
      'https://api.tmj.test/v2/passenger/rides/ride-123',
    );
    final body = jsonDecode(capturedRequest.body) as Map<String, dynamic>;
    expect(body.containsKey('pickup_location'), isFalse);
    expect(body['destination_location']['address'], 'Av. Brasil, 1000');
    expect(body['destination_location']['coordinates']['latitude'], -22.9);
    expect(body['stops'], hasLength(1));
    expect(body['stops'][0]['address'], 'Praça XV, 10');
  });
}
