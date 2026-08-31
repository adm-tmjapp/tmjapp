import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmjapp/features/destination_search/domain/entities/route_location.dart';
import 'package:tmjapp/features/destination_search/domain/entities/place_suggestion.dart';
import 'package:tmjapp/features/destination_search/domain/repositories/destination_search_repository.dart';
import 'package:tmjapp/features/destination_search/domain/usecases/resolve_destination_usecase.dart';
import 'package:tmjapp/features/destination_search/domain/usecases/search_places_usecase.dart';
import 'package:tmjapp/features/favorites/data/datasources/favorite_address_local_datasource.dart';
import 'package:tmjapp/features/favorites/presentation/controllers/add_favorite_address_controller.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('stores Casa, Trabalho and Academia independently', () async {
    final dataSource = FavoriteAddressLocalDataSource();
    const casa = RouteLocation(
      title: 'Rua de Casa, 10',
      subtitle: 'Recife - PE',
      latitude: -8.01,
      longitude: -34.90,
    );
    const trabalho = RouteLocation(
      title: 'Avenida do Trabalho, 20',
      subtitle: 'Recife - PE',
      latitude: -8.02,
      longitude: -34.91,
    );
    const academia = RouteLocation(
      title: 'Rua da Academia, 30',
      subtitle: 'Recife - PE',
      latitude: -8.03,
      longitude: -34.92,
    );

    await dataSource.saveFavorite(label: 'Casa', location: casa);
    await dataSource.saveFavorite(label: 'Trabalho', location: trabalho);
    await dataSource.saveFavorite(label: 'Academia', location: academia);

    expect((await dataSource.getFavorite('Casa'))?.title, casa.title);
    expect((await dataSource.getFavorite('Trabalho'))?.title, trabalho.title);
    expect((await dataSource.getFavorite('Academia'))?.title, academia.title);
  });

  test('updates only the selected favorite category', () async {
    final dataSource = FavoriteAddressLocalDataSource();
    const original = RouteLocation(
      title: 'Rua Antiga, 10',
      subtitle: 'Recife - PE',
      latitude: -8.01,
      longitude: -34.90,
    );
    const updated = RouteLocation(
      title: 'Rua Nova, 99',
      subtitle: 'Recife - PE',
      latitude: -8.04,
      longitude: -34.93,
    );

    await dataSource.saveFavorite(label: 'Casa', location: original);
    await dataSource.saveFavorite(label: 'Casa', location: updated);

    final saved = await dataSource.getFavorite('Casa');
    expect(saved?.title, updated.title);
    expect(saved?.latitude, updated.latitude);
  });

  test('lists and deletes persisted favorites', () async {
    final dataSource = FavoriteAddressLocalDataSource();
    const location = RouteLocation(
      title: 'Rua para excluir, 55',
      subtitle: 'Recife - PE',
      latitude: -8.06,
      longitude: -34.95,
    );

    await dataSource.saveFavorite(label: 'Casa', location: location);
    expect((await dataSource.getAllFavorites())['Casa']?.title, location.title);

    await dataSource.deleteFavorite('Casa');
    expect(await dataSource.getFavorite('Casa'), isNull);
    expect(await dataSource.getAllFavorites(), isEmpty);
  });

  test('controller saves a custom-named location in the Academia card',
      () async {
    final dataSource = FavoriteAddressLocalDataSource();
    final repository = _UnusedDestinationRepository();
    final controller = AddFavoriteAddressController(
      searchPlacesUseCase: SearchPlacesUseCase(repository),
      resolveDestinationUseCase: ResolveDestinationUseCase(repository),
      favoriteAddressLocalDataSource: dataSource,
    );
    const academia = RouteLocation(
      title: 'Rua da Academia, 113',
      subtitle: 'Recife - PE',
      latitude: -8.05,
      longitude: -34.94,
    );

    controller
      ..setLabel('Academia')
      ..setPresetLocation(academia)
      ..updateCustomLabel('Academia perto de casa');
    await controller.saveFavorite();

    expect(controller.state.successMessage, isNotNull);
    expect((await dataSource.getFavorite('Academia'))?.title, academia.title);
    expect(await dataSource.getFavorite('Casa'), isNull);
    controller.dispose();
  });
}

class _UnusedDestinationRepository implements DestinationSearchRepository {
  @override
  Future<RouteLocation> getCurrentLocation() => throw UnimplementedError();

  @override
  Future<List<RouteLocation>> getRecentDestinations() =>
      throw UnimplementedError();

  @override
  Future<RouteLocation> getPlaceDetails(PlaceSuggestion suggestion) =>
      throw UnimplementedError();

  @override
  Future<void> saveRecentDestination(RouteLocation location) =>
      throw UnimplementedError();

  @override
  Future<List<PlaceSuggestion>> searchPlaces(String input) =>
      throw UnimplementedError();
}
