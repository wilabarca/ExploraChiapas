import 'package:flutter/material.dart';

class EventosBanner extends StatelessWidget {
  final VoidCallback? onExplorar;

  const EventosBanner({super.key, this.onExplorar});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 560;
        return AspectRatio(
          aspectRatio: isTablet ? 4.2 / 1.6 : 2.6 / 1.6,
          child: Container(
            padding: EdgeInsets.all(isTablet ? 24 : 18),
            decoration: BoxDecoration(
              color: const Color(0xFFDDEFDD),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -10,
                  bottom: -10,
                  child: Icon(
                    Icons.fact_check_outlined,
                    size: isTablet ? 90 : 70,
                    color: Colors.black.withOpacity(0.06),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Descubrir eventos locales próximos',
                      style: TextStyle(
                        fontSize: isTablet ? 20 : 16.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: Text(
                        'Festivales, talleres artesanales y ceremonias '
                        'tradicionales esta semana.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12.5,
                          color: Colors.black54,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // 🟢 Aquí el cambio: InkWell → GestureDetector
                    GestureDetector(
                      onTap: onExplorar,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Explorar',
                            style: TextStyle(
                              fontSize: 14, // tal como pediste
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward,
                            size: 16, // tal como pediste
                            color: Color(0xFF2E7D32),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
