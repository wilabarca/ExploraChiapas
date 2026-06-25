import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class InterestCard extends StatelessWidget {
  final String nombre;
  final IconData icono;
  final String imageUrl;
  final bool isSelected;
  final VoidCallback onTap;

  // ✓ Sin width/height fijos — usa LayoutBuilder internamente
  const InterestCard({
    super.key,
    required this.nombre,
    required this.icono,
    required this.imageUrl,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: const Color(0xFF4CAF50), width: 3)
              : null,
        ),
        // ✓ LayoutBuilder: adapta contenido al espacio real disponible
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(isSelected ? 14 : 16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Imagen de fondo
                  CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: const Color(0xFF2E7D32)),
                    errorWidget: (_, __, ___) => Container(
                      color: const Color(0xFF2E7D32),
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.white54,
                      ),
                    ),
                  ),

                  // Gradiente inferior
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.65),
                        ],
                        stops: const [0.4, 1.0],
                      ),
                    ),
                  ),

                  // Overlay verde si seleccionado
                  if (isSelected)
                    Container(color: const Color(0xFF2E7D32).withOpacity(0.30)),

                  // Ícono + nombre
                  Positioned(
                    bottom: 12,
                    left: 14,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icono, color: Colors.white, size: 20),
                        const SizedBox(height: 4),
                        Text(
                          nombre,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Check si seleccionado
                  if (isSelected)
                    const Positioned(
                      top: 10,
                      right: 10,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: Color(0xFF4CAF50),
                        child: Icon(Icons.check, color: Colors.white, size: 14),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
