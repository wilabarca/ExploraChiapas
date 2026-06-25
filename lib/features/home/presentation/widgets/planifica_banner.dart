import 'package:flutter/material.dart';

class PlanificaBanner extends StatelessWidget {
  const PlanificaBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FAF0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD8F5D8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.auto_awesome, color: Color(0xFF2E7D32), size: 14),
              SizedBox(width: 6),
              Text(
                'PLANIFICA TU AVENTURA',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2E7D32),
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Descubre la magia de\nChiapas a tu ritmo.',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B1B1B),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Creamos una ruta personalizada basada en tus gustos: naturaleza, cultura o gastronomía.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF666666),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              // ← navega al chat
              onPressed: () => Navigator.pushNamed(context, '/chat'),
              icon: const Icon(Icons.route, color: Colors.white, size: 18),
              label: const Text(
                'Crear mi ruta personalizada',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.chat_bubble_outline,
                color: Color(0xFF2E7D32),
                size: 13,
              ),
              const SizedBox(width: 6),
              GestureDetector(
                // ← también navega al chat
                onTap: () => Navigator.pushNamed(context, '/chat'),
                child: const Text(
                  'Habla con nuestro guía inteligente',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.w500,
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
