
import '../repositories/i_map_repository.dart';

class GetRouteUseCase {
  final IMapRepository _repository;
  GetRouteUseCase(this._repository);

  Future<List<List<List<double>>>> call({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) =>
      _repository.getRoutes(
        originLat: originLat,
        originLng: originLng,
        destLat: destLat,
        destLng: destLng,
      );
}