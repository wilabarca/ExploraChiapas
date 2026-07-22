import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/services/avatar/avatar_service.dart';
import '../providers/profile_provider.dart';

class ProfileAvatar extends StatefulWidget {
  final double radius;
  final VoidCallback? onTap;
  final bool showEditButton;

  const ProfileAvatar({
    super.key,
    required this.radius,
    this.onTap,
    this.showEditButton = false,
  });

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  bool _uploading = false;
  String? _localUrl; // URL guardada en SharedPreferences (fallback offline)

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _cargarUrlLocal();
  }

  Future<void> _cargarUrlLocal() async {
    final url = await getIt<AvatarService>().getAvatarUrl();
    if (mounted && url.isNotEmpty && !url.contains('seed=default')) {
      setState(() => _localUrl = url);
    }
  }

  void _mostrarOpciones() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderSubtle(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Cambiar foto de perfil',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryContainer(context),
                child: Icon(
                  Icons.camera_alt_outlined,
                  color: AppColors.primary(context),
                ),
              ),
              title: const Text('Tomar foto'),
              onTap: () {
                Navigator.pop(ctx);
                _seleccionarImagen(ImageSource.camera);
              },
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryContainer(context),
                child: Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.primary(context),
                ),
              ),
              title: const Text('Elegir de galería'),
              onTap: () {
                Navigator.pop(ctx);
                _seleccionarImagen(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _seleccionarImagen(ImageSource source) async {
    final foto = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (foto == null) return;

    setState(() => _uploading = true);
    try {
      // 1. Subir a Cloudinary y guardar URL en SharedPreferences
      final url = await getIt<AvatarService>().subirFotoReal(foto);

      // 2. Sincronizar la URL al backend para que persista entre sesiones
      if (mounted) {
        await context.read<ProfileProvider>().updatePerfil(fotoPerfilUrl: url);
        setState(() => _localUrl = url);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir la foto: $e'),
            backgroundColor: AppColors.error(context),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasAction = widget.onTap != null || widget.showEditButton;

    final perfil = context.watch<ProfileProvider>().perfil;
    final backendUrl = perfil != null && perfil.ImgUrl.isNotEmpty
        ? perfil.ImgUrl
        : null;
    final avatarUrl =
        backendUrl ??
        _localUrl ??
        getIt<AvatarService>().avatarPorDefecto(
          seed: perfil?.nombre ?? 'explorachiapas',
        );

    Widget avatar = CircleAvatar(
      radius: widget.radius,
      backgroundColor: AppColors.primaryContainer(context),
      child: _uploading
          ? SizedBox(
              width: widget.radius * 0.55,
              height: widget.radius * 0.55,
              child: CircularProgressIndicator(
                color: AppColors.primary(context),
                strokeWidth: 2.5,
              ),
            )
          : ClipOval(
              child: CachedNetworkImage(
                imageUrl: avatarUrl,
                width: widget.radius * 2,
                height: widget.radius * 2,
                fit: BoxFit.cover,
                placeholder: (_, __) => SizedBox(
                  width: widget.radius * 0.55,
                  height: widget.radius * 0.55,
                  child: CircularProgressIndicator(
                    color: AppColors.primary(context),
                    strokeWidth: 2.5,
                  ),
                ),
                errorWidget: (_, __, ___) => Icon(
                  Icons.person,
                  size: widget.radius * 0.85,
                  color: AppColors.primary(context),
                ),
              ),
            ),
    );

    if (!hasAction) return avatar;

    return GestureDetector(
      onTap: widget.showEditButton ? _mostrarOpciones : widget.onTap,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          avatar,
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary(context),
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.showEditButton ? Icons.edit : Icons.camera_alt_outlined,
              color: AppColors.onPrimary(context),
              size: widget.showEditButton ? 14 : 18,
            ),
          ),
        ],
      ),
    );
  }
}
