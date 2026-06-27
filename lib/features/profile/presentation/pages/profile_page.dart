import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_stats.dart';
import '../widgets/profile_menu_item.dart';
import '../widgets/profile_premium_banner.dart';
import '../widgets/profile_interests.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadPerfil();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Mi Perfil',
          style: TextStyle(
            color: Color(0xFF1B5E20),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B5E20)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF2E7D32)),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfilePage()),
            ),
          ),
        ],
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          if (provider.status == ProfileStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
            );
          }

          final perfil = provider.perfil;
          if (perfil == null) {
            return const Center(child: Text('No se pudo cargar el perfil'));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // ── Header verde ─────────────────────────────
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                  child: Column(
                    children: [
                      const ProfileAvatar(),
                      const SizedBox(height: 14),
                      Text(
                        perfil.nombre,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B1B1B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        perfil.email,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF777777),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          perfil.tipoUsuarioLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── Stats ────────────────────────────────────
                const ProfileStats(),

                const SizedBox(height: 12),

                // ── Banner premium ───────────────────────────
                if (!perfil.isPremium) const ProfilePremiumBanner(),

                const SizedBox(height: 12),

                // ── Intereses ────────────────────────────────
                const ProfileInterests(),

                const SizedBox(height: 12),

                // ── Menú ─────────────────────────────────────
                Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      ProfileMenuItem(
                        icon: Icons.edit_outlined,
                        label: 'Editar perfil',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfilePage(),
                          ),
                        ),
                      ),
                      ProfileMenuItem(
                        icon: Icons.favorite_outline,
                        label: 'Mis favoritos',
                        onTap: () {},
                      ),
                      ProfileMenuItem(
                        icon: Icons.star_outline,
                        label: 'Mis reseñas',
                        onTap: () {},
                      ),
                      ProfileMenuItem(
                        icon: Icons.notifications_outlined,
                        label: 'Notificaciones',
                        onTap: () {},
                      ),
                      ProfileMenuItem(
                        icon: Icons.help_outline,
                        label: 'Ayuda',
                        onTap: () {},
                      ),
                      ProfileMenuItem(
                        icon: Icons.logout,
                        label: 'Cerrar sesión',
                        color: Colors.red,
                        onTap: () => _confirmarCerrarSesion(context),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmarCerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacementNamed(context, '/');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Cerrar sesión',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}