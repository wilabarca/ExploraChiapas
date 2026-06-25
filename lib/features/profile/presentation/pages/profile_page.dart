import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_stats.dart';
import '../widgets/profile_interests.dart';
import '../widgets/profile_menu_item.dart';
import '../widgets/profile_premium_banner.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _mostrarDialogoCerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FAF0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.logout_outlined,
                  color: Color(0xFF2E7D32),
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '¿Quieres cerrar sesión?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B1B1B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Tu progreso y rutas personalizadas se guardarán de forma segura.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF888888),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    if (!ctx.mounted) return;
                    Navigator.of(ctx).pop();
                    Navigator.pushReplacementNamed(ctx, '/');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Cerrar sesión',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF5F5F5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Color(0xFF555555),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 20,
        title: Row(
          children: [
            Image.asset(
              'assets/images/ExploraChiapas Logo.png',
              height: 26,
            ),
            const SizedBox(width: 8),
            const Text(
              'ExploraChiapas',
              style: TextStyle(
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 24),

          // Avatar
          Center(
            child: ProfileAvatar(
              imageUrl: 'https://i.pravatar.cc/150?img=11',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const EditProfilePage()),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Nombre y correo
          const Center(
            child: Text(
              'Juan Pérez',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B1B1B),
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Center(
            child: Text(
              'juan.perez@email.com',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF888888),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Stats
          const ProfileStats(),

          const SizedBox(height: 16),

          // Intereses
          const ProfileInterests(),

          const SizedBox(height: 16),

          // Editar perfil
          ProfileMenuItem(
            icono: Icons.manage_accounts_outlined,
            label: 'Editar perfil',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfilePage()),
            ),
          ),

          // Cerrar sesión
          ProfileMenuItem(
            icono: Icons.logout_outlined,
            label: 'Cerrar sesión',
            onTap: () => _mostrarDialogoCerrarSesion(context),
          ),

          // Eliminar cuenta
          ProfileMenuItem(
            icono: Icons.delete_outline,
            label: 'Eliminar cuenta',
            onTap: () {},
            iconColor: Colors.red,
            labelColor: Colors.red,
            bgColor: const Color(0xFFFFF5F5),
          ),

          const SizedBox(height: 16),

          // Premium banner
          const ProfilePremiumBanner(),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}