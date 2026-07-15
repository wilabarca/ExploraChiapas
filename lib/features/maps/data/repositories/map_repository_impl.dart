import '../../domain/entities/destination_entity.dart';
import '../../domain/repositories/i_map_repository.dart';
import '../datasources/map_remote_datasource.dart';

class MapRepositoryImpl implements IMapRepository {
  final IMapRemoteDatasource _datasource;
  MapRepositoryImpl(this._datasource);

  @override
  Future<List<DestinationEntity>> getDestinations({String? tipo}) =>
      _datasource.getDestinations(tipo: tipo);

  @override
  Future<List<DestinationEntity>> getDestinationsNearby({
    required double lat,
    required double lng,
    required double radioKm,
  }) =>
      _datasource.getDestinationsNearby(lat: lat, lng: lng, radioKm: radioKm);

  @override
  Future<List<List<double>>> getRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) =>
      _datasource.getRoute(
        originLat: originLat,
        originLng: originLng,
        destLat: destLat,
        destLng: destLng,
      );
}