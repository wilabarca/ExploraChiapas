import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/envento_entity.dart';
import '../../domain/entities/evento.dart';
import '../providers/eventos_provider.dart';
import '../widgets/evento_card.dart';
import '../widgets/evento_filtro_chip.dart';
import 'detalle_evento_page.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';

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
    'Este fin de semana',
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
      // ✅ Usa la imagen real del backend si existe; solo cae al
      // fallback por categoría cuando el evento no trae imagenUrl.
      imageUrl: (e.imagenUrl != null && e.imagenUrl!.isNotEmpty)
          ? e.imagenUrl!
          : _imagenPorCategoria(e.categoriaNombre),
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

  bool _esEsteFinDeSemana(DateTime fecha) {
    final hoy = DateTime.now();
    final diasHastaSabado = (6 - hoy.weekday + 7) % 7;
    final sabado = DateTime(
      hoy.year,
      hoy.month,
      hoy.day + (diasHastaSabado == 0 ? 7 : diasHastaSabado),
    );
    final lunes = sabado.add(const Duration(days: 2));
    return !fecha.isBefore(sabado) && fecha.isBefore(lunes);
  }

  List<EventoEntity> _filtrar(List<Evento> eventos) {
    var lista = eventos.where((e) => e.activo).map(_mapEvento).toList();

    if (_filtroActivo == 'Este fin de semana') {
      lista = lista.where((e) => _esEsteFinDeSemana(e.fechaInicio)).toList();
    } else if (_filtroActivo != 'Todos') {
      lista = lista.where((e) => e.categoria == _filtroActivo).toList();
    }

    if (_busqueda.isNotEmpty) {
      final q = _busqueda.toLowerCase();
      lista = lista
          .where(
            (e) =>
                e.titulo.toLowerCase().contains(q) ||
                e.ubicacion.toLowerCase().contains(q) ||
                e.categoria.toLowerCase().contains(q),
          )
          .toList();
    }

    return lista;
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LocaleProvider>().langCode;
    String s(String k) => AppStrings.tr(k, lang);

    return Scaffold(
      backgroundColor: AppColors.surface(context),
      appBar: AppBar(
        backgroundColor: AppColors.surface(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          s('eventos_y_actividades'),
          style: TextStyle(
            color: AppColors.textPrimary(context),
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
                style: TextStyle(fontSize: 15, color: AppColors.textPrimary(context)),
                decoration: InputDecoration(
                  hintText: s('buscar_eventos'),
                  hintStyle: TextStyle(
                    color: AppColors.textHint(context),
                    fontSize: 15,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.primary(context),
                  ),
                  filled: true,
                  fillColor: AppColors.background(context),
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
                  return Center(
                    child: CircularProgressIndicator(color: AppColors.primary(context)),
                  );
                }

                if (provider.status == EventosStatus.error) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_off_outlined,
                          size: 48,
                          color: AppColors.textHint(context),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          provider.errorMessage ?? s('error_cargar_eventos'),
                          style: TextStyle(
                            color: AppColors.textSecondary(context),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () => provider.cargarEventos(),
                          icon: const Icon(Icons.refresh),
                          label: Text(s('reintentar')),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary(context),
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
                        Icon(
                          Icons.event_busy,
                          size: 48,
                          color: AppColors.textHint(context),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          s('sin_eventos'),
                          style: TextStyle(
                            color: AppColors.textSecondary(context),
                            fontSize: 15,
                          ),
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
