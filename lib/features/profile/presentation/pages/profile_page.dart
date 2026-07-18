import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_interests.dart';
import '../widgets/profile_stats.dart';
import '../widgets/profile_menu_item.dart';
import 'edit_profile_page.dart';
import '../../../home/presentation/widgets/custom_bottom_nav_bar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Preferencias locales
  String _idioma    = 'Español';
  String _unidades  = 'km';
  String _tema      = 'Claro';
  String _moneda    = 'MXN';

  // Privacidad
  bool _compartirUbicacion   = false;
  bool _compartirHistorial   = false;
  bool _mostrarPerfilPublico = true;

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
        break;
    }
  }

  void _seleccionarOpcion(
    String titulo,
    List<String> opciones,
    String actual,
    void Function(String) onSelected,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        children: opciones.map((op) {
          return SimpleDialogOption(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => onSelected(op));
            },
            child: Row(
              children: [
                Icon(
                  op == actual ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: op == actual ? const Color(0xFF2E7D32) : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(op, style: const TextStyle(fontSize: 15)),
              ],
            ),
          );
        }).toList(),
      ),
    );
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
      bottomNavigationBar: AppBottomNav(
        navItems: AppBottomNav.items,
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

                  // ── Menú principal ────────────────────────
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

                  SizedBox(height: screenH * 0.024),

                  // ── Preferencias ──────────────────────────
                  const _SectionHeader(titulo: 'Preferencias'),
                  const SizedBox(height: 10),
                  _PreferenciaTile(
                    icon:  Icons.language_outlined,
                    label: 'Idioma',
                    valor: _idioma,
                    onTap: () => _seleccionarOpcion(
                      'Idioma',
                      ['Español', 'English'],
                      _idioma,
                      (v) => _idioma = v,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _PreferenciaTile(
                    icon:  Icons.straighten_outlined,
                    label: 'Unidades',
                    valor: _unidades,
                    onTap: () => _seleccionarOpcion(
                      'Unidades de distancia',
                      ['km', 'millas'],
                      _unidades,
                      (v) => _unidades = v,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _PreferenciaTile(
                    icon:  Icons.brightness_6_outlined,
                    label: 'Tema',
                    valor: _tema,
                    onTap: () => _seleccionarOpcion(
                      'Tema de la app',
                      ['Claro', 'Oscuro'],
                      _tema,
                      (v) => _tema = v,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _PreferenciaTile(
                    icon:  Icons.attach_money_outlined,
                    label: 'Moneda',
                    valor: _moneda,
                    onTap: () => _seleccionarOpcion(
                      'Moneda',
                      ['MXN', 'USD', 'EUR'],
                      _moneda,
                      (v) => _moneda = v,
                    ),
                  ),

                  SizedBox(height: screenH * 0.024),

                  // ── Privacidad ────────────────────────────
                  const _SectionHeader(titulo: 'Privacidad'),
                  const SizedBox(height: 10),
                  _ToggleTile(
                    icon:   Icons.location_on_outlined,
                    label:  'Compartir ubicación',
                    valor:  _compartirUbicacion,
                    onChanged: (v) => setState(() => _compartirUbicacion = v),
                  ),
                  const SizedBox(height: 8),
                  _ToggleTile(
                    icon:   Icons.history_outlined,
                    label:  'Compartir historial',
                    valor:  _compartirHistorial,
                    onChanged: (v) => setState(() => _compartirHistorial = v),
                  ),
                  const SizedBox(height: 8),
                  _ToggleTile(
                    icon:   Icons.public_outlined,
                    label:  'Mostrar perfil público',
                    valor:  _mostrarPerfilPublico,
                    onChanged: (v) => setState(() => _mostrarPerfilPublico = v),
                  ),
                  const SizedBox(height: 8),
                  ProfileMenuItem(
                    icon:  Icons.download_outlined,
                    label: 'Descargar mis datos',
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Función próximamente disponible'),
                        backgroundColor: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacementNamed(context, '/');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Cerrar sesión', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminarCuenta(BuildContext context, ProfileProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminar cuenta'),
        content: const Text(
          '¿Estás seguro? Esta acción es permanente y no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Widgets privados ──────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String titulo;
  const _SectionHeader({required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Text(
      titulo,
      style: const TextStyle(
        fontSize:   13,
        fontWeight: FontWeight.w600,
        color:      Color(0xFF777777),
        letterSpacing: 0.5,
      ),
    );
  }
}

class _PreferenciaTile extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final String       valor;
  final VoidCallback onTap;

  const _PreferenciaTile({
    required this.icon,
    required this.label,
    required this.valor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF2E7D32), size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize:   15,
                  fontWeight: FontWeight.w500,
                  color:      Color(0xFF1B1B1B),
                ),
              ),
            ),
            Text(
              valor,
              style: const TextStyle(fontSize: 13, color: Color(0xFF777777)),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, color: Color(0xFFAAAAAA), size: 20),
          ],
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData          icon;
  final String            label;
  final bool              valor;
  final void Function(bool) onChanged;

  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.valor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF2E7D32), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize:   15,
                fontWeight: FontWeight.w500,
                color:      Color(0xFF1B1B1B),
              ),
            ),
          ),
          Switch(
            value:           valor,
            onChanged:       onChanged,
            activeColor:     const Color(0xFF2E7D32),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}
