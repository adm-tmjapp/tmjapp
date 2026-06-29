import 'package:flutter/foundation.dart';
import 'package:tmjapp/features/trip_history/data/datasources/trip_history_remote_datasource.dart';
import 'package:tmjapp/features/trip_history/presentation/controllers/trip_history_state.dart';

class TripHistoryController extends ChangeNotifier {
  TripHistoryController({
    required TripHistoryRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final TripHistoryRemoteDataSource _remoteDataSource;
  bool _isDisposed = false;

  TripHistoryState _state = const TripHistoryState();
  TripHistoryState get state => _state;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  Future<void> initialize() async {
    if (_isDisposed) return;

    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      final trips = await _remoteDataSource.fetchTrips();
      if (_isDisposed) return;

      _state = _state.copyWith(
        isLoading: false,
        allTrips: trips,
        clearError: true,
      );
    } catch (error) {
      if (_isDisposed) return;

      _state = _state.copyWith(
        isLoading: false,
        errorMessage: error.toString().replaceFirst('Exception: ', ''),
      );
    }
    notifyListeners();
  }

  Future<void> refresh() => initialize();

  void selectTab(int index) {
    if (_isDisposed) return;

    _state = _state.copyWith(selectedTab: index, clearError: true);
    notifyListeners();
  }
}
