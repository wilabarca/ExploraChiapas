import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_interests.dart';
import '../widgets/profile_stats.dart';
import '../widgets/profile_menu_item.dart';
import 'edit_profile_page.dart';
// ajusta el import según tu path real:
import '../../../home/presentation/widgets/custom_bottom_nav_bar.dart';

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

  void _onNavTap(BottomNavTab tab) {
    switch (tab) {
      case BottomNavTab.explorar:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case BottomNavTab.mapa:
        Navigator.pushReplacementNamed(context, '/mapa');
        break;
      case BottomNavTab.favoritos:
        Navigator.pushReplacementNamed(context, '/favoritos');
        break;
      case BottomNavTab.resenas:
        Navigator.pushReplacementNamed(context, '/resenas');
        break;
      case BottomNavTab.perfil:
        break; // ya estamos aquí
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq           = MediaQuery.of(context);
    final screenW      = mq.size.width;
    final screenH      = mq.size.height;
    final isSmall      = screenW < 360;
    final avatarRadius = screenW * 0.135;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F7F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: const Text(
          'ExploraChiapas',
          style: TextStyle(
            color: Color(0xFF1B5E20),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // ✅ Bottom nav de vuelta con perfil seleccionado
      bottomNavigationBar: AppBottomNav(
        navItems: AppBottomNav.items, // cambia a itemsLocal si es usuario Local
        currentTab: BottomNavTab.perfil,
        onTap: _onNavTap,
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No se pudo cargar el perfil'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => provider.loadPerfil(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                    ),
                    child: const Text(
                      'Reintentar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenW * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenH * 0.025),

                  // ── Avatar + nombre + email ──────────────
                  Center(
                    child: Column(
                      children: [
                        SizedBox(
                          width:  avatarRadius * 2,
                          height: avatarRadius * 2,
                          child: ProfileAvatar(
                            radius:         avatarRadius,
                            showEditButton: true,
                            onTap: () => _irAEditarPerfil(context),
                          ),
                        ),
                        SizedBox(height: screenH * 0.012),
                        Text(
                          perfil.nombre,
                          style: TextStyle(
                            fontSize:   isSmall ? 18 : 22,
                            fontWeight: FontWeight.bold,
                            color:      const Color(0xFF1B1B1B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          perfil.email,
                          style: const TextStyle(
                            fontSize: 13,
                            color:    Color(0xFF777777),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: screenH * 0.025),

                  // ── Stats ─────────────────────────────────
                  const ProfileStats(
                    rutasCreadas: '0',
                    favoritos:    '0',
                    resenas:      '0',
                  ),

                  SizedBox(height: screenH * 0.016),

                  // ── Mis Intereses ─────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Mis Intereses',
                              style: TextStyle(
                                fontSize:   15,
                                fontWeight: FontWeight.bold,
                                color:      Color(0xFF1B1B1B),
                              ),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  Navigator.pushNamed(context, '/intereses'),
                              child: const Row(
                                children: [
                                  Icon(Icons.edit_outlined,
                                      size: 14, color: Color(0xFF2E7D32)),
                                  SizedBox(width: 4),
                                  Text(
                                    'Editar',
                                    style: TextStyle(
                                      fontSize:   13,
                                      color:      Color(0xFF2E7D32),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const ProfileInterests(),
                      ],
                    ),
                  ),

                  SizedBox(height: screenH * 0.016),

                  // ── Menú ──────────────────────────────────
                  ProfileMenuItem(
                    icon:  Icons.manage_accounts_outlined,
                    label: 'Editar perfil',
                    onTap: () => _irAEditarPerfil(context),
                  ),
                  SizedBox(height: screenH * 0.01),
                  ProfileMenuItem(
                    icon:  Icons.logout_outlined,
                    label: 'Cerrar sesión',
                    onTap: () => _confirmarCerrarSesion(context),
                  ),
                  SizedBox(height: screenH * 0.01),
                  ProfileMenuItem(
                    icon:        Icons.delete_outline,
                    label:       'Eliminar cuenta',
                    dangerColor: const Color(0xFFD32F2F),
                    onTap:       () => _confirmarEliminarCuenta(context, provider),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _irAEditarPerfil(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditProfilePage()),
    ).then((_) {
      if (mounted) context.read<ProfileProvider>().loadPerfil();
    });
  }

  void _confirmarCerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
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
              backgroundColor: const Color(0xFF2E7D32),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Cerrar sesión',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminarCuenta(
    BuildContext context,
    ProfileProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminar cuenta'),
        content: const Text(
          '¿Estás seguro? Esta acción es permanente y no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await provider.deletePerfil();
              if (!context.mounted) return;
              if (success) Navigator.pushReplacementNamed(context, '/');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Eliminar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}