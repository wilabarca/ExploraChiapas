import 'package:flutter/material.dart';

/// Antes mostraba los chips de "Mis intereses" (campo que la entidad real
/// no tiene). Ahora muestra los datos de contacto/registro que sí trae
/// `PerfilEntity`: teléfono y fecha de registro.
///
/// `Wrap` se mantiene por si en el futuro agregas más campos (ej. ciudad,
/// intereses reales desde otro endpoint) y no caben en una sola fila.
class ProfileContactInfo extends StatelessWidget {
  final String? telefono;
  final DateTime registeredAt;

  const ProfileContactInfo({
    super.key,
    required this.telefono,
    required this.registeredAt,
  });

  @override
  Widget build(BuildContext context) {
    final items = <_InfoItem>[
      _InfoItem(
        icon: Icons.phone_outlined,
        label: 'Teléfono',
        value: (telefono == null || telefono!.isEmpty) ? 'No registrado' : telefono!,
      ),
      _InfoItem(
        icon: Icons.calendar_today_outlined,
        label: 'Miembro desde',
        value: _formatearFecha(registeredAt),
      ),
    ];

    return Wrap(
      spacing: 20,
      runSpacing: 12,
      children: items.map((item) {
        return SizedBox(
          width: 150,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(item.icon, size: 18, color: const Color(0xFF2E7D32)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF999999)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.value,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1B1B1B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatearFecha(DateTime fecha) {
    const meses = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
    ];
    return '${fecha.day} ${meses[fecha.month - 1]}. ${fecha.year}';
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({required this.icon, required this.label, required this.value});
}