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
        Row(
          children: [
            _TypeChip(
              label: 'Turista',
              isSelected: selected == 'Turista',
              onTap: () => onChanged('Turista'),
            ),
            const SizedBox(width: 10),
            _TypeChip(
              label: 'Habitante Local',
              isSelected: selected == 'Habitante Local',
              onTap: () => onChanged('Habitante Local'),
            ),
          ],
        ),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4CAF50) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF4CAF50),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF4CAF50),
          ),
        ),
      ),
    );
  }
}