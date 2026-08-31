import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:tmjapp/core/config/app_config.dart';
import 'package:tmjapp/features/destination_search/domain/entities/place_suggestion.dart';
import 'package:tmjapp/features/destination_search/domain/entities/route_location.dart';

class DestinationSearchRemoteDataSource {
  DestinationSearchRemoteDataSource({
    Location? location,
    http.Client? client,
    String? apiKey,
  })  : _location = location ?? Location(),
        _client = client ?? http.Client(),
        _configuredApiKey = apiKey;

  final Location _location;
  final http.Client _client;
  final String? _configuredApiKey;

  String get _apiKey =>
      _configuredApiKey ?? AppConfig.instance.googlePlacesApiKey;

  String? _extractStreetNumber(String input) {
    final match = RegExp(r'(?:,|\s)\s*(\d+[a-zA-Z]?(?:[-/]\d+)?)\s*$')
        .firstMatch(input.trim());
    return match?.group(1);
  }

  String _withTypedStreetNumber(String address, String input) {
    final number = _extractStreetNumber(input);
    if (number == null ||
        RegExp('(?:^|\\D)${RegExp.escape(number)}(?:\\D|\$)')
            .hasMatch(address)) {
      return address;
    }
    return '$address, $number';
  }

  RouteLocation? _routeLocationFromResult(
    Map<String, dynamic> result, {
    required String typedAddress,
  }) {
    final geometry = result['geometry'] as Map<String, dynamic>? ?? const {};
    final location = geometry['location'] as Map<String, dynamic>? ?? const {};
    final latitude = (location['lat'] as num?)?.toDouble();
    final longitude = (location['lng'] as num?)?.toDouble();
    if (latitude == null || longitude == null) return null;

    final components =
        result['address_components'] as List<dynamic>? ?? const [];
    String? route;
    String? streetNumber;
    for (final component in components.whereType<Map<String, dynamic>>()) {
      final types = (component['types'] as List<dynamic>? ?? const [])
          .whereType<String>();
      if (types.contains('route')) {
        route = component['long_name'] as String?;
      }
      if (types.contains('street_number')) {
        streetNumber = component['long_name'] as String?;
      }
    }

    streetNumber ??= _extractStreetNumber(typedAddress);
    final formattedAddress =
        (result['formatted_address'] as String? ?? '').trim();
    final title = route?.trim().isNotEmpty == true
        ? _withTypedStreetNumber(
            streetNumber == null ? route! : '$route, $streetNumber',
            typedAddress,
          )
        : _withTypedStreetNumber(formattedAddress, typedAddress);

    return RouteLocation(
      title: title,
      subtitle: formattedAddress,
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<RouteLocation> getCurrentLocation() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        throw Exception('Ative a localizacao para buscar seu endereco.');
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

    final apiKey = _apiKey;
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json'
      '?latlng=$latitude,$longitude&key=$apiKey&language=pt-br',
    );

    final response = await _client.get(url);
    if (response.statusCode != 200) {
      throw Exception('Não foi possível carregar sua localização atual.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>? ?? const [];
    final formattedAddress = results.isNotEmpty
        ? (results.first as Map<String, dynamic>)['formatted_address']
            as String?
        : null;

    return RouteLocation(
      title: formattedAddress ?? 'Localizacao atual',
      subtitle: 'Localizacao atual',
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<List<PlaceSuggestion>> searchPlaces(String input) async {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return const [];
    }

    final apiKey = _apiKey;
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json'
      '?input=${Uri.encodeComponent(trimmed)}'
      '&key=$apiKey&language=pt-br&components=country:br',
    );

    final response = await _client.get(url);
    if (response.statusCode != 200) {
      throw Exception('Não foi possível buscar endereços agora.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final predictions = data['predictions'] as List<dynamic>? ?? const [];

    return predictions.map((prediction) {
      final item = prediction as Map<String, dynamic>;
      final structured =
          item['structured_formatting'] as Map<String, dynamic>? ?? const {};
      final rawTitle = structured['main_text'] as String? ??
          item['description'] as String? ??
          '';

      return PlaceSuggestion(
        title: _withTypedStreetNumber(rawTitle, trimmed),
        subtitle: structured['secondary_text'] as String? ?? '',
        placeId: item['place_id'] as String? ?? '',
        query: trimmed,
      );
    }).toList();
  }

  Future<RouteLocation> getPlaceDetails(PlaceSuggestion suggestion) async {
    final apiKey = _apiKey;
    final typedNumber = _extractStreetNumber(suggestion.query);

    if (typedNumber != null) {
      final geocodeUrl = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json'
        '?address=${Uri.encodeComponent(suggestion.query)}'
        '&key=$apiKey&language=pt-br&components=country:BR',
      );
      final geocodeResponse = await _client.get(geocodeUrl);
      if (geocodeResponse.statusCode == 200) {
        final geocodeData =
            jsonDecode(geocodeResponse.body) as Map<String, dynamic>;
        final results = geocodeData['results'] as List<dynamic>? ?? const [];
        if (results.isNotEmpty) {
          final resolved = _routeLocationFromResult(
            results.first as Map<String, dynamic>,
            typedAddress: suggestion.query,
          );
          if (resolved != null) return resolved;
        }
      }
    }

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json'
      '?place_id=${suggestion.placeId}&key=$apiKey&language=pt-br',
    );

    final response = await _client.get(url);
    if (response.statusCode != 200) {
      throw Exception('Não foi possível carregar o endereço selecionado.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final result = data['result'] as Map<String, dynamic>? ?? const {};
    final resolved = _routeLocationFromResult(
      result,
      typedAddress:
          suggestion.query.isEmpty ? suggestion.title : suggestion.query,
    );
    if (resolved == null) {
      throw Exception('Não foi possível resolver esse endereço.');
    }
    return resolved;
  }
}
