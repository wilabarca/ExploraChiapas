import '../entities/destination_entity.dart';
import '../entities/route_info.dart';

abstract class IMapRepository {
  Future<List<DestinationEntity>> getDestinations({String? tipo});
  Future<List<DestinationEntity>> getDestinationsNearby({
    required double lat,
    required double lng,
    required double radioKm,
  });
  Future<List<RouteInfo>> getRoutes({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    String perfil = 'driving',
  });
}
