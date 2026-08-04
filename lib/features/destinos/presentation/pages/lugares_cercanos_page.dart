import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../home/presentation/widgets/destino_card.dart';
import '../../../home/presentation/widgets/home_app_bar.dart';
import '../../../maps/domain/entities/destination_entity.dart';
import '../../../maps/domain/usecases/get_destinations_nearby_usecase.dart';
import 'lugar_detail_page.dart';

/// Búsqueda real de destinos cercanos a la ubicación actual del usuario,
/// con radio configurable. Antes "Lugares cercanos" (en
/// `explorar_cerca_page.dart`) solo abría el mapa general — el método
/// del backend que sí acepta un radio en km (`getDestinationsNearby`)
/// existía en el código pero nunca se llamaba desde ninguna pantalla, y
/// además devolvía datos de muestra en vez de consultar el backend real.
class LugaresCercanosPage extends StatefulWidget {
  const LugaresCercanosPage({super.key});

  @override
  State<LugaresCercanosPage> createState() => _LugaresCercanosPageState();
}

class _LugaresCercanosPageState extends State<LugaresCercanosPage> {
  static const double _radioMinimo = 1;
  static const double _radioMaximo = 30;

  double _radioKm = 10;
  Position? _posicion;
  List<DestinationEntity> _resultados = [];
  bool _cargando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _obtenerUbicacionYBuscar();
  }

  Future<void> _obtenerUbicacionYBuscar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        if (!mounted) return;
        setState(() {
          _cargando = false;
          _error = 'Activa el GPS para buscar lugares cerca de ti.';
        });
        return;
      }

      var permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }
      if (permiso == LocationPermission.denied ||
          permiso == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _cargando = false;
          _error =
              'Necesitamos acceso a tu ubicación para mostrarte lugares '
              'cercanos.';
        });
        return;
      }

      // Paso 1 — última posición conocida: es instantánea (no espera al
      // GPS), suficiente para una búsqueda "cerca de mí" aproximada.
      // Antes se pedía directo un fix nuevo con solo 8s de margen y
      // `LocationAccuracy.high` (el GPS de alta precisión puede tardar
      // bastante más que eso en interiores o con señal débil), así que
      // cualquier demora terminaba en "No se pudo obtener tu ubicación"
      // aunque el GPS sí funcionara, solo que no a tiempo.
      final ultimaConocida = await Geolocator.getLastKnownPosition();
      if (ultimaConocida != null && mounted) {
        setState(() => _posicion = ultimaConocida);
        await _buscar();
      }

      // Paso 2 — posición fresca en segundo plano, con más margen y
      // precisión media (más rápida de conseguir que "high"). Si ya se
      // mostraron resultados con la última conocida, un fallo aquí es
      // silencioso — el usuario ya tiene algo útil en pantalla.
      try {
        final fresca = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 20),
          ),
        );
        if (!mounted) return;
        setState(() => _posicion = fresca);
        await _buscar();
      } catch (e) {
        if (ultimaConocida == null) rethrow;
        debugPrint(
          '[LugaresCercanos] fix fresco falló, se usa el último conocido: $e',
        );
        if (mounted) setState(() => _cargando = false);
      }
    } catch (e) {
      debugPrint('[LugaresCercanos] no se pudo obtener ubicación: $e');
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _error =
            'No se pudo obtener tu ubicación. Verifica tu conexión '
            'GPS e intenta de nuevo.';
      });
    }
  }

  Future<void> _buscar() async {
    final pos = _posicion;
    if (pos == null) return;

    setState(() => _cargando = true);
    final resultados = await getIt<GetDestinationsNearbyUseCase>()(
      lat: pos.latitude,
      lng: pos.longitude,
      radioKm: _radioKm,
    );
    if (!mounted) return;
    setState(() {
      _resultados = resultados;
      _cargando = false;
    });
  }

  double _distanciaKm(DestinationEntity d) {
    final pos = _posicion;
    if (pos == null) return 0;
    return Geolocator.distanceBetween(
          pos.latitude,
          pos.longitude,
          d.lat,
          d.lng,
        ) /
        1000;
  }

  String _categoriaLegible(String tipo) {
    if (tipo.isEmpty) return 'Destino';
    return tipo[0].toUpperCase() + tipo.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: const HomeAppBar(mostrarFlecha: true),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeSlideIn(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: AppColors.primary(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Lugares cercanos',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            FadeSlideIn(
              delay: const Duration(milliseconds: 80),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    Text(
                      'Radio de búsqueda',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_radioKm.round()} km',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            FadeSlideIn(
              delay: const Duration(milliseconds: 80),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primary(context),
                    thumbColor: AppColors.primary(context),
                    inactiveTrackColor: AppColors.borderSubtle(context),
                  ),
                  child: Slider(
                    value: _radioKm,
                    min: _radioMinimo,
                    max: _radioMaximo,
                    divisions: (_radioMaximo - _radioMinimo).round(),
                    label: '${_radioKm.round()} km',
                    // Solo se dispara la búsqueda al soltar (onChangeEnd):
                    // así arrastrar el slider no manda una petición al
                    // backend por cada píxel de movimiento.
                    onChanged: (v) => setState(() => _radioKm = v),
                    onChangeEnd: (_) => _buscar(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Expanded(child: _buildContenido(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildContenido(BuildContext context) {
    if (_error != null) {
      return _EstadoMensaje(
        icon: Icons.location_off_outlined,
        mensaje: _error!,
        accion: 'Reintentar',
        onAccion: _obtenerUbicacionYBuscar,
      );
    }

    if (_cargando && _resultados.isEmpty) {
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          SkeletonCardRow(
            count: 3,
            cardHeight: 220,
            cardWidth: double.infinity,
          ),
        ],
      );
    }

    if (_resultados.isEmpty) {
      return _EstadoMensaje(
        icon: Icons.search_off_rounded,
        mensaje:
            'No encontramos destinos en un radio de '
            '${_radioKm.round()} km. Prueba ampliando la búsqueda.',
      );
    }

    return RefreshIndicator(
      onRefresh: _buscar,
      color: AppColors.primary(context),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        itemCount: _resultados.length,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (context, i) {
          final d = _resultados[i];
          return FadeSlideIn(
            delay: Duration(milliseconds: 60 * i),
            offsetY: 12,
            child: DestinoCard(
              nombre: d.nombre,
              categoria: _categoriaLegible(d.tipo),
              calificacion: d.calificacion,
              esSostenible: d.esSostenible,
              distanciaKm: _distanciaKm(d),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LugarDetailPage(
                    id: d.id,
                    nombre: d.nombre,
                    categoria: d.tipo,
                    calificacion: d.calificacion,
                    imageUrl: '',
                    descripcion: d.descripcion.isNotEmpty
                        ? d.descripcion
                        : null,
                    lat: d.lat,
                    lng: d.lng,
                    categoryId: d.categoryId,
                    isSaturated: d.afluencia > 75,
                    targetType: d.categoryId != null ? 'destination' : null,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EstadoMensaje extends StatelessWidget {
  final IconData icon;
  final String mensaje;
  final String? accion;
  final VoidCallback? onAccion;

  const _EstadoMensaje({
    required this.icon,
    required this.mensaje,
    this.accion,
    this.onAccion,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.textHint(context)),
            const SizedBox(height: 14),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary(context),
                height: 1.4,
              ),
            ),
            if (accion != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onAccion,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary(context),
                  side: BorderSide(color: AppColors.primary(context)),
                ),
                child: Text(accion!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
