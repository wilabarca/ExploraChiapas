import 'package:flutter/material.dart';
import '../../domain/entities/envento_entity.dart';
import '../../domain/entities/evento_false.data.dart';
import '../widgets/evento_card.dart';
import '../widgets/evento_filtro_chip.dart';
import 'detalle_evento_page.dart';

class EventosPage extends StatefulWidget {
  const EventosPage({super.key});

  @override
  State<EventosPage> createState() => _EventosPageState();
}

class _EventosPageState extends State<EventosPage> {
  String _filtroActivo = 'Todos';
  String _busqueda = '';
  final _searchCtrl = TextEditingController();

  final _filtros = [
    'Todos',
    'Festivales',
    'Talleres',
    'Gastronomía',
    'Cultura',
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<EventoEntity> get _eventosFiltrados {
    var lista = eventosFake.where((e) => e.activo).toList();

    // Filtro por categoría
    if (_filtroActivo != 'Todos') {
      lista = lista
          .where((e) => e.categoria == _filtroActivo)
          .toList();
    }

    // Filtro por búsqueda
    if (_busqueda.isNotEmpty) {
      final q = _busqueda.toLowerCase();
      lista = lista
          .where((e) =>
              e.titulo.toLowerCase().contains(q) ||
              e.ubicacion.toLowerCase().contains(q) ||
              e.categoria.toLowerCase().contains(q))
          .toList();
    }

    return lista;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color(0xFF1B1B1B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Eventos y Actividades',
          style: TextStyle(
            color: Color(0xFF1B1B1B),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ── Buscador ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 50),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) =>
                    setState(() => _busqueda = v),
                style: const TextStyle(
                    fontSize: 15, color: Color(0xFF1B1B1B)),
                decoration: InputDecoration(
                  hintText: 'Buscar eventos...',
                  hintStyle: const TextStyle(
                    color: Color(0xFFAAAAAA),
                    fontSize: 15,
                  ),
                  prefixIcon: const Icon(Icons.search,
                      color: Color(0xFF2E7D32)),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Filtros horizontales ───────────────────────────────────
          SizedBox(
            height: 42,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filtros.length,
              itemBuilder: (context, i) => EventoFiltroChip(
                label: _filtros[i],
                activo: _filtros[i] == _filtroActivo,
                onTap: () =>
                    setState(() => _filtroActivo = _filtros[i]),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ── Lista de eventos ───────────────────────────────────────
          Expanded(
            child: _eventosFiltrados.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.event_busy,
                            size: 48,
                            color: Color(0xFFCCCCCC)),
                        const SizedBox(height: 12),
                        const Text(
                          'No hay eventos disponibles',
                          style: TextStyle(
                              color: Color(0xFF888888),
                              fontSize: 15),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding:
                        const EdgeInsets.only(bottom: 20),
                    itemCount: _eventosFiltrados.length,
                    itemBuilder: (context, i) {
                      final evento = _eventosFiltrados[i];
                      return EventoCard(
                        evento: evento,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                DetalleEventoPage(evento: evento),
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