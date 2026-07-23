import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../domain/entities/destino.dart';
import '../../domain/entities/ubicacion_destino.dart';
import '../../domain/usecases/get_ubicacion_destino_usecase.dart';
import '../providers/destinos_provider.dart';
import 'lugar_detail_page.dart';

/// Una alternativa ya resuelta con su ubicación real (o sin ella, si el
/// backend no la tiene todavía — en ese caso no se muestra en el mapa
/// pero sí en la lista, sin distancia).
class _Alternativa {
  final Destino destino;
  final UbicacionDestino? ubicacion;
  final double? distanciaKm;

  const _Alternativa({required this.destino, this.ubicacion, this.distanciaKm});
}

class AlternativasMenosConcurridasPage extends StatefulWidget {
  final String destinoId;
  final String destinoNombre;
  final String categoryId;
  final String? destinoLocationId;

  const AlternativasMenosConcurridasPage({
    super.key,
    required this.destinoId,
    required this.destinoNombre,
    required this.categoryId,
    this.destinoLocationId,
  });

  @override
  State<AlternativasMenosConcurridasPage> createState() =>
      _AlternativasMenosConcurridasPageState();
}

class _AlternativasMenosConcurridasPageState
    extends State<AlternativasMenosConcurridasPage> {
  final _mapCtrl = MapController();
  final _getUbicacion = getIt<GetUbicacionDestinoUseCase>();

  UbicacionDestino? _ubicacionActual;
  bool _cargandoUbicacionActual = true;

  List<_Alternativa> _alternativasResueltas = [];
  bool _resolviendoUbicaciones = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _iniciar());
  }

  Future<void> _iniciar() async {
    await Future.wait([
      _cargarUbicacionActual(),
      context.read<DestinoProvider>().buscarAlternativas(
        destinoId: widget.destinoId,
        categoryId: widget.categoryId,
      ),
    ]);
    await _resolverUbicacionesAlternativas();
  }

  Future<void> _cargarUbicacionActual() async {
    final locationId = widget.destinoLocationId;
    if (locationId == null || locationId.trim().isEmpty) {
      if (mounted) setState(() => _cargandoUbicacionActual = false);
      return;
    }
    final result = await _getUbicacion(id: locationId);
    if (!mounted) return;
    setState(() {
      _ubicacionActual = result.fold((_) => null, (ubicacion) => ubicacion);
      _cargandoUbicacionActual = false;
    });
    _ajustarCamara();
  }

  Future<void> _resolverUbicacionesAlternativas() async {
    if (!mounted) return;
    final candidatas = context
        .read<DestinoProvider>()
        .alternativas
        .take(10)
        .toList();

    if (candidatas.isEmpty) {
      setState(() => _alternativasResueltas = []);
      return;
    }

    setState(() => _resolviendoUbicaciones = true);

    final resueltas = await Future.wait(
      candidatas.map((destino) async {
        final result = await _getUbicacion(id: destino.locationId);
        return result.fold((_) => _Alternativa(destino: destino), (ubicacion) {
          final distancia = _ubicacionActual != null
              ? _haversine(
                  _ubicacionActual!.latitude,
                  _ubicacionActual!.longitude,
                  ubicacion.latitude,
                  ubicacion.longitude,
                )
              : null;
          return _Alternativa(
            destino: destino,
            ubicacion: ubicacion,
            distanciaKm: distancia,
          );
        });
      }),
    );

    // Las que sí tienen ubicación primero, ordenadas por cercanía; luego
    // las que no la tienen (igual visibles en la lista, sin distancia).
    resueltas.sort((a, b) {
      if (a.distanciaKm == null && b.distanciaKm == null) return 0;
      if (a.distanciaKm == null) return 1;
      if (b.distanciaKm == null) return -1;
      return a.distanciaKm!.compareTo(b.distanciaKm!);
    });

    if (!mounted) return;
    setState(() {
      _alternativasResueltas = resueltas;
      _resolviendoUbicaciones = false;
    });
    _ajustarCamara();
  }

  void _ajustarCamara() {
    final puntos = <LatLng>[
      if (_ubicacionActual != null)
        LatLng(_ubicacionActual!.latitude, _ubicacionActual!.longitude),
      for (final a in _alternativasResueltas)
        if (a.ubicacion != null)
          LatLng(a.ubicacion!.latitude, a.ubicacion!.longitude),
    ];
    if (puntos.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (puntos.length == 1) {
        _mapCtrl.move(puntos.first, 13);
        return;
      }
      _mapCtrl.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(puntos),
          padding: const EdgeInsets.all(48),
        ),
      );
    });
  }

  double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = _rad(lat2 - lat1);
    final dLon = _rad(lon2 - lon1);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_rad(lat1)) * cos(_rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _rad(double deg) => deg * pi / 180;

  String _fmtDist(double km) =>
      km < 1 ? '${(km * 1000).round()} m' : '${km.toStringAsFixed(1)} km';

  void _abrirAlternativa(Destino destino) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LugarDetailPage(
          id: destino.id,
          nombre: destino.name,
          categoria: 'Destino turístico',
          calificacion: destino.averageRating,
          imageUrl: destino.imageUrl ?? '',
          descripcion: destino.description,
          totalResenas: destino.totalReviews,
          targetType: 'destination',
          categoryId: destino.categoryId,
          locationId: destino.locationId,
          isSaturated: destino.isSaturated,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.surface(context),
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary(context)),
        title: Text(
          'Alternativas menos concurridas',
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 240, child: _buildMapa(context)),
          Expanded(child: _buildLista(context)),
        ],
      ),
    );
  }

  Widget _buildMapa(BuildContext context) {
    final actualPt = _ubicacionActual != null
        ? LatLng(_ubicacionActual!.latitude, _ubicacionActual!.longitude)
        : null;

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapCtrl,
          options: MapOptions(
            initialCenter: actualPt ?? const LatLng(16.75, -93.11),
            initialZoom: actualPt != null ? 13 : 7,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.explorachiapas.app',
            ),
            MarkerLayer(
              markers: [
                if (actualPt != null)
                  Marker(
                    point: actualPt,
                    width: 42,
                    height: 42,
                    alignment: Alignment.topCenter,
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 42,
                    ),
                  ),
                for (final a in _alternativasResueltas)
                  if (a.ubicacion != null)
                    Marker(
                      point: LatLng(
                        a.ubicacion!.latitude,
                        a.ubicacion!.longitude,
                      ),
                      width: 38,
                      height: 38,
                      alignment: Alignment.topCenter,
                      child: GestureDetector(
                        onTap: () => _abrirAlternativa(a.destino),
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.green,
                          size: 38,
                        ),
                      ),
                    ),
              ],
            ),
          ],
        ),
        if (_cargandoUbicacionActual)
          const Positioned(
            top: 12,
            right: 12,
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      ],
    );
  }

  Widget _buildLista(BuildContext context) {
    return Consumer<DestinoProvider>(
      builder: (context, provider, _) {
        if (provider.alternativasStatus == DestinoStatus.loading ||
            _resolviendoUbicaciones) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.alternativasStatus == DestinoStatus.error) {
          return _buildMensaje(
            context,
            icon: Icons.wifi_off_outlined,
            titulo: 'No se pudieron cargar las alternativas',
            subtitulo:
                provider.alternativasErrorMessage ??
                'Revisa tu conexión e intenta de nuevo.',
          );
        }

        if (_alternativasResueltas.isEmpty) {
          return _buildMensaje(
            context,
            icon: Icons.groups_outlined,
            titulo: 'Sin alternativas por ahora',
            subtitulo:
                'No encontramos otros destinos de esta categoría marcados '
                'como menos concurridos.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: _alternativasResueltas.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final alternativa = _alternativasResueltas[index];
            return FadeSlideIn(
              delay: Duration(milliseconds: 40 * index),
              child: _AlternativaCard(
                alternativa: alternativa,
                distanciaTexto: alternativa.distanciaKm != null
                    ? _fmtDist(alternativa.distanciaKm!)
                    : null,
                onTap: () => _abrirAlternativa(alternativa.destino),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMensaje(
    BuildContext context, {
    required IconData icon,
    required String titulo,
    required String subtitulo,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: AppColors.textSecondary(context)),
            const SizedBox(height: 12),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitulo,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapCtrl.dispose();
    super.dispose();
  }
}

class _AlternativaCard extends StatefulWidget {
  final _Alternativa alternativa;
  final String? distanciaTexto;
  final VoidCallback onTap;

  const _AlternativaCard({
    required this.alternativa,
    required this.distanciaTexto,
    required this.onTap,
  });

  @override
  State<_AlternativaCard> createState() => _AlternativaCardState();
}

class _AlternativaCardState extends State<_AlternativaCard> {
  bool _presionado = false;

  @override
  Widget build(BuildContext context) {
    final destino = widget.alternativa.destino;
    return Listener(
      onPointerDown: (_) => setState(() => _presionado = true),
      onPointerUp: (_) => setState(() => _presionado = false),
      onPointerCancel: (_) => setState(() => _presionado = false),
      child: AnimatedScale(
        scale: _presionado ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderSubtle(context)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child:
                      destino.imageUrl != null && destino.imageUrl!.isNotEmpty
                      ? Image.network(
                          destino.imageUrl!,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(context),
                        )
                      : _placeholder(context),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        destino.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: Color(0xFFFFC107),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            destino.averageRating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                          if (widget.distanciaTexto != null) ...[
                            const SizedBox(width: 10),
                            Icon(
                              Icons.near_me_outlined,
                              size: 13,
                              color: AppColors.textSecondary(context),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              widget.distanciaTexto!,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) => Container(
    width: 56,
    height: 56,
    color: AppColors.primaryContainer(context),
    child: Icon(Icons.terrain, color: AppColors.primary(context), size: 24),
  );
}
