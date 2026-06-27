import '../entities/destination_entity.dart';
import '../repositories/i_map_repository.dart';

class GetDestinationsUseCase {
  final IMapRepository _repository;
  GetDestinationsUseCase(this._repository);

  Future<List<DestinationEntity>> call({String? tipo}) =>
      _repository.getDestinations(tipo: tipo);
}