import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/resena_entity.dart';
import '../widgets/star_rating.dart';

class EscribirResenaPage extends StatefulWidget {
  final DestinoResenaEntity destino;

  const EscribirResenaPage({super.key, required this.destino});

  @override
  State<EscribirResenaPage> createState() => _EscribirResenaPageState();
}

class _EscribirResenaPageState extends State<EscribirResenaPage> {
  double _calificacion = 0;
  final _comentarioCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _comentarioCtrl.dispose();
    super.dispose();
  }

  Future<void> _publicarResena() async {
    if (_calificacion == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una calificación'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
      return;
    }

    if (_comentarioCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor escribe un comentario'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    // TODO: conectar con la API
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Reseña publicada exitosamente!'),
        backgroundColor: Color(0xFF2E7D32),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2E7D32)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'ExploraChiapas',
          style: TextStyle(
            color: Color(0xFF2E7D32),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // ── Imagen del destino ──────────────────────────────────────
            // ✓ AspectRatio para imagen proporcional
            AspectRatio(
              aspectRatio: 16 / 7,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: widget.destino.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(color: const Color(0xFFD8F5D8)),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.6),
                          ],
                          stops: const [0.4, 1.0],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.destino.esPopular)
                            Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E7D32),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'DESTINO POPULAR',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          Text(
                            widget.destino.nombre,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.white70,
                                size: 12,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                widget.destino.ubicacion,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: size.height * 0.04),

            // ── Calificación ────────────────────────────────────────────
            const Text(
              '¿Qué tal fue tu visita?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B1B1B),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Califica tu experiencia para ayudar a otros eco-viajeros.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
            ),

            SizedBox(height: size.height * 0.03),

            // Estrellas interactivas
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                return GestureDetector(
                  onTap: () =>
                      setState(() => _calificacion = (i + 1).toDouble()),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      i < _calificacion ? Icons.star : Icons.star_border,
                      color: i < _calificacion
                          ? const Color(0xFFFFC107)
                          : const Color(0xFFDDDDDD),
                      size: 42,
                    ),
                  ),
                );
              }),
            ),

            SizedBox(height: size.height * 0.03),

            // ── Comentario ──────────────────────────────────────────────
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                'TU COMENTARIO',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2E7D32),
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 10),
            // ✓ ConstrainedBox: área de texto con altura mínima garantizada
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 120),
              child: TextField(
                controller: _comentarioCtrl,
                maxLines: null,
                style: const TextStyle(fontSize: 14, color: Color(0xFF1B1B1B)),
                decoration: InputDecoration(
                  hintText:
                      'Comparte tu experiencia...\n¿Cómo estuvo el agua? ¿Viste fauna local?',
                  hintStyle: const TextStyle(
                    color: Color(0xFFAAAAAA),
                    fontSize: 14,
                    height: 1.6,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFF4CAF50),
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),

            SizedBox(height: size.height * 0.04),

            // ── Botón publicar ──────────────────────────────────────────
            // ✓ FractionallySizedBox: botón proporcional al ancho
            FractionallySizedBox(
              widthFactor: 1.0,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 54),
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _publicarResena,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Icon(Icons.send_rounded, color: Colors.white),
                  label: Text(
                    _isLoading ? 'Publicando...' : 'Publicar Reseña',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    disabledBackgroundColor: const Color(0xFFB0BEC5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: size.height * 0.04),
          ],
        ),
      ),
    );
  }
}
