import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  GoogleMapController? _mapController;

  // Centro de Chiapas
  static const _chiapasCenter = CameraPosition(
    target: LatLng(16.7521, -93.1152),
    zoom: 7.5,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapProvider>().loadDestinations();
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _moverCamaraA(double lat, double lng) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(lat, lng), 13),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Mapa ──────────────────────────────────────────
          Consumer<MapProvider>(
            builder: (_, provider, __) => GoogleMap(
              initialCameraPosition: _chiapasCenter,
              markers: provider.markers,
              polylines: provider.polylines,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              onMapCreated: (c) => _mapController = c,
              onTap: (_) => provider.clearSelection(),
            ),
          ),

          // ── Barra superior con filtros ─────────────────────
          SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
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

                // Filtros
                MapFilterBar(
                  onFilterChanged: (tipo) =>
                      context.read<MapProvider>().loadDestinations(tipo: tipo),
                ),
              ],
            ),
          ),

          // ── Loading indicator ──────────────────────────────
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

          // ── Bottom sheet del destino seleccionado ──────────
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

          // ── Botón de ubicación actual ──────────────────────
          Positioned(
            right: 16,
            bottom: 200,
            child: FloatingActionButton.small(
              onPressed: () {
                _mapController?.animateCamera(
                  CameraUpdate.newCameraPosition(_chiapasCenter),
                );
              },
              backgroundColor: Colors.white,
              elevation: 4,
              child: const Icon(Icons.my_location,
                  color: Color(0xFF2E7D32)),
            ),
          ),
        ],
      ),
    );
  }
}