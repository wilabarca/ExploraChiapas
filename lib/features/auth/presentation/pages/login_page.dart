import 'package:flutter/material.dart';
import '../widgets/register_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
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
              SizedBox(height: size.height * 0.06),

              Image.asset('assets/images/ExploraChiapas Logo.png', height: 52),

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
                        child: const Text(
                          '¿Olvidaste tu contraseña?',
                          style: TextStyle(
                            color: Color(0xFF2E7D32),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: lógica de login
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
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

              SizedBox(height: size.height * 0.03),
            ],
          ),
        ),
      ),
    );
  }
}
