import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/propuesta_destino.dart';
import '../providers/mis_propuestas_provider.dart';
import '../widgets/propuesta_card.dart';
import 'detalle_propuesta_page.dart';

class MisPropuestasPage extends StatefulWidget {
  const MisPropuestasPage({super.key});

  @override
  State<MisPropuestasPage> createState() => _MisPropuestasPageState();
}

class _MisPropuestasPageState extends State<MisPropuestasPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MisPropuestasProvider>().cargar();
    });
  }

  void _abrirDetalle(PropuestaDestino propuesta) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetallePropuestaPage(propuesta: propuesta),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis recomendaciones'),
        actions: [
          Consumer<MisPropuestasProvider>(
            builder: (_, provider, __) => IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Actualizar',
              onPressed: provider.status == MisPropuestasStatus.loading
                  ? null
                  : provider.cargar,
            ),
          ),
        ],
      ),
      body: Consumer<MisPropuestasProvider>(
        builder: (context, provider, _) {
          if (provider.status == MisPropuestasStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.status == MisPropuestasStatus.error) {
            return _PantallaError(
              mensaje: provider.errorMessage ??
                  'No pudimos cargar tus recomendaciones.',
              onReintentar: provider.cargar,
            );
          }

          if (provider.propuestas.isEmpty) {
            return _PantallaVacia(
              onRecomendar: () => Navigator.pushNamed(context, '/recomendar'),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.cargar,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.propuestas.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => PropuestaCard(
                propuesta: provider.propuestas[i],
                onTap: () => _abrirDetalle(provider.propuestas[i]),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/recomendar'),
        icon: const Icon(Icons.add),
        label: const Text('Nueva recomendación'),
      ),
    );
  }
}

class _PantallaVacia extends StatelessWidget {
  final VoidCallback onRecomendar;
  const _PantallaVacia({required this.onRecomendar});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.place_outlined, size: 64, color: cs.primary.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            const Text(
              'Aún no tienes recomendaciones',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Propón un lugar que conozcas y ayúdanos a enriquecer el mapa de Chiapas.',
              style: TextStyle(
                  fontSize: 14, color: cs.onSurface.withValues(alpha: 0.6)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRecomendar,
              icon: const Icon(Icons.add),
              label: const Text('Recomendar un lugar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PantallaError extends StatelessWidget {
  final String mensaje;
  final VoidCallback onReintentar;
  const _PantallaError({required this.mensaje, required this.onReintentar});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_outlined, size: 56, color: cs.error.withValues(alpha: 0.6)),
            const SizedBox(height: 16),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: cs.onSurface.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onReintentar,
              icon: const Icon(Icons.refresh),
              label: const Text('Intentar de nuevo'),
            ),
          ],
        ),
      ),
    );
  }
}
