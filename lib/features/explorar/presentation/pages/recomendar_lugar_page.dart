import 'package:flutter/material.dart';

class RecomendarLugarPage extends StatefulWidget {
  const RecomendarLugarPage({super.key});

  @override
  State<RecomendarLugarPage> createState() => _RecomendarLugarPageState();
}

class _RecomendarLugarPageState extends State<RecomendarLugarPage> {
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _ubicacionController = TextEditingController();
  String _categoriaSeleccionada = 'Naturaleza';
  bool _enviando = false;

  final List<String> _categorias = [
    'Naturaleza',
    'Cultura',
    'Gastronomía',
    'Aventura',
    'Descanso',
    'Otro',
  ];

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _ubicacionController.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (_nombreController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe el nombre del lugar')),
      );
      return;
    }
    if (_ubicacionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Indica la ubicación del lugar')),
      );
      return;
    }

    setState(() => _enviando = true);
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _enviando = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Gracias! Tu recomendación fue enviada para revisión.'),
        backgroundColor: Color(0xFF2E7D32),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B1B1B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Recomendar lugar',
          style: TextStyle(
            color: Color(0xFF1B1B1B),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline,
                      color: Color(0xFF2E7D32), size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Ayúdanos a descubrir los tesoros de Chiapas. Comparte un lugar especial que conozcas.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF1B5E20),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _Campo(
              label: 'Nombre del lugar',
              controller: _nombreController,
              hint: 'Ej: Cascada El Chiflón',
            ),
            const SizedBox(height: 16),
            _Campo(
              label: 'Ubicación',
              controller: _ubicacionController,
              hint: 'Municipio o dirección aproximada',
              icono: Icons.location_on_outlined,
            ),
            const SizedBox(height: 16),
            const Text(
              'Categoría',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1B1B1B),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categorias.map((cat) {
                final activa = cat == _categoriaSeleccionada;
                return GestureDetector(
                  onTap: () => setState(() => _categoriaSeleccionada = cat),
                  child: Chip(
                    label: Text(cat),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: activa ? Colors.white : const Color(0xFF555555),
                      fontWeight: FontWeight.w500,
                    ),
                    backgroundColor: activa
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFF0F0F0),
                    side: BorderSide.none,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Descripción (opcional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1B1B1B),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descripcionController,
              maxLines: 4,
              maxLength: 300,
              decoration: InputDecoration(
                hintText:
                    'Cuéntanos más sobre este lugar: qué hace especial, cómo llegar, etc.',
                hintStyle:
                    const TextStyle(color: Color(0xFFBBBBBB), fontSize: 13),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2E7D32)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _enviando ? null : _enviar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _enviando
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Enviar recomendación',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _Campo extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData icono;

  const _Campo({
    required this.label,
    required this.controller,
    required this.hint,
    this.icono = Icons.edit_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1B1B1B),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                const TextStyle(color: Color(0xFFBBBBBB), fontSize: 13),
            prefixIcon: Icon(icono, color: const Color(0xFF2E7D32), size: 20),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2E7D32)),
            ),
          ),
        ),
      ],
    );
  }
}
