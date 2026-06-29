import 'package:flutter/foundation.dart';
import 'package:tmjapp/features/payments/data/datasources/payments_remote_datasource.dart';
import 'package:tmjapp/features/payments/presentation/controllers/payments_state.dart';

class PaymentsController extends ChangeNotifier {
  PaymentsController({
    required PaymentsRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final PaymentsRemoteDataSource _remoteDataSource;
  bool _isDisposed = false;

  PaymentsState _state = const PaymentsState();
  PaymentsState get state => _state;

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
      final overview = await _remoteDataSource.fetchOverview();
      if (_isDisposed) return;

      _state = _state.copyWith(
        isLoading: false,
        totalSpent: overview.totalSpent,
        completedRides: overview.completedRides,
        methods: overview.methods,
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
}
