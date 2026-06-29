import 'package:flutter/foundation.dart';
import 'package:tmjapp/features/home/domain/entities/home_location.dart';
import 'package:tmjapp/features/home/domain/usecases/build_trip_preview_usecase.dart';
import 'package:tmjapp/features/home/domain/usecases/load_home_data_usecase.dart';
import 'package:tmjapp/features/home/presentation/controllers/home_state.dart';

class HomeController extends ChangeNotifier {
  HomeController({
    required LoadHomeDataUseCase loadHomeDataUseCase,
    required BuildTripPreviewUseCase buildTripPreviewUseCase,
  })  : _loadHomeDataUseCase = loadHomeDataUseCase,
        _buildTripPreviewUseCase = buildTripPreviewUseCase;

  final LoadHomeDataUseCase _loadHomeDataUseCase;
  final BuildTripPreviewUseCase _buildTripPreviewUseCase;

  HomeState _state = HomeState.initial();
  bool _isDisposed = false;

  HomeState get state => _state;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _emit() {
    if (_isDisposed) return;
    notifyListeners();
  }

  Future<void> initialize() async {
    _state = _state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
    );
    _emit();

    try {
      final snapshot = await _loadHomeDataUseCase.execute();
      if (_isDisposed) return;
      _state = _state.copyWith(
        profile: snapshot.profile,
        currentLocation: snapshot.currentLocation,
        drivers: snapshot.activeDrivers,
        activeRide: snapshot.activeRide,
        isLoading: false,
        clearErrorMessage: true,
      );
    } catch (error) {
      if (_isDisposed) return;
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: error.toString().replaceFirst('Exception: ', ''),
      );
    }

    _emit();
  }

  Future<void> previewTrip({
    required HomeLocation origin,
    required HomeLocation destination,
  }) async {
    _state = _state.copyWith(
      isPreviewingRoute: true,
      clearErrorMessage: true,
    );
    _emit();

    try {
      final route = await _buildTripPreviewUseCase.execute(
        origin: origin,
        destination: destination,
      );
      if (_isDisposed) return;

      _state = _state.copyWith(
        isPreviewingRoute: false,
        routePoints: route,
      );
    } catch (error) {
      if (_isDisposed) return;
      _state = _state.copyWith(
        isPreviewingRoute: false,
        errorMessage: error.toString().replaceFirst('Exception: ', ''),
      );
    }

    _emit();
  }

  void clearTripPreview() {
    _state = _state.copyWith(clearRoute: true, clearErrorMessage: true);
    _emit();
  }

  void clearActiveRide() {
    _state = _state.copyWith(activeRide: null);
    _emit();
  }
}
