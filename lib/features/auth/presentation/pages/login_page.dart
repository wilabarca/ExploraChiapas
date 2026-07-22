import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../utils/validadores_auth.dart';
import '../widgets/auth_bird_logo.dart';
import '../widgets/register_field.dart';
import '../providers/auth_provider.dart';
import '../../../../core/permissions/location_permission.dart';
import '../../../../core/services/google_auth_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/network/api_client.dart';

const int _minPasswordLength = 6;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  String? _emailError;
  String? _passwordError;
  String? _errorGeneral;

  @override
  void initState() {
    super.initState();
    // Despierta el backend (Render duerme tras inactividad) mientras el
    // usuario todavía está escribiendo/eligiendo cómo iniciar sesión, para
    // que el login no se sienta lento por el cold start del servidor.
    getIt<ApiClient>().warmup();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // ── Validación ────────────────────────────────────────────────────────────

  /// Valida ambos campos y actualiza los mensajes de error en pantalla.
  /// Devuelve true solo si el formulario está listo para enviarse.
  bool _validarFormulario() {
    final emailError = ValidadoresAuth.email(_emailCtrl.text);
    final passwordError = ValidadoresAuth.password(
      _passCtrl.text,
      minLength: _minPasswordLength,
    );

    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
      _errorGeneral = null;
    });

    return emailError == null && passwordError == null;
  }

  // ── Login con email/contraseña ──────────────────────────────────────────

  Future<void> _handleLogin() async {
    if (!_validarFormulario()) return;

    final provider = context.read<AuthProvider>();

    try {
      final success = await provider.login(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        await _continuarDespuesDeLogin(provider);
      } else {
        _mostrarError(provider.errorMessage ?? 'Error al iniciar sesión');
        provider.resetStatus();
      }
    } catch (e) {
      // Red de seguridad ante cualquier fallo inesperado (ej. un plugin
      // nativo fallando justo al volver de segundo plano) para que la
      // pantalla nunca quede rota sin explicación.
      debugPrint('[LoginPage] Error inesperado en login: $e');
      if (mounted) {
        _mostrarError('Ocurrió un problema inesperado. Intenta de nuevo.');
      }
    }
  }

  // ── Login con Google ─────────────────────────────────────────────────────

  Future<void> _handleGoogleLogin() async {
    GoogleSignInAccount? account;
    try {
      account = await GoogleAuthService.signIn();
    } catch (e) {
      if (!mounted) return;
      _mostrarError(_mensajeErrorGoogle(e));
      return;
    }
    // El usuario cerró el selector de cuentas sin elegir ninguna: no es error.
    if (account == null) return;

    try {
      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        if (!mounted) return;
        _mostrarError('No se pudo obtener el token de Google');
        return;
      }

      if (!mounted) return;
      final provider = context.read<AuthProvider>();
      final success = await provider.loginWithGoogle(idToken: idToken);

      if (!mounted) return;

      if (success) {
        await _continuarDespuesDeLogin(provider);
      } else {
        _mostrarError(
          provider.errorMessage ?? 'Error al iniciar sesión con Google',
        );
        provider.resetStatus();
      }
    } catch (e) {
      debugPrint('[LoginPage] Error inesperado en login con Google: $e');
      if (mounted) {
        _mostrarError('Ocurrió un problema inesperado. Intenta de nuevo.');
      }
    }
  }

  String _mensajeErrorGoogle(Object error) {
    final texto = error.toString();
    if (texto.contains('ApiException: 10')) {
      return 'Error de configuración de Google Sign-In. Avisa a soporte.';
    }
    if (texto.contains('network_error') || texto.contains('ApiException: 7')) {
      return 'Sin conexión a internet. Verifica tu red e intenta de nuevo.';
    }
    return 'No se pudo iniciar sesión con Google. Intenta de nuevo.';
  }

  // ── Flujo compartido tras un login exitoso (email o Google) ───────────────

  Future<void> _continuarDespuesDeLogin(AuthProvider provider) async {
    try {
      final interests = await provider.loadUserInterests();

      if (!mounted) return;

      if (interests == null) {
        _mostrarError(
          provider.errorMessage ??
              'No se pudo verificar la configuración de tu cuenta',
        );
        return;
      }

      if (interests.onboardingCompleted) {
        await LocationPermissionHelper().checkAndRequestOnLogin(context);
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else {
        Navigator.pushReplacementNamed(context, '/intereses');
      }
    } catch (e) {
      debugPrint('[LoginPage] Error inesperado tras login: $e');
      if (mounted) {
        _mostrarError('Ocurrió un problema inesperado. Intenta de nuevo.');
      }
    }
  }

  // Antes esto era un SnackBar: podía quedar flotando sobre la pantalla
  // equivocada si justo en ese momento ocurría una navegación (p. ej. el
  // interceptor de 401 sacando al usuario). Al ser parte del árbol de esta
  // misma pantalla, el banner inline nunca puede "sobrevivir" a un cambio
  // de ruta ni superponerse a otra pantalla.
  void _mostrarError(String mensaje) {
    if (!mounted) return;
    setState(() => _errorGeneral = mensaje);
  }

  // El usuario ya empezó a corregir sus datos: el error anterior ya no
  // aplica, así que desaparece en vez de quedar mostrando algo obsoleto.
  void _limpiarErrorGeneral(String texto) {
    if (_errorGeneral != null) setState(() => _errorGeneral = null);
  }

  // ── UI ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isLoading =
        context.watch<AuthProvider>().status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Center(
          // ConstrainedBox: en pantallas anchas (tablets) el formulario no
          // se estira de borde a borde, queda centrado y legible.
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.05),
                  const AuthBirdLogo(),
                  SizedBox(height: size.height * 0.04),
                  const _Encabezado(),
                  SizedBox(height: size.height * 0.025),
                  _ErrorBanner(mensaje: _errorGeneral),
                  _FormularioLogin(
                    emailCtrl: _emailCtrl,
                    passCtrl: _passCtrl,
                    emailError: _emailError,
                    passwordError: _passwordError,
                    isLoading: isLoading,
                    onSubmit: _handleLogin,
                    onFieldChanged: _limpiarErrorGeneral,
                  ),
                  SizedBox(height: size.height * 0.02),
                  const _Separador(),
                  SizedBox(height: size.height * 0.02),
                  _BotonGoogle(
                    isLoading: isLoading,
                    onPressed: _handleGoogleLogin,
                  ),
                  SizedBox(height: size.height * 0.03),
                  _EnlaceRegistro(
                    onTap: () => Navigator.pushNamed(context, '/registro'),
                  ),
                  SizedBox(height: size.height * 0.04),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Widgets de presentación (sin estado, extraídos para legibilidad) ───────

class _Encabezado extends StatelessWidget {
  const _Encabezado();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Inicio de Sesión',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.primary(context),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Únete a la comunidad de exploradores '
          'más exclusiva de Chiapas.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary(context),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _FormularioLogin extends StatelessWidget {
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final String? emailError;
  final String? passwordError;
  final bool isLoading;
  final VoidCallback onSubmit;
  final ValueChanged<String>? onFieldChanged;

  const _FormularioLogin({
    required this.emailCtrl,
    required this.passCtrl,
    required this.emailError,
    required this.passwordError,
    required this.isLoading,
    required this.onSubmit,
    this.onFieldChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer(context).withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          RegisterField(
            controller: emailCtrl,
            label: 'EMAIL',
            hint: 'explorador@selva.com',
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            errorText: emailError,
            onChanged: onFieldChanged,
          ),
          const SizedBox(height: 16),
          RegisterField(
            controller: passCtrl,
            label: 'CONTRASEÑA',
            hint: '••••••••',
            icon: Icons.lock_outline,
            isPassword: true,
            errorText: passwordError,
            onChanged: onFieldChanged,
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                // TODO: recuperar contraseña
              },
              child: Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(
                  color: AppColors.primary(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: isLoading ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: isLoading
                  ? SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        color: AppColors.onPrimary(context),
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      'Iniciar Sesión',
                      style: TextStyle(
                        color: AppColors.onPrimary(context),
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Separador extends StatelessWidget {
  const _Separador();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.borderSubtle(context))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'o',
            style: TextStyle(
              color: AppColors.textSecondary(context),
              fontSize: 13,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.borderSubtle(context))),
      ],
    );
  }
}

class _BotonGoogle extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _BotonGoogle({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: Image.network(
        'https://www.google.com/favicon.ico',
        width: 20,
        height: 20,
        errorBuilder: (_, __, ___) => const Icon(Icons.login, size: 20),
      ),
      label: Text(
        'Continuar con Google',
        style: TextStyle(
          color: AppColors.textPrimary(context),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        side: BorderSide(color: AppColors.border(context)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        backgroundColor: AppColors.surface(context),
      ),
    );
  }
}

class _EnlaceRegistro extends StatelessWidget {
  final VoidCallback onTap;
  const _EnlaceRegistro({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿No tienes cuenta? ',
          style: TextStyle(color: AppColors.textSecondary(context)),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            'Regístrate',
            style: TextStyle(
              color: AppColors.primary(context),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

/// Mensaje de error del intento de login (credenciales incorrectas, sin
/// conexión, error inesperado, etc.). Aparece/desaparece con una animación
/// de fade + slide + escala; al vivir dentro del propio árbol de la
/// pantalla, nunca puede quedar flotando sobre otra ruta.
class _ErrorBanner extends StatelessWidget {
  final String? mensaje;

  const _ErrorBanner({required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: mensaje == null
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: TweenAnimationBuilder<double>(
                key: ValueKey(mensaje),
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  final t = value.clamp(0.0, 1.0);
                  return Opacity(
                    opacity: t,
                    child: Transform.translate(
                      offset: Offset(0, (1 - t) * -10),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer(context),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.error(context).withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 20,
                        color: AppColors.error(context),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          mensaje!,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            height: 1.35,
                            color: AppColors.onErrorContainer(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
