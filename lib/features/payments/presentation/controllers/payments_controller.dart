import 'package:flutter/foundation.dart';
import 'package:tmjapp/features/payments/data/datasources/payments_remote_datasource.dart';
import 'package:tmjapp/features/payments/data/datasources/payments_local_datasource.dart';
import 'package:tmjapp/features/payments/domain/entities/payment_method_item.dart';
import 'package:tmjapp/features/payments/presentation/controllers/payments_state.dart';

class PaymentsController extends ChangeNotifier {
  PaymentsController({
    required PaymentsRemoteDataSource remoteDataSource,
    PaymentsLocalDataSource? localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource ?? PaymentsLocalDataSource();

  final PaymentsRemoteDataSource _remoteDataSource;
  final PaymentsLocalDataSource _localDataSource;
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
      final localCards = await _localDataSource.getCards();
      final balance = await _localDataSource.getBalance();
      PaymentsOverview overview;
      try {
        overview = await _remoteDataSource.fetchOverview();
      } catch (_) {
        overview = const PaymentsOverview(
          totalSpent: 0,
          completedRides: 0,
          methods: [],
        );
      }
      if (_isDisposed) return;

      _state = _state.copyWith(
        isLoading: false,
        totalSpent: overview.totalSpent,
        completedRides: overview.completedRides,
        methods: [
          ...localCards,
          ...overview.methods.where(_isCardMethod),
        ],
        balance: balance,
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

  Future<void> saveCard(PaymentMethodItem card) async {
    await _localDataSource.saveCard(card);
    final localCards = await _localDataSource.getCards();
    final remoteMethods =
        _state.methods.where((item) => !item.isLocal && _isCardMethod(item));
    _state = _state.copyWith(methods: [...localCards, ...remoteMethods]);
    notifyListeners();
  }

  Future<void> addBalance(double amount) async {
    if (amount <= 0) return;
    final balance = await _localDataSource.addBalance(amount);
    _state = _state.copyWith(balance: balance);
    notifyListeners();
  }

  bool _isCardMethod(PaymentMethodItem item) {
    final id = item.id.toLowerCase();
    final brand = item.brand.toLowerCase();
    return brand == 'card' ||
        brand == 'visa' ||
        brand == 'mastercard' ||
        brand == 'elo' ||
        id.contains('card');
  }
}
