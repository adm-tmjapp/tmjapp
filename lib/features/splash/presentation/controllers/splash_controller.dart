import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tmjapp/core/presentation/controllers/disposable_change_notifier.dart';
import 'package:tmjapp/features/splash/domain/usecases/resolve_splash_destination_usecase.dart';

import 'splash_state.dart';

class SplashController extends ChangeNotifier with DisposableChangeNotifier {
  SplashController(this._resolveDestinationUseCase);

  final ResolveSplashDestinationUseCase _resolveDestinationUseCase;

  SplashState _state = const SplashState.initial();
  SplashState get state => _state;

  Timer? _progressTimer;

  Future<void> initialize() async {
    const totalSteps = 24;
    const totalDuration = Duration(milliseconds: 1800);
    final stepDuration = Duration(
      milliseconds: totalDuration.inMilliseconds ~/ totalSteps,
    );

    _progressTimer?.cancel();
    var currentStep = 0;

    _progressTimer = Timer.periodic(stepDuration, (timer) {
      currentStep++;
      final nextProgress = currentStep / totalSteps;
      _state = _state.copyWith(
        progress: nextProgress.clamp(0.0, 1.0),
      );
      notifyListeners();
      if (currentStep >= totalSteps) {
        timer.cancel();
      }
    });

    final destination = await _resolveDestinationUseCase();
    if (isDisposed) return;
    await Future<void>.delayed(totalDuration);
    if (isDisposed) return;

    _state = _state.copyWith(
      progress: 1.0,
      isLoading: false,
      destination: destination,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }
}
