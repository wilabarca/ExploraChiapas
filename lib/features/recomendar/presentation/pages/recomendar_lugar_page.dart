import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/permissions/location_permission.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/validation/input_sanitizer.dart';
import '../providers/recomendar_provider.dart';
import '../widgets/recomendar_result_dialogs.dart';

class RecomendarLugarPage extends StatefulWidget {
  const RecomendarLugarPage({super.key});

  @override
  State<RecomendarLugarPage> createState() => _RecomendarLugarPageState();
}

class _RecomendarLugarPageState extends State<RecomendarLugarPage> {
  final _descripcionCtrl = TextEditingController();

  String? _errorDescripcion;
  bool _obteniendoUbicacion = false;
  String? _ubicacionError;
  double? _lat;
  double? _lng;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _obtenerUbicacion());
  }

  @override
  void dispose() {
    _descripcionCtrl.dispose();
    super.dispose();
  }

  Future<void> _obtenerUbicacion() async {
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
            'Necesitamos tu ubicación para enviar la recomendación.';
      });
      return;
    }

    final posicion = await LocationService().getCurrentPosition();
    if (!mounted) return;

    setState(() {
      _obteniendoUbicacion = false;
      if (posicion != null) {
        _lat = posicion.latitude;
        _lng = posicion.longitude;
      } else {
        _ubicacionError =
            'No pudimos obtener tu ubicación actual. '
            'Verifica que el GPS esté activado.';
      }
    });
  }

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
    final texto = InputSanitizer.limpiar(_descripcionCtrl.text);
    final errorTexto = InputSanitizer.validarTexto(
      texto,
      etiqueta: 'La descripción del lugar',
      minLength: 10,
      maxLength: 255,
    );

    setState(() => _errorDescripcion = errorTexto);
    if (errorTexto != null) return false;

    if (_lat == null || _lng == null) {
      if (!_obteniendoUbicacion) {
        await _obtenerUbicacion();
        if (!mounted) return false;
      }
      if (_lat == null || _lng == null) {
        return mostrarErrorSugerenciaDialog(
          context,
          mensaje:
              _ubicacionError ??
              'No pudimos determinar tu ubicación. Actívala e inténtalo de nuevo.',
        );
      }
    }

    final provider = context.read<RecomendarProvider>();

    // No se espera este Future: solo muestra el overlay de carga y
    // retorna de inmediato para poder seguir con la petición al backend.
    // Se cierra explícitamente más abajo con Navigator.pop.
    mostrarEnviandoSugerenciaDialog(context);

    final exito = await provider.enviarSugerencia(
      latitude: _lat!,
      longitude: _lng!,
      address: texto,
    );

    if (!mounted) return false;
    Navigator.of(context, rootNavigator: true).pop(); // cierra el loading
    if (!mounted) return false;

    if (exito) {
      await mostrarSugerenciaEnviadaSheet(context);
      if (!mounted) return false;
      Navigator.pop(context);
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
    return (mensaje != null && mensaje.isNotEmpty)
        ? mensaje
        : 'Ha ocurrido un problema. Inténtalo nuevamente.';
  }

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
          'Recomendar Lugar',
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
                        Icons.info_outline,
                        size: 18,
                        color: AppColors.onPrimaryContainer(context),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Ayúdanos a descubrir los tesoros de Chiapas. '
                          'Comparte un lugar especial cerca de tu ubicación '
                          'actual; nuestro equipo lo revisará antes de '
                          'publicarlo.',
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

                SizedBox(height: screenH * 0.02),

                _EstadoUbicacion(
                  obteniendo: _obteniendoUbicacion,
                  disponible: _lat != null && _lng != null,
                  error: _ubicacionError,
                  onReintentar: _obtenerUbicacion,
                ),

                SizedBox(height: screenH * 0.025),

                // ── Descripción del lugar ─────────────────
                _buildLabel('Describe el lugar'),
                SizedBox(height: screenH * 0.010),
                _buildTextField(
                  controller: _descripcionCtrl,
                  hint:
                      'Ej. Cascada El Chiflón, a 15 min caminando desde '
                      'el centro...',
                  maxLines: 4,
                  isSmall: isSmall,
                  errorText: _errorDescripcion,
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

                SizedBox(height: screenH * 0.022),

                // ── Banner inspiración ────────────────────
                AspectRatio(
                  aspectRatio: 16 / 7,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          'https://images.unsplash.com/photo-1518638150340-f706e86654de?w=800&q=80',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(color: AppColors.primary(context)),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.65),
                              ],
                              stops: const [0.4, 1.0],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Inspiración Chiapas',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmall ? 16 : 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Tus recomendaciones ayudan a otros viajeros.',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
          onChanged: (_) {
            if (_errorDescripcion != null) {
              setState(() => _errorDescripcion = null);
            } else {
              // Solo para refrescar el contador de caracteres.
              setState(() {});
            }
          },
          style: TextStyle(
            fontSize: isSmall ? 13 : 15,
            color: AppColors.textPrimary(context),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textHint(context)),
            // Evita heredar el "filled: true" del tema global (rectángulo
            // cuadrado de fondo).
            filled: false,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }
}

/// Chip de estado de la ubicación GPS: obteniendo / disponible / error.
class _EstadoUbicacion extends StatelessWidget {
  final bool obteniendo;
  final bool disponible;
  final String? error;
  final VoidCallback onReintentar;

  const _EstadoUbicacion({
    required this.obteniendo,
    required this.disponible,
    required this.error,
    required this.onReintentar,
  });

  @override
  Widget build(BuildContext context) {
    late final IconData icono;
    late final Color color;
    late final String texto;

    if (obteniendo) {
      icono = Icons.my_location_outlined;
      color = AppColors.textSecondary(context);
      texto = 'Obteniendo tu ubicación...';
    } else if (error != null) {
      icono = Icons.location_off_outlined;
      color = AppColors.error(context);
      texto = error!;
    } else if (disponible) {
      icono = Icons.location_on;
      color = AppColors.primary(context);
      texto = 'Ubicación detectada';
    } else {
      icono = Icons.location_searching;
      color = AppColors.textSecondary(context);
      texto = 'Ubicación no disponible';
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Row(
        key: ValueKey('$obteniendo-$disponible-$error'),
        children: [
          if (obteniendo)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: color),
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
          if (!obteniendo && (error != null || !disponible))
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
    );
  }
}
