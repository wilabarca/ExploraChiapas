import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/envento_entity.dart';
import '../../domain/entities/evento.dart';
import '../providers/eventos_provider.dart';
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<EventosProvider>();
      if (provider.status == EventosStatus.idle) {
        provider.cargarEventos();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  EventoEntity _mapEvento(Evento e) {
    return EventoEntity(
      id: e.id,
      titulo: e.titulo,
      descripcion: e.descripcion ?? '',
      fechaInicio: e.fechaInicio,
      fechaFin: e.fechaFin,
      ubicacion: e.municipio ?? 'Chiapas',
      categoria: e.categoriaNombre ?? 'General',
      imageUrl: _imagenPorCategoria(e.categoriaNombre),
      activo: e.activo,
    );
  }

  String _imagenPorCategoria(String? cat) {
    switch (cat) {
      case 'Gastronomía':
        return 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&q=80';
      case 'Cultura':
        return 'https://images.unsplash.com/photo-1518638150340-f706e86654de?w=800&q=80';
      case 'Festivales':
        return 'https://images.unsplash.com/photo-1533587851505-d119e13fa0d7?w=800&q=80';
      case 'Talleres':
        return 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800&q=80';
      default:
        return 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80';
    }
  }

  List<EventoEntity> _filtrar(List<Evento> eventos) {
    var lista = eventos
        .where((e) => e.activo)
        .map(_mapEvento)
        .toList();

    if (_filtroActivo != 'Todos') {
      lista = lista.where((e) => e.categoria == _filtroActivo).toList();
    }

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
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B1B1B)),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 50),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _busqueda = v),
                style: const TextStyle(fontSize: 15, color: Color(0xFF1B1B1B)),
                decoration: InputDecoration(
                  hintText: 'Buscar eventos...',
                  hintStyle: const TextStyle(
                    color: Color(0xFFAAAAAA),
                    fontSize: 15,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF2E7D32)),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 42,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filtros.length,
              itemBuilder: (context, i) => EventoFiltroChip(
                label: _filtros[i],
                activo: _filtros[i] == _filtroActivo,
                onTap: () => setState(() => _filtroActivo = _filtros[i]),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: Consumer<EventosProvider>(
              builder: (context, provider, _) {
                if (provider.status == EventosStatus.loading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
                  );
                }

                if (provider.status == EventosStatus.error) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_off_outlined,
                            size: 48, color: Color(0xFFCCCCCC)),
                        const SizedBox(height: 12),
                        Text(
                          provider.errorMessage ?? 'Error al cargar eventos',
                          style: const TextStyle(
                              color: Color(0xFF888888), fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () => provider.cargarEventos(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final lista = _filtrar(provider.eventos);

                if (lista.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.event_busy,
                            size: 48, color: Color(0xFFCCCCCC)),
                        const SizedBox(height: 12),
                        const Text(
                          'No hay eventos disponibles',
                          style: TextStyle(
                              color: Color(0xFF888888), fontSize: 15),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: lista.length,
                  itemBuilder: (context, i) {
                    final evento = lista[i];
                    return EventoCard(
                      evento: evento,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetalleEventoPage(evento: evento),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
