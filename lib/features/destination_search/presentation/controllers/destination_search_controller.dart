import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tmjapp/features/destination_search/domain/entities/destination_search_result.dart';
import 'package:tmjapp/features/destination_search/domain/entities/place_suggestion.dart';
import 'package:tmjapp/features/destination_search/domain/entities/route_location.dart';
import 'package:tmjapp/features/destination_search/domain/usecases/get_current_route_origin_usecase.dart';
import 'package:tmjapp/features/destination_search/domain/usecases/get_recent_destinations_usecase.dart';
import 'package:tmjapp/features/destination_search/domain/usecases/resolve_destination_usecase.dart';
import 'package:tmjapp/features/destination_search/domain/usecases/save_recent_destination_usecase.dart';
import 'package:tmjapp/features/destination_search/domain/usecases/search_places_usecase.dart';
import 'package:tmjapp/features/destination_search/presentation/controllers/destination_search_state.dart';

class DestinationSearchController extends ChangeNotifier {
  DestinationSearchController({
    required GetCurrentRouteOriginUseCase getCurrentRouteOriginUseCase,
    required GetRecentDestinationsUseCase getRecentDestinationsUseCase,
    required SearchPlacesUseCase searchPlacesUseCase,
    required ResolveDestinationUseCase resolveDestinationUseCase,
    required SaveRecentDestinationUseCase saveRecentDestinationUseCase,
  })  : _getCurrentRouteOriginUseCase = getCurrentRouteOriginUseCase,
        _getRecentDestinationsUseCase = getRecentDestinationsUseCase,
        _searchPlacesUseCase = searchPlacesUseCase,
        _resolveDestinationUseCase = resolveDestinationUseCase,
        _saveRecentDestinationUseCase = saveRecentDestinationUseCase;

  final GetCurrentRouteOriginUseCase _getCurrentRouteOriginUseCase;
  final GetRecentDestinationsUseCase _getRecentDestinationsUseCase;
  final SearchPlacesUseCase _searchPlacesUseCase;
  final ResolveDestinationUseCase _resolveDestinationUseCase;
  final SaveRecentDestinationUseCase _saveRecentDestinationUseCase;

  DestinationSearchState _state = DestinationSearchState.initial();
  Timer? _debounce;

  // NOVO: Flag para controlar o ciclo de vida do controller
  bool _isDisposed = false;

  DestinationSearchState get state => _state;

  // NOVO: Sobrescrita do método para evitar o erro de uso após o dispose
  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  Future<void> initialize() async {
    _state = _state.copyWith(
      isLoading: true,
      isResolvingOrigin: true,
      clearErrorMessage: true,
      clearOriginErrorMessage: true,
    );
    notifyListeners();

    try {
      _state = _state.copyWith(
        recentDestinations: await _getRecentDestinationsUseCase.execute(),
        isLoading: false,
        clearErrorMessage: true,
      );
      notifyListeners();
    } catch (error) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: error.toString().replaceFirst('Exception: ', ''),
      );
      notifyListeners();
    }

    await retryResolveOrigin();
  }

  Future<void> retryResolveOrigin() async {
    _state = _state.copyWith(
      isResolvingOrigin: true,
      clearOriginErrorMessage: true,
    );
    notifyListeners();

    try {
      final origin = await _getCurrentRouteOriginUseCase.execute().timeout(
            const Duration(seconds: 8),
          );
      _state = _state.copyWith(
        origin: origin,
        isResolvingOrigin: false,
        clearOriginErrorMessage: true,
      );
    } catch (error) {
      _state = _state.copyWith(
        isResolvingOrigin: false,
        originErrorMessage: error.toString().replaceFirst('Exception: ', ''),
      );
    }

    notifyListeners();
  }

  void updateQuery(String value) {
    _debounce?.cancel();
    _state = _state.copyWith(
      query: value,
      isSearching: value.trim().isNotEmpty,
      clearErrorMessage: true,
      clearSuggestions: value.trim().isEmpty,
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

  Future<DestinationSearchResult?> selectSuggestion(
    PlaceSuggestion suggestion,
  ) async {
    final origin = await _requireOrigin();
    if (origin == null) {
      return null;
    }

    try {
      final destination = await _resolveDestinationUseCase.execute(suggestion);
      await _saveRecentDestinationUseCase.execute(destination);
      final recentDestinations = await _getRecentDestinationsUseCase.execute();

      _state = _state.copyWith(
        recentDestinations: recentDestinations,
        clearSuggestions: true,
        query: destination.title,
      );
      notifyListeners();

      return DestinationSearchResult(
        origin: origin,
        destination: destination,
      );
    } catch (error) {
      _state = _state.copyWith(
        errorMessage: error.toString().replaceFirst('Exception: ', ''),
      );
      notifyListeners();
      return null;
    }
  }

  Future<DestinationSearchResult?> selectRecentDestination(
    RouteLocation destination,
  ) async {
    final origin = await _requireOrigin();
    if (origin == null) {
      return null;
    }

    await _saveRecentDestinationUseCase.execute(destination);
    return DestinationSearchResult(origin: origin, destination: destination);
  }

  Future<RouteLocation?> _requireOrigin() async {
    if (_state.origin != null) {
      return _state.origin;
    }

    if (!_state.isResolvingOrigin) {
      await retryResolveOrigin();
    }

    if (_state.origin != null) {
      return _state.origin;
    }

    _state = _state.copyWith(
      errorMessage: _state.originErrorMessage ??
          'Localização atual indisponivel no momento.',
    );
    notifyListeners();
    return null;
  }

  @override
  void dispose() {
    _isDisposed = true; // NOVO: Sinaliza que o controller foi destruído
    _debounce?.cancel();
    super.dispose();
  }
}
