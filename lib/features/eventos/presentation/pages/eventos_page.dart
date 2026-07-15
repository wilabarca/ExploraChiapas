import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EventosPage extends StatefulWidget {
  const EventosPage({super.key});

  @override
  State<EventosPage> createState() => _EventosPageState();
}

class _EventosPageState extends State<EventosPage> {
  final _busquedaController = TextEditingController();
  String _filtroActivo = 'Todos';

  final List<String> _filtros = [
    'Todos',
    'Festivales',
    'Talleres',
    'Gastronomía',
    'Cultura',
    'Naturaleza',
  ];

  final List<Map<String, dynamic>> _eventos = [
    {
      'nombre': 'Festival del Café Chiapaneco',
      'categoria': 'Gastronomía',
      'fecha': '15 Jul 2026',
      'lugar': 'San Cristóbal de las Casas',
      'imagen':
          'https://images.unsplash.com/photo-1447933601403-0c6688de566e?w=800&q=80',
    },
    {
      'nombre': 'Feria de las Culturas Indígenas',
      'categoria': 'Cultura',
      'fecha': '20 Jul 2026',
      'lugar': 'Tuxtla Gutiérrez',
      'imagen':
          'https://images.unsplash.com/photo-1533587851505-d119e13fa0d7?w=800&q=80',
    },
    {
      'nombre': 'Taller de Tejido Tradicional Tzotzil',
      'categoria': 'Talleres',
      'fecha': '25 Jul 2026',
      'lugar': 'Zinacantán',
      'imagen':
          'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&q=80',
    },
    {
      'nombre': 'Festival de la Selva Lacandona',
      'categoria': 'Naturaleza',
      'fecha': '1 Ago 2026',
      'lugar': 'Palenque',
      'imagen':
          'https://images.unsplash.com/photo-1501854140801-50d01698950b?w=800&q=80',
    },
    {
      'nombre': 'Encuentro de Músicos Mayas',
      'categoria': 'Festivales',
      'fecha': '10 Ago 2026',
      'lugar': 'Comitán de Domínguez',
      'imagen':
          'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800&q=80',
    },
    {
      'nombre': 'Taller de Cocina Regional',
      'categoria': 'Gastronomía',
      'fecha': '18 Ago 2026',
      'lugar': 'San Cristóbal de las Casas',
      'imagen':
          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&q=80',
    },
  ];

  List<Map<String, dynamic>> get _eventosFiltrados {
    var lista = _eventos;
    if (_filtroActivo != 'Todos') {
      lista = lista.where((e) => e['categoria'] == _filtroActivo).toList();
    }
    final busqueda = _busquedaController.text.toLowerCase();
    if (busqueda.isNotEmpty) {
      lista = lista
          .where((e) =>
              (e['nombre'] as String).toLowerCase().contains(busqueda) ||
              (e['lugar'] as String).toLowerCase().contains(busqueda))
          .toList();
    }
    return lista;
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
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
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _busquedaController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Buscar eventos...',
                hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
                prefixIcon:
                    const Icon(Icons.search, color: Color(0xFF2E7D32)),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Container(
            color: Colors.white,
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filtros.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filtro = _filtros[index];
                final activo = filtro == _filtroActivo;
                return GestureDetector(
                  onTap: () => setState(() => _filtroActivo = filtro),
                  child: Chip(
                    label: Text(filtro),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: activo ? Colors.white : const Color(0xFF555555),
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor:
                        activo ? const Color(0xFF2E7D32) : const Color(0xFFF0F0F0),
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _eventosFiltrados.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy_outlined,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        const Text(
                          'Sin eventos encontrados',
                          style: TextStyle(color: Color(0xFF999999)),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _eventosFiltrados.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final evento = _eventosFiltrados[index];
                      return _EventoCard(evento: evento);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _EventoCard extends StatelessWidget {
  final Map<String, dynamic> evento;
  const _EventoCard({required this.evento});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: CachedNetworkImage(
              imageUrl: evento['imagen'] as String,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Container(height: 160, color: const Color(0xFFD8F5D8)),
              errorWidget: (_, __, ___) => Container(
                height: 160,
                color: const Color(0xFFD8F5D8),
                child: const Icon(Icons.image_not_supported, color: Colors.white54),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    evento['categoria'] as String,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  evento['nombre'] as String,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B1B1B),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 13, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 4),
                    Text(
                      evento['fecha'] as String,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF666666)),
                    ),
                    const SizedBox(width: 14),
                    const Icon(Icons.location_on_outlined,
                        size: 13, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        evento['lugar'] as String,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF666666)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
