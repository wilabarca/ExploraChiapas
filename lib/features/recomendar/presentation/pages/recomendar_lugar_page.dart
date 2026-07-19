import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class RecomendarLugarPage extends StatefulWidget {
  const RecomendarLugarPage({super.key});

  @override
  State<RecomendarLugarPage> createState() => _RecomendarLugarPageState();
}

class _RecomendarLugarPageState extends State<RecomendarLugarPage> {
  final _nombreCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _ubicacionCtrl = TextEditingController();

  String _categoriaSeleccionada = 'Naturaleza';
  bool _isLoading = false;

  final List<String> _categorias = [
    'Naturaleza',
    'Cultura',
    'Gastronomía',
    'Aventura',
  ];

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    _ubicacionCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviarSugerencia() async {
    if (_nombreCtrl.text.isEmpty || _descripcionCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Completa nombre y descripción'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('¡Sugerencia enviada! Gracias por contribuir.'),
        backgroundColor: AppColors.primary(context),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenW = mq.size.width;
    final screenH = mq.size.height;
    final isSmall = screenW < 360;

    return Scaffold(
      backgroundColor: AppColors.surface(context),
      appBar: AppBar(
        backgroundColor: AppColors.surface(context),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B5E20)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Recomendar Lugar',
          style: TextStyle(
            color: Color(0xFF1B5E20),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: constraints.maxWidth * 0.05,
              vertical: screenH * 0.020,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Banner informativo ────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F8F1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'Ayúdanos a descubrir los tesoros de Chiapas. '
                    'Tu sugerencia será revisada por nuestro equipo '
                    'para ser parte de las rutas exclusivas de Selva Moderna.',
                    style: TextStyle(
                      fontSize: isSmall ? 12 : 14,
                      color: const Color(0xFF444444),
                      height: 1.5,
                    ),
                  ),
                ),

                SizedBox(height: screenH * 0.025),

                // ── Nombre del lugar ──────────────────────
                _buildLabel('Nombre del lugar'),
                SizedBox(height: screenH * 0.010),
                _buildTextField(
                  controller: _nombreCtrl,
                  hint: 'Ej. Cascadas de Agua Azul',
                  isSmall: isSmall,
                ),

                SizedBox(height: screenH * 0.022),

                // ── Descripción ───────────────────────────
                _buildLabel('Descripción'),
                SizedBox(height: screenH * 0.010),
                _buildTextField(
                  controller: _descripcionCtrl,
                  hint: 'Cuéntanos por qué este lugar es especial...',
                  maxLines: 5,
                  isSmall: isSmall,
                ),

                SizedBox(height: screenH * 0.022),

                // ── Categoría con Wrap ────────────────────
                _buildLabel('Categoría'),
                SizedBox(height: screenH * 0.012),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: _categorias.map((cat) {
                    final isSelected = cat == _categoriaSeleccionada;
                    return GestureDetector(
                      onTap: () => setState(() => _categoriaSeleccionada = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary(context)
                              : AppColors.surface(context),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary(context)
                                : AppColors.textHint(context),
                          ),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: isSmall ? 12 : 14,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary(context),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: screenH * 0.022),

                // ── Dirección / Ubicación ─────────────────
                _buildLabel('Dirección o Ubicación'),
                SizedBox(height: screenH * 0.010),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.background(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _ubicacionCtrl,
                    style: TextStyle(
                      fontSize: isSmall ? 13 : 15,
                      color: AppColors.textPrimary(context),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Calle, ciudad o coordenadas',
                      hintStyle: TextStyle(color: AppColors.textHint(context)),
                      prefixIcon: Icon(
                        Icons.location_on_outlined,
                        color: AppColors.primary(context),
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: screenH * 0.022),

                // ── Subir fotografías ─────────────────────
                _buildLabel('Subir fotografías'),
                SizedBox(height: screenH * 0.010),
                AspectRatio(
                  aspectRatio: 16 / 7,
                  child: GestureDetector(
                    onTap: () {}, // TODO: image picker
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.background(context),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.textHint(context),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_outlined,
                            color: AppColors.primary(context),
                            size: 32,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Presiona para subir fotos',
                            style: TextStyle(
                              color: AppColors.primary(context),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'MÁXIMO 5 IMÁGENES (JPG, PNG)',
                            style: TextStyle(
                              color: AppColors.textHint(context),
                              fontSize: 11,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: screenH * 0.030),

                // ── Botón enviar ──────────────────────────
                FractionallySizedBox(
                  widthFactor: 1.0,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 54),
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _enviarSugerencia,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Icon(
                              Icons.send_outlined,
                              color: Colors.white,
                              size: 18,
                            ),
                      label: Text(
                        _isLoading ? 'Enviando...' : 'Enviar sugerencia',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmall ? 15 : 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary(context),
                        disabledBackgroundColor: const Color(0xFFB0BEC5),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: screenH * 0.022),

                // ── Banner inspiración ────────────────────
                AspectRatio(
                  aspectRatio: 16 / 7,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          'https://images.unsplash.com/photo-1518638150340-f706e86654de?w=800&q=80',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(color: const Color(0xFF1B5E20)),
                        ),
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
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Inspiración Chiapas',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmall ? 16 : 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Tus recomendaciones ayudan a otros viajeros.',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: screenH * 0.020),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Builder(
      builder: (context) => Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary(context),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required bool isSmall,
    int maxLines = 1,
  }) {
    return Builder(
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.background(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(
            fontSize: isSmall ? 13 : 15,
            color: AppColors.textPrimary(context),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textHint(context)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }
}
