import 'package:flutter/material.dart';
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
      backgroundColor: const Color(0xFFF8F8F8),
      // ── Header consistente ──────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B1B1B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detalle del negocio',
          style: TextStyle(
            color: Color(0xFF1B1B1B),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<Negocio>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Text(
                'No se pudo cargar el negocio.\n${snapshot.error ?? ''}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF999999)),
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
                      icon: const Icon(
                        Icons.rate_review_outlined,
                        color: Color(0xFF2E7D32),
                      ),
                      label: const Text(
                        'Escribir reseña',
                        style: TextStyle(
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFF2E7D32)),
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
