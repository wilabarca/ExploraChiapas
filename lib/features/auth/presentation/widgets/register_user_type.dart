import 'package:flutter/material.dart';

class RegisterUserType extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const RegisterUserType({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TIPOS DE USUARIO',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2E7D32),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),

        // Wrap: los chips fluyen automaticamente si no caben en una linea
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children:
              ['Turista Nacional', 'Turista Extranjero', 'Habitante Local'].map(
                (tipo) {
                  final isSelected = selected == tipo;
                  return GestureDetector(
                    onTap: () => onChanged(tipo),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF4CAF50)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF4CAF50),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        tipo,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF4CAF50),
                        ),
                      ),
                    ),
                  );
                },
              ).toList(),
        ),
      ],
    );
  }
}
