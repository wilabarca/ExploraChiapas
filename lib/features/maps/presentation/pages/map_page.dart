import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/destination_entity.dart';
import '../../domain/entities/via_poi_entity.dart';
import '../../data/datasources/overpass_vias_datasource.dart';
import '../providers/map_provider.dart';
import '../widgets/destination_bottom_sheet.dart';
import '../widgets/map_filter_bar.dart';
import '../../../favoritos/presentation/providers/favoritos_provider.dart';
import '../../../favoritos/domain/entities/favorito.dart';
import '../../../negocio/domain/entities/negocio.dart';
import '../../../negocio/domain/usecases/obtener_negocio.dart';
import '../../../negocio/presentation/pages/negocio_datalle_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/theme/app_colors.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver, RouteAware {
  final MapController _mapController = MapController();
  final TextEditingController _busquedaCtrl = TextEditingController();
  StreamSubscription<MapEvent>? _zoomSub;
  MapProvider? _mapProvider;
  bool _estabaSiguiendo = false;

  List<Negocio> _negocios = [];
  bool _cargandoNegocios = false;
  double _currentZoom = 7.5;
  String _busqueda = '';
  bool _mostrandoBusqueda = false;

  Position? _liveUserPosition;
  StreamSubscription<Position>? _liveLocationSub;
  bool _yaSeCentroEnUsuario = false;
  AnimationController? _camAnimCtrl;

  bool _mostrarLeyenda = false;

  static const _chiapasCenter = LatLng(16.7521, -93.1152);

  // Casetas de cobro y gasolineras: aparecen desde un poco antes que los
  // negocios (son Ãºtiles al planear ruta, no solo dentro de la ciudad).
  static const _zoomVias = 11.0;

  final OverpassViasDatasource _viasDatasource = OverpassViasDatasource();
  List<ViaPoiEntity> _viasPois = [];
  bool _mostrarVias = true;
  bool _cargandoVias = false;
  Timer? _debounceVias;
  LatLngBounds? _boundsConsultados;

  // Evita refrescos duplicados si `resumed` y `didPopNext` se disparan
  // casi al mismo tiempo (p. ej. al volver de una pantalla justo cuando
  // la app tambiÃ©n pasa a primer plano).
  bool _refrescando = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<MapProvider>().loadDestinations();
      _cargarNegocios();
      _iniciarUbicacionEnVivo();
      _cargarVias(_mapController.camera.visibleBounds);
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
      if (event is MapEventMoveEnd) {
        _programarCargaVias(event.camera.visibleBounds);
      }
    });
  }

  // Overpass es un servicio pÃºblico compartido: se consulta con debounce y
  // solo cuando el usuario deja de mover el mapa (moveEnd), y se evita
  // repetir la consulta si el recuadro visible sigue dentro del Ãºltimo ya
  // cargado â€” asÃ­ la capa "se actualiza" al explorar sin bombardear la API.
  void _programarCargaVias(LatLngBounds bounds) {
    _debounceVias?.cancel();
    _debounceVias = Timer(const Duration(milliseconds: 600), () {
      _cargarVias(bounds);
    });
  }

  Future<void> _cargarVias(LatLngBounds bounds) async {
    if (!mounted || !_mostrarVias) return;
    if (_currentZoom < _zoomVias) return;
    if (_boundsConsultados != null &&
        _boundsConsultados!.containsBounds(bounds)) {
      return;
    }
    if (_cargandoVias) return;

    setState(() => _cargandoVias = true);
    // Se consulta un recuadro ligeramente mÃ¡s grande que el visible para
    // que al hacer pan pequeÃ±o no dispare otra consulta de inmediato.
    final padLat = (bounds.north - bounds.south) * 0.5;
    final padLng = (bounds.east - bounds.west) * 0.5;
    final consultado = LatLngBounds(
      LatLng(bounds.south - padLat, bounds.west - padLng),
      LatLng(bounds.north + padLat, bounds.east + padLng),
    );

    final pois = await _viasDatasource.obtenerPois(
      south: consultado.south,
      west: consultado.west,
      north: consultado.north,
      east: consultado.east,
    );

    if (!mounted) return;
    setState(() {
      _viasPois = pois;
      _boundsConsultados = consultado;
      _cargandoVias = false;
    });
  }

  // Punto de ubicaciÃ³n en tiempo real en la vista general (fuera de navegaciÃ³n).
  Future<void> _iniciarUbicacionEnVivo() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      if (!await Geolocator.isLocationServiceEnabled()) return;

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (!mounted) return;
      setState(() => _liveUserPosition = pos);
      _animarCamaraAlUsuario(pos);

      _liveLocationSub =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 5,
            ),
          ).listen((pos) {
            if (!mounted) return;
            setState(() => _liveUserPosition = pos);
          });
    } catch (_) {
      // Sin permiso o GPS no disponible: simplemente no se muestra el punto.
    }
  }

  Future<void> _cargarNegocios() async {
    setState(() => _cargandoNegocios = true);
    final result = await getIt<ObtenerNegocios>().call();
    if (!mounted) return;
    result.fold(
      (_) => setState(() => _cargandoNegocios = false),
      (lista) => setState(() {
        _negocios = lista;
        _cargandoNegocios = false;
      }),
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

    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      AppNavigator.routeObserver.subscribe(this, route);
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

  // La app vuelve a primer plano (p. ej. el usuario dejÃ³ la app abierta,
  // fue a otro lado y regresÃ³): refresca por si algo cambiÃ³ mientras tanto
  // (un negocio nuevo, un destino reciÃ©n aprobado).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refrescarDatos();
    }
  }

  // Se dispara al volver a este mapa tras cerrar (pop) una pantalla
  // apilada encima (detalle de negocio, ruta local, etc.) â€” mismo patrÃ³n
  // ya usado en Home para promociones/eventos.
  @override
  void didPopNext() {
    _refrescarDatos();
  }

  Future<void> _refrescarDatos() async {
    if (!mounted || _refrescando) return;
    // Si el usuario tiene una ficha/ruta abierta, un refresco de fondo no
    // debe interrumpirla ni resetear su selecciÃ³n.
    if (_mapProvider?.selected != null) return;

    _refrescando = true;
    try {
      await Future.wait([
        context.read<MapProvider>().loadDestinations(),
        _cargarNegocios(),
      ]);
    } finally {
      _refrescando = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AppNavigator.routeObserver.unsubscribe(this);
    _mapProvider?.removeListener(_seguirUsuario);
    _zoomSub?.cancel();
    _liveLocationSub?.cancel();
    _debounceVias?.cancel();
    _camAnimCtrl?.dispose();
    _busquedaCtrl.dispose();
    super.dispose();
  }

  void _moverCamaraA(double lat, double lng) {
    _mapController.move(LatLng(lat, lng), 16);
  }

  // Un solo vuelo animado hacia la ubicaciÃ³n real del usuario en cuanto se
  // obtiene el primer fix de GPS â€” solo una vez por apertura de pantalla
  // (no en cada actualizaciÃ³n del stream, o la cÃ¡mara "pelearÃ­a" con el
  // usuario si estÃ¡ paneando el mapa manualmente).
  void _animarCamaraAlUsuario(Position pos) {
    if (_yaSeCentroEnUsuario || !mounted) return;
    _yaSeCentroEnUsuario = true;

    _camAnimCtrl?.dispose();
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _camAnimCtrl = controller;

    final origen = _mapController.camera.center;
    final origenZoom = _mapController.camera.zoom;
    final destino = LatLng(pos.latitude, pos.longitude);
    const destinoZoom = 13.0;
    final curva = CurvedAnimation(parent: controller, curve: Curves.easeInOut);

    curva.addListener(() {
      if (!mounted) return;
      final t = curva.value;
      _mapController.move(
        LatLng(
          origen.latitude + (destino.latitude - origen.latitude) * t,
          origen.longitude + (destino.longitude - origen.longitude) * t,
        ),
        origenZoom + (destinoZoom - origenZoom) * t,
      );
    });

    controller.forward();
  }

  // Encontrar un resultado (destino real o negocio real) y no verlo porque
  // sigue fuera de la vista actual del mapa (p. ej. buscando algo lejano
  // mientras el mapa estÃ¡ centrado en todo Chiapas) se siente igual que
  // "no aparece nada". Al buscar, la cÃ¡mara se mueve al primer resultado.
  void _centrarEnPrimerResultado(String query) {
    if (query.trim().isEmpty) return;
    final q = query.toLowerCase();

    for (final d in context.read<MapProvider>().destinations) {
      if (d.nombre.toLowerCase().contains(q)) {
        _moverCamaraA(d.lat, d.lng);
        return;
      }
    }

    for (final n in _negocios) {
      if (n.nombre.toLowerCase().contains(q) &&
          n.latitud != 0.0 &&
          n.longitud != 0.0) {
        _moverCamaraA(n.latitud, n.longitud);
        return;
      }
    }
  }

  void _cerrarBusqueda() {
    setState(() {
      _mostrandoBusqueda = false;
      _busqueda = '';
      _busquedaCtrl.clear();
    });
  }

  // Softer, less saturated versions of the original colors. Las claves
  // deben coincidir con el slug generado en `_slugCategoria` del
  // datasource (nombre real de categorÃ­a, en minÃºsculas y sin acentos) â€”
  // cubre las 6 categorÃ­as reales de `/categories?scope=destinos`.
  Color _colorPorTipo(String tipo) {
    switch (tipo) {
      case 'naturaleza':
        return const Color(0xFF43A047);
      case 'cultura':
        return const Color(0xFF1976D2);
      case 'gastronomia':
        return const Color(0xFFEF6C00);
      case 'aventura':
        return const Color(0xFF7B1FA2);
      case 'descanso':
        return const Color(0xFF00838F);
      case 'pueblos magicos':
        return const Color(0xFFAD1457);
      case 'arqueologia':
        return const Color(0xFF6D4C41);
      default:
        return const Color(0xFF00ACC1);
    }
  }

  IconData _iconoPorTipo(String tipo) {
    switch (tipo) {
      case 'naturaleza':
        return Icons.park_outlined;
      case 'cultura':
        return Icons.account_balance_outlined;
      case 'gastronomia':
        return Icons.restaurant_outlined;
      case 'aventura':
        return Icons.terrain_outlined;
      case 'descanso':
        return Icons.spa_outlined;
      case 'pueblos magicos':
        return Icons.location_city_outlined;
      case 'arqueologia':
        return Icons.temple_hindu_outlined;
      default:
        return Icons.place_outlined;
    }
  }

  IconData _iconoVia(TipoViaPoi tipo) {
    switch (tipo) {
      case TipoViaPoi.casetaCobro:
        return Icons.toll;
      case TipoViaPoi.gasolinera:
        return Icons.local_gas_station;
    }
  }

  Color _colorVia(TipoViaPoi tipo) {
    switch (tipo) {
      case TipoViaPoi.casetaCobro:
        return const Color(0xFF6D4C41);
      case TipoViaPoi.gasolinera:
        return const Color(0xFF546E7A);
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

  List<Negocio> _filtrarNegocios(List<Negocio> todos) {
    if (_busqueda.isEmpty) return todos;
    final q = _busqueda.toLowerCase();
    return todos.where((n) => n.nombre.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Los negocios ahora se muestran desde que se abre el mapa, sin
    // esperar a que el usuario haga zoom manual ni busque algo â€” antes
    // exigÃ­an zoom >= 13 (o una bÃºsqueda activa), lo que se sentÃ­a como
    // "el mapa estÃ¡ vacÃ­o". Van agrupados en su propio cluster (como los
    // destinos) para que no se amontonen visualmente al estar lejos.
    final _negociosConCoordenadas = _filtrarNegocios(
      _negocios,
    ).where((n) => n.latitud != 0.0 && n.longitud != 0.0).toList();

    // Intereses guardados por el usuario en el onboarding (mismos UUID de
    // categorÃ­a que `Destino.categoryId`/`DestinationEntity.categoryId`) â€”
    // se usan para resaltar, no para ocultar, los destinos recomendados.
    final interesesUsuario = context
        .watch<AuthProvider>()
        .userInterests
        ?.interests
        .map((i) => i.id)
        .toSet();

    return Scaffold(
      body: Stack(
        children: [
          // â”€â”€ Mapa â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Consumer<MapProvider>(
            builder: (_, provider, __) {
              final destinos = _filtrarDestinos(provider.destinations);

              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _chiapasCenter,
                  initialZoom: 7.5,
                  minZoom: 6,
                  // A partir de zoom ~17 el tile de OSM empieza a mostrar
                  // senderos/detalle crudo sin curar (ver captura: caminos
                  // de excursionismo, etiquetas en otros idiomas). Limitarlo
                  // mantiene una vista mÃ¡s "app turÃ­stica", no de mapa crudo.
                  maxZoom: 17,
                  onTap: (_, __) {
                    provider.clearSelection();
                    if (_mostrandoBusqueda) _cerrarBusqueda();
                  },
                ),
                children: [
                  // En modo oscuro se usa el basemap oscuro de CARTO en vez
                  // del tile claro estÃ¡ndar de OSM â€” de otra forma el mapa
                  // queda deslumbrante/blanco en medio de una UI oscura.
                  TileLayer(
                    urlTemplate: AppColors.isDark(context)
                        ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png'
                        : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: AppColors.isDark(context)
                        ? const ['a', 'b', 'c', 'd']
                        : const [],
                    userAgentPackageName: 'com.explorachiapas.app',
                    maxZoom: 17,
                  ),

                  // Routes â€” blue so they don't blend with green nature markers
                  if (provider.allRoutes.isNotEmpty)
                    PolylineLayer(
                      polylines: List.generate(
                        provider.allRoutes.length,
                        (i) => Polyline(
                          points: provider.allRoutes[i].points
                              .map((p) => LatLng(p[0], p[1]))
                              .toList(),
                          color: i == provider.selectedRouteIndex
                              ? const Color(0xFF0277BD)
                              : const Color(0xFF0277BD).withValues(alpha: 0.35),
                          strokeWidth: i == provider.selectedRouteIndex ? 5 : 3,
                          pattern: i == provider.selectedRouteIndex
                              ? const StrokePattern.solid()
                              : const StrokePattern.dotted(),
                        ),
                      ),
                    ),

                  // Destinos agrupados: evita que se encimen cuando estÃ¡n
                  // muy cerca entre sÃ­ (p. ej. dos lugares en la misma ciudad).
                  MarkerClusterLayerWidget(
                    options: MarkerClusterLayerOptions(
                      maxClusterRadius: 45,
                      size: const Size(40, 40),
                      markers: destinos.map((d) {
                        final recomendado =
                            interesesUsuario != null &&
                            d.categoryId != null &&
                            interesesUsuario.contains(d.categoryId);
                        return Marker(
                          point: LatLng(d.lat, d.lng),
                          width: recomendado ? 44 : 36,
                          height: recomendado ? 44 : 36,
                          child: GestureDetector(
                            onTap: () {
                              provider.selectDestination(d);
                              _moverCamaraA(d.lat, d.lng);
                            },
                            child: _MarkerPop(
                              child: recomendado
                                  ? _MarcadorRecomendado(
                                      icono: _iconoPorTipo(d.tipo),
                                      color: _colorPorTipo(d.tipo),
                                    )
                                  : Icon(
                                      _iconoPorTipo(d.tipo),
                                      color: _colorPorTipo(d.tipo),
                                      size: 34,
                                      shadows: const [
                                        Shadow(
                                          color: Colors.black26,
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        );
                      }).toList(),
                      builder: (context, markers) => Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary(context),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [
                            BoxShadow(color: Colors.black38, blurRadius: 4),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${markers.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      // zoomToBoundsOnClick (activado por defecto) ya centra
                      // y hace zoom automÃ¡ticamente al tocar un cluster.
                    ),
                  ),

                  // Negocios agrupados â€” visibles desde que se abre el mapa,
                  // en su propio cluster para no encimarse con destinos.
                  if (_negociosConCoordenadas.isNotEmpty)
                    MarkerClusterLayerWidget(
                      options: MarkerClusterLayerOptions(
                        maxClusterRadius: 45,
                        size: const Size(40, 40),
                        markers: _negociosConCoordenadas
                            .map(
                              (n) => Marker(
                                point: LatLng(n.latitud, n.longitud),
                                width: 30,
                                height: 30,
                                child: GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          NegocioDetallePage(negocioId: n.id),
                                    ),
                                  ),
                                  child: _MarkerPop(
                                    child: Icon(
                                      _iconoNegocio(n.tipoNegocioId),
                                      color: const Color(0xFFF57C00),
                                      size: 26,
                                      shadows: const [
                                        Shadow(
                                          color: Colors.black26,
                                          blurRadius: 3,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        builder: (context, markers) => Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFF57C00),
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: const [
                              BoxShadow(color: Colors.black38, blurRadius: 4),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${markers.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),

                  MarkerLayer(
                    markers: [
                      // Casetas de cobro / gasolineras â€” datos reales de
                      // Overpass (OSM), visibles desde zoom de carretera.
                      if (_mostrarVias && _currentZoom >= _zoomVias)
                        ..._viasPois.map(
                          (v) => Marker(
                            point: LatLng(v.lat, v.lng),
                            width: 26,
                            height: 26,
                            child: Tooltip(
                              message: v.nombre,
                              child: Icon(
                                _iconoVia(v.tipo),
                                color: _colorVia(v.tipo),
                                size: 22,
                                shadows: const [
                                  Shadow(color: Colors.black26, blurRadius: 3),
                                ],
                              ),
                            ),
                          ),
                        ),

                      // User navigation arrow
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
                                color: const Color(0xFF1976D2),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF1976D2,
                                    ).withValues(alpha: 0.35),
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

                      // Punto de ubicaciÃ³n en tiempo real (fuera de navegaciÃ³n)
                      if (!provider.enNavegacion && _liveUserPosition != null)
                        Marker(
                          point: LatLng(
                            _liveUserPosition!.latitude,
                            _liveUserPosition!.longitude,
                          ),
                          width: 24,
                          height: 24,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF2196F3),
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: const [
                                BoxShadow(color: Colors.black38, blurRadius: 6),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),

                  RichAttributionWidget(
                    alignment: AttributionAlignment.bottomLeft,
                    popupInitialDisplayDuration: const Duration(seconds: 3),
                    attributions: [
                      const TextSourceAttribution(
                        'Â© OpenStreetMap contributors',
                      ),
                      if (AppColors.isDark(context))
                        const TextSourceAttribution('Â© CARTO'),
                    ],
                  ),
                ],
              );
            },
          ),

          // â”€â”€ Loading bar â€” thin line at top, doesn't block the map â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          // Cubre tanto la carga de destinos (MapProvider) como la de
          // negocios (estado local): al abrir el mapa ambas arrancan en
          // paralelo, y el usuario debe ver que algo estÃ¡ cargando en
          // cualquiera de los dos casos, no solo en uno.
          Consumer<MapProvider>(
            builder: (_, provider, __) {
              if (provider.status != MapStatus.loading && !_cargandoNegocios) {
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

          // â”€â”€ Estado vacÃ­o: bÃºsqueda sin resultados â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          if (_busqueda.isNotEmpty && !_cargandoNegocios)
            Consumer<MapProvider>(
              builder: (_, provider, __) {
                if (provider.status == MapStatus.loading) {
                  return const SizedBox.shrink();
                }
                final sinResultados =
                    _filtrarDestinos(provider.destinations).isEmpty &&
                    _negociosConCoordenadas.isEmpty;
                if (!sinResultados) return const SizedBox.shrink();
                return Positioned(
                  top: 130,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface(
                          context,
                        ).withValues(alpha: 0.95),
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
                          Icon(
                            Icons.search_off,
                            size: 16,
                            color: AppColors.textSecondary(context),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Sin resultados para "$_busqueda"',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

          // â”€â”€ Header + filter bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          SafeArea(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  padding: _mostrandoBusqueda
                      ? const EdgeInsets.symmetric(horizontal: 4, vertical: 4)
                      : const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
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
                              icon: Icon(
                                Icons.arrow_back,
                                color: AppColors.textPrimary(context),
                              ),
                              onPressed: _cerrarBusqueda,
                            ),
                            Expanded(
                              child: TextField(
                                controller: _busquedaCtrl,
                                autofocus: true,
                                decoration: InputDecoration(
                                  hintText: 'Buscar destino...',
                                  hintStyle: TextStyle(
                                    color: AppColors.textHint(context),
                                  ),
                                  // Evita heredar el "filled: true" del tema
                                  // global (rectÃ¡ngulo cuadrado de fondo).
                                  filled: false,
                                  border: InputBorder.none,
                                ),
                                style: TextStyle(
                                  color: AppColors.textPrimary(context),
                                  fontSize: 15,
                                ),
                                onChanged: (v) {
                                  setState(() => _busqueda = v);
                                  _centrarEnPrimerResultado(v);
                                },
                              ),
                            ),
                            if (_busqueda.isNotEmpty)
                              IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: AppColors.textSecondary(context),
                                ),
                                onPressed: () => setState(() {
                                  _busqueda = '';
                                  _busquedaCtrl.clear();
                                }),
                              ),
                          ],
                        )
                      : Row(
                          children: [
                            Icon(
                              Icons.explore_outlined,
                              color: AppColors.primary(context),
                            ),
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
                              icon: Icon(
                                Icons.info_outline,
                                color: _mostrarLeyenda
                                    ? AppColors.primary(context)
                                    : AppColors.textSecondary(context),
                              ),
                              tooltip: 'Leyenda del mapa',
                              onPressed: () => setState(
                                () => _mostrarLeyenda = !_mostrarLeyenda,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.search,
                                color: AppColors.primary(context),
                              ),
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
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _mostrarLeyenda
                      ? Padding(
                          key: const ValueKey('leyenda'),
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: const _LeyendaMapa(),
                        )
                      : const SizedBox.shrink(key: ValueKey('sin-leyenda')),
                ),
              ],
            ),
          ),

          // â”€â”€ Destination bottom sheet (+ selector de rutas, si hay) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          // Antes el selector de rutas vivÃ­a en un Positioned con offset fijo
          // (bottom: 260) independiente de la ficha, y como la ficha tiene
          // alto variable (segÃºn descripciÃ³n/insignias), a veces terminaban
          // encimados. Ahora van juntos en la misma columna: el selector se
          // apila arriba de la ficha de forma natural, sin coordenadas fijas.
          Consumer<MapProvider>(
            builder: (_, provider, __) {
              final selected = provider.selected;
              if (selected == null) return const SizedBox.shrink();

              return Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (provider.hayAlternativas)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
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
                            children: List.generate(provider.allRoutes.length, (
                              i,
                            ) {
                              final isActive = provider.selectedRouteIndex == i;
                              return GestureDetector(
                                onTap: () => provider.selectRoute(i),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? AppColors.primary(context)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    i == 0
                                        ? 'Ruta principal'
                                        : 'Alternativa $i',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isActive
                                          ? AppColors.onPrimary(context)
                                          : AppColors.textPrimary(context),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    DestinationBottomSheet(
                      destino: selected,
                      routeInfo: provider.enNavegacion
                          ? (provider.routeInfoRestante ??
                                provider.selectedRouteInfo)
                          : provider.selectedRouteInfo,
                      routePie: provider.routePie,
                      routeBici: provider.routeBici,
                      esRecomendado:
                          interesesUsuario != null &&
                          selected.categoryId != null &&
                          interesesUsuario.contains(selected.categoryId),
                      onCerrar: provider.clearSelection,
                      onGuardar: () {
                        if (selected.esMock) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Este destino es de muestra y aÃºn no estÃ¡ '
                                'disponible en el servidor, no se puede guardar.',
                              ),
                              backgroundColor: Colors.orange,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                              ),
                            ),
                          );
                          return;
                        }
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
                                  backgroundColor: ok
                                      ? AppColors.primary(context)
                                      : AppColors.error(context),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            });
                      },
                      onVerRuta: () async {
                        final ok = await provider.loadRouteTo(selected);
                        if (!mounted) return;
                        if (ok) {
                          _moverCamaraA(selected.lat, selected.lng);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                provider.routeError ??
                                    'No se pudo calcular la ruta. Intenta de nuevo.',
                              ),
                              backgroundColor: AppColors.error(context),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }
                      },
                      onRecalcular: provider.allRoutes.isEmpty
                          ? null
                          : () async {
                              final ok = await provider.recalcularRuta();
                              if (!mounted || ok) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    provider.routeError ??
                                        'No se pudo recalcular la ruta.',
                                  ),
                                  backgroundColor: AppColors.error(context),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            },
                    ),
                  ],
                ),
              );
            },
          ),

          // â”€â”€ Toggle casetas/gasolineras â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Consumer<MapProvider>(
            builder: (ctx, provider, __) {
              if (provider.selected != null) return const SizedBox.shrink();
              return Positioned(
                right: 16,
                bottom: 256,
                child: FloatingActionButton.small(
                  heroTag: 'toggle_vias',
                  onPressed: () {
                    setState(() => _mostrarVias = !_mostrarVias);
                    if (_mostrarVias) {
                      _cargarVias(_mapController.camera.visibleBounds);
                    }
                  },
                  backgroundColor: _mostrarVias
                      ? AppColors.primary(ctx)
                      : AppColors.surface(context),
                  elevation: 4,
                  tooltip: 'Casetas y gasolineras',
                  child: Icon(
                    Icons.toll,
                    color: _mostrarVias
                        ? AppColors.onPrimary(ctx)
                        : AppColors.primary(ctx),
                  ),
                ),
              );
            },
          ),

          // â”€â”€ Recenter button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          // Oculto mientras la ficha del destino estÃ¡ abierta: su alto
          // varÃ­a (badges, descripciÃ³n larga, etc.) y este botÃ³n de
          // posiciÃ³n fija terminaba encimado sobre el tÃ­tulo.
          Consumer<MapProvider>(
            builder: (ctx, provider, __) {
              if (provider.selected != null) return const SizedBox.shrink();
              return Positioned(
                right: 16,
                bottom: 200,
                child: FloatingActionButton.small(
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
                  backgroundColor: AppColors.surface(context),
                  elevation: 4,
                  child: Icon(
                    // Different icons: follow user vs. see full state
                    provider.enNavegacion
                        ? Icons.my_location
                        : Icons.zoom_out_map,
                    color: AppColors.primary(ctx),
                  ),
                ),
              );
            },
          ),

          // â”€â”€ Stop navigation button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          // Se oculta si la ficha del destino ya estÃ¡ abierta: su propia "X"
          // hace lo mismo (provider.clearSelection) y, al tener alto
          // variable, chocaba con este botÃ³n de posiciÃ³n fija.
          Consumer<MapProvider>(
            builder: (_, provider, __) {
              if (!provider.enNavegacion || provider.selected != null) {
                return const SizedBox.shrink();
              }
              return Positioned(
                left: 16,
                bottom: 200,
                child: FloatingActionButton.small(
                  onPressed: provider.clearSelection,
                  backgroundColor: AppColors.error(context),
                  elevation: 4,
                  child: Icon(Icons.close, color: AppColors.onError(context)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Marcador de destino que coincide con los intereses guardados del
/// usuario: mismo Ã­cono/color por categorÃ­a, pero con un anillo y una
/// insignia de estrella para distinguirlo sin ocultar el resto del mapa.
/// Entrada suave (fade + escala) para cada marcador al aparecer en el
/// mapa â€” un solo `TweenAnimationBuilder` sin `AnimationController` propio,
/// igual de ligero que `FadeSlideIn` pero pensado para Ã­conos pequeÃ±os.
class _MarkerPop extends StatelessWidget {
  final Widget child;
  const _MarkerPop({required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.scale(scale: value, child: child),
        );
      },
      child: child,
    );
  }
}

class _MarcadorRecomendado extends StatelessWidget {
  final IconData icono;
  final Color color;
  const _MarcadorRecomendado({required this.icono, required this.color});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: color, width: 2),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
          ),
          alignment: Alignment.center,
          child: Icon(icono, color: color, size: 22),
        ),
        Positioned(
          top: -4,
          right: -4,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary(context),
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: const Icon(Icons.star, size: 10, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

/// Leyenda compacta de los marcadores y colores del mapa â€” se muestra u
/// oculta con el botÃ³n de info del encabezado.
class _LeyendaMapa extends StatelessWidget {
  const _LeyendaMapa();

  static const _items = [
    (Color(0xFF43A047), Icons.eco_outlined, 'Naturaleza / poco concurrido'),
    (Color(0xFFF57C00), Icons.storefront, 'Negocio local'),
    (Color(0xFF6D4C41), Icons.toll, 'Caseta de cobro'),
    (Color(0xFF546E7A), Icons.local_gas_station, 'Gasolinera'),
    (Color(0xFF0277BD), Icons.route, 'Ruta calculada'),
    (Color(0xFF1B5E20), Icons.star, 'Recomendado para ti'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8),
        ],
      ),
      child: Wrap(
        spacing: 14,
        runSpacing: 8,
        children: [
          for (final item in _items)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.$2, size: 14, color: item.$1),
                const SizedBox(width: 5),
                Text(
                  item.$3,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
