import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/map_provider.dart';
import '../widgets/destination_bottom_sheet.dart';
import '../widgets/map_filter_bar.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();

  static const _chiapasCenter = LatLng(16.7521, -93.1152);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapProvider>().loadDestinations();
    });
  }

  void _moverCamaraA(double lat, double lng) {
    _mapController.move(LatLng(lat, lng), 13);
  }

  Color _colorPorTipo(String tipo) {
    switch (tipo) {
      case 'naturaleza':
        return const Color(0xFF2E7D32);
      case 'cultura':
        return const Color(0xFF1565C0);
      case 'gastronomia':
        return const Color(0xFFE65100);
      case 'aventura':
        return const Color(0xFF6A1B9A);
      default:
        return const Color(0xFF00838F);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Consumer<MapProvider>(
            builder: (_, provider, __) => FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _chiapasCenter,
                initialZoom: 7.5,
                onTap: (_, __) => provider.clearSelection(),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.explorachiapas.app',
                ),
                if (provider.routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: provider.routePoints
                            .map((p) => LatLng(p[0], p[1]))
                            .toList(),
                        color: const Color(0xFF2E7D32),
                        strokeWidth: 4,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: provider.destinations.map((d) {
                    return Marker(
                      point: LatLng(d.lat, d.lng),
                      width: 36,
                      height: 36,
                      child: GestureDetector(
                        onTap: () => provider.selectDestination(d),
                        child: Icon(
                          Icons.location_on,
                          color: _colorPorTipo(d.tipo),
                          size: 36,
                          shadows: const [
                            Shadow(color: Colors.black26, blurRadius: 4),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.explore_outlined,
                          color: Color(0xFF2E7D32)),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Explorar Chiapas',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B1B1B),
                          ),
                        ),
                      ),
                      Consumer<MapProvider>(
                        builder: (_, p, __) => Text(
                          '${p.destinations.length} lugares',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF777777),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                MapFilterBar(
                  onFilterChanged: (tipo) =>
                      context.read<MapProvider>().loadDestinations(tipo: tipo),
                ),
              ],
            ),
          ),

          Consumer<MapProvider>(
            builder: (_, provider, __) {
              if (provider.status != MapStatus.loading) {
                return const SizedBox.shrink();
              }
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF2E7D32),
                ),
              );
            },
          ),

          Consumer<MapProvider>(
            builder: (_, provider, __) {
              final selected = provider.selected;
              if (selected == null) return const SizedBox.shrink();

              return Align(
                alignment: Alignment.bottomCenter,
                child: DestinationBottomSheet(
                  destino: selected,
                  onCerrar: provider.clearSelection,
                  onGuardar: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('${selected.nombre} guardado en favoritos'),
                        backgroundColor: const Color(0xFF2E7D32),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                  onVerRuta: () async {
                    await provider.loadRouteTo(selected);
                    _moverCamaraA(selected.lat, selected.lng);
                  },
                ),
              );
            },
          ),

          Positioned(
            right: 16,
            bottom: 200,
            child: FloatingActionButton.small(
              onPressed: () => _mapController.move(_chiapasCenter, 7.5),
              backgroundColor: Colors.white,
              elevation: 4,
              child: const Icon(Icons.my_location, color: Color(0xFF2E7D32)),
            ),
          ),
        ],
      ),
    );
  }
}
