import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/interest_card.dart';
import '../providers/auth_provider.dart';
import '../../../../core/permissions/location_permission.dart';
import '../../../../core/theme/app_colors.dart';

class InterestsPage extends StatefulWidget {
  const InterestsPage({super.key});

  @override
  State<InterestsPage> createState() => _InterestsPageState();
}

class _InterestsPageState extends State<InterestsPage> {
  final Set<String> _selected = {};
  bool _isLoading = false;

  final List<Map<String, dynamic>> _categorias = [
    {
      'nombre': 'Naturaleza',
      'icono': Icons.eco_outlined,
      'imagen':
          'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800&q=80',
    },
    {
      'nombre': 'Cultura',
      'icono': Icons.account_balance_outlined,
      'imagen':
          'https://images.unsplash.com/photo-1518638150340-f706e86654de?w=800&q=80',
    },
    {
      'nombre': 'Gastronomía',
      'icono': Icons.restaurant_outlined,
      'imagen':
          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&q=80',
    },
    {
      'nombre': 'Descanso',
      'icono': Icons.spa_outlined,
      'imagen':
          'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=800&q=80',
    },
    {
      'nombre': 'Aventura',
      'icono': Icons.kayaking_outlined,
      'imagen':
          'https://images.unsplash.com/photo-1502126324834-38f8e02d7160?w=800&q=80',
    },
  ];

  void _toggle(String nombre) {
    setState(() {
      if (_selected.contains(nombre)) {
        _selected.remove(nombre);
      } else {
        _selected.add(nombre);
      }
    });
  }

  Future<void> _handleContinuar() async {
    setState(() => _isLoading = true);

    try {
      // 1. Guardar intereses y marcar onboarding completo
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('intereses', _selected.toList());
      await prefs.setBool('onboarding_completo', true);

      if (!mounted) return;

      // 2. Auto-login tras registro usando credenciales guardadas
      final authProvider = context.read<AuthProvider>();
      final registroData = authProvider.registroData;

      if (registroData != null) {
        final email = registroData['email'] as String?;
        final password = registroData['password'] as String?;

        if (email != null && password != null) {
          debugPrint('Auto-login tras registro: $email');
          final success = await authProvider.login(
            email: email,
            password: password,
          );
          if (success) {
            debugPrint('Auto-login exitoso');
          } else {
            debugPrint('Auto-login falló: ${authProvider.errorMessage}');
          }
        }
      }

      // 3. Limpiar datos sensibles de memoria
      authProvider.clearRegistroData();

      if (!mounted) return;

      // 4. Pedir permisos de ubicación
      await LocationPermissionHelper().requestWithDialog(context);

      if (!mounted) return;

      // 5. Navegar al home
      Navigator.pushReplacementNamed(context, '/home');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface(context),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),

                    Text(
                      '¿Qué tipo de turismo\nte interesa?',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Personalizaremos tu aventura en Chiapas\nbasándonos en tus preferencias.',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary(context),
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Tarjetas de intereses ──
                    AspectRatio(
                      aspectRatio: 16 / 7,
                      child: InterestCard(
                        nombre: _categorias[0]['nombre'],
                        icono: _categorias[0]['icono'],
                        imageUrl: _categorias[0]['imagen'],
                        isSelected: _selected.contains(
                          _categorias[0]['nombre'],
                        ),
                        onTap: () => _toggle(_categorias[0]['nombre']),
                      ),
                    ),

                    const SizedBox(height: 10),

                    IntrinsicHeight(
                      child: Row(
                        children: [
                          Expanded(
                            child: AspectRatio(
                              aspectRatio: 1.0,
                              child: InterestCard(
                                nombre: _categorias[1]['nombre'],
                                icono: _categorias[1]['icono'],
                                imageUrl: _categorias[1]['imagen'],
                                isSelected: _selected.contains(
                                  _categorias[1]['nombre'],
                                ),
                                onTap: () => _toggle(_categorias[1]['nombre']),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: AspectRatio(
                              aspectRatio: 1.0,
                              child: InterestCard(
                                nombre: _categorias[2]['nombre'],
                                icono: _categorias[2]['icono'],
                                imageUrl: _categorias[2]['imagen'],
                                isSelected: _selected.contains(
                                  _categorias[2]['nombre'],
                                ),
                                onTap: () => _toggle(_categorias[2]['nombre']),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    IntrinsicHeight(
                      child: Row(
                        children: [
                          Expanded(
                            child: AspectRatio(
                              aspectRatio: 1.0,
                              child: InterestCard(
                                nombre: _categorias[3]['nombre'],
                                icono: _categorias[3]['icono'],
                                imageUrl: _categorias[3]['imagen'],
                                isSelected: _selected.contains(
                                  _categorias[3]['nombre'],
                                ),
                                onTap: () => _toggle(_categorias[3]['nombre']),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: AspectRatio(
                              aspectRatio: 1.0,
                              child: InterestCard(
                                nombre: _categorias[4]['nombre'],
                                icono: _categorias[4]['icono'],
                                imageUrl: _categorias[4]['imagen'],
                                isSelected: _selected.contains(
                                  _categorias[4]['nombre'],
                                ),
                                onTap: () => _toggle(_categorias[4]['nombre']),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Botón Continuar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Column(
                children: [
                  FractionallySizedBox(
                    widthFactor: 1.0,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 54),
                      child: ElevatedButton.icon(
                        onPressed: (_selected.isEmpty || _isLoading)
                            ? null
                            : _handleContinuar,
                        icon: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                              ),
                        label: Text(
                          _isLoading ? 'Configurando...' : 'Continuar',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary(context),
                          disabledBackgroundColor: const Color(0xFFB0BEC5),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Puedes cambiar esto más tarde en tu perfil.',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary(context)),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
