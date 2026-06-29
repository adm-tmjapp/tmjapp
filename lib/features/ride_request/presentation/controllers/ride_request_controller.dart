import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tmjapp/core/presentation/controllers/disposable_change_notifier.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_payment_method.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_request_args.dart';
import 'package:tmjapp/features/ride_request/domain/entities/ride_stage.dart';
import 'package:tmjapp/features/ride_request/domain/usecases/cancel_ride_usecase.dart';
import 'package:tmjapp/features/ride_request/domain/usecases/checkout_ride_usecase.dart';
import 'package:tmjapp/features/ride_request/domain/usecases/create_ride_quote_usecase.dart';
import 'package:tmjapp/features/ride_request/domain/usecases/get_ride_detail_usecase.dart';
import 'package:tmjapp/features/ride_request/domain/usecases/get_ride_eta_usecase.dart';
import 'package:tmjapp/features/ride_request/domain/usecases/get_ride_payment_options_usecase.dart';
import 'package:tmjapp/features/ride_request/domain/usecases/get_ride_status_usecase.dart';
import 'package:tmjapp/features/ride_request/domain/usecases/issue_ride_realtime_token_usecase.dart';
import 'package:tmjapp/features/ride_request/presentation/controllers/ride_request_state.dart';

class RideRequestController extends ChangeNotifier
    with DisposableChangeNotifier {
  RideRequestController({
    required RideRequestArgs args,
    required CreateRideQuoteUseCase createRideQuoteUseCase,
    required GetRidePaymentOptionsUseCase getRidePaymentOptionsUseCase,
    required CheckoutRideUseCase checkoutRideUseCase,
    required GetRideStatusUseCase getRideStatusUseCase,
    required GetRideDetailUseCase getRideDetailUseCase,
    required GetRideEtaUseCase getRideEtaUseCase,
    required IssueRideRealtimeTokenUseCase issueRideRealtimeTokenUseCase,
    required CancelRideUseCase cancelRideUseCase,
  })  : _args = args,
        _createRideQuoteUseCase = createRideQuoteUseCase,
        _getRidePaymentOptionsUseCase = getRidePaymentOptionsUseCase,
        _checkoutRideUseCase = checkoutRideUseCase,
        _getRideStatusUseCase = getRideStatusUseCase,
        _getRideDetailUseCase = getRideDetailUseCase,
        _getRideEtaUseCase = getRideEtaUseCase,
        _issueRideRealtimeTokenUseCase = issueRideRealtimeTokenUseCase,
        _cancelRideUseCase = cancelRideUseCase;

  final RideRequestArgs _args;
  final CreateRideQuoteUseCase _createRideQuoteUseCase;
  final GetRidePaymentOptionsUseCase _getRidePaymentOptionsUseCase;
  final CheckoutRideUseCase _checkoutRideUseCase;
  final GetRideStatusUseCase _getRideStatusUseCase;
  final GetRideDetailUseCase _getRideDetailUseCase;
  final GetRideEtaUseCase _getRideEtaUseCase;
  final IssueRideRealtimeTokenUseCase _issueRideRealtimeTokenUseCase;
  final CancelRideUseCase _cancelRideUseCase;
  Timer? _statusPollingTimer;

  RideRequestState _state = RideRequestState.initial();

  RideRequestState get state => _state;
  RideRequestArgs get args => _args;

  Future<void> initialize() async {
    _state = _state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
      stage: _args.hasExistingRide
          ? _resolveStage(_args.existingRideStatus ?? '')
          : RideStage.confirming,
    );
    notifyListeners();

    if (_args.hasExistingRide) {
      await _resumeRide();
      return;
    }

    try {
      final quote = await _createRideQuoteUseCase.execute(
        userId: _args.userId,
        origin: _args.origin,
        destination: _args.destination,
      );
      if (isDisposed) return;
      print('====== DADOS RECEBIDOS DA API ======');
      print('Produtos encontrados: ${quote.products.length}');
      print('====================================');
      final paymentOptions =
          await _getRidePaymentOptionsUseCase.execute(quote.rideId);
      if (isDisposed) return;

      _state = _state.copyWith(
        rideId: quote.rideId,
        products: quote.products,
        paymentOptions: paymentOptions.options,
        isLoading: false,
        selectedProductIndex: quote.products.isEmpty ? -1 : 0,
        selectedPaymentMethod: paymentOptions.selectedMethod,
        rideStatus: 'pending',
      );
    } catch (error) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: error.toString().replaceFirst('Exception: ', ''),
      );
    }

    notifyListeners();
  }

  Future<void> _resumeRide() async {
    final rideId = _args.existingRideId;
    if (rideId == null || rideId.trim().isEmpty) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: 'Não foi possível retomar a corrida atual.',
      );
      notifyListeners();
      return;
    }

    _state = _state.copyWith(
      rideId: rideId,
      products:
          _args.initialProduct == null ? const [] : [_args.initialProduct!],
      selectedProductIndex: _args.initialProduct == null ? -1 : 0,
      paymentMethodLabel: _args.initialPaymentMethodLabel,
      rideStatus: _args.existingRideStatus,
      isLoading: false,
    );
    notifyListeners();

    await _refreshRideDetail(rideId);
    if (isDisposed) return;
    await _refreshRideStatus();
    if (isDisposed) return;
    _startStatusPolling();
  }

  void selectProduct(int index) {
    if (index < 0 || index >= _state.products.length) {
      return;
    }

    _state = _state.copyWith(
      selectedProductIndex: index,
      clearErrorMessage: true,
    );
    notifyListeners();
  }

  void selectPaymentMethod(RidePaymentMethod method) {
    _state = _state.copyWith(
      selectedPaymentMethod: method,
      clearErrorMessage: true,
    );
    notifyListeners();
  }

  Future<void> cancelSearching() async {
    final rideId = _state.rideId;
    if (rideId == null || rideId.trim().isEmpty) {
      _state = _state.copyWith(
        errorMessage: 'Não foi possível localizar a corrida para cancelamento.',
      );
      print('Chegou no finally/fim do cancelamento');
      notifyListeners();
      return;
    }

    _state = _state.copyWith(
      isCancelling: true,
      clearErrorMessage: true,
    );
    notifyListeners();

    try {
      await _cancelRideUseCase.execute(
        rideId: rideId,
        reason: 'Cancelado pelo passageiro no app.',
      );
      if (isDisposed) return;
      _stopStatusPolling();
      _state = _state.copyWith(
        isCancelling: false,
        stage: RideStage.cancelled,
        rideStatus: 'cancelled',
        errorMessage: 'Corrida cancelada com sucesso.',
      );
    } catch (error) {
      _state = _state.copyWith(
        isCancelling: false,
        errorMessage: error.toString().replaceFirst('Exception: ', ''),
      );
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _stopStatusPolling();
    super.dispose();
  }

  void _startStatusPolling() {
    _stopStatusPolling();
    _statusPollingTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _refreshRideStatus(),
    );
    unawaited(_refreshRideStatus());
  }

  void _stopStatusPolling() {
    _statusPollingTimer?.cancel();
    _statusPollingTimer = null;
  }

  Future<void> _refreshRideStatus() async {
    if (isDisposed) return;
    final rideId = _state.rideId;
    if (rideId == null || rideId.trim().isEmpty) {
      return;
    }

    try {
      final snapshot = await _getRideStatusUseCase.execute(rideId);
      if (isDisposed) return;
      final nextStage = _resolveStage(snapshot.status);
      final shouldLoadRideDetails = nextStage != RideStage.searchingDriver;

      _state = _state.copyWith(
        stage: nextStage,
        rideStatus: snapshot.status,
        statusUpdatedAt: snapshot.updatedAt,
      );

      if (shouldLoadRideDetails) {
        await _refreshRideDetail(rideId);
      }

      if (nextStage == RideStage.driverAssigned ||
          nextStage == RideStage.rideInProgress) {
        await _refreshRideEta(rideId);
        await _ensureRealtimeSession(rideId);
      }

      if (_isTerminalStatus(snapshot.status)) {
        _stopStatusPolling();
      }

      notifyListeners();
    } catch (_) {
      // Mantem o fluxo ativo mesmo se uma consulta pontual falhar.
    }
  }

  bool _isTerminalStatus(String status) {
    final normalizedStatus = status.trim().toLowerCase();
    return normalizedStatus == 'completed' ||
        normalizedStatus == 'cancelled' ||
        normalizedStatus == 'canceled';
  }

  RideStage _resolveStage(String status) {
    final normalizedStatus = status.trim().toLowerCase();
    switch (normalizedStatus) {
      case 'accepted':
        return RideStage.driverAssigned;
      case 'ongoing':
        return RideStage.rideInProgress;
      case 'completed':
        return RideStage.completed;
      case 'cancelled':
      case 'canceled':
        return RideStage.cancelled;
      default:
        return RideStage.searchingDriver;
    }
  }

  Future<void> _refreshRideDetail(String rideId) async {
    try {
      final detail = await _getRideDetailUseCase.execute(rideId);
      if (isDisposed) return;
      _state = _state.copyWith(
        rideStatus: detail.status,
        driver: detail.driver,
        vehicle: detail.vehicle,
        paymentMethodLabel: _mapPaymentMethodLabel(detail.paymentMethod),
      );
    } catch (_) {
      // Mantem o fluxo responsivo mesmo se os detalhes atrasarem.
    }
  }

  Future<void> _refreshRideEta(String rideId) async {
    try {
      final eta = await _getRideEtaUseCase.execute(rideId);
      if (isDisposed) return;
      _state = _state.copyWith(
        rideStatus: eta.status,
        driverLatitude: eta.latitude,
        driverLongitude: eta.longitude,
        driverLocationUpdatedAt: eta.capturedAt,
      );
    } catch (_) {
      // ETA é complementar e não deve quebrar a tela.
    }
  }

  Future<void> _ensureRealtimeSession(String rideId) async {
    if (_state.realtimeSession != null) {
      return;
    }

    try {
      final session = await _issueRideRealtimeTokenUseCase.execute(rideId);
      if (isDisposed) return;
      _state = _state.copyWith(
        realtimeSession: session,
      );
    } catch (_) {
      // O polling continua cobrindo o fluxo enquanto o realtime não estiver ativo.
    }
  }

  String? _mapPaymentMethodLabel(String? backendValue) {
    final normalizedValue = (backendValue ?? '').trim().toUpperCase();
    switch (normalizedValue) {
      case 'CARD':
        return 'Cartao';
      case 'PIX':
        return 'Pix';
      case 'CASH':
        return 'Dinheiro';
      default:
        return null;
    }
  }

  // Adicionamos o parâmetro nomeado opcional {String? cardId}
  Future<void> requestRide({String? cardId}) async {
    final selectedProduct = _state.selectedProduct;
    if (selectedProduct == null) {
      _state = _state.copyWith(
        errorMessage: 'Escolha um veiculo para continuar.',
      );
      notifyListeners();
      return;
    }

    if ((_state.rideId ?? '').trim().isEmpty) {
      _state = _state.copyWith(
        errorMessage: 'Não foi possível identificar a corrida para finalizar.',
      );
      notifyListeners();
      return;
    }

    _state = _state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
    );
    notifyListeners();

    try {
      final checkoutResult = await _checkoutRideUseCase.execute(
        rideId: _state.rideId!,
        product: selectedProduct,
        paymentMethod: _state.selectedPaymentMethod,
        // cardId: cardId,  <-- COMENTE OU APAGUE ESTA LINHA POR ENQUANTO
      );
      if (isDisposed) return;
      final nextStage = _resolveStage(checkoutResult.status);

      _state = _state.copyWith(
        stage: nextStage,
        isLoading: false,
        rideStatus: checkoutResult.status,
        statusUpdatedAt: checkoutResult.updatedAt,
        clearErrorMessage: true,
      );
      if (nextStage != RideStage.searchingDriver) {
        await _refreshRideDetail(_state.rideId!);
        if (isDisposed) return;
      }
      if (isDisposed) return;
      _startStatusPolling();
    } catch (error) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: error.toString().replaceFirst('Exception: ', ''),
      );
    }

    notifyListeners();
  }
}
