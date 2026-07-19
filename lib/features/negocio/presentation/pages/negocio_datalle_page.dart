import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/negocio.dart';
import '../../domain/usecases/obtener_negocio_por_id.dart';
import '../../../../core/di/injector.dart';
import '../widgets/negocio_header.dart';
import '../widgets/negocio_info.dart';
import '../widgets/negocio_servicios.dart';
import '../widgets/negocio_horarios.dart';

class NegocioDetallePage extends StatefulWidget {
  final String negocioId;

  const NegocioDetallePage({super.key, required this.negocioId});

  @override
  State<NegocioDetallePage> createState() => _NegocioDetallePageState();
}

class _NegocioDetallePageState extends State<NegocioDetallePage> {
  final _obtenerNegocioPorId = getIt<ObtenerNegocioPorId>();

  late Future<Negocio> _future;
  bool _esFavorito = false; // TODO: sincronizar con feature favoritos/API

  @override
  void initState() {
    super.initState();
    _future = _obtenerNegocioPorId(widget.negocioId).then(
      (either) =>
          either.fold((failure) => throw Exception(failure.message), (negocio) {
            _esFavorito = negocio.esFavorito;
            return negocio;
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      // ── Header consistente ──────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: AppColors.surface(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detalle del negocio',
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<Negocio>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary(context)),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Text(
                'No se pudo cargar el negocio.\n${snapshot.error ?? ''}',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary(context)),
              ),
            );
          }

          final negocio = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NegocioHeader(
                    negocio: negocio,
                    esFavorito: _esFavorito,
                    onToggleFavorito: () {
                      setState(() => _esFavorito = !_esFavorito);
                      // TODO: persistir en tabla favorito_negocio vía API
                    },
                  ),
                  const SizedBox(height: 22),
                  NegocioInfo(negocio: negocio),
                  const SizedBox(height: 22),
                  NegocioServicios(servicios: negocio.servicios),
                  const SizedBox(height: 22),
                  NegocioHorarios(horarios: negocio.horarios),
                  const SizedBox(height: 26),
                  // ── Botón escribir reseña ──────────────────────────
                  FractionallySizedBox(
                    widthFactor: 1.0,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: navegar a pantalla de nueva reseña con
                        // negocioId, o reutilizar '/resenas' con argumento.
                        Navigator.pushNamed(context, '/resenas');
                      },
                      icon: Icon(
                        Icons.rate_review_outlined,
                        color: AppColors.primary(context),
                      ),
                      label: Text(
                        'Escribir reseña',
                        style: TextStyle(
                          color: AppColors.primary(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: AppColors.primary(context)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
