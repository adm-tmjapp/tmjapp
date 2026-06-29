import 'package:tmjapp/features/home/data/datasources/home_local_datasource.dart';
import 'package:tmjapp/features/home/data/datasources/home_remote_datasource.dart';
import 'package:tmjapp/features/home/domain/entities/home_active_ride.dart';
import 'package:tmjapp/features/home/domain/entities/home_driver.dart';
import 'package:tmjapp/features/home/domain/entities/home_location.dart';
import 'package:tmjapp/features/home/domain/entities/home_profile.dart';
import 'package:tmjapp/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl({
    required HomeLocalDataSource localDataSource,
    required HomeRemoteDataSource remoteDataSource,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource;

  final HomeLocalDataSource _localDataSource;
  final HomeRemoteDataSource _remoteDataSource;

  @override
  Future<HomeProfile> getProfile() {
    return _localDataSource.getProfile();
  }

  @override
  Future<HomeLocation> getCurrentLocation() {
    return _remoteDataSource.getCurrentLocation();
  }

  @override
  Future<List<HomeDriver>> getActiveDrivers() {
    return _remoteDataSource.getActiveDrivers();
  }

  @override
  Future<HomeActiveRide?> getActiveRide() {
    return _remoteDataSource.getActiveRide();
  }

  @override
  Future<List<HomeLocation>> getRoute({
    required HomeLocation origin,
    required HomeLocation destination,
  }) {
    return _remoteDataSource.getRoute(
      origin: origin,
      destination: destination,
    );
  }
}
