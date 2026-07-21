import 'dart:async';
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
import '../../../negocio/domain/entities/negocio.dart';
import '../../../negocio/domain/usecases/obtener_negocio.dart';
import '../../../negocio/presentation/pages/negocio_datalle_page.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  final TextEditingController _busquedaCtrl = TextEditingController();
  StreamSubscription<MapEvent>? _zoomSub;
  MapProvider? _mapProvider;
  bool _estabaSiguiendo = false;

  List<Negocio> _negocios = [];
  double _currentZoom = 7.5;
  String _busqueda = '';
  bool _mostrandoBusqueda = false;

  static const _chiapasCenter = LatLng(16.7521, -93.1152);

  // Negocios appear at zoom 13 (city-level detail)
  static const _zoomNegocios = 13.0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<MapProvider>().loadDestinations();
      _cargarNegocios();
    });

    // Track zoom to reveal/hide business markers
    _zoomSub = _mapController.mapEventStream.listen((event) {
      if (!mounted) return;
      if (event is MapEventMove || event is MapEventMoveEnd) {
        final zoom = event.camera.zoom;
        if ((zoom - _currentZoom).abs() >= 0.4) {
          setState(() => _currentZoom = zoom);
        }
      }
    });
  }

  Future<void> _cargarNegocios() async {
    final result = await getIt<ObtenerNegocios>().call();
    result.fold(
      (_) {},
      (lista) {
        if (!mounted) return;
        setState(() => _negocios = lista);
      },
    );
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

  void _seguirUsuario() {
    final provider = _mapProvider;
    if (provider == null) return;
    if (!provider.enNavegacion) {
      if (_estabaSiguiendo) {
        _estabaSiguiendo = false;
        _mapController.move(_chiapasCenter, 7.5);
      }
      return;
    }
    _estabaSiguiendo = true;
    final pos = provider.userPosition;
    if (pos == null) return;
    _mapController.move(LatLng(pos.latitude, pos.longitude), 17);
  }

  @override
  void dispose() {
    _mapProvider?.removeListener(_seguirUsuario);
    _zoomSub?.cancel();
    _busquedaCtrl.dispose();
    super.dispose();
  }

  void _moverCamaraA(double lat, double lng) {
    _mapController.move(LatLng(lat, lng), 15);
  }

  void _cerrarBusqueda() {
    setState(() {
      _mostrandoBusqueda = false;
      _busqueda = '';
      _busquedaCtrl.clear();
    });
  }

  // Softer, less saturated versions of the original colors
  Color _colorPorTipo(String tipo) {
    switch (tipo) {
      case 'naturaleza':  return const Color(0xFF43A047);
      case 'cultura':     return const Color(0xFF1976D2);
      case 'gastronomia': return const Color(0xFFEF6C00);
      case 'aventura':    return const Color(0xFF7B1FA2);
      default:            return const Color(0xFF00ACC1);
    }
  }

  IconData _iconoPorTipo(String tipo) {
    switch (tipo) {
      case 'naturaleza':  return Icons.park_outlined;
      case 'cultura':     return Icons.account_balance_outlined;
      case 'gastronomia': return Icons.restaurant_outlined;
      case 'aventura':    return Icons.terrain_outlined;
      case 'descanso':    return Icons.spa_outlined;
      default:            return Icons.place_outlined;
    }
  }

  IconData _iconoNegocio(String tipoId) {
    final t = tipoId.toLowerCase();
    if (t.contains('restaurante') || t.contains('gastronomia')) {
      return Icons.restaurant;
    }
    if (t.contains('hotel') || t.contains('hostal')) return Icons.hotel;
    if (t.contains('cafe')) return Icons.coffee_outlined;
    return Icons.storefront;
  }

  List<DestinationEntity> _filtrarDestinos(List<DestinationEntity> todos) {
    if (_busqueda.isEmpty) return todos;
    final q = _busqueda.toLowerCase();
    return todos.where((d) => d.nombre.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final mostrarNegocios = _currentZoom >= _zoomNegocios && _busqueda.isEmpty;
    final mostrarHintNegocios = _currentZoom >= 10 &&
        _currentZoom < _zoomNegocios &&
        _busqueda.isEmpty &&
        _negocios.isNotEmpty;

    return Scaffold(
      body: Stack(
        children: [
          // ── Mapa ────────────────────────────────────────────────────────────
          Consumer<MapProvider>(
            builder: (_, provider, __) {
              final destinos = _filtrarDestinos(provider.destinations);

              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _chiapasCenter,
                  initialZoom: 7.5,
                  onTap: (_, __) {
                    provider.clearSelection();
                    if (_mostrandoBusqueda) _cerrarBusqueda();
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.explorachiapas.app',
                  ),

                  // Routes — blue so they don't blend with green nature markers
                  if (provider.allRoutes.isNotEmpty)
                    PolylineLayer(
                      polylines: List.generate(
                        provider.allRoutes.length,
                        (i) => Polyline(
                          points: provider.allRoutes[i]
                              .map((p) => LatLng(p[0], p[1]))
                              .toList(),
                          color: i == provider.selectedRouteIndex
                              ? const Color(0xFF0277BD)
                              : const Color(0xFF0277BD).withValues(alpha: 0.35),
                          strokeWidth:
                              i == provider.selectedRouteIndex ? 5 : 3,
                          pattern: i == provider.selectedRouteIndex
                              ? const StrokePattern.solid()
                              : const StrokePattern.dotted(),
                        ),
                      ),
                    ),

                  MarkerLayer(
                    markers: [
                      // Destinos — always visible, icon varies by type
                      ...destinos.map(
                        (d) => Marker(
                          point: LatLng(d.lat, d.lng),
                          width: 36,
                          height: 36,
                          child: GestureDetector(
                            onTap: () => provider.selectDestination(d),
                            child: Icon(
                              _iconoPorTipo(d.tipo),
                              color: _colorPorTipo(d.tipo),
                              size: 34,
                              shadows: const [
                                Shadow(color: Colors.black26, blurRadius: 4),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Negocios — appear only when zoomed in (city level)
                      if (mostrarNegocios)
                        ..._negocios.map(
                          (n) => Marker(
                            point: LatLng(n.latitud, n.longitud),
                            width: 28,
                            height: 28,
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      NegocioDetallePage(negocioId: n.id),
                                ),
                              ),
                              child: Icon(
                                _iconoNegocio(n.tipoNegocioId),
                                color: const Color(0xFFF57C00),
                                size: 26,
                                shadows: const [
                                  Shadow(color: Colors.black26, blurRadius: 3),
                                ],
                              ),
                            ),
                          ),
                        ),

                      // User navigation arrow
                      if (provider.enNavegacion && provider.userPosition != null)
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
                                color: const Color(0xFF1976D2),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF1976D2)
                                        .withValues(alpha: 0.35),
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
              );
            },
          ),

          // ── Loading bar — thin line at top, doesn't block the map ──────────
          Consumer<MapProvider>(
            builder: (_, provider, __) {
              if (provider.status != MapStatus.loading) {
                return const SizedBox.shrink();
              }
              return Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.transparent,
                  color: AppColors.primary(context),
                  minHeight: 3,
                ),
              );
            },
          ),

          // ── Header + filter bar ─────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  padding: _mostrandoBusqueda
                      ? const EdgeInsets.symmetric(horizontal: 4, vertical: 4)
                      : const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surface(context),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _mostrandoBusqueda
                      ? Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_back,
                                  color: AppColors.textPrimary(context)),
                              onPressed: _cerrarBusqueda,
                            ),
                            Expanded(
                              child: TextField(
                                controller: _busquedaCtrl,
                                autofocus: true,
                                decoration: InputDecoration(
                                  hintText: 'Buscar destino...',
                                  hintStyle: TextStyle(
                                      color: AppColors.textHint(context)),
                                  border: InputBorder.none,
                                ),
                                style: TextStyle(
                                    color: AppColors.textPrimary(context),
                                    fontSize: 15),
                                onChanged: (v) =>
                                    setState(() => _busqueda = v),
                              ),
                            ),
                            if (_busqueda.isNotEmpty)
                              IconButton(
                                icon: Icon(Icons.clear,
                                    color: AppColors.textSecondary(context)),
                                onPressed: () => setState(() {
                                  _busqueda = '';
                                  _busquedaCtrl.clear();
                                }),
                              ),
                          ],
                        )
                      : Row(
                          children: [
                            Icon(Icons.explore_outlined,
                                color: AppColors.primary(context)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Explorar Chiapas',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary(context),
                                    ),
                                  ),
                                  Consumer<MapProvider>(
                                    builder: (_, p, __) => Text(
                                      '${p.destinations.length} destinos',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary(context),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.search,
                                  color: AppColors.primary(context)),
                              tooltip: 'Buscar destino',
                              onPressed: () =>
                                  setState(() => _mostrandoBusqueda = true),
                            ),
                          ],
                        ),
                ),
                MapFilterBar(
                  onFilterChanged: (tipo) {
                    context.read<MapProvider>().loadDestinations(tipo: tipo);
                    _cerrarBusqueda();
                  },
                ),
              ],
            ),
          ),

          // ── Hint: "acerca el mapa para ver negocios" ────────────────────────
          if (mostrarHintNegocios)
            Positioned(
              bottom: 250,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface(context).withValues(alpha: 0.93),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.storefront,
                          size: 14, color: Color(0xFFF57C00)),
                      const SizedBox(width: 6),
                      Text(
                        'Acerca el mapa para ver negocios cercanos',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── Route alternative selector ───────────────────────────────────────
          Consumer<MapProvider>(
            builder: (_, provider, __) {
              if (!provider.hayAlternativas) return const SizedBox.shrink();
              return Positioned(
                bottom: 260,
                left: 16,
                right: 16,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surface(context),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children:
                          List.generate(provider.allRoutes.length, (i) {
                        final isActive = provider.selectedRouteIndex == i;
                        return GestureDetector(
                          onTap: () => provider.selectRoute(i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin:
                                const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.primary(context)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              i == 0 ? 'Ruta principal' : 'Alternativa $i',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isActive
                                    ? Colors.white
                                    : AppColors.textPrimary(context),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              );
            },
          ),

          // ── Destination bottom sheet ─────────────────────────────────────────
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
                              ok ? const Color(0xFF388E3C) : Colors.red,
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

          // ── Recenter button ─────────────────────────────────────────────────
          Positioned(
            right: 16,
            bottom: 200,
            child: Consumer<MapProvider>(
              builder: (ctx, provider, __) => FloatingActionButton.small(
                onPressed: () {
                  if (provider.enNavegacion && provider.userPosition != null) {
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
                  // Different icons: follow user vs. see full state
                  provider.enNavegacion
                      ? Icons.my_location
                      : Icons.zoom_out_map,
                  color: AppColors.primary(ctx),
                ),
              ),
            ),
          ),

          // ── Stop navigation button ──────────────────────────────────────────
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
