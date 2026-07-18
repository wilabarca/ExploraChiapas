import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/services/avatar/avatar_service.dart';
import '../providers/profile_provider.dart';

/// Widget reutilizable que muestra el avatar del usuario.
/// Lee la foto real desde [ProfileProvider.perfil.ImgUrl]; si viene
/// vacío, usa [AvatarService.avatarPorDefecto] como respaldo visual.
/// Se usa en ProfilePage y EditProfilePage.
class ProfileAvatar extends StatelessWidget {
  final double radius;

  /// Si [onTap] no es null, muestra el botón de cámara y llama al callback.
  final VoidCallback? onTap;

  /// Si true, muestra el botón de editar (ícono de lápiz verde) en lugar de cámara.
  final bool showEditButton;

  const ProfileAvatar({
    super.key,
    required this.radius,
    this.onTap,
    this.showEditButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasAction = onTap != null;

    final perfil = context.watch<ProfileProvider>().perfil;
    final tieneFotoPropia = perfil != null && perfil.ImgUrl.isNotEmpty;
    final avatarUrl = tieneFotoPropia
        ? perfil.ImgUrl
        : getIt<AvatarService>().avatarPorDefecto(
            seed: perfil?.nombre ?? perfil?.id ?? 'explorachiapas',
          );

    final avatar = AspectRatio(
      aspectRatio: 1,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFFE8F5E9),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: avatarUrl,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            placeholder: (_, __) => SizedBox(
              width: radius * 0.55,
              height: radius * 0.55,
              child: const CircularProgressIndicator(
                color: Color(0xFF2E7D32),
                strokeWidth: 2.5,
              ),
            ),
            errorWidget: (_, __, ___) => Icon(
              Icons.person,
              size: radius * 0.85,
              color: const Color(0xFF2E7D32),
            ),
          ),
        ),
      ),
    );

    if (!hasAction) return avatar;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          avatar,
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32),
              shape: BoxShape.circle,
            ),
            child: Icon(
              showEditButton ? Icons.edit : Icons.camera_alt_outlined,
              color: Colors.white,
              size: showEditButton ? 14 : 18,
            ),
          ),
        ],
      ),
    );
  }
}
