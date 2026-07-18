import 'package:flutter/material.dart';

import '../../domain/entities/resena_entity.dart';
import 'star_rating.dart';

/// ⚠️ Este archivo reemplaza tanto a tu `resena_card.dart` como a
/// `ResenaCard.dart` — tenías los dos en el árbol y eso puede causar
/// conflictos de clase duplicada. Borra el otro (el de mayúscula) y deja
/// solo este.
///
/// La API solo devuelve `userId`, no nombre ni foto del usuario, así que
/// mostramos un ícono genérico.
class ResenaCard extends StatelessWidget {
  final Resena resena;

  const ResenaCard({super.key, required this.resena});

  String _formatearFecha(DateTime fecha) {
    const meses = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
    ];
    return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFFD8F5D8),
                child: Icon(Icons.person, color: Color(0xFF2E7D32), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StarRating(rating: resena.rating.toDouble(), size: 14),
                    const SizedBox(height: 2),
                    Text(
                      _formatearFecha(resena.createdAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF888888),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (resena.comment != null && resena.comment!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              resena.comment!,
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF444444),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}