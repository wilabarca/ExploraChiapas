import '../entities/destination_entity.dart';
import '../repositories/i_map_repository.dart';

class GetDestinationsNearbyUseCase {
  final IMapRepository _repository;
  GetDestinationsNearbyUseCase(this._repository);

  Future<List<DestinationEntity>> call({
    required double lat,
    required double lng,
    required double radioKm,
  }) => _repository.getDestinationsNearby(lat: lat, lng: lng, radioKm: radioKm);
}
