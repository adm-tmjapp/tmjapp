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
  })  : _location = location ?? Location(),
        _client = client ?? http.Client();

  final Location _location;
  final http.Client _client;

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

    final apiKey = AppConfig.instance.googlePlacesApiKey;
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

    final apiKey = AppConfig.instance.googlePlacesApiKey;
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
      final terms = item['terms'] as List<dynamic>? ?? const [];
      final title = terms.isNotEmpty
          ? (terms.first as Map<String, dynamic>)['value'] as String? ??
              (item['description'] as String? ?? '')
          : (item['description'] as String? ?? '');

      return PlaceSuggestion(
        title: title,
        subtitle:
            item['structured_formatting']?['secondary_text'] as String? ?? '',
        placeId: item['place_id'] as String? ?? '',
      );
    }).toList();
  }

  Future<RouteLocation> getPlaceDetails(PlaceSuggestion suggestion) async {
    final apiKey = AppConfig.instance.googlePlacesApiKey;
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
    final geometry = result['geometry'] as Map<String, dynamic>? ?? const {};
    final location = geometry['location'] as Map<String, dynamic>? ?? const {};
    final latitude = (location['lat'] as num?)?.toDouble();
    final longitude = (location['lng'] as num?)?.toDouble();

    if (latitude == null || longitude == null) {
      throw Exception('Não foi possível resolver esse endereço.');
    }

    return RouteLocation(
      title: suggestion.title,
      subtitle: suggestion.subtitle,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
