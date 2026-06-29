import 'package:tmjapp/features/home/domain/entities/home_location.dart';
import 'package:tmjapp/features/home/domain/repositories/home_repository.dart';

class BuildTripPreviewUseCase {
  const BuildTripPreviewUseCase(this._repository);

  final HomeRepository _repository;

  Future<List<HomeLocation>> execute({
    required HomeLocation origin,
    required HomeLocation destination,
  }) {
    return _repository.getRoute(origin: origin, destination: destination);
  }
}
