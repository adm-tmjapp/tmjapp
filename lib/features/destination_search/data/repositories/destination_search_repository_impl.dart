import 'package:tmjapp/features/destination_search/data/datasources/destination_search_local_datasource.dart';
import 'package:tmjapp/features/destination_search/data/datasources/destination_search_remote_datasource.dart';
import 'package:tmjapp/features/destination_search/domain/entities/place_suggestion.dart';
import 'package:tmjapp/features/destination_search/domain/entities/route_location.dart';
import 'package:tmjapp/features/destination_search/domain/repositories/destination_search_repository.dart';

class DestinationSearchRepositoryImpl implements DestinationSearchRepository {
  DestinationSearchRepositoryImpl({
    required DestinationSearchLocalDataSource localDataSource,
    required DestinationSearchRemoteDataSource remoteDataSource,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource;

  final DestinationSearchLocalDataSource _localDataSource;
  final DestinationSearchRemoteDataSource _remoteDataSource;

  @override
  Future<RouteLocation> getCurrentLocation() {
    return _remoteDataSource.getCurrentLocation();
  }

  @override
  Future<List<PlaceSuggestion>> searchPlaces(String input) {
    return _remoteDataSource.searchPlaces(input);
  }

  @override
  Future<RouteLocation> getPlaceDetails(PlaceSuggestion suggestion) {
    return _remoteDataSource.getPlaceDetails(suggestion);
  }

  @override
  Future<List<RouteLocation>> getRecentDestinations() {
    return _localDataSource.getRecentDestinations();
  }

  @override
  Future<void> saveRecentDestination(RouteLocation location) {
    return _localDataSource.saveRecentDestination(location);
  }
}
