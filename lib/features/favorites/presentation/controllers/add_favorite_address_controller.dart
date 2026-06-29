import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tmjapp/features/destination_search/domain/entities/place_suggestion.dart';
import 'package:tmjapp/features/destination_search/domain/entities/route_location.dart';
import 'package:tmjapp/features/destination_search/domain/usecases/resolve_destination_usecase.dart';
import 'package:tmjapp/features/destination_search/domain/usecases/search_places_usecase.dart';
import 'package:tmjapp/features/favorites/presentation/controllers/add_favorite_address_state.dart';

class AddFavoriteAddressController extends ChangeNotifier {
  AddFavoriteAddressController({
    required SearchPlacesUseCase searchPlacesUseCase,
    required ResolveDestinationUseCase resolveDestinationUseCase,
  })  : _searchPlacesUseCase = searchPlacesUseCase,
        _resolveDestinationUseCase = resolveDestinationUseCase;

  final SearchPlacesUseCase _searchPlacesUseCase;
  final ResolveDestinationUseCase _resolveDestinationUseCase;

  AddFavoriteAddressState _state = AddFavoriteAddressState.initial();
  Timer? _debounce;
  bool _isDisposed = false;

  AddFavoriteAddressState get state => _state;

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  void updateQuery(String value) {
    _debounce?.cancel();
    _state = _state.copyWith(
      query: value,
      isSearching: value.trim().isNotEmpty,
      clearSuggestions: value.trim().isEmpty,
      clearError: true,
      clearSuccess: true,
    );
    notifyListeners();

    if (value.trim().isEmpty) {
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 350), () async {
      try {
        final suggestions = await _searchPlacesUseCase.execute(value);
        _state = _state.copyWith(
          suggestions: suggestions,
          isSearching: false,
          clearError: true,
        );
      } catch (error) {
        _state = _state.copyWith(
          isSearching: false,
          errorMessage: error.toString().replaceFirst('Exception: ', ''),
        );
      }
      notifyListeners();
    });
  }

  Future<void> selectSuggestion(PlaceSuggestion suggestion) async {
    _state = _state.copyWith(isSearching: true, clearError: true, clearSuccess: true);
    notifyListeners();
    try {
      final destination = await _resolveDestinationUseCase.execute(suggestion);
      _state = _state.copyWith(
        isSearching: false,
        selectedLocation: RouteLocation(
          title: destination.title,
          subtitle: destination.subtitle,
          latitude: destination.latitude,
          longitude: destination.longitude,
        ),
        query: destination.title,
        clearSuggestions: true,
      );
    } catch (error) {
      _state = _state.copyWith(
        isSearching: false,
        errorMessage: error.toString().replaceFirst('Exception: ', ''),
      );
    }
    notifyListeners();
  }

  void setPresetLocation(RouteLocation location) {
    _state = _state.copyWith(
      selectedLocation: location,
      query: location.title,
      clearError: true,
      clearSuccess: true,
      clearSuggestions: true,
    );
    notifyListeners();
  }

  void setLabel(String value) {
    _state = _state.copyWith(
      selectedLabel: value,
      clearSuccess: true,
      clearError: true,
    );
    notifyListeners();
  }

  void updateCustomLabel(String value) {
    _state = _state.copyWith(customLabel: value, clearSuccess: true);
    notifyListeners();
  }

  Future<void> saveFavorite() async {
    if (_state.selectedLocation == null) {
      _state = _state.copyWith(
        errorMessage: 'Selecione um endere\u00e7o para salvar.',
        clearSuccess: true,
      );
      notifyListeners();
      return;
    }

    _state = _state.copyWith(isSaving: true, clearError: true, clearSuccess: true);
    notifyListeners();

    // TODO: integrar com backend/armazenamento real de favoritos.
    await Future<void>.delayed(const Duration(milliseconds: 450));

    final label = _state.customLabel.trim().isNotEmpty ? _state.customLabel.trim() : _state.selectedLabel;
    _state = _state.copyWith(
      isSaving: false,
      successMessage: 'Endere\u00e7o salvo como "$label".',
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _debounce?.cancel();
    super.dispose();
  }
}
