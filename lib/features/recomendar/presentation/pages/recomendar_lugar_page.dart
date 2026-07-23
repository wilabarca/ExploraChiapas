import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/ubicacion_propuesta.dart';
import '../providers/recomendar_provider.dart';
import 'seleccionar_ubicacion_page.dart';

class RecomendarLugarPage extends StatefulWidget {
  const RecomendarLugarPage({super.key});

  @override
  State<RecomendarLugarPage> createState() => _RecomendarLugarPageState();
}

class _RecomendarLugarPageState extends State<RecomendarLugarPage> {
  final _nombreCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _categoriaSeleccionadaId;
  UbicacionPropuesta? _ubicacion;
  final List<XFile> _imagenes = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<RecomendarProvider>();
      if (provider.categorias.isEmpty) {
        provider.cargarCategorias();
      }
    });
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarUbicacion() async {
    final resultado = await Navigator.push<UbicacionPropuesta>(
      context,
      MaterialPageRoute(
        builder: (_) => SeleccionarUbicacionPage(ubicacionInicial: _ubicacion),
      ),
    );
    if (resultado != null) {
      setState(() => _ubicacion = resultado);
    }
  }

  Future<void> _agregarImagenes() async {
    if (_imagenes.length >= 5) {
      _mostrarError('Máximo 5 fotografías permitidas.');
      return;
    }
    final picker = ImagePicker();
    final seleccionadas = await picker.pickMultiImage(imageQuality: 80);
    if (seleccionadas.isEmpty) return;

    final disponibles = 5 - _imagenes.length;
    final aAgregar = seleccionadas.take(disponibles).toList();
    setState(() => _imagenes.addAll(aAgregar));

    if (seleccionadas.length > disponibles) {
      _mostrarError('Solo se añadieron $disponibles foto(s). Límite: 5.');
    }
  }

  void _quitarImagen(int index) => setState(() => _imagenes.removeAt(index));

  void _mostrarError(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mensaje),
      backgroundColor: Theme.of(context).colorScheme.error,
      behavior: SnackBarBehavior.floating,
    ));
  }

  bool _validar() {
    if (!(_formKey.currentState?.validate() ?? false)) return false;
    if (_categoriaSeleccionadaId == null) {
      _mostrarError('Selecciona una categoría.');
      return false;
    }
    if (_ubicacion == null) {
      _mostrarError('Selecciona la ubicación en el mapa.');
      return false;
    }
    if (_imagenes.isEmpty) {
      _mostrarError('Agrega al menos 1 fotografía.');
      return false;
    }
    return true;
  }

  Future<void> _enviar() async {
    if (!_validar()) return;
    final provider = context.read<RecomendarProvider>();
    if (provider.propuestaIdCreada != null) {
      await provider.reintentarImagenes(imagenes: List.from(_imagenes));
    } else {
      await provider.enviarPropuesta(
        nombre: _nombreCtrl.text.trim(),
        descripcion: _descripcionCtrl.text.trim(),
        categoriaId: _categoriaSeleccionadaId!,
        ubicacion: _ubicacion!,
        imagenes: List.from(_imagenes),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RecomendarProvider>(
      builder: (context, provider, _) {
        if (provider.status == RecomendarStatus.exito) {
          return _PantallaExito(
            onVerMisRecomendaciones: () {
              provider.reiniciar();
              Navigator.pushNamed(context, '/mis-propuestas');
            },
            onVolver: () {
              provider.reiniciar();
              Navigator.pop(context);
            },
          );
        }

        final enviando = provider.status == RecomendarStatus.creandoUbicacion ||
            provider.status == RecomendarStatus.creandoPropuesta ||
            provider.status == RecomendarStatus.subiendoImagenes;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Recomendar lugar'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: enviando ? null : () => Navigator.pop(context),
            ),
          ),
          body: AbsorbPointer(
            absorbing: enviando,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BannerInfo(),
                    const SizedBox(height: 20),

                    // ── Nombre ──────────────────────────────────────────────
                    _label('Nombre del lugar *'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nombreCtrl,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Ej: Cascadas de Suchiapa',
                        prefixIcon: Icon(Icons.place_outlined),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'El nombre es obligatorio';
                        if (v.trim().length < 3) return 'Mínimo 3 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ── Categoría ────────────────────────────────────────────
                    _label('Categoría *'),
                    const SizedBox(height: 8),
                    _SelectorCategoria(
                      categorias: provider.categorias,
                      cargando: provider.status == RecomendarStatus.loadingCategorias,
                      seleccionadaId: _categoriaSeleccionadaId,
                      onSeleccionar: (id) => setState(() => _categoriaSeleccionadaId = id),
                    ),
                    const SizedBox(height: 16),

                    // ── Descripción ──────────────────────────────────────────
                    _label('Descripción *'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descripcionCtrl,
                      maxLines: 4,
                      maxLength: 500,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText:
                            'Cuéntanos qué hace especial este lugar, qué puede hacer '
                            'el visitante y por qué debería agregarse a ExploraChiapas.',
                        alignLabelWithHint: true,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'La descripción es obligatoria';
                        if (v.trim().length < 10) return 'Describe el lugar con más detalle';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ── Ubicación ────────────────────────────────────────────
                    _label('Ubicación *'),
                    const SizedBox(height: 8),
                    _SelectorUbicacion(
                      ubicacion: _ubicacion,
                      onSeleccionar: _seleccionarUbicacion,
                    ),
                    const SizedBox(height: 20),

                    // ── Fotografías ──────────────────────────────────────────
                    Row(children: [
                      _label('Fotografías *  '),
                      Text(
                        '${_imagenes.length}/5',
                        style: TextStyle(
                          fontSize: 13,
                          color: _imagenes.length >= 5
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.5),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 4),
                    Text(
                      'Mínimo 1, máximo 5. La primera foto será la portada.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _SelectorImagenes(
                      imagenes: _imagenes,
                      onAgregar: _agregarImagenes,
                      onQuitar: _quitarImagen,
                    ),
                    const SizedBox(height: 24),

                    // ── Progreso y errores ───────────────────────────────────
                    if (enviando) _IndicadorProgreso(status: provider.status),
                    if (provider.status == RecomendarStatus.error &&
                        provider.errorMessage != null)
                      _BannerError(
                        mensaje: provider.errorMessage!,
                        puedeReintentar: provider.propuestaIdCreada != null,
                        onReintentar: _enviar,
                      ),
                    const SizedBox(height: 8),

                    // ── Botón principal ──────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: enviando ? null : _enviar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: enviando
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                provider.propuestaIdCreada != null
                                    ? 'Reintentar envío de fotos'
                                    : 'Enviar recomendación',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: enviando
                            ? null
                            : () => Navigator.pushNamed(context, '/mis-propuestas'),
                        child: const Text('Ver mis recomendaciones'),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _label(String texto) => Text(
        texto,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      );
}

// ── Widgets ────────────────────────────────────────────────────────────────────

class _BannerInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: cs.onPrimaryContainer, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Ayúdanos a descubrir nuevos lugares de Chiapas. Comparte la ubicación, '
              'información y fotografías del sitio. Nuestro equipo revisará tu '
              'recomendación antes de publicarla como un destino oficial.',
              style: TextStyle(
                  fontSize: 13, color: cs.onPrimaryContainer, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectorCategoria extends StatelessWidget {
  final List<dynamic> categorias;
  final bool cargando;
  final String? seleccionadaId;
  final void Function(String id) onSeleccionar;

  const _SelectorCategoria({
    required this.categorias,
    required this.cargando,
    required this.seleccionadaId,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (cargando) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (categorias.isEmpty) {
      return Text(
        'No se pudieron cargar las categorías.',
        style: TextStyle(color: cs.error, fontSize: 13),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categorias.map((cat) {
        final selected = cat.id == seleccionadaId;
        return ChoiceChip(
          label: Text(cat.nombre),
          selected: selected,
          onSelected: (_) => onSeleccionar(cat.id),
          selectedColor: cs.primary,
          labelStyle: TextStyle(
            color: selected ? cs.onPrimary : cs.onSurface,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        );
      }).toList(),
    );
  }
}

class _SelectorUbicacion extends StatelessWidget {
  final UbicacionPropuesta? ubicacion;
  final VoidCallback onSeleccionar;

  const _SelectorUbicacion({required this.ubicacion, required this.onSeleccionar});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (ubicacion == null) {
      return OutlinedButton.icon(
        onPressed: onSeleccionar,
        icon: const Icon(Icons.map_outlined),
        label: const Text('Seleccionar en el mapa'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          side: BorderSide(color: cs.outline),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
    return GestureDetector(
      onTap: onSeleccionar,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: cs.primary.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(12),
          color: cs.primaryContainer.withValues(alpha: 0.3),
        ),
        child: Row(
          children: [
            Icon(Icons.location_on, color: cs.primary, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${ubicacion!.municipality}, ${ubicacion!.state}',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface),
                  ),
                  if (ubicacion!.address.isNotEmpty &&
                      ubicacion!.address != 'Chiapas, México')
                    Text(
                      ubicacion!.address,
                      style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurface.withValues(alpha: 0.6)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  Text(
                    '${ubicacion!.latitude.toStringAsFixed(6)}, '
                    '${ubicacion!.longitude.toStringAsFixed(6)}',
                    style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurface.withValues(alpha: 0.4)),
                  ),
                ],
              ),
            ),
            Icon(Icons.edit_outlined, size: 18, color: cs.primary),
          ],
        ),
      ),
    );
  }
}

class _SelectorImagenes extends StatelessWidget {
  final List<XFile> imagenes;
  final VoidCallback onAgregar;
  final void Function(int) onQuitar;

  const _SelectorImagenes({
    required this.imagenes,
    required this.onAgregar,
    required this.onQuitar,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (imagenes.length < 5)
            GestureDetector(
              onTap: onAgregar,
              child: Container(
                width: 80,
                height: 80,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: cs.outline),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_outlined, color: cs.primary, size: 26),
                    const SizedBox(height: 4),
                    Text('Agregar',
                        style: TextStyle(fontSize: 11, color: cs.primary)),
                  ],
                ),
              ),
            ),
          ...imagenes.asMap().entries.map((entry) {
            final idx = entry.key;
            final img = entry.value;
            return Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: cs.surfaceContainer,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(img.path),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.image,
                        color: cs.onSurface.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 2,
                  right: 10,
                  child: GestureDetector(
                    onTap: () => onQuitar(idx),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                          color: Colors.black54, shape: BoxShape.circle),
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 14),
                    ),
                  ),
                ),
                if (idx == 0)
                  Positioned(
                    bottom: 4,
                    left: 4,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: cs.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('Portada',
                          style: TextStyle(
                              fontSize: 9,
                              color: cs.onPrimary,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _IndicadorProgreso extends StatelessWidget {
  final RecomendarStatus status;
  const _IndicadorProgreso({required this.status});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pasos = [
      (RecomendarStatus.creandoUbicacion, 'Preparando ubicación'),
      (RecomendarStatus.creandoPropuesta, 'Registrando recomendación'),
      (RecomendarStatus.subiendoImagenes, 'Subiendo fotografías'),
    ];
    final currentIndex = pasos.indexWhere((p) => p.$1 == status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: pasos.asMap().entries.map((entry) {
          final i = entry.key;
          final paso = entry.value;
          final activo = i == currentIndex;
          final terminado = i < currentIndex;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(children: [
              if (terminado)
                Icon(Icons.check_circle, color: cs.primary, size: 16)
              else if (activo)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: cs.primary),
                )
              else
                Icon(Icons.radio_button_unchecked,
                    color: cs.onPrimaryContainer.withValues(alpha: 0.4),
                    size: 16),
              const SizedBox(width: 10),
              Text(
                paso.$2,
                style: TextStyle(
                  fontSize: 13,
                  color: activo
                      ? cs.onPrimaryContainer
                      : terminado
                          ? cs.primary
                          : cs.onPrimaryContainer.withValues(alpha: 0.5),
                  fontWeight: activo ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ]),
          );
        }).toList(),
      ),
    );
  }
}

class _BannerError extends StatelessWidget {
  final String mensaje;
  final bool puedeReintentar;
  final VoidCallback onReintentar;

  const _BannerError({
    required this.mensaje,
    required this.puedeReintentar,
    required this.onReintentar,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.error_outline, color: cs.onErrorContainer, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(mensaje,
                  style: TextStyle(fontSize: 13, color: cs.onErrorContainer)),
            ),
          ]),
          if (puedeReintentar) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: onReintentar,
              child: Text('Reintentar subida de fotos',
                  style: TextStyle(color: cs.onErrorContainer)),
            ),
          ],
        ],
      ),
    );
  }
}

class _PantallaExito extends StatelessWidget {
  final VoidCallback onVerMisRecomendaciones;
  final VoidCallback onVolver;

  const _PantallaExito({
    required this.onVerMisRecomendaciones,
    required this.onVolver,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_circle_outline,
                      size: 48, color: cs.primary),
                ),
                const SizedBox(height: 24),
                Text(
                  'Recomendación enviada',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Gracias por ayudarnos a descubrir nuevos lugares de Chiapas. '
                  'Tu recomendación será revisada antes de publicarse en ExploraChiapas.',
                  style: TextStyle(
                    fontSize: 14,
                    color: cs.onSurface.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: onVerMisRecomendaciones,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Ver mis recomendaciones'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onVolver,
                  child: const Text('Volver al inicio'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
