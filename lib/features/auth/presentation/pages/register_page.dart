import 'package:flutter/material.dart';
import '../widgets/register_field.dart';
import '../widgets/register_user_type.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String _tipoUsuario = 'Turista';
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF0FAF0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              SizedBox(height: size.height * 0.05),

              Image.asset('assets/images/ExploraChiapas Logo.png', height: 52),

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
                      hint: 'Contraseña',
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

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: lógica de registro
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
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
