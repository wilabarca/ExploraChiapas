enum TipoViaPoi { casetaCobro, gasolinera }

class ViaPoiEntity {
  final int id;
  final double lat;
  final double lng;
  final String nombre;
  final TipoViaPoi tipo;

  const ViaPoiEntity({
    required this.id,
    required this.lat,
    required this.lng,
    required this.nombre,
    required this.tipo,
  });
}
