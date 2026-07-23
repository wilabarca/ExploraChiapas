import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/storage/secure_session_storage.dart';
import '../../../../core/utils/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import 'home_turista_page.dart';
import 'home_local_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _tipoUsuario = '';
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _cargarTipo();
  }

  Future<void> _cargarTipo() async {
    final tipoUsuario = await getIt<SecureSessionStorage>().getTipoUsuario();
    setState(() {
      _tipoUsuario = tipoUsuario ?? '';
      _loaded = true;
    });
    debugPrint('🏠 Tipo de usuario cargado: $_tipoUsuario');

    if (mounted) {
      final profileProvider = context.read<ProfileProvider>();
      if (profileProvider.perfil == null) {
        profileProvider.loadPerfil();
      }
    }
  }

  bool get _esLocal => _tipoUsuario == AppConstants.tipoHabitanteLocal;

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary(context)),
        ),
      );
    }

    return _esLocal ? const HomeLocalPage() : const HomeTuristaPage();
  }
}
