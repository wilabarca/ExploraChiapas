import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/register_field.dart';
import '../widgets/register_user_type.dart';
import '../providers/auth_provider.dart';
import '../../domain/entities/usuario_registro.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String _tipoUsuario = 'Turista Nacional';

  final _nombreCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _telefonoCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_nombreCtrl.text.isEmpty ||
        _emailCtrl.text.isEmpty ||
        _telefonoCtrl.text.isEmpty ||
        _passCtrl.text.isEmpty ||
        _confirmCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos.')),
      );
      return;
    }

    if (_passCtrl.text != _confirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden.')),
      );
      return;
    }

    if (_passCtrl.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La contraseña debe tener al menos 8 caracteres.'),
        ),
      );
      return;
    }

    final provider = context.read<AuthProvider>();

    // Mapea el string del selector al enum correcto
    TipoUsuario tipo;
    switch (_tipoUsuario) {
      case 'Turista Nacional':
        tipo = TipoUsuario.turistaNacional;
        break;
      case 'Turista Extranjero':
        tipo = TipoUsuario.turistaExtranjero;
        break;
      default:
        tipo = TipoUsuario.habitanteLocal;
    }

    debugPrint(
      'Registrando: '
      'nombre=${_nombreCtrl.text.trim()} '
      'email=${_emailCtrl.text.trim()} '
      'tipo=$tipo',
    );

    final success = await provider.register(
      UsuarioRegistro(
        nombre: _nombreCtrl.text.trim(),
        correo: _emailCtrl.text.trim(),
        telefono: _telefonoCtrl.text.trim(),
        contrasena: _passCtrl.text.trim(),
        tipoUsuario: tipo,
      ),
    );

    debugPrint('Register result  : success=$success');
    debugPrint('Error message    : ${provider.errorMessage}');
    debugPrint('Status           : ${provider.status}');

    if (!mounted) return;

    if (success) {
      debugPrint('Navegando a /intereses');
      Navigator.pushReplacementNamed(context, '/intereses');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Error al registrarse'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      provider.resetStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isLoading =
        context.watch<AuthProvider>().status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: const Color(0xFFF0FAF0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              SizedBox(height: size.height * 0.05),

              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 60),
                child: Image.asset(
                  'assets/images/ExploraChiapas Logo.png',
                  fit: BoxFit.contain,
                ),
              ),

              SizedBox(height: size.height * 0.04),

              const Text(
                'Únete a\nExploraChiapas',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Selecciona tu perfil y comienza la aventura',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF4CAF50)),
              ),

              SizedBox(height: size.height * 0.04),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFD8F5D8),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RegisterUserType(
                      selected: _tipoUsuario,
                      onChanged: (val) => setState(() => _tipoUsuario = val),
                    ),

                    const SizedBox(height: 20),

                    RegisterField(
                      controller: _nombreCtrl,
                      hint: 'Tu nombre',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 12),

                    RegisterField(
                      controller: _emailCtrl,
                      hint: 'Email',
                      icon: Icons.person_outline,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),

                    RegisterField(
                      controller: _telefonoCtrl,
                      hint: 'Teléfono',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),

                    RegisterField(
                      controller: _passCtrl,
                      hint: 'Contraseña (mín. 8 caracteres)',
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),
                    const SizedBox(height: 12),

                    RegisterField(
                      controller: _confirmCtrl,
                      hint: 'Repite Contraseña',
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),

                    const SizedBox(height: 28),

                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: 54,
                        minWidth: double.infinity,
                      ),
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleRegister,
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
                                'Crear Cuenta',
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

              SizedBox(height: size.height * 0.03),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '¿Ya tienes cuenta? ',
                    style: TextStyle(color: Color(0xFF4CAF50)),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/login'),
                    child: const Text(
                      'Inicia sesión',
                      style: TextStyle(
                        color: Color(0xFF1B5E20),
                        fontWeight: FontWeight.bold,
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
