import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_avatar.dart';
import '../../../../core/di/injector.dart'; // ajusta al path real de getIt
import '../../../../core/services/avatar/avatar_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nombreCtrl   = TextEditingController();
  final _telefonoCtrl = TextEditingController();

  // Clave para forzar rebuild de ProfileAvatar al regenerar avatar
  Key _avatarKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    final perfil = context.read<ProfileProvider>().perfil;
    if (perfil != null) {
      _nombreCtrl.text   = perfil.nombre;
      _telefonoCtrl.text = perfil.telefono ?? '';
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    super.dispose();
  }

  /// Regenera el avatar usando el nombre ingresado y fuerza rebuild del widget
  Future<void> _cambiarAvatar() async {
    final nombre = _nombreCtrl.text.trim();
    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Escribe tu nombre primero para generar el avatar'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    try {
      final service = getIt<AvatarService>();
      await service.asignarAvatarPorNombre(nombre);
      // Cambiar la key fuerza a ProfileAvatar a reconstruirse y recargar la URL
      if (mounted) setState(() => _avatarKey = UniqueKey());
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No se pudo actualizar el avatar'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _guardar() async {
    final provider = context.read<ProfileProvider>();
    final success  = await provider.updatePerfil(
      nombre:   _nombreCtrl.text.trim(),
      telefono: _telefonoCtrl.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Perfil actualizado correctamente'),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Error al actualizar'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq       = MediaQuery.of(context);
    final screenW  = mq.size.width;
    final screenH  = mq.size.height;
    final isSmall  = screenW < 360;

    // Radio proporcional al ancho de pantalla
    final avatarRadius = screenW * 0.145;

    final isLoading = context.watch<ProfileProvider>().status ==
        ProfileStatus.loading;
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: constraints.maxWidth * 0.06,
              vertical:   screenH * 0.030,
            ),
            child: Column(
              children: [

                // ── ProfileAvatar reutilizable con botón cámara ──
                // _avatarKey fuerza recarga cuando se regenera el avatar
                SizedBox(
                  width:  avatarRadius * 2,
                  height: avatarRadius * 2,
                  child: ProfileAvatar(
                    key:            _avatarKey,
                    radius:         avatarRadius,
                    showEditButton: false, // muestra ícono cámara
                    onTap:          _cambiarAvatar,
                  ),
                ),

                SizedBox(height: screenH * 0.008),
                GestureDetector(
                  onTap: _cambiarAvatar,
                  child: const Text(
                    'CAMBIAR FOTO DE PERFIL',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2E7D32),
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                SizedBox(height: screenH * 0.028),

                // ── Tipo de usuario (solo lectura) ────────────
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 50),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: Text(
                      perfil?.tipoUsuarioLabel ?? 'Turista',
                      style: TextStyle(
                        fontSize: isSmall ? 13 : 15,
                        color: const Color(0xFF555555),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: screenH * 0.020),

                // ── Nombre ────────────────────────────────────
                _buildLabel('Nombre completo', Icons.person_outline),
                const SizedBox(height: 8),
                _buildField(
                  controller: _nombreCtrl,
                  hint:       'Tu nombre completo',
                ),

                SizedBox(height: screenH * 0.020),

                // ── Email (solo lectura) ──────────────────────
                _buildLabel('Correo electrónico', Icons.email_outlined),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 50),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: Text(
                      perfil?.email ?? '',
                      style: TextStyle(
                        fontSize: isSmall ? 13 : 15,
                        color: const Color(0xFF555555),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: screenH * 0.020),

                // ── Contraseña ────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
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

                SizedBox(height: screenH * 0.020),

                // ── Nota informativa ──────────────────────────
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Color(0xFF2E7D32),
                        size: 18,
                      ),
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

                SizedBox(height: screenH * 0.032),

                // ── Botón guardar ─────────────────────────────
                FractionallySizedBox(
                  widthFactor: 1.0,
                  child: SizedBox(
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
                ),

                SizedBox(height: screenH * 0.020),
              ],
            ),
          );
        },
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