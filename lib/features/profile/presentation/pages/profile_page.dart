import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
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
              onSelected(op);
            },
            child: Row(
              children: [
                Icon(
                  op == actual ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: op == actual ? AppColors.primary(context) : Colors.grey,
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
    final lang         = context.watch<LocaleProvider>().langCode;
    final prefs        = context.watch<PreferencesProvider>();

    String s(String key) => AppStrings.tr(key, lang);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.surface(context),
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Text(
          s('app_name'),
          style: const TextStyle(
            color:      Color(0xFF1B5E20),
            fontSize:   18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        navItems:   AppBottomNav.items,
        currentTab: BottomNavTab.perfil,
        onTap:      _onNavTap,
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          final perfil = provider.perfil;

          // Solo spinner en la primera carga (sin datos en caché)
          if (provider.status == ProfileStatus.loading && perfil == null) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary(context)),
            );
          }

          if (perfil == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(s('no_cargo_perfil')),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => provider.loadPerfil(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary(context),
                    ),
                    child: Text(
                      s('reintentar'),
                      style: const TextStyle(color: Colors.white),
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
                            color:      AppColors.textPrimary(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          perfil.email,
                          style: TextStyle(
                            fontSize: 13,
                            color:    AppColors.textSecondary(context),
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

                  // ── Mis Intereses (acordeón) ───────────────
                  _Acordeon(
                    titulo: s('mis_intereses'),
                    icono:  Icons.favorite_outline,
                    accion: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/intereses'),
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined,
                              size: 14, color: AppColors.primary(context)),
                          const SizedBox(width: 4),
                          Text(
                            s('editar'),
                            style: TextStyle(
                              fontSize:   13,
                              color:      AppColors.primary(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    children: const [ProfileInterests()],
                  ),

                  SizedBox(height: screenH * 0.01),

                  // ── Menú principal (acordeón) ─────────────
                  _Acordeon(
                    titulo: s('menu'),
                    icono:  Icons.menu_outlined,
                    children: [
                      ProfileMenuItem(
                        icon:  Icons.manage_accounts_outlined,
                        label: s('editar_perfil'),
                        onTap: () => _irAEditarPerfil(context),
                      ),
                      const SizedBox(height: 8),
                      ProfileMenuItem(
                        icon:  Icons.logout_outlined,
                        label: s('cerrar_sesion'),
                        onTap: () => _confirmarCerrarSesion(context, lang),
                      ),
                    ],
                  ),

                  SizedBox(height: screenH * 0.01),

                  // ── Preferencias (acordeón) ───────────────
                  _Acordeon(
                    titulo: s('preferencias'),
                    icono:  Icons.settings_outlined,
                    children: [
                      _PreferenciaTile(
                        icon:  Icons.language_outlined,
                        label: s('idioma'),
                        valor: prefs.idioma,
                        onTap: () => _seleccionarOpcion(
                          s('idioma'),
                          ['Español', 'English'],
                          prefs.idioma,
                          (v) {
                            prefs.setIdioma(v);
                            context.read<LocaleProvider>().setLocale(
                              Locale(v == 'English' ? 'en' : 'es'),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      _PreferenciaTile(
                        icon:  Icons.straighten_outlined,
                        label: s('unidades'),
                        valor: prefs.unidades,
                        onTap: () => _seleccionarOpcion(
                          s('unidades'),
                          ['km', 'millas'],
                          prefs.unidades,
                          prefs.setUnidades,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _PreferenciaTile(
                        icon:  Icons.brightness_6_outlined,
                        label: s('tema'),
                        valor: s(prefs.tema == 'Claro' ? 'claro' : 'oscuro'),
                        onTap: () => _seleccionarOpcion(
                          s('tema'),
                          [s('claro'), s('oscuro')],
                          s(prefs.tema == 'Claro' ? 'claro' : 'oscuro'),
                          (v) => prefs.setTema(
                            v == s('oscuro') ? 'Oscuro' : 'Claro',
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _PreferenciaTile(
                        icon:  Icons.attach_money_outlined,
                        label: s('moneda'),
                        valor: prefs.moneda,
                        onTap: () => _seleccionarOpcion(
                          s('moneda'),
                          ['MXN', 'USD', 'EUR'],
                          prefs.moneda,
                          prefs.setMoneda,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: screenH * 0.01),

                  // ── Privacidad (acordeón) ─────────────────
                  _Acordeon(
                    titulo: s('privacidad'),
                    icono:  Icons.shield_outlined,
                    children: [
                      _ToggleTile(
                        icon:      Icons.location_on_outlined,
                        label:     s('compartir_ubicacion'),
                        valor:     prefs.compartirUbicacion,
                        onChanged: (v) => prefs.setCompartirUbicacion(v),
                      ),
                      const SizedBox(height: 8),
                      _ToggleTile(
                        icon:      Icons.history_outlined,
                        label:     s('compartir_historial'),
                        valor:     prefs.compartirHistorial,
                        onChanged: (v) => prefs.setCompartirHistorial(v),
                      ),
                      const SizedBox(height: 8),
                      _ToggleTile(
                        icon:      Icons.public_outlined,
                        label:     s('mostrar_perfil_publico'),
                        valor:     prefs.mostrarPerfilPublico,
                        onChanged: (v) => prefs.setMostrarPerfilPublico(v),
                      ),
                      const SizedBox(height: 8),
                      ProfileMenuItem(
                        icon:  Icons.download_outlined,
                        label: s('descargar_datos'),
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(s('proximamente')),
                            backgroundColor: AppColors.primary(context),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ProfileMenuItem(
                        icon:        Icons.delete_outline,
                        label:       s('eliminar_cuenta'),
                        dangerColor: AppColors.error(context),
                        onTap:       () =>
                            _confirmarEliminarCuenta(context, provider, lang),
                      ),
                    ],
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

  void _confirmarCerrarSesion(BuildContext context, String lang) {
    String s(String key) => AppStrings.tr(key, lang);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title:   Text(s('cerrar_sesion_titulo')),
        content: Text(s('cerrar_sesion_msg')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s('cancelar'),
                style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacementNamed(context, '/');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary(context),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(s('cerrar_sesion'),
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminarCuenta(
    BuildContext context,
    ProfileProvider provider,
    String lang,
  ) {
    String s(String key) => AppStrings.tr(key, lang);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title:   Text(s('eliminar_cuenta_titulo')),
        content: Text(s('eliminar_cuenta_msg')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s('cancelar'),
                style: const TextStyle(color: Colors.grey)),
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
            child: Text(s('eliminar'),
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Acordeón ─────────────────────────────────────────────────────────────────

class _Acordeon extends StatefulWidget {
  final String    titulo;
  final IconData  icono;
  final Widget?   accion;
  final List<Widget> children;

  const _Acordeon({
    required this.titulo,
    required this.icono,
    required this.children,
    this.accion,
  });

  @override
  State<_Acordeon> createState() => _AcordeonState();
}

class _AcordeonState extends State<_Acordeon>
    with SingleTickerProviderStateMixin {
  bool _expandido = false;
  late final AnimationController _ctrl;
  late final Animation<double> _rotacion;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 250),
    );
    _rotacion = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expandido = !_expandido);
    if (_expandido) {
      _ctrl.forward();
    } else {
      _ctrl.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color:        AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:   Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:        AppColors.primaryContainer(context),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(widget.icono,
                        color: AppColors.primary(context), size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      widget.titulo,
                      style: TextStyle(
                        fontSize:   15,
                        fontWeight: FontWeight.w600,
                        color:      AppColors.textPrimary(context),
                      ),
                    ),
                  ),
                  if (widget.accion != null) ...[
                    widget.accion!,
                    const SizedBox(width: 8),
                  ],
                  RotationTransition(
                    turns: _rotacion,
                    child: Icon(
                      Icons.expand_more,
                      color: AppColors.textSecondary(context),
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Contenido animado ────────────────────────────
          AnimatedCrossFade(
            duration:      const Duration(milliseconds: 250),
            firstChild:    const SizedBox(width: double.infinity),
            secondChild:   Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.children,
              ),
            ),
            crossFadeState: _expandido
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
          ),
        ],
      ),
    );
  }
}

// ── Tile de preferencia con valor actual ──────────────────────────────────────

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
          color:        AppColors.background(context),
          borderRadius: BorderRadius.circular(12),
          border:       Border.all(color: AppColors.border(context)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary(context), size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize:   14,
                  fontWeight: FontWeight.w500,
                  color:      AppColors.textPrimary(context),
                ),
              ),
            ),
            Text(
              valor,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary(context)),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right, color: AppColors.textHint(context), size: 18),
          ],
        ),
      ),
    );
  }
}

// ── Toggle tile ───────────────────────────────────────────────────────────────

class _ToggleTile extends StatelessWidget {
  final IconData           icon;
  final String             label;
  final bool               valor;
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
        color:        AppColors.background(context),
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary(context), size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize:   14,
                fontWeight: FontWeight.w500,
                color:      AppColors.textPrimary(context),
              ),
            ),
          ),
          Switch(
            value:     valor,
            onChanged: onChanged,
            activeThumbColor:      AppColors.primary(context),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}
