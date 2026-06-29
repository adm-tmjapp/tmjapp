import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmjapp/features/destination_search/domain/entities/route_location.dart';

class DestinationSearchLocalDataSource {
  static const _recentDestinationsKey = 'destination_search.recent_destinations';

  Future<List<RouteLocation>> getRecentDestinations() async {
    final preferences = await SharedPreferences.getInstance();
    final encodedItems =
        preferences.getStringList(_recentDestinationsKey) ?? const [];

    return encodedItems
        .map((item) => jsonDecode(item) as Map<String, dynamic>)
        .map(RouteLocation.fromJson)
        .toList();
  }

  Future<void> saveRecentDestination(RouteLocation location) async {
    final preferences = await SharedPreferences.getInstance();
    final currentItems = await getRecentDestinations();

    final filtered = currentItems
        .where((item) => item.title.toLowerCase() != location.title.toLowerCase())
        .toList();

    final updated = [location, ...filtered].take(6).toList();

    await preferences.setStringList(
      _recentDestinationsKey,
      updated.map((item) => jsonEncode(item.toJson())).toList(),
    );
  }
}
