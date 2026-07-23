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
import '../widgets/eliminar_cuenta_dialogs.dart';
import 'edit_profile_page.dart';
import '../../../home/presentation/widgets/custom_bottom_nav_bar.dart';
import '../../../home/presentation/widgets/home_app_bar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../favoritos/presentation/providers/favoritos_provider.dart';
import '../../../resena/presentation/providers/ResenasProvider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Evita que un doble tap dispare dos eliminaciones/solicitudes en
  // paralelo mientras el flujo de eliminar cuenta está en curso.
  bool _eliminandoCuenta = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadPerfil();
      final favProvider = context.read<FavoritosProvider>();
      if (favProvider.status == FavoritosStatus.idle) {
        favProvider.cargarFavoritos();
      }
      context.read<ResenasProvider>().cargarMisResenasCount();
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
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
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
                  op == actual
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: op == actual
                      ? AppColors.primary(context)
                      : AppColors.textHint(context),
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
    final mq = MediaQuery.of(context);
    final screenW = mq.size.width;
    final screenH = mq.size.height;
    final isSmall = screenW < 360;
    final avatarRadius = screenW * 0.135;
    final lang = context.watch<LocaleProvider>().langCode;
    final prefs = context.watch<PreferencesProvider>();

    String s(String key) => AppStrings.tr(key, lang);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: const HomeAppBar(),
      bottomNavigationBar: AppBottomNav(
        navItems: AppBottomNav.items,
        currentTab: BottomNavTab.perfil,
        onTap: _onNavTap,
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          final perfil = provider.perfil;

          if (provider.status == ProfileStatus.loading && perfil == null) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primary(context),
              ),
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
                      style: TextStyle(color: AppColors.onPrimary(context)),
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

                  Center(
                    child: Column(
                      children: [
                        SizedBox(
                          width: avatarRadius * 2,
                          height: avatarRadius * 2,
                          child: ProfileAvatar(
                            radius: avatarRadius,
                            showEditButton: true,
                            onTap: () => _irAEditarPerfil(context),
                          ),
                        ),
                        SizedBox(height: screenH * 0.012),
                        Text(
                          perfil.nombre,
                          style: TextStyle(
                            fontSize: isSmall ? 18 : 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          perfil.email,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: screenH * 0.025),

                  Consumer2<FavoritosProvider, ResenasProvider>(
                    builder: (context, favProvider, resenasProvider, _) {
                      return ProfileStats(
                        favoritos: favProvider.favoritos.length.toString(),
                        resenas: resenasProvider.misResenasCount.toString(),
                      );
                    },
                  ),

                  SizedBox(height: screenH * 0.016),

                  _Acordeon(
                    titulo: s('mis_intereses'),
                    icono: Icons.favorite_outline,
                    accion: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/intereses'),
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 14,
                            color: AppColors.primary(context),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            s('editar'),
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.primary(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    children: const [ProfileInterests()],
                  ),

                  SizedBox(height: screenH * 0.01),

                  _Acordeon(
                    titulo: s('menu'),
                    icono: Icons.menu_outlined,
                    children: [
                      ProfileMenuItem(
                        icon: Icons.manage_accounts_outlined,
                        label: s('editar_perfil'),
                        onTap: () => _irAEditarPerfil(context),
                      ),
                      const SizedBox(height: 8),
                      ProfileMenuItem(
                        icon: Icons.logout_outlined,
                        label: s('cerrar_sesion'),
                        onTap: () => _confirmarCerrarSesion(context, lang),
                      ),
                    ],
                  ),

                  SizedBox(height: screenH * 0.01),

                  _Acordeon(
                    titulo: s('preferencias'),
                    icono: Icons.settings_outlined,
                    children: [
                      _PreferenciaTile(
                        icon: Icons.language_outlined,
                        label: s('idioma'),
                        valor: _nombreDeIdioma(lang),
                        onTap: () =>
                            _mostrarSelectorIdioma(context, prefs, lang),
                      ),
                      const SizedBox(height: 8),
                      _PreferenciaTile(
                        icon: Icons.straighten_outlined,
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
                        icon: Icons.brightness_6_outlined,
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
                        icon: Icons.attach_money_outlined,
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

                  _Acordeon(
                    titulo: s('privacidad'),
                    icono: Icons.shield_outlined,
                    children: [
                      _ToggleTile(
                        icon: Icons.location_on_outlined,
                        label: s('compartir_ubicacion'),
                        valor: prefs.compartirUbicacion,
                        onChanged: (v) => prefs.setCompartirUbicacion(v),
                      ),
                      const SizedBox(height: 8),
                      _ToggleTile(
                        icon: Icons.history_outlined,
                        label: s('compartir_historial'),
                        valor: prefs.compartirHistorial,
                        onChanged: (v) => prefs.setCompartirHistorial(v),
                      ),
                      const SizedBox(height: 8),
                      _ToggleTile(
                        icon: Icons.public_outlined,
                        label: s('mostrar_perfil_publico'),
                        valor: prefs.mostrarPerfilPublico,
                        onChanged: (v) => prefs.setMostrarPerfilPublico(v),
                      ),
                      const SizedBox(height: 8),
                      ProfileMenuItem(
                        icon: Icons.download_outlined,
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
                        icon: Icons.delete_outline,
                        label: s('eliminar_cuenta'),
                        dangerColor: AppColors.error(context),
                        onTap: () =>
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

  static String _nombreDeIdioma(String code) {
    const map = {
      'es': 'Español',
      'en': 'English',
      'fr': 'Français',
      'de': 'Deutsch',
      'it': 'Italiano',
      'pt': 'Português',
      'zh': '中文',
      'ja': '日本語',
      'ko': '한국어',
      'ru': 'Русский',
      'ar': 'العربية',
      'nl': 'Nederlands',
      'pl': 'Polski',
      'tr': 'Türkçe',
      'vi': 'Tiếng Việt',
      'th': 'ภาษาไทย',
      'id': 'Bahasa Indonesia',
      'hi': 'हिन्दी',
      'sv': 'Svenska',
      'da': 'Dansk',
      'fi': 'Suomi',
      'nb': 'Norsk',
      'cs': 'Čeština',
      'hu': 'Magyar',
      'ro': 'Română',
      'uk': 'Українська',
      'el': 'Ελληνικά',
      'ca': 'Català',
    };
    return map[code] ?? code.toUpperCase();
  }

  void _mostrarSelectorIdioma(
    BuildContext context,
    PreferencesProvider prefs,
    String currentCode,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _LanguagePickerSheet(
        currentCode: currentCode,
        onSelected: (nombre, code) {
          prefs.setIdioma(nombre);
          context.read<LocaleProvider>().setLocale(Locale(code));
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
        title: Text(s('cerrar_sesion_titulo')),
        content: Text(s('cerrar_sesion_msg')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              s('cancelar'),
              style: TextStyle(color: AppColors.textSecondary(context)),
            ),
          ),

          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);

              await context.read<AuthProvider>().logout();

              if (!context.mounted) return;

              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              s('cerrar_sesion'),
              style: TextStyle(color: AppColors.onPrimary(context)),
            ),
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
        title: Text(s('eliminar_cuenta_titulo')),
        content: Text(s('eliminar_cuenta_msg')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              s('cancelar'),
              style: TextStyle(color: AppColors.textSecondary(context)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _eliminarCuenta(context, provider, lang);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              s('eliminar'),
              style: TextStyle(color: AppColors.onError(context)),
            ),
          ),
        ],
      ),
    );
  }

  /// Orquesta el flujo completo tras confirmar "Eliminar cuenta". Se
  /// repite mientras el usuario elija "Reintentar" ante un error; el
  /// `bool _eliminandoCuenta` evita que dos flujos corran en paralelo.
  Future<void> _eliminarCuenta(
    BuildContext context,
    ProfileProvider provider,
    String lang,
  ) async {
    if (_eliminandoCuenta) return;
    setState(() => _eliminandoCuenta = true);

    try {
      var reintentar = true;
      while (reintentar) {
        reintentar = await _intentarEliminarCuenta(context, provider, lang);
      }
    } finally {
      if (mounted) setState(() => _eliminandoCuenta = false);
    }
  }

  /// Un solo intento de eliminación. Devuelve `true` cuando el usuario
  /// pide reintentar tras un error; en cualquier otro desenlace (éxito,
  /// cancelación o contexto ya desmontado) devuelve `false`.
  ///
  /// 1) Llama al backend a través de [ProfileProvider.deletePerfil].
  /// 2) Si tiene éxito (o el backend responde 404: la cuenta ya no
  ///    existía), cierra la sesión por completo con [AuthProvider.logout]
  ///    y vacía todo el stack de navegación hacia Login — nunca queda una
  ///    ruta protegida atrás a la que se pueda volver.
  /// 3) Si falla, muestra un error claro sin tocar la sesión actual: la
  ///    cuenta y la sesión solo se limpian cuando el backend confirma la
  ///    eliminación.
  Future<bool> _intentarEliminarCuenta(
    BuildContext context,
    ProfileProvider provider,
    String lang,
  ) async {
    // No se espera este Future: solo muestra el overlay de carga y
    // retorna de inmediato para poder seguir con la petición al backend.
    // Se cierra explícitamente más abajo con Navigator.pop.
    mostrarEliminandoCuentaDialog(context);

    final eliminada = await provider.deletePerfil();
    final cuentaYaNoExistia = provider.errorStatusCode == 404;

    if (!context.mounted) return false;
    Navigator.of(context, rootNavigator: true).pop(); // cierra el loading
    if (!context.mounted) return false;

    if (eliminada || cuentaYaNoExistia) {
      await context.read<AuthProvider>().logout();
      if (!context.mounted) return false;

      await mostrarCuentaEliminadaSheet(context);
      if (!context.mounted) return false;

      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      return false;
    }

    final mensaje = _mensajeErrorEliminarCuenta(provider, lang);
    final reintentar = await mostrarErrorEliminarCuentaDialog(
      context,
      mensaje: mensaje,
    );
    return context.mounted && reintentar;
  }

  String _mensajeErrorEliminarCuenta(ProfileProvider provider, String lang) {
    final statusCode = provider.errorStatusCode;
    if (statusCode == 401) {
      return AppStrings.tr('error_eliminar_cuenta_sesion', lang);
    }
    if (statusCode != null && statusCode >= 500) {
      return AppStrings.tr('error_eliminar_cuenta_servidor', lang);
    }
    final mensaje = provider.errorMessage;
    return (mensaje != null && mensaje.isNotEmpty)
        ? mensaje
        : AppStrings.tr('error_eliminar_cuenta', lang);
  }
}

class _Acordeon extends StatefulWidget {
  final String titulo;
  final IconData icono;
  final Widget? accion;
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
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _rotacion = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
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
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
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
                      color: AppColors.primaryContainer(context),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      widget.icono,
                      color: AppColors.primary(context),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      widget.titulo,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary(context),
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
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
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

class _PreferenciaTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String valor;
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
          color: AppColors.background(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary(context), size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ),
            Text(
              valor,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right,
              color: AppColors.textHint(context),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguagePickerSheet extends StatefulWidget {
  final String currentCode;
  final void Function(String nombre, String code) onSelected;

  const _LanguagePickerSheet({
    required this.currentCode,
    required this.onSelected,
  });

  @override
  State<_LanguagePickerSheet> createState() => _LanguagePickerSheetState();
}

class _LanguagePickerSheetState extends State<_LanguagePickerSheet> {
  static const _todos = [
    ['es', 'Español', '🇪🇸'],
    ['en', 'English', '🇬🇧'],
    ['fr', 'Français', '🇫🇷'],
    ['de', 'Deutsch', '🇩🇪'],
    ['it', 'Italiano', '🇮🇹'],
    ['pt', 'Português', '🇧🇷'],
    ['zh', '中文', '🇨🇳'],
    ['ja', '日本語', '🇯🇵'],
    ['ko', '한국어', '🇰🇷'],
    ['ru', 'Русский', '🇷🇺'],
    ['ar', 'العربية', '🇸🇦'],
    ['nl', 'Nederlands', '🇳🇱'],
    ['pl', 'Polski', '🇵🇱'],
    ['tr', 'Türkçe', '🇹🇷'],
    ['vi', 'Tiếng Việt', '🇻🇳'],
    ['th', 'ภาษาไทย', '🇹🇭'],
    ['id', 'Bahasa Indonesia', '🇮🇩'],
    ['hi', 'हिन्दी', '🇮🇳'],
    ['sv', 'Svenska', '🇸🇪'],
    ['da', 'Dansk', '🇩🇰'],
    ['fi', 'Suomi', '🇫🇮'],
    ['nb', 'Norsk', '🇳🇴'],
    ['cs', 'Čeština', '🇨🇿'],
    ['hu', 'Magyar', '🇭🇺'],
    ['ro', 'Română', '🇷🇴'],
    ['uk', 'Українська', '🇺🇦'],
    ['el', 'Ελληνικά', '🇬🇷'],
    ['ca', 'Català', '🏳️'],
  ];

  final _ctrl = TextEditingController();
  List<List<String>> _filtrados = _todos;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      final q = _ctrl.text.toLowerCase();
      setState(() {
        _filtrados = q.isEmpty
            ? _todos
            : _todos.where((l) => l[1].toLowerCase().contains(q)).toList();
      });
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderSubtle(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(
                  Icons.language_outlined,
                  color: AppColors.primary(context),
                ),
                const SizedBox(width: 10),
                Text(
                  'Idioma / Language',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _ctrl,
              style: TextStyle(color: AppColors.textPrimary(context)),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.textHint(context),
                ),
                hintText: 'Buscar idioma...',
                hintStyle: TextStyle(color: AppColors.textHint(context)),
                filled: true,
                fillColor: AppColors.background(context),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _filtrados.length,
              itemBuilder: (_, i) {
                final lang = _filtrados[i];
                final isSelected = lang[0] == widget.currentCode;
                return ListTile(
                  leading: Text(lang[2], style: const TextStyle(fontSize: 24)),
                  title: Text(
                    lang[1],
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected
                          ? AppColors.primary(context)
                          : AppColors.textPrimary(context),
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle,
                          color: AppColors.primary(context),
                          size: 20,
                        )
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    widget.onSelected(lang[1], lang[0]);
                  },
                );
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool valor;
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
        color: AppColors.background(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary(context), size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
          Switch(
            value: valor,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary(context),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}
