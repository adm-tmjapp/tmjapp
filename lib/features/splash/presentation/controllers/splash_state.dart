import 'package:tmjapp/features/splash/domain/entities/splash_destination.dart';

class SplashState {
  const SplashState({
    required this.progress,
    required this.isLoading,
    this.destination,
  });

  const SplashState.initial()
      : progress = 0.0,
        isLoading = true,
        destination = null;

  final double progress;
  final bool isLoading;
  final SplashDestination? destination;

  SplashState copyWith({
    double? progress,
    bool? isLoading,
    SplashDestination? destination,
  }) {
    return SplashState(
      progress: progress ?? this.progress,
      isLoading: isLoading ?? this.isLoading,
      destination: destination ?? this.destination,
    );
  }
}
