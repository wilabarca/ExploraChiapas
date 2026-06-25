import 'package:flutter/material.dart';

enum BubbleType { bot, user }

class ChatBubble extends StatelessWidget {
  final String mensaje;
  final String hora;
  final BubbleType tipo;

  const ChatBubble({
    super.key,
    required this.mensaje,
    required this.hora,
    required this.tipo,
  });

  @override
  Widget build(BuildContext context) {
    final esUsuario = tipo == BubbleType.user;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment:
            esUsuario ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: esUsuario
                  ? const Color(0xFF2E7D32)
                  : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(esUsuario ? 18 : 4),
                bottomRight: Radius.circular(esUsuario ? 4 : 18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              mensaje,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: esUsuario ? Colors.white : const Color(0xFF1B1B1B),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hora,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }
}