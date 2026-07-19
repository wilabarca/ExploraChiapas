import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/map_provider.dart';
import '../widgets/destination_bottom_sheet.dart';
import '../widgets/map_filter_bar.dart';
import '../../../favoritos/presentation/providers/favoritos_provider.dart';
import '../../../favoritos/domain/entities/favorito.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  MapProvider? _mapProvider;

  static const _chiapasCenter = LatLng(16.7521, -93.1152);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapProvider>().loadDestinations();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<MapProvider>();
    if (_mapProvider != provider) {
      _mapProvider?.removeListener(_seguirUsuario);
      _mapProvider = provider;
      _mapProvider!.addListener(_seguirUsuario);
    }
  }

  // Se llama cada vez que el provider notifica — mueve la cámara al usuario
  void _seguirUsuario() {
    final provider = _mapProvider;
    if (provider == null || !provider.enNavegacion) return;
    final pos = provider.userPosition;
    if (pos == null) return;
    _mapController.move(LatLng(pos.latitude, pos.longitude), 17);
  }

  @override
  void dispose() {
    _mapProvider?.removeListener(_seguirUsuario);
    super.dispose();
  }

  void _moverCamaraA(double lat, double lng) {
    _mapController.move(LatLng(lat, lng), 15);
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
                  markers: [
                    // Marcadores de destinos
                    ...provider.destinations.map((d) {
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
                    }),

                    // Flecha de navegación del usuario
                    if (provider.enNavegacion &&
                        provider.userPosition != null)
                      Marker(
                        point: LatLng(
                          provider.userPosition!.latitude,
                          provider.userPosition!.longitude,
                        ),
                        width: 56,
                        height: 56,
                        child: Transform.rotate(
                          angle: provider.userHeading * math.pi / 180,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF1565C0),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF1565C0)
                                      .withValues(alpha: 0.4),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.navigation,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                  ],
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
                    context
                        .read<FavoritosProvider>()
                        .agregarFavorito(
                          targetType: FavoritoTargetType.destination,
                          targetId: selected.id,
                        )
                        .then((ok) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            ok
                                ? '${selected.nombre} guardado en favoritos'
                                : 'No se pudo guardar en favoritos',
                          ),
                          backgroundColor:
                              ok ? const Color(0xFF2E7D32) : Colors.red,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    });
                  },
                  onVerRuta: () async {
                    await provider.loadRouteTo(selected);
                    _moverCamaraA(selected.lat, selected.lng);
                  },
                ),
              );
            },
          ),

          // Botón para recentrar en el usuario (durante navegación) o en Chiapas
          Positioned(
            right: 16,
            bottom: 200,
            child: Consumer<MapProvider>(
              builder: (_, provider, __) => FloatingActionButton.small(
                onPressed: () {
                  if (provider.enNavegacion &&
                      provider.userPosition != null) {
                    _mapController.move(
                      LatLng(
                        provider.userPosition!.latitude,
                        provider.userPosition!.longitude,
                      ),
                      17,
                    );
                  } else {
                    _mapController.move(_chiapasCenter, 7.5);
                  }
                },
                backgroundColor: Colors.white,
                elevation: 4,
                child: Icon(
                  provider.enNavegacion
                      ? Icons.my_location
                      : Icons.my_location,
                  color: const Color(0xFF2E7D32),
                ),
              ),
            ),
          ),

          // Botón para detener navegación
          Consumer<MapProvider>(
            builder: (_, provider, __) {
              if (!provider.enNavegacion) return const SizedBox.shrink();
              return Positioned(
                left: 16,
                bottom: 200,
                child: FloatingActionButton.small(
                  onPressed: provider.clearSelection,
                  backgroundColor: Colors.red,
                  elevation: 4,
                  child: const Icon(Icons.close, color: Colors.white),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
