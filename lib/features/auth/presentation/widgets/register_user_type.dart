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
          'TIPO DE USUARIO',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2E7D32),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFEAF7EA),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFB2DFDB), width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selected,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF4CAF50),
              ),
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF2E7D32),
                fontFamily: 'Poppins',
              ),
              dropdownColor: const Color(0xFFEAF7EA),
              borderRadius: BorderRadius.circular(12),
              items: const [
                DropdownMenuItem(
                  value: 'Turista Nacional',
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        color: Color(0xFF4CAF50),
                        size: 18,
                      ),
                      SizedBox(width: 10),
                      Text('Turista Nacional'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'Turista Extranjero',
                  child: Row(
                    children: [
                      Icon(
                        Icons.flight_outlined,
                        color: Color(0xFF4CAF50),
                        size: 18,
                      ),
                      SizedBox(width: 10),
                      Text('Turista Extranjero'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'Habitante Local',
                  child: Row(
                    children: [
                      Icon(
                        Icons.home_outlined,
                        color: Color(0xFF4CAF50),
                        size: 18,
                      ),
                      SizedBox(width: 10),
                      Text('Habitante Local'),
                    ],
                  ),
                ),
              ],
              onChanged: (val) {
                if (val != null) onChanged(val);
              },
            ),
          ),
        ),
      ],
    );
  }
}
