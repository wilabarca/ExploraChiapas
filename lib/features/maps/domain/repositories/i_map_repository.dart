import '../entities/destination_entity.dart';

abstract class IMapRepository {
  Future<List<DestinationEntity>> getDestinations({String? tipo});
  Future<List<DestinationEntity>> getDestinationsNearby({
    required double lat,
    required double lng,
    required double radioKm,
  });
  Future<List<List<List<double>>>> getRoutes({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  });
}