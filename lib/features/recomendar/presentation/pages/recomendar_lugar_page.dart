import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../core/permissions/location_permission.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/reverse_geocoding_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_constants.dart';
import '../../../../core/validation/input_sanitizer.dart';
import '../../../categorias/domain/entities/categoria.dart';
import '../../../categorias/presentation/providers/categorias_provider.dart';
import '../../domain/entities/ubicacion_seleccionada.dart';
import '../providers/recomendar_provider.dart';
import '../widgets/recomendar_result_dialogs.dart';
import 'seleccionar_ubicacion_mapa_page.dart';

/// "Recomendar lugar": el usuario propone un NUEVO destino turístico que
/// todavía no existe en ExploraChiapas. No es "recomendar una ruta" (una
/// ruta se compone de destinos ya existentes) ni confirma asistencia a
/// nada — la propuesta queda pendiente hasta que un admin_plataforma la
/// aprueba o rechaza.
class RecomendarLugarPage extends StatefulWidget {
  const RecomendarLugarPage({super.key});

  @override
  State<RecomendarLugarPage> createState() => _RecomendarLugarPageState();
}

class _RecomendarLugarPageState extends State<RecomendarLugarPage> {
  final _nombreCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _picker = ImagePicker();

  String? _errorNombre;
  String? _errorDescripcion;
  String? _errorCategoria;
  String? _errorFotos;

  Categoria? _categoriaSeleccionada;

  UbicacionSeleccionada? _ubicacion;
  bool _obteniendoUbicacion = false;
  String? _ubicacionError;

  final List<XFile> _fotos = [];

  bool _enviando = false;

  // El picker de imágenes no filtra formato por sí solo: se valida la
  // extensión real de cada archivo elegido contra lo que el backend
  // soporta (JPG/JPEG, PNG, WEBP).
  static const _extensionesPermitidas = {'jpg', 'jpeg', 'png', 'webp'};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoriasProvider>().cargarSiHaceFalta();
      _obtenerUbicacionInicial();
    });
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  // ── Ubicación ────────────────────────────────────────────────────────

  Future<void> _obtenerUbicacionInicial() async {
    if (!mounted) return;
    setState(() {
      _obteniendoUbicacion = true;
      _ubicacionError = null;
    });

    final concedido = await LocationPermissionHelper().requestWithDialog(
      context,
    );
    if (!mounted) return;

    if (!concedido) {
      setState(() {
        _obteniendoUbicacion = false;
        _ubicacionError =
            'Necesitamos tu ubicación para sugerir el lugar. También '
            'puedes elegirla manualmente en el mapa.';
      });
      return;
    }

    final posicion = await LocationService().getCurrentPosition();
    if (!mounted) return;

    if (posicion == null) {
      setState(() {
        _obteniendoUbicacion = false;
        _ubicacionError =
            'No pudimos obtener tu ubicación actual. Verifica que el GPS '
            'esté activado o elígela en el mapa.';
      });
      return;
    }

    final direccion = await ReverseGeocodingService().buscar(
      latitude: posicion.latitude,
      longitude: posicion.longitude,
    );
    if (!mounted) return;

    setState(() {
      _obteniendoUbicacion = false;
      _ubicacion = UbicacionSeleccionada(
        latitude: posicion.latitude,
        longitude: posicion.longitude,
        address: direccion?.address,
        municipality: direccion?.municipality,
        state: direccion?.state,
      );
    });
  }

  Future<void> _abrirMapaParaAjustarUbicacion() async {
    final resultado = await Navigator.push<UbicacionSeleccionada>(
      context,
      MaterialPageRoute(
        builder: (_) => SeleccionarUbicacionMapaPage(
          latitudInicial: _ubicacion?.latitude,
          longitudInicial: _ubicacion?.longitude,
        ),
      ),
    );

    if (resultado == null || !mounted) return;
    setState(() {
      _ubicacion = resultado;
      _ubicacionError = null;
    });
  }

  // ── Fotografías ──────────────────────────────────────────────────────

  Future<void> _agregarFotos() async {
    final restantes = AppConstants.destinationProposalMaxImages - _fotos.length;
    if (restantes <= 0) return;

    final List<XFile> seleccionadas;
    try {
      seleccionadas = await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1600,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No se pudo abrir la galería de fotos.'),
          backgroundColor: AppColors.error(context),
        ),
      );
      return;
    }
    if (seleccionadas.isEmpty || !mounted) return;

    final validas = <XFile>[];
    var descartadasPorFormato = 0;

    for (final foto in seleccionadas) {
      final extension = foto.path.split('.').last.toLowerCase();
      if (!_extensionesPermitidas.contains(extension)) {
        descartadasPorFormato++;
        continue;
      }
      validas.add(foto);
    }

    final descartadasPorLimite = validas.length > restantes
        ? validas.length - restantes
        : 0;

    setState(() {
      _fotos.addAll(validas.take(restantes));
      if (_fotos.isNotEmpty) _errorFotos = null;
    });

    if (!mounted) return;
    if (descartadasPorFormato > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            descartadasPorFormato == 1
                ? '1 imagen no se agregó: formato no compatible (usa JPG, PNG o WEBP).'
                : '$descartadasPorFormato imágenes no se agregaron: formato no compatible (usa JPG, PNG o WEBP).',
          ),
          backgroundColor: AppColors.error(context),
        ),
      );
    } else if (descartadasPorLimite > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Solo puedes agregar hasta '
            '${AppConstants.destinationProposalMaxImages} fotografías.',
          ),
          backgroundColor: AppColors.error(context),
        ),
      );
    }
  }

  void _quitarFoto(int index) {
    setState(() {
      _fotos.removeAt(index);
      if (_fotos.isEmpty) {
        _errorFotos = 'Agrega al menos 1 fotografía';
      }
    });
  }

  // ── Envío ────────────────────────────────────────────────────────────

  Future<void> _enviarConReintentos() async {
    if (_enviando) return;
    setState(() => _enviando = true);
    try {
      var reintentar = true;
      while (reintentar) {
        reintentar = await _intentarEnviar();
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  /// Un solo intento de envío. Devuelve `true` cuando el usuario pide
  /// reintentar tras un error; en cualquier otro desenlace, `false`.
  Future<bool> _intentarEnviar() async {
    final nombre = InputSanitizer.limpiar(_nombreCtrl.text);
    final errorNombre = InputSanitizer.validarTexto(
      nombre,
      etiqueta: 'El nombre del lugar',
      minLength: 3,
      maxLength: 100,
    );

    final descripcion = InputSanitizer.limpiar(_descripcionCtrl.text);
    final errorDescripcion = InputSanitizer.validarTexto(
      descripcion,
      etiqueta: 'La descripción',
      minLength: 10,
      maxLength: 255,
    );

    final errorCategoria = _categoriaSeleccionada == null
        ? 'Selecciona una categoría'
        : null;

    final errorFotos = _fotos.isEmpty
        ? 'Agrega al menos 1 fotografía (máximo ${AppConstants.destinationProposalMaxImages})'
        : (_fotos.length > AppConstants.destinationProposalMaxImages
              ? 'Máximo ${AppConstants.destinationProposalMaxImages} fotografías'
              : null);

    setState(() {
      _errorNombre = errorNombre;
      _errorDescripcion = errorDescripcion;
      _errorCategoria = errorCategoria;
      _errorFotos = errorFotos;
    });

    if (errorNombre != null ||
        errorDescripcion != null ||
        errorCategoria != null ||
        errorFotos != null) {
      return false;
    }

    if (_ubicacion == null) {
      if (!_obteniendoUbicacion) {
        await _obtenerUbicacionInicial();
        if (!mounted) return false;
      }
      if (_ubicacion == null) {
        return mostrarErrorSugerenciaDialog(
          context,
          mensaje:
              _ubicacionError ??
              'No pudimos determinar la ubicación. Selecciónala en el '
                  'mapa e inténtalo de nuevo.',
        );
      }
    }

    final provider = context.read<RecomendarProvider>();

    // No se espera este Future: solo muestra el overlay de progreso y
    // retorna de inmediato para poder seguir con la petición al backend.
    // Se cierra explícitamente más abajo con Navigator.pop.
    mostrarEnviandoPropuestaDialog(context, provider);

    final exito = await provider.enviarPropuesta(
      name: nombre,
      description: descripcion,
      categoryId: _categoriaSeleccionada!.id,
      latitude: _ubicacion!.latitude,
      longitude: _ubicacion!.longitude,
      mapProvider: AppConstants.mapProviderOpenStreetMap,
      rutasImagenes: _fotos.map((foto) => foto.path).toList(),
    );

    if (!mounted) return false;
    Navigator.of(context, rootNavigator: true).pop(); // cierra el progreso
    if (!mounted) return false;

    if (exito) {
      final verMisRecomendaciones = await mostrarSugerenciaEnviadaSheet(
        context,
      );
      if (!mounted) return false;
      provider.reset();
      if (verMisRecomendaciones) {
        Navigator.pushReplacementNamed(context, '/mis-recomendaciones');
      } else {
        Navigator.pop(context);
      }
      return false;
    }

    final mensaje = _mensajeError(provider);
    return mostrarErrorSugerenciaDialog(context, mensaje: mensaje);
  }

  String _mensajeError(RecomendarProvider provider) {
    final statusCode = provider.errorStatusCode;
    if (statusCode == 401) {
      return 'Tu sesión expiró. Inicia sesión nuevamente para continuar.';
    }
    if (statusCode == 403) {
      return 'No tienes permiso para realizar esta acción.';
    }
    if (statusCode == 404) {
      return 'No fue posible encontrar el recurso solicitado.';
    }
    if (statusCode == 409) {
      return 'Ya existe un registro con esos datos.';
    }
    if (statusCode != null && statusCode >= 500) {
      return 'Ocurrió un error en el servidor. Inténtalo más tarde.';
    }
    final mensaje = provider.errorMessage;
    final baseMensaje = (mensaje != null && mensaje.isNotEmpty)
        ? mensaje
        : 'No pudimos enviar tu recomendación. Inténtalo nuevamente.';

    // La ubicación y/o la propuesta ya se registraron en un intento
    // anterior: al reintentar no se duplican, solo se retoma desde las
    // fotografías — vale la pena que el usuario lo sepa.
    if (provider.propuestaYaCreada) {
      return '$baseMensaje Tu recomendación ya quedó registrada; solo '
          'falta terminar de subir las fotos.';
    }
    return baseMensaje;
  }

  // ── UI ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenW = mq.size.width;
    final screenH = mq.size.height;
    final isSmall = screenW < 360;

    return Scaffold(
      backgroundColor: AppColors.surface(context),
      appBar: AppBar(
        backgroundColor: AppColors.surface(context),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primary(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Recomendar lugar',
          style: TextStyle(
            color: AppColors.primary(context),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: constraints.maxWidth * 0.05,
              vertical: screenH * 0.020,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Banner informativo ────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer(context),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.explore_outlined,
                        color: AppColors.onPrimaryContainer(context),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Ayúdanos a descubrir nuevos lugares de Chiapas. '
                          'Comparte la ubicación, información y '
                          'fotografías del sitio. Nuestro equipo revisará '
                          'tu recomendación antes de publicarla como un '
                          'destino oficial en ExploraChiapas.',
                          style: TextStyle(
                            fontSize: isSmall ? 12 : 14,
                            color: AppColors.onPrimaryContainer(context),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: screenH * 0.025),

                // ── Nombre del lugar ──────────────────────
                _buildLabel('Nombre del lugar'),
                SizedBox(height: screenH * 0.010),
                _buildTextField(
                  controller: _nombreCtrl,
                  hint: 'Ej. Cascadas de Suchiapa',
                  isSmall: isSmall,
                  errorText: _errorNombre,
                  onChanged: () {
                    if (_errorNombre != null) {
                      setState(() => _errorNombre = null);
                    }
                  },
                ),

                SizedBox(height: screenH * 0.022),

                // ── Categoría ──────────────────────────────
                _buildLabel('Categoría'),
                SizedBox(height: screenH * 0.010),
                _SelectorCategoria(
                  seleccionada: _categoriaSeleccionada,
                  error: _errorCategoria,
                  onSeleccionar: (categoria) {
                    setState(() {
                      _categoriaSeleccionada = categoria;
                      _errorCategoria = null;
                    });
                  },
                ),

                SizedBox(height: screenH * 0.022),

                // ── Descripción ────────────────────────────
                _buildLabel('Descripción'),
                SizedBox(height: screenH * 0.010),
                _buildTextField(
                  controller: _descripcionCtrl,
                  hint:
                      '¿Qué tiene de especial? ¿Qué puede hacer el '
                      'visitante ahí?',
                  maxLines: 4,
                  isSmall: isSmall,
                  errorText: _errorDescripcion,
                  onChanged: () {
                    if (_errorDescripcion != null) {
                      setState(() => _errorDescripcion = null);
                    } else {
                      setState(() {}); // refresca el contador
                    }
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '${_descripcionCtrl.text.trim().length}/255',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textHint(context),
                    ),
                  ),
                ),

                SizedBox(height: screenH * 0.022),

                // ── Ubicación ──────────────────────────────
                _buildLabel('Ubicación'),
                SizedBox(height: screenH * 0.010),
                _EstadoUbicacion(
                  obteniendo: _obteniendoUbicacion,
                  ubicacion: _ubicacion,
                  error: _ubicacionError,
                  onReintentar: _obtenerUbicacionInicial,
                  onAjustarEnMapa: _abrirMapaParaAjustarUbicacion,
                ),

                SizedBox(height: screenH * 0.022),

                // ── Fotografías ────────────────────────────
                _buildLabel('Fotografías'),
                SizedBox(height: screenH * 0.010),
                _SelectorFotos(
                  fotos: _fotos,
                  onAgregar: _agregarFotos,
                  onQuitar: _quitarFoto,
                  error: _errorFotos,
                ),
                const SizedBox(height: 6),
                Text(
                  '${_fotos.length} de '
                  '${AppConstants.destinationProposalMaxImages} fotografías',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textHint(context),
                  ),
                ),

                SizedBox(height: screenH * 0.030),

                // ── Botón enviar ──────────────────────────
                FractionallySizedBox(
                  widthFactor: 1.0,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 54),
                    child: ElevatedButton.icon(
                      onPressed: _enviando ? null : _enviarConReintentos,
                      icon: _enviando
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: AppColors.onPrimary(context),
                                strokeWidth: 2.5,
                              ),
                            )
                          : Icon(
                              Icons.send_outlined,
                              color: AppColors.onPrimary(context),
                              size: 18,
                            ),
                      label: Text(
                        _enviando ? 'Enviando...' : 'Enviar recomendación',
                        style: TextStyle(
                          color: AppColors.onPrimary(context),
                          fontSize: isSmall ? 15 : 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary(context),
                        disabledBackgroundColor: AppColors.textHint(context),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: screenH * 0.015),

                // ── Ver mis recomendaciones ───────────────
                Center(
                  child: TextButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/mis-recomendaciones'),
                    icon: Icon(
                      Icons.list_alt_outlined,
                      size: 18,
                      color: AppColors.primary(context),
                    ),
                    label: Text(
                      'Ver mis recomendaciones',
                      style: TextStyle(
                        color: AppColors.primary(context),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: screenH * 0.020),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Builder(
      builder: (context) => Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary(context),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required bool isSmall,
    int maxLines = 1,
    String? errorText,
    required VoidCallback onChanged,
  }) {
    return Builder(
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.background(context),
          borderRadius: BorderRadius.circular(12),
          border: errorText != null
              ? Border.all(color: AppColors.error(context), width: 1.2)
              : null,
        ),
        child: TextField(
          controller: controller,
          maxLines: maxLines,
          onChanged: (_) => onChanged(),
          style: TextStyle(
            fontSize: isSmall ? 13 : 15,
            color: AppColors.textPrimary(context),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: isSmall ? 12 : 14,
              color: AppColors.textHint(context),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Selector de categoría (fuente de verdad: la API) ────────────────────
class _SelectorCategoria extends StatelessWidget {
  final Categoria? seleccionada;
  final String? error;
  final ValueChanged<Categoria> onSeleccionar;

  const _SelectorCategoria({
    required this.seleccionada,
    required this.error,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoriasProvider>(
      builder: (context, categoriasProvider, _) {
        if (categoriasProvider.status == CategoriasStatus.loading) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.background(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Cargando categorías...',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          );
        }

        final categorias = categoriasProvider.categoriasDeDestinos;

        if (categoriasProvider.status == CategoriasStatus.error ||
            categorias.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.background(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 16,
                  color: AppColors.error(context),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'No se pudieron cargar las categorías.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.error(context),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => categoriasProvider.cargar(),
                  child: Text(
                    'Reintentar',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary(context),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: AppColors.background(context),
            borderRadius: BorderRadius.circular(12),
            border: error != null
                ? Border.all(color: AppColors.error(context), width: 1.2)
                : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Categoria>(
              isExpanded: true,
              value: seleccionada,
              hint: Text(
                'Seleccionar categoría',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textHint(context),
                ),
              ),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.textSecondary(context),
              ),
              items: categorias
                  .map(
                    (categoria) => DropdownMenuItem<Categoria>(
                      value: categoria,
                      child: Text(
                        categoria.nombre,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (categoria) {
                if (categoria != null) onSeleccionar(categoria);
              },
            ),
          ),
        );
      },
    );
  }
}

// ── Estado de ubicación (GPS automático + ajuste manual en mapa) ────────
class _EstadoUbicacion extends StatelessWidget {
  final bool obteniendo;
  final UbicacionSeleccionada? ubicacion;
  final String? error;
  final VoidCallback onReintentar;
  final VoidCallback onAjustarEnMapa;

  const _EstadoUbicacion({
    required this.obteniendo,
    required this.ubicacion,
    required this.error,
    required this.onReintentar,
    required this.onAjustarEnMapa,
  });

  @override
  Widget build(BuildContext context) {
    final disponible = ubicacion != null;

    late final IconData icono;
    late final Color color;
    late final String texto;

    if (obteniendo) {
      icono = Icons.my_location_outlined;
      color = AppColors.textSecondary(context);
      texto = 'Obteniendo tu ubicación...';
    } else if (error != null && !disponible) {
      icono = Icons.location_off_outlined;
      color = AppColors.error(context);
      texto = error!;
    } else if (disponible) {
      icono = Icons.location_on;
      color = AppColors.primary(context);
      texto = 'Ubicación seleccionada';
    } else {
      icono = Icons.location_searching;
      color = AppColors.textSecondary(context);
      texto = 'Ubicación no disponible';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Row(
            key: ValueKey('$obteniendo-$disponible-$error'),
            children: [
              if (obteniendo)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color,
                  ),
                )
              else
                Icon(icono, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  texto,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              if (!obteniendo && error != null && !disponible)
                GestureDetector(
                  onTap: onReintentar,
                  child: Text(
                    'Reintentar',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary(context),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (disponible) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.place_outlined,
                  size: 16,
                  color: AppColors.primary(context),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ubicacion!.resumen,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      Text(
                        '${ubicacion!.latitude.toStringAsFixed(5)}, '
                        '${ubicacion!.longitude.toStringAsFixed(5)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        if (!obteniendo) ...[
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onAjustarEnMapa,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.map_outlined,
                  size: 16,
                  color: AppColors.primary(context),
                ),
                const SizedBox(width: 6),
                Text(
                  disponible ? 'Ajustar en el mapa' : 'Elegir en el mapa',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ── Selector de fotografías (1 a 5) ──────────────────────────────────────
class _SelectorFotos extends StatelessWidget {
  final List<XFile> fotos;
  final VoidCallback onAgregar;
  final void Function(int index) onQuitar;
  final String? error;

  const _SelectorFotos({
    required this.fotos,
    required this.onAgregar,
    required this.onQuitar,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    final puedeAgregarMas =
        fotos.length < AppConstants.destinationProposalMaxImages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 88,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              if (puedeAgregarMas)
                GestureDetector(
                  onTap: onAgregar,
                  child: Container(
                    width: 88,
                    height: 88,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: AppColors.background(context),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: error != null
                            ? AppColors.error(context)
                            : AppColors.borderSubtle(context),
                        width: error != null ? 1.2 : 1,
                      ),
                    ),
                    child: Icon(
                      Icons.add_a_photo_outlined,
                      color: AppColors.primary(context),
                    ),
                  ),
                ),
              for (var i = 0; i < fotos.length; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(
                          File(fotos[i].path),
                          width: 88,
                          height: 88,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 88,
                            height: 88,
                            color: AppColors.primaryContainer(context),
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: AppColors.primary(context),
                            ),
                          ),
                        ),
                      ),
                      if (i == 0)
                        Positioned(
                          left: 4,
                          bottom: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Portada',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        right: 2,
                        top: 2,
                        child: GestureDetector(
                          onTap: () => onQuitar(i),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 6),
          Text(
            error!,
            style: TextStyle(fontSize: 12, color: AppColors.error(context)),
          ),
        ],
      ],
    );
  }
}
