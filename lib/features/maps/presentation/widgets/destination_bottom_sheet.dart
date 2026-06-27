import 'package:flutter/material.dart';
import '../../domain/entities/destination_entity.dart';

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
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                color: Colors.grey[300],
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
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B1B1B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Color(0xFFFFC107), size: 16),
                        const SizedBox(width: 4),
                        Text(
                          destino.calificacion.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _TipoBadge(tipo: destino.tipo),
                      ],
                    ),
                  ],
                ),
              ),
              if (destino.esSostenible)
                const Tooltip(
                  message: 'Destino con baja afluencia: experiencia tranquila',
                  child: Icon(Icons.eco, color: Color(0xFF2E7D32), size: 28),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Barra de afluencia
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Afluencia actual',
                    style: TextStyle(fontSize: 12, color: Color(0xFF777777)),
                  ),
                  Text(
                    destino.afluencia > 75 ? '⚠️ Alta' : 'Normal',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: destino.afluencia > 75
                          ? Colors.orange
                          : const Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: destino.afluencia / 100,
                  minHeight: 6,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation(
                    destino.afluencia > 75
                        ? Colors.orange
                        : const Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            destino.descripcion,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF555555),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onGuardar,
                  icon: const Icon(Icons.bookmark_border,
                      color: Color(0xFF2E7D32)),
                  label: const Text(
                    'Guardar',
                    style: TextStyle(color: Color(0xFF2E7D32)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF2E7D32)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onVerRuta,
                  icon: const Icon(Icons.directions, color: Colors.white),
                  label: const Text(
                    'Ver ruta',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
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

  static const _colores = {
    'naturaleza':  Color(0xFFE8F5E9),
    'cultura':     Color(0xFFE3F2FD),
    'gastronomia': Color(0xFFFFF3E0),
    'aventura':    Color(0xFFF3E5F5),
    'descanso':    Color(0xFFE0F7FA),
  };

  static const _textColores = {
    'naturaleza':  Color(0xFF2E7D32),
    'cultura':     Color(0xFF1565C0),
    'gastronomia': Color(0xFFE65100),
    'aventura':    Color(0xFF6A1B9A),
    'descanso':    Color(0xFF00838F),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: _colores[tipo] ?? const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        tipo[0].toUpperCase() + tipo.substring(1),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _textColores[tipo] ?? const Color(0xFF2E7D32),
        ),
      ),
    );
  }
}