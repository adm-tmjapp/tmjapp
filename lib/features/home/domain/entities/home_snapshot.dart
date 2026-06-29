import 'package:tmjapp/features/home/domain/entities/home_active_ride.dart';
import 'package:tmjapp/features/home/domain/entities/home_driver.dart';
import 'package:tmjapp/features/home/domain/entities/home_location.dart';
import 'package:tmjapp/features/home/domain/entities/home_profile.dart';

class HomeSnapshot {
  const HomeSnapshot({
    required this.profile,
    required this.currentLocation,
    required this.activeDrivers,
    required this.activeRide,
  });

  final HomeProfile profile;
  final HomeLocation currentLocation;
  final List<HomeDriver> activeDrivers;
  final HomeActiveRide? activeRide;
}
