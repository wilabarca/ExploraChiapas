import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nombreCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final perfil = context.read<ProfileProvider>().perfil;
    if (perfil != null) {
      _nombreCtrl.text = perfil.nombre;
      _telefonoCtrl.text = perfil.telefono ?? '';
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final provider = context.read<ProfileProvider>();
    final success = await provider.updatePerfil(
      nombre: _nombreCtrl.text.trim(),
      telefono: _telefonoCtrl.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Perfil actualizado correctamente'),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Error al actualizar'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        context.watch<ProfileProvider>().status == ProfileStatus.loading;
    final perfil = context.watch<ProfileProvider>().perfil;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B5E20)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Editar Perfil',
          style: TextStyle(
            color: Color(0xFF1B5E20),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          children: [
            // ── Avatar default ────────────────────────────────
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 54,
                  backgroundColor: const Color(0xFFE8F5E9),
                  child: const Icon(
                    Icons.person,
                    size: 54,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2E7D32),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            const Text(
              'CAMBIAR FOTO DE PERFIL',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2E7D32),
                letterSpacing: 1.2,
              ),
            ),

            const SizedBox(height: 28),

            // ── Tipo de usuario (solo lectura) ────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Text(
                perfil?.tipoUsuarioLabel ?? 'Turista',
                style: const TextStyle(fontSize: 15, color: Color(0xFF555555)),
              ),
            ),

            const SizedBox(height: 20),

            // ── Nombre ────────────────────────────────────────
            _buildLabel('Nombre completo', Icons.person_outline),
            const SizedBox(height: 8),
            _buildField(controller: _nombreCtrl, hint: 'Tu nombre completo'),

            const SizedBox(height: 20),

            // ── Email (solo lectura) ──────────────────────────
            _buildLabel('Correo electrónico', Icons.email_outlined),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Text(
                perfil?.email ?? '',
                style: const TextStyle(fontSize: 15, color: Color(0xFF555555)),
              ),
            ),

            const SizedBox(height: 20),

            // ── Contraseña (placeholder) ──────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      color: Color(0xFF2E7D32),
                      size: 20,
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
                            fontSize: 15,
                            color: Color(0xFF1B1B1B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {}, // TODO: cambiar contraseña
                    child: const Text(
                      'CAMBIAR',
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Nota informativa ──────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF2E7D32), size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tu información se utiliza para personalizar '
                      'tus planes de viaje y reservas en parques naturales.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF555555),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Botón guardar ─────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: isLoading ? null : _guardar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  disabledBackgroundColor: const Color(0xFFB0BEC5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: isLoading
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

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF555555)),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF555555),
          ),
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 15, color: Color(0xFF1B1B1B)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
