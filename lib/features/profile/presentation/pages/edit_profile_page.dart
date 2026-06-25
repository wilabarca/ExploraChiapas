import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nombreCtrl = TextEditingController(text: 'Santuario Chiapas');
  final _emailCtrl  = TextEditingController(text: 'santuario@chiapas.travel');
  bool _isLoading   = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Perfil actualizado correctamente.'),
        backgroundColor: Color(0xFF2E7D32),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color(0xFF2E7D32)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Editar Perfil',
          style: TextStyle(
            color: Color(0xFF2E7D32),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 24),

            // Avatar con cámara
            Stack(
              children: [
                CircleAvatar(
                  radius: 56,
                  backgroundColor: const Color(0xFFD8F5D8),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: 'https://i.pravatar.cc/150?img=15',
                      width: 112,
                      height: 112,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const Icon(
                        Icons.person,
                        size: 56,
                        color: Color(0xFF2E7D32),
                      ),
                      errorWidget: (_, __, ___) => const Icon(
                        Icons.person,
                        size: 56,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2E7D32),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            const Text(
              'CAMBIAR FOTO DE PERFIL',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF888888),
                letterSpacing: 1.1,
              ),
            ),

            const SizedBox(height: 28),

            // Tipo de usuario (solo lectura)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Turista Local',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF888888),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Nombre
            _EditField(
              label: 'Nombre completo',
              icono: Icons.person_outline,
              controller: _nombreCtrl,
            ),

            const SizedBox(height: 16),

            // Correo
            _EditField(
              label: 'Correo electrónico',
              icono: Icons.email_outlined,
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 16),

            // Contraseña
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FAF0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD8F5D8)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      color: Color(0xFF2E7D32),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contraseña',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '••••••••••••',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1B1B1B),
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'CAMBIAR',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Nota informativa
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FAF0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD8F5D8)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline,
                      color: Color(0xFF2E7D32), size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tu información se utiliza para personalizar tus planes de viaje y reservas en parques naturales.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF555555),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Botón guardar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _guardarCambios,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  disabledBackgroundColor: const Color(0xFFB0BEC5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Guardar cambios',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  final String label;
  final IconData icono;
  final TextEditingController controller;
  final TextInputType keyboardType;

  const _EditField({
    required this.label,
    required this.icono,
    required this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icono, size: 16, color: const Color(0xFF888888)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF888888),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF1B1B1B),
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: Color(0xFF4CAF50), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}