import 'package:tmjapp/features/home/domain/entities/home_snapshot.dart';
import 'package:tmjapp/features/home/domain/repositories/home_repository.dart';

class LoadHomeDataUseCase {
  const LoadHomeDataUseCase(this._repository);

  final HomeRepository _repository;

  Future<HomeSnapshot> execute() async {
    final profile = await _repository.getProfile();
    final currentLocation = await _repository.getCurrentLocation();
    final activeDrivers = await _repository.getActiveDrivers();
    final activeRide = await _repository.getActiveRide();

    return HomeSnapshot(
      profile: profile,
      currentLocation: currentLocation,
      activeDrivers: activeDrivers,
      activeRide: activeRide,
    );
  }
}
