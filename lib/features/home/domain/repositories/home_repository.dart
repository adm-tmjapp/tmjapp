import 'package:tmjapp/features/home/domain/entities/home_active_ride.dart';
import 'package:tmjapp/features/home/domain/entities/home_driver.dart';
import 'package:tmjapp/features/home/domain/entities/home_location.dart';
import 'package:tmjapp/features/home/domain/entities/home_profile.dart';

abstract class HomeRepository {
  Future<HomeProfile> getProfile();

  Future<HomeLocation> getCurrentLocation();

  Future<List<HomeDriver>> getActiveDrivers();

  Future<HomeActiveRide?> getActiveRide();

  Future<List<HomeLocation>> getRoute({
    required HomeLocation origin,
    required HomeLocation destination,
  });
}
