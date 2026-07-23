import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/destination_entity.dart';
import '../../../../core/theme/app_colors.dart';

class DestinationBottomSheet extends StatelessWidget {
  final DestinationEntity destino;
  final VoidCallback onVerRuta;
  final VoidCallback onGuardar;
  final VoidCallback onCerrar;

  const DestinationBottomSheet({
    super.key,
    required this.destino,
    required this.onVerRuta,
    required this.onGuardar,
    required this.onCerrar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderSubtle(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destino.nombre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded,
                                color: Color(0xFFFFC107), size: 16),
                            const SizedBox(width: 4),
                            Text(
                              destino.calificacion.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary(context),
                              ),
                            ),
                          ],
                        ),
                        _TipoBadge(tipo: destino.tipo),
                        if (destino.esMock)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Muestra',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Close + eco badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: onCerrar,
                    child: Icon(Icons.close,
                        size: 20, color: AppColors.textSecondary(context)),
                  ),
                  if (destino.esSostenible) ...[
                    const SizedBox(height: 6),
                    Tooltip(
                      message:
                          'Destino con baja afluencia: experiencia tranquila',
                      child: Icon(Icons.eco,
                          color: AppColors.primary(context), size: 24),
                    ),
                  ],
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Crowd level bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Afluencia actual',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary(context)),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (destino.afluencia > 75)
                        const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(Icons.warning_amber_rounded,
                              size: 14, color: Colors.orange),
                        ),
                      Text(
                        destino.afluencia > 75 ? 'Alta' : 'Normal',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: destino.afluencia > 75
                              ? Colors.orange
                              : AppColors.primary(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: destino.afluencia / 100,
                  minHeight: 6,
                  backgroundColor: AppColors.surfaceContainer(context),
                  valueColor: AlwaysStoppedAnimation(
                    destino.afluencia > 75
                        ? Colors.orange
                        : AppColors.primary(context),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            destino.descripcion,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary(context),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onGuardar,
                  icon: Icon(Icons.bookmark_border,
                      color: AppColors.primary(context)),
                  label: Text(
                    'Guardar',
                    style: TextStyle(color: AppColors.primary(context)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primary(context)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onVerRuta,
                  icon: const Icon(Icons.directions, color: Colors.white),
                  label: const Text('Ver ruta',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary(context),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.share_outlined),
                color: AppColors.textSecondary(context),
                tooltip: 'Compartir',
                onPressed: () {
                  Share.share(
                    '¡Visita ${destino.nombre} en ExploraChiapas!\n${destino.descripcion}',
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TipoBadge extends StatelessWidget {
  final String tipo;
  const _TipoBadge({required this.tipo});

  // Softer background colors (same palette, reduced saturation)
  static const _fondos = {
    'naturaleza':  Color(0xFFE8F5E9),
    'cultura':     Color(0xFFE3F2FD),
    'gastronomia': Color(0xFFFFF3E0),
    'aventura':    Color(0xFFF3E5F5),
    'descanso':    Color(0xFFE0F7FA),
  };
  static const _fondosDark = {
    'naturaleza':  Color(0xFF1B3A1C),
    'cultura':     Color(0xFF0D253A),
    'gastronomia': Color(0xFF3A2200),
    'aventura':    Color(0xFF2A0B3A),
    'descanso':    Color(0xFF003A40),
  };
  static const _textos = {
    'naturaleza':  Color(0xFF43A047),
    'cultura':     Color(0xFF1976D2),
    'gastronomia': Color(0xFFEF6C00),
    'aventura':    Color(0xFF7B1FA2),
    'descanso':    Color(0xFF00ACC1),
  };
  static const _iconos = {
    'naturaleza':  Icons.park_outlined,
    'cultura':     Icons.account_balance_outlined,
    'gastronomia': Icons.restaurant_outlined,
    'aventura':    Icons.terrain_outlined,
    'descanso':    Icons.spa_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final fondo = isDark
        ? (_fondosDark[tipo] ?? const Color(0xFF1B3A1C))
        : (_fondos[tipo] ?? const Color(0xFFE8F5E9));
    final texto = _textos[tipo] ?? const Color(0xFF43A047);
    final icono = _iconos[tipo] ?? Icons.place_outlined;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 12, color: texto),
          const SizedBox(width: 4),
          Text(
            tipo[0].toUpperCase() + tipo.substring(1),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: texto,
            ),
          ),
        ],
      ),
    );
  }
}
