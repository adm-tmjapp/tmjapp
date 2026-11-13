import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmjapp/api/base_api.dart';
import 'package:tmjapp/features/ride_request/data/datasources/ride_rating_remote_datasource.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('sends the passenger rating for the completed ride', () async {
    late http.Request request;
    final client = MockClient((value) async {
      request = value;
      return http.Response('', 204);
    });
    final dataSource = RideRatingRemoteDataSource(
      baseApi: BaseApi(baseUrl: 'https://api.tmj.test/', client: client),
    );

    await dataSource.submitDriverRating(rideId: 'ride-123', rating: 5);

    expect(request.url.path, '/v2/passenger/rides/ride-123/rating');
    expect(jsonDecode(request.body), {'rating': 5});
  });

  test('does not accept an out-of-range rating', () async {
    final dataSource = RideRatingRemoteDataSource(
      baseApi: BaseApi(
        baseUrl: 'https://api.tmj.test/',
        client: MockClient((_) async => http.Response('', 500)),
      ),
    );

    expect(
      () => dataSource.submitDriverRating(rideId: 'ride-123', rating: 0),
      throwsA(isA<Exception>()),
    );
  });
}
