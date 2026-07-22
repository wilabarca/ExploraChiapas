import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/auth_provider.dart';
import '../widgets/interest_card.dart';

import '../../domain/entities/user_interests.dart';

import '../../../../core/permissions/location_permission.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_constants.dart';

class InterestsPage extends StatefulWidget {
  const InterestsPage({super.key});

  @override
  State<InterestsPage> createState() => _InterestsPageState();
}

class _InterestsPageState extends State<InterestsPage> {
  final Set<String> _selectedIds = {};

  List<UserInterest> _categorias = [];

  bool _isLoading = false;
  bool _isInitialLoading = true;
  bool _isEditing = false;

  String? _loadError;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = context.read<AuthProvider>();

    /*
     * Las categorías disponibles vienen
     * siempre del backend.
     */
    final categories = await provider.loadInterestCategories();

    if (!mounted) return;

    if (categories == null) {
      setState(() {
        _isInitialLoading = false;
        _loadError =
            provider.errorMessage ?? 'No se pudieron cargar los intereses';
      });

      return;
    }

    /*
     * Revisar si ya existe una sesión.
     *
     * Durante un registro nuevo puede que
     * todavía no exista JWT porque el
     * auto-login ocurre al continuar.
     */
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString(AppConstants.jwtTokenKey);

    UserInterests? current;

    if (token != null && token.isNotEmpty) {
      current = await provider.loadUserInterests();

      if (!mounted) return;

      if (current == null) {
        setState(() {
          _isInitialLoading = false;
          _loadError =
              provider.errorMessage ?? 'No se pudieron cargar tus intereses';
        });

        return;
      }
    }

    if (!mounted) return;

    setState(() {
      _categorias = categories;

      if (current != null) {
        _selectedIds
          ..clear()
          ..addAll(current.interests.map((interest) => interest.id));

        _isEditing = current.onboardingCompleted;
      }

      _isInitialLoading = false;
      _loadError = null;
    });
  }

  void _toggle(String categoryId) {
    setState(() {
      if (_selectedIds.contains(categoryId)) {
        _selectedIds.remove(categoryId);
      } else {
        _selectedIds.add(categoryId);
      }
    });
  }

  Future<bool> _ensureAuthenticatedAfterRegistration(
    AuthProvider provider,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final currentToken = prefs.getString(AppConstants.jwtTokenKey);

    /*
     * Si ya tenemos JWT no hace falta
     * volver a iniciar sesión.
     */
    if (currentToken != null && currentToken.isNotEmpty) {
      return true;
    }

    final registroData = provider.registroData;

    if (registroData == null) {
      return false;
    }

    final email = registroData['email'] as String?;

    final password = registroData['password'] as String?;

    if (email == null || password == null) {
      return false;
    }

    return provider.login(email: email, password: password);
  }

  Future<void> _handleContinuar() async {
    if (_selectedIds.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final provider = context.read<AuthProvider>();

    try {
      /*
       * Para un usuario recién registrado,
       * primero debemos asegurarnos de tener
       * JWT antes de llamar PUT /users/interests.
       */
      final authenticated = await _ensureAuthenticatedAfterRegistration(
        provider,
      );

      if (!mounted) return;

      if (!authenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.errorMessage ?? 'No se pudo iniciar la sesión',
            ),
            backgroundColor: AppColors.error(context),
          ),
        );

        return;
      }

      /*
       * Aquí se guardan REALMENTE los UUID
       * en usuario_interes mediante backend.
       */
      final success = await provider.saveUserInterests(
        categoryIds: _selectedIds.toList(),
      );

      if (!mounted) return;

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.errorMessage ??
                  'No se pudieron guardar '
                      'los intereses',
            ),
            backgroundColor: AppColors.error(context),
          ),
        );

        return;
      }

      provider.clearRegistroData();

      /*
       * Si venimos desde Perfil → Editar,
       * simplemente regresamos al perfil.
       */
      if (_isEditing) {
        Navigator.pop(context, true);

        return;
      }

      /*
       * Onboarding inicial.
       */
      await LocationPermissionHelper().requestWithDialog(context);

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } catch (e) {
      // Antes no había ningún catch aquí: cualquier excepción
      // inesperada (ej. Geolocator fallando justo al volver de segundo
      // plano) se propagaba sin control y dejaba la pantalla rota. Ahora
      // se avisa al usuario y puede reintentar.
      debugPrint('[InterestsPage] Error inesperado al guardar: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Ocurrió un problema inesperado. Intenta de nuevo.',
            ),
            backgroundColor: AppColors.error(context),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  IconData _iconFor(String name) {
    switch (name.toLowerCase()) {
      case 'naturaleza':
        return Icons.eco_outlined;

      case 'cultura':
        return Icons.account_balance_outlined;

      case 'gastronomía':
      case 'gastronomia':
        return Icons.restaurant_outlined;

      case 'aventura':
        return Icons.kayaking_outlined;

      case 'arqueología':
      case 'arqueologia':
        return Icons.temple_buddhist_outlined;

      case 'pueblos mágicos':
      case 'pueblos magicos':
        return Icons.location_city_outlined;

      case 'festivales':
        return Icons.celebration_outlined;

      case 'talleres':
        return Icons.palette_outlined;

      default:
        return Icons.explore_outlined;
    }
  }

  String _imageFor(String name) {
    switch (name.toLowerCase()) {
      case 'naturaleza':
        return 'https://images.unsplash.com/'
            'photo-1464822759023-fed622ff2c3b'
            '?w=800&q=80';

      case 'cultura':
        return 'https://images.unsplash.com/'
            'photo-1518638150340-f706e86654de'
            '?w=800&q=80';

      case 'gastronomía':
      case 'gastronomia':
        return 'https://images.unsplash.com/'
            'photo-1504674900247-0877df9cc836'
            '?w=800&q=80';

      case 'aventura':
        return 'https://images.unsplash.com/'
            'photo-1502126324834-38f8e02d7160'
            '?w=800&q=80';

      default:
        return 'https://images.unsplash.com/'
            'photo-1516026672322-bc52d61a55d5'
            '?w=800&q=80';
    }
  }

  Widget _buildCategory(UserInterest category) {
    return InterestCard(
      nombre: category.name,
      icono: _iconFor(category.name),
      imageUrl: _imageFor(category.name),
      isSelected: _selectedIds.contains(category.id),
      onTap: () => _toggle(category.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return Scaffold(
        backgroundColor: AppColors.surface(context),
        body: const SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        backgroundColor: AppColors.surface(context),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 50),
                  const SizedBox(height: 12),
                  Text(_loadError!, textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isInitialLoading = true;
                        _loadError = null;
                      });

                      _loadData();
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

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
                      _isEditing
                          ? 'Edita tus intereses'
                          : '¿Qué tipo de turismo\n'
                                'te interesa?',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Personalizaremos tu '
                      'aventura en Chiapas '
                      'basándonos en tus '
                      'preferencias.',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary(context),
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 24),

                    if (_categorias.isNotEmpty)
                      AspectRatio(
                        aspectRatio: 16 / 7,
                        child: _buildCategory(_categorias.first),
                      ),

                    if (_categorias.length > 1) const SizedBox(height: 10),

                    if (_categorias.length > 1)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _categorias.length - 1,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1,
                            ),
                        itemBuilder: (context, index) {
                          return _buildCategory(_categorias[index + 1]);
                        },
                      ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: (_selectedIds.isEmpty || _isLoading)
                          ? null
                          : _handleContinuar,
                      icon: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: AppColors.onPrimary(context),
                                strokeWidth: 2.5,
                              ),
                            )
                          : Icon(
                              Icons.arrow_forward,
                              color: AppColors.onPrimary(context),
                            ),
                      label: Text(
                        _isLoading
                            ? 'Guardando...'
                            : _isEditing
                            ? 'Guardar cambios'
                            : 'Continuar',
                        style: TextStyle(
                          color: AppColors.onPrimary(context),
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary(context),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Puedes cambiar esto '
                    'más tarde en tu perfil.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary(context),
                    ),
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
