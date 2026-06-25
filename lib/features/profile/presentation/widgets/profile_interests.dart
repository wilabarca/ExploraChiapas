import 'package:flutter/material.dart';

class ProfileInterests extends StatelessWidget {
  const ProfileInterests({super.key});

  @override
  Widget build(BuildContext context) {
    final intereses = [
      'Naturaleza',
      'Gastronomía',
      'Cultura',
      'Aventura',
      'Descanso',
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mis Intereses',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B1B1B),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const Row(
                  children: [
                    Icon(Icons.edit_outlined,
                        size: 14, color: Color(0xFF2E7D32)),
                    SizedBox(width: 4),
                    Text(
                      'Editar',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: intereses.map((interes) {
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FAF0),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD8F5D8)),
                ),
                child: Text(
                  interes,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}