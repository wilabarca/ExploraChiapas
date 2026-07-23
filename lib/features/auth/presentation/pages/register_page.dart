import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/validadores_auth.dart';
import '../widgets/auth_bird_logo.dart';
import '../widgets/register_field.dart';
import '../widgets/register_user_type.dart';
import '../providers/auth_provider.dart';
import '../../domain/entities/usuario_registro.dart';
import '../../../../core/utils/app_constants.dart';
import '../../../../core/theme/app_colors.dart';

const int _minPasswordLength = 8;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String _tipoUsuario = 'Turista Nacional';
  bool _aceptoTerminos = false;

  final _nombreCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  String? _nombreError;
  String? _emailError;
  String? _telefonoError;
  String? _passwordError;
  String? _confirmError;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _telefonoCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ── Validación ────────────────────────────────────────────────────────────

  /// Valida todos los campos y actualiza los mensajes de error en pantalla.
  /// Devuelve true solo si el formulario está listo para enviarse.
  bool _validarFormulario() {
    final nombreError = ValidadoresAuth.nombre(_nombreCtrl.text);
    final emailError = ValidadoresAuth.email(_emailCtrl.text);
    final telefonoError = ValidadoresAuth.telefono(_telefonoCtrl.text);
    final passwordError = ValidadoresAuth.password(
      _passCtrl.text,
      minLength: _minPasswordLength,
    );
    final confirmError = ValidadoresAuth.confirmarPassword(
      _passCtrl.text,
      _confirmCtrl.text,
    );

    setState(() {
      _nombreError = nombreError;
      _emailError = emailError;
      _telefonoError = telefonoError;
      _passwordError = passwordError;
      _confirmError = confirmError;
    });

    return nombreError == null &&
        emailError == null &&
        telefonoError == null &&
        passwordError == null &&
        confirmError == null;
  }

  // ── Abre URL en el navegador del sistema ──────────────────────────────────
  Future<void> _abrirUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _handleRegister() async {
    if (!_validarFormulario()) return;

    if (!_aceptoTerminos) {
      _mostrarError(
        'Debes aceptar los Términos y Condiciones y la Política de Privacidad.',
      );
      return;
    }

    try {
      final provider = context.read<AuthProvider>();

      final success = await provider.register(
        UsuarioRegistro(
          nombre: _nombreCtrl.text.trim(),
          correo: _emailCtrl.text.trim(),
          telefono: _telefonoCtrl.text.trim(),
          contrasena: _passCtrl.text.trim(),
          tipoUsuario: _tipoDesdeSeleccion(),
        ),
      );

      if (!mounted) return;

      if (success) {
        Navigator.pushReplacementNamed(context, '/intereses');
      } else {
        _mostrarError(provider.errorMessage ?? 'Error al registrarse');
        provider.resetStatus();
      }
    } catch (e) {
      // Red de seguridad ante cualquier fallo inesperado (ej. un plugin
      // nativo o el servidor comportándose de forma anómala) para que la
      // pantalla nunca quede rota sin explicación.
      debugPrint('[RegisterPage] Error inesperado al registrar: $e');
      if (mounted) {
        _mostrarError('Ocurrió un problema inesperado. Intenta de nuevo.');
      }
    }
  }

  TipoUsuario _tipoDesdeSeleccion() {
    switch (_tipoUsuario) {
      case 'Turista Nacional':
        return TipoUsuario.turistaNacional;
      case 'Turista Extranjero':
        return TipoUsuario.turistaExtranjero;
      default:
        return TipoUsuario.habitanteLocal;
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: AppColors.error(context),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
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
                  SizedBox(height: size.height * 0.035),
                  const _Encabezado(),
                  SizedBox(height: size.height * 0.035),
                  _FormularioRegistro(
                    tipoUsuario: _tipoUsuario,
                    onTipoUsuarioChanged: (val) =>
                        setState(() => _tipoUsuario = val),
                    nombreCtrl: _nombreCtrl,
                    emailCtrl: _emailCtrl,
                    telefonoCtrl: _telefonoCtrl,
                    passCtrl: _passCtrl,
                    confirmCtrl: _confirmCtrl,
                    nombreError: _nombreError,
                    emailError: _emailError,
                    telefonoError: _telefonoError,
                    passwordError: _passwordError,
                    confirmError: _confirmError,
                    aceptoTerminos: _aceptoTerminos,
                    onAceptoTerminosChanged: (val) =>
                        setState(() => _aceptoTerminos = val),
                    onAbrirTerminos: () => _abrirUrl(AppConstants.terminosUrl),
                    onAbrirPrivacidad: () =>
                        _abrirUrl(AppConstants.privacidadUrl),
                    isLoading: isLoading,
                    onSubmit: _handleRegister,
                  ),
                  SizedBox(height: size.height * 0.03),
                  _EnlaceLogin(
                    onTap: () => Navigator.pushNamed(context, '/login'),
                  ),
                  SizedBox(height: size.height * 0.03),
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
          'Únete a\nExploraChiapas',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.primary(context),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Selecciona tu perfil y comienza la aventura',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary(context),
          ),
        ),
      ],
    );
  }
}

class _FormularioRegistro extends StatelessWidget {
  final String tipoUsuario;
  final ValueChanged<String> onTipoUsuarioChanged;
  final TextEditingController nombreCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController telefonoCtrl;
  final TextEditingController passCtrl;
  final TextEditingController confirmCtrl;
  final String? nombreError;
  final String? emailError;
  final String? telefonoError;
  final String? passwordError;
  final String? confirmError;
  final bool aceptoTerminos;
  final ValueChanged<bool> onAceptoTerminosChanged;
  final VoidCallback onAbrirTerminos;
  final VoidCallback onAbrirPrivacidad;
  final bool isLoading;
  final VoidCallback onSubmit;

  const _FormularioRegistro({
    required this.tipoUsuario,
    required this.onTipoUsuarioChanged,
    required this.nombreCtrl,
    required this.emailCtrl,
    required this.telefonoCtrl,
    required this.passCtrl,
    required this.confirmCtrl,
    required this.nombreError,
    required this.emailError,
    required this.telefonoError,
    required this.passwordError,
    required this.confirmError,
    required this.aceptoTerminos,
    required this.onAceptoTerminosChanged,
    required this.onAbrirTerminos,
    required this.onAbrirPrivacidad,
    required this.isLoading,
    required this.onSubmit,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RegisterUserType(
            selected: tipoUsuario,
            onChanged: onTipoUsuarioChanged,
          ),
          const SizedBox(height: 18),
          RegisterField(
            controller: nombreCtrl,
            label: 'NOMBRE',
            hint: 'Tu nombre completo',
            icon: Icons.person_outline,
            errorText: nombreError,
          ),
          const SizedBox(height: 16),
          RegisterField(
            controller: emailCtrl,
            label: 'EMAIL',
            hint: 'explorador@selva.com',
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            errorText: emailError,
          ),
          const SizedBox(height: 16),
          RegisterField(
            controller: telefonoCtrl,
            label: 'TELÉFONO',
            hint: '10 dígitos',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            // Bloquea directamente cualquier caracter que no sea dígito y
            // limita la longitud a 10 mientras se escribe, además de la
            // validación que se muestra al enviar.
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(ValidadoresAuth.telefonoDigitos),
            ],
            errorText: telefonoError,
          ),
          const SizedBox(height: 16),
          RegisterField(
            controller: passCtrl,
            label: 'CONTRASEÑA',
            hint: 'Mínimo $_minPasswordLength caracteres',
            icon: Icons.lock_outline,
            isPassword: true,
            errorText: passwordError,
          ),
          const SizedBox(height: 16),
          RegisterField(
            controller: confirmCtrl,
            label: 'REPITE CONTRASEÑA',
            hint: 'Vuelve a escribirla',
            icon: Icons.lock_outline,
            isPassword: true,
            errorText: confirmError,
          ),
          const SizedBox(height: 18),
          _AceptoTerminos(
            value: aceptoTerminos,
            onChanged: onAceptoTerminosChanged,
            onAbrirTerminos: onAbrirTerminos,
            onAbrirPrivacidad: onAbrirPrivacidad,
          ),
          const SizedBox(height: 16),
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
                      'Crear Cuenta',
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

class _AceptoTerminos extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final VoidCallback onAbrirTerminos;
  final VoidCallback onAbrirPrivacidad;

  const _AceptoTerminos({
    required this.value,
    required this.onChanged,
    required this.onAbrirTerminos,
    required this.onAbrirPrivacidad,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Checkbox(
          value: value,
          activeColor: AppColors.primary(context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          onChanged: (val) => onChanged(val ?? false),
        ),
        Expanded(
          child: Wrap(
            children: [
              Text(
                'Acepto los ',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary(context),
                ),
              ),
              GestureDetector(
                onTap: onAbrirTerminos,
                child: Text(
                  'Términos y Condiciones',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primary(context),
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.primary(context),
                  ),
                ),
              ),
              Text(
                ' y la ',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary(context),
                ),
              ),
              GestureDetector(
                onTap: onAbrirPrivacidad,
                child: Text(
                  'Política de Privacidad',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primary(context),
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.primary(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EnlaceLogin extends StatelessWidget {
  final VoidCallback onTap;
  const _EnlaceLogin({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿Ya tienes cuenta? ',
          style: TextStyle(color: AppColors.textSecondary(context)),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            'Inicia sesión',
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
