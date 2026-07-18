import 'package:flutter/material.dart';
import '../providers/promociones_provider.dart';

class PromocionesFiltroBar extends StatelessWidget {
  final PromocionesFiltro filtroActivo;
  final ValueChanged<PromocionesFiltro> onFiltroChanged;

  const PromocionesFiltroBar({
    super.key,
    required this.filtroActivo,
    required this.onFiltroChanged,
  });

  static const _opciones = [
    (PromocionesFiltro.activas, 'Vigentes'),
    (PromocionesFiltro.proximas, 'Próximas'),
    (PromocionesFiltro.finalizadas, 'Historial'),
  ];

  @override
  Widget build(BuildContext context) {
    // Wrap: los chips fluyen a la siguiente línea si no caben.
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _opciones.map((opcion) {
        final (valor, label) = opcion;
        final activo = valor == filtroActivo;

        return GestureDetector(
          onTap: () => onFiltroChanged(valor),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: activo ? const Color(0xFF2E7D32) : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: activo
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFDDDDDD),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: activo ? Colors.white : const Color(0xFF555555),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
