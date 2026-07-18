import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/services/avatar/avatar_service.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final isSmall = screenW < 360;
    final logoHeight = isSmall ? 28.0 : 34.0;
    final fontSize = isSmall ? 16.0 : 19.0;
    final avatarRadius = isSmall ? 17.0 : 20.0;

    // ✅ Una sola fuente de verdad: ProfileProvider.perfil.
    // PerfilEntity.ImgUrl es String (no nullable); si viene vacío,
    // significa que el usuario no tiene foto propia y usamos el
    // avatar determinístico por defecto.
    final perfil = context.watch<ProfileProvider>().perfil;
    final tieneFotoPropia = perfil != null && perfil.ImgUrl.isNotEmpty;
    final avatarUrl = tieneFotoPropia
        ? perfil.ImgUrl
        : getIt<AvatarService>().avatarPorDefecto(
            seed: perfil?.nombre ?? perfil?.id ?? 'explorachiapas',
          );

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: screenW * 0.04,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: logoHeight,
            height: logoHeight,
            child: Image.asset(
              'assets/images/ExploraChiapas Logo.png',
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(width: screenW * 0.02),
          Flexible(
            child: Text(
              'ExploraChiapas',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: const Color(0xFF2E7D32),
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
              ),
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: screenW * 0.04),
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/perfil'),
            child: CircleAvatar(
              radius: avatarRadius,
              backgroundColor: const Color(0xFFD8F5D8),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: avatarUrl,
                  width: avatarRadius * 2,
                  height: avatarRadius * 2,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Icon(
                    Icons.person,
                    color: const Color(0xFF2E7D32),
                    size: avatarRadius,
                  ),
                  errorWidget: (_, __, ___) => Icon(
                    Icons.person,
                    color: const Color(0xFF2E7D32),
                    size: avatarRadius,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}