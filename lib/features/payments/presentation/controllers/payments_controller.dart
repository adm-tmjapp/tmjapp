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

      List<PaymentMethodItem> savedCards;
      try {
        savedCards = await _remoteDataSource.fetchSavedCards();
      } catch (_) {
        savedCards = const [];
      }

      _state = _state.copyWith(
        isLoading: false,
        totalSpent: overview.totalSpent,
        completedRides: overview.completedRides,
        methods: [
          ...savedCards,
          ...overview.methods.where(_isCardMethod).where(
                (item) => savedCards.every((card) => card.id != item.id),
              ),
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

  Future<void> tokenizeCard({
    required String holderName,
    required String number,
    required String expiryMonth,
    required String expiryYear,
    required String ccv,
  }) async {
    final card = await _remoteDataSource.tokenizeCard(
      holderName: holderName,
      number: number,
      expiryMonth: expiryMonth,
      expiryYear: expiryYear,
      ccv: ccv,
    );
    final methods = [
      card,
      ..._state.methods.where((item) => item.id != card.id),
    ];
    _state = _state.copyWith(methods: methods);
    notifyListeners();
  }

  Future<void> refreshSavedCards() async {
    if (_isDisposed) return;

    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      final savedCards = await _remoteDataSource.fetchSavedCards();
      if (_isDisposed) return;

      _state = _state.copyWith(
        isLoading: false,
        methods: savedCards,
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
