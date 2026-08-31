import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tmjapp/features/destination_search/data/datasources/destination_search_remote_datasource.dart';
import 'package:tmjapp/features/destination_search/domain/entities/place_suggestion.dart';

void main() {
  test('keeps the typed street number in autocomplete suggestions', () async {
    final dataSource = DestinationSearchRemoteDataSource(
      apiKey: 'test-key',
      client: MockClient((request) async {
        expect(request.url.path, contains('/place/autocomplete/json'));
        expect(request.url.queryParameters['input'],
            'Rua Demóstenes Madeira de Pinho 113');
        return http.Response(
          jsonEncode({
            'status': 'OK',
            'predictions': [
              {
                'place_id': 'street-place-id',
                'description':
                    'Rua Demóstenes Madeira de Pinho, Rio de Janeiro',
                'structured_formatting': {
                  'main_text': 'Rua Demóstenes Madeira de Pinho',
                  'secondary_text': 'Recreio dos Bandeirantes, Rio de Janeiro',
                },
              },
            ],
          }),
          200,
        );
      }),
    );

    final suggestions =
        await dataSource.searchPlaces('Rua Demóstenes Madeira de Pinho 113');

    expect(suggestions.single.title, 'Rua Demóstenes Madeira de Pinho, 113');
    expect(suggestions.single.query, 'Rua Demóstenes Madeira de Pinho 113');
  });

  test('geocodes the complete typed address to preserve number and precision',
      () async {
    final dataSource = DestinationSearchRemoteDataSource(
      apiKey: 'test-key',
      client: MockClient((request) async {
        expect(request.url.path, contains('/geocode/json'));
        expect(request.url.queryParameters['address'],
            'Rua Demóstenes Madeira de Pinho 113');
        return http.Response(
          jsonEncode({
            'status': 'OK',
            'results': [
              {
                'formatted_address':
                    'Rua Demóstenes Madeira de Pinho, 113 - Recreio dos Bandeirantes, Rio de Janeiro - RJ',
                'address_components': [
                  {
                    'long_name': '113',
                    'types': ['street_number'],
                  },
                  {
                    'long_name': 'Rua Demóstenes Madeira de Pinho',
                    'types': ['route'],
                  },
                ],
                'geometry': {
                  'location': {'lat': -23.0123, 'lng': -43.4567},
                },
              },
            ],
          }),
          200,
        );
      }),
    );

    final location = await dataSource.getPlaceDetails(
      const PlaceSuggestion(
        title: 'Rua Demóstenes Madeira de Pinho, 113',
        subtitle: 'Recreio dos Bandeirantes, Rio de Janeiro',
        placeId: 'street-place-id',
        query: 'Rua Demóstenes Madeira de Pinho 113',
      ),
    );

    expect(location.title, 'Rua Demóstenes Madeira de Pinho, 113');
    expect(location.subtitle, contains('113'));
    expect(location.latitude, -23.0123);
    expect(location.longitude, -43.4567);
  });
}
