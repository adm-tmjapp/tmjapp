import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:tmjapp/core/config/app_environment.dart';

class AppConfig {
  AppConfig._({
    required this.environment,
    required this.apiBaseUrl,
    required this.googlePlacesApiKey,
    required this.apiAuthToken,
  });

  static late final AppConfig instance;

  final AppEnvironment environment;
  final String apiBaseUrl;
  final String googlePlacesApiKey;
  final String? apiAuthToken;

  static void initialize(AppEnvironment environment) {
    instance = AppConfig._(
      environment: environment,
      apiBaseUrl: _readRequired('API_BASE_URL'),
      googlePlacesApiKey: _readRequired('GOOGLE_PLACES_API_KEY'),
      apiAuthToken: _readOptional('API_AUTH_TOKEN'),
    );
  }

  static String _readRequired(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw StateError('Missing required env var: $key');
    }
    return value;
  }

  static String? _readOptional(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      return null;
    }
    return value;
  }
}
