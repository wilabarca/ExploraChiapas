import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/register_field.dart';
import '../providers/auth_provider.dart';
import '../../../../core/permissions/location_permission.dart';
import '../../../../core/utils/app_constants.dart';
import '../../../../core/services/google_auth_service.dart';
import '../../../../core/theme/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // ── Abre URL en el navegador del sistema ──────────────────────────────────
  Future<void> _abrirUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _handleGoogleLogin() async {
    final account = await GoogleAuthService.signIn();
    if (account == null) return;

    final auth    = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:         Text('No se pudo obtener el token de Google'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!mounted) return;
    final provider = context.read<AuthProvider>();
    final success = await provider.loginWithGoogle(idToken: idToken);

    if (!mounted) return;

if (success) {
  await _continuarDespuesDeLogin(
    provider,
  );
} else {
  ScaffoldMessenger.of(context)
      .showSnackBar(
    SnackBar(
      content: Text(
        provider.errorMessage ??
            'Error al iniciar sesión '
                'con Google',
      ),
      backgroundColor: Colors.red,
      behavior:
          SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(12),
      ),
    ),
  );

  provider.resetStatus();
}
  }

  Future<void> _continuarDespuesDeLogin(
  AuthProvider provider,
) async {
  final interests =
      await provider.loadUserInterests();

  if (!mounted) return;

  if (interests == null) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          provider.errorMessage ??
              'No se pudo verificar '
                  'la configuración '
                  'de tu cuenta',
        ),
        backgroundColor: Colors.red,
      ),
    );

    return;
  }

  if (interests.onboardingCompleted) {
    await LocationPermissionHelper()
        .checkAndRequestOnLogin(
      context,
    );

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false,
    );
  } else {
    Navigator.pushReplacementNamed(
      context,
      '/intereses',
    );
  }
}

  Future<void> _handleLogin() async {
    final provider = context.read<AuthProvider>();

    final success = await provider.login(
      email:    _emailCtrl.text.trim(),
      password: _passCtrl.text.trim(),
    );

    if (!mounted) return;

   if (success) {
  await _continuarDespuesDeLogin(
    provider,
  );
} else {
  ScaffoldMessenger.of(context)
      .showSnackBar(
    SnackBar(
      content: Text(
        provider.errorMessage ??
            'Error al iniciar sesión',
      ),
      backgroundColor: Colors.red,
      behavior:
          SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(12),
      ),
    ),
  );

  provider.resetStatus();
}
  }

  @override
  Widget build(BuildContext context) {
    final size      = MediaQuery.sizeOf(context);
    final isLoading =
        context.watch<AuthProvider>().status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: const Color(0xFFF0FAF0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              SizedBox(height: size.height * 0.06),

              // ── Logo más grande ← cambio aquí ──────────────────────────
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 90), // era 60
                child: Image.asset(
                  'assets/images/ExploraChiapas Logo.png',
                  fit: BoxFit.contain,
                ),
              ),

              SizedBox(height: size.height * 0.05),

              const Text(
                'Bienvenido de\nvuelta',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Inicia sesión para continuar tu aventura',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF4CAF50)),
              ),

              SizedBox(height: size.height * 0.05),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFD8F5D8),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    RegisterField(
                      controller: _emailCtrl,
                      hint: 'Email',
                      icon: Icons.person_outline,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 12),

                    RegisterField(
                      controller: _passCtrl,
                      hint: 'Contraseña',
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),

                    const SizedBox(height: 14),

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

                    const SizedBox(height: 28),

                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: 54,
                        minWidth: double.infinity,
                      ),
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary(context),
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
                                'Iniciar Sesión',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: size.height * 0.02),

              // ── Divider ──────────────────────────────────────────────────
              Row(
                children: [
                  Expanded(child: Divider(color: AppColors.textHint(context))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'o',
                      style: TextStyle(
                        color:    AppColors.textSecondary(context),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: AppColors.textHint(context))),
                ],
              ),

              SizedBox(height: size.height * 0.02),

              // ── Botón Continuar con Google ────────────────────────────────
              OutlinedButton.icon(
                onPressed: isLoading ? null : _handleGoogleLogin,
                icon: Image.network(
                  'https://www.google.com/favicon.ico',
                  width:  20,
                  height: 20,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.login, size: 20),
                ),
                label: Text(
                  'Continuar con Google',
                  style: TextStyle(
                    color:      AppColors.textPrimary(context),
                    fontSize:   15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize:  const Size(double.infinity, 52),
                  side:         BorderSide(color: AppColors.border(context)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: AppColors.surface(context),
                ),
              ),

              SizedBox(height: size.height * 0.03),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '¿No tienes cuenta? ',
                    style: TextStyle(color: Color(0xFF4CAF50)),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/registro'),
                    child: const Text(
                      'Regístrate',
                      style: TextStyle(
                        color: Color(0xFF1B5E20),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: size.height * 0.02),

              // ── Links legales ← nuevo ─────────────────────────────────
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 4,
                runSpacing: 4,
                children: [
                  Text(
                    'Al continuar aceptas los',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context)),
                  ),
                  GestureDetector(
                    onTap: () => _abrirUrl(AppConstants.terminosUrl),
                    child: Text(
                      'Términos y Condiciones',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary(context),
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.primary(context),
                      ),
                    ),
                  ),
                  Text(
                    'y la',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context)),
                  ),
                  GestureDetector(
                    onTap: () => _abrirUrl(AppConstants.privacidadUrl),
                    child: Text(
                      'Política de Privacidad',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary(context),
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.primary(context),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: size.height * 0.03),
            ],
          ),
        ),
      ),
    );
  }
}
