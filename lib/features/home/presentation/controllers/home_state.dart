import 'package:tmjapp/features/home/domain/entities/home_active_ride.dart';
import 'package:tmjapp/features/home/domain/entities/home_driver.dart';
import 'package:tmjapp/features/home/domain/entities/home_location.dart';
import 'package:tmjapp/features/home/domain/entities/home_profile.dart';

class HomeState {
  const HomeState({
    required this.profile,
    required this.drivers,
    required this.activeRide,
    required this.routePoints,
    required this.isLoading,
    required this.isPreviewingRoute,
    required this.errorMessage,
    required this.currentLocation,
  });

  factory HomeState.initial() {
    return const HomeState(
      profile: HomeProfile(name: '', phone: '', userId: ''),
      drivers: [],
      activeRide: null,
      routePoints: [],
      isLoading: true,
      isPreviewingRoute: false,
      errorMessage: null,
      currentLocation: null,
    );
  }

  final HomeProfile profile;
  final List<HomeDriver> drivers;
  final HomeActiveRide? activeRide;
  final List<HomeLocation> routePoints;
  final bool isLoading;
  final bool isPreviewingRoute;
  final String? errorMessage;
  final HomeLocation? currentLocation;

  HomeState copyWith({
    HomeProfile? profile,
    List<HomeDriver>? drivers,
    HomeActiveRide? activeRide,
    List<HomeLocation>? routePoints,
    bool? isLoading,
    bool? isPreviewingRoute,
    String? errorMessage,
    HomeLocation? currentLocation,
    bool clearErrorMessage = false,
    bool clearRoute = false,
    bool clearActiveRide = false,
  }) {
    return HomeState(
      profile: profile ?? this.profile,
      drivers: drivers ?? this.drivers,
      activeRide: clearActiveRide ? null : (activeRide ?? this.activeRide),
      routePoints: clearRoute ? const [] : (routePoints ?? this.routePoints),
      isLoading: isLoading ?? this.isLoading,
      isPreviewingRoute: isPreviewingRoute ?? this.isPreviewingRoute,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      currentLocation: currentLocation ?? this.currentLocation,
    );
  }
}
