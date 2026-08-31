import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmjapp/features/destination_search/domain/entities/route_location.dart';

class FavoriteAddressLocalDataSource {
  static const _keyPrefix = 'favorites.address.';
  static const _labelsKey = 'favorites.address.labels';

  String _keyForLabel(String label) {
    final normalized = label.trim().toLowerCase().replaceAll(' ', '_');
    return '$_keyPrefix$normalized';
  }

  Future<RouteLocation?> getFavorite(String label) async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_keyForLabel(label));
    if (encoded == null || encoded.isEmpty) return null;

    try {
      return RouteLocation.fromJson(
        jsonDecode(encoded) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> saveFavorite({
    required String label,
    required RouteLocation location,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final didSave = await preferences.setString(
      _keyForLabel(label),
      jsonEncode(location.toJson()),
    );
    if (!didSave) {
      throw Exception('Não foi possível salvar o endereço neste dispositivo.');
    }
    final labels = preferences.getStringList(_labelsKey) ?? <String>[];
    if (!labels.contains(label)) {
      labels.add(label);
      await preferences.setStringList(_labelsKey, labels);
    }
  }

  Future<Map<String, RouteLocation>> getAllFavorites() async {
    final preferences = await SharedPreferences.getInstance();
    final labels = <String>{
      ...?preferences.getStringList(_labelsKey),
      // Migração dos favoritos salvos antes da criação do índice de rótulos.
      for (final label in const ['Casa', 'Trabalho', 'Academia'])
        if (preferences.containsKey(_keyForLabel(label))) label,
    };
    final result = <String, RouteLocation>{};
    for (final label in labels) {
      final favorite = await getFavorite(label);
      if (favorite != null) result[label] = favorite;
    }
    return result;
  }

  Future<void> deleteFavorite(String label) async {
    final preferences = await SharedPreferences.getInstance();
    final didRemove = await preferences.remove(_keyForLabel(label));
    final labels = preferences.getStringList(_labelsKey) ?? <String>[];
    labels.remove(label);
    await preferences.setStringList(_labelsKey, labels);
    if (!didRemove && preferences.containsKey(_keyForLabel(label))) {
      throw Exception('Não foi possível excluir o endereço.');
    }
  }
}
