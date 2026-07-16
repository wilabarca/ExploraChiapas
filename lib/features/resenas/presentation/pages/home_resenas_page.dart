import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/resena_entity.dart';
import '../../domain/entities/resenas_fake_data.dart';
import '../widgets/destino_resena_card.dart';
import 'detalle_resena_page.dart';

class HomeResenasPage extends StatefulWidget {
  const HomeResenasPage({super.key});

  @override
  State<HomeResenasPage> createState() => _HomeResenasPageState();
}

class _HomeResenasPageState extends State<HomeResenasPage> {
  // ← Solo 3 categorías: General, Restaurante, Hotel
  String _filtroActivo = 'General';
  final _filtros = ['General', 'Naturaleza', 'Cultura', 'Restaurante', 'Hotel'];

  List<DestinoResenaEntity> get _destinosFiltrados {
    if (_filtroActivo == 'General') return destinosFake;
    return destinosFake.where((d) => d.tipo == _filtroActivo).toList();
  }

  @override
  Widget build(BuildContext context) {
    // ✓ MediaQuery.sizeOf evita rebuilds innecesarios
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2E7D32)),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/images/ExploraChiapas Logo.png',
              height: 26,
            ),
            const SizedBox(width: 8),
            const Text(
              'ExploraChiapas',
              style: TextStyle(
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Encabezado ──────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reseñas',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B1B1B),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Descubre experiencias reales de otros viajeros',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF888888),
                  ),
                ),
                const SizedBox(height: 14),

                // ✓ Wrap: chips fluyen si no caben en una línea
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _filtros.map((f) {
                    final activo = f == _filtroActivo;
                    return GestureDetector(
                      onTap: () => setState(() => _filtroActivo = f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 9),
                        decoration: BoxDecoration(
                          color: activo
                              ? const Color(0xFF2E7D32)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: activo
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFDDDDDD),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          f,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: activo
                                ? Colors.white
                                : const Color(0xFF555555),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),

          // ── Grid de destinos ─────────────────────────────────────────
          Expanded(
            child: _destinosFiltrados.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 48, color: Color(0xFFCCCCCC)),
                        SizedBox(height: 12),
                        Text(
                          'No hay destinos en esta categoría',
                          style: TextStyle(color: Color(0xFF888888)),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      // ✓ childAspectRatio proporcional a la pantalla
                      childAspectRatio:
                          (size.width / 2 - 22) / (size.height * 0.38),
                    ),
                    itemCount: _destinosFiltrados.length,
                    itemBuilder: (context, i) {
                      final destino = _destinosFiltrados[i];
                      return DestinoResenaCard(
                        destino: destino,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                DetalleResenaPage(destino: destino),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}