import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/services/avatar/avatar_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool mostrarFlecha;

  const HomeAppBar({super.key, this.mostrarFlecha = false});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final isDark = AppColors.isDark(context);

    // Tamaños proporcionales con clamp para phone → tablet
    final logoSize = (screenW * 0.1).clamp(36.0, 52.0);
    final fontSize = (screenW * 0.052).clamp(18.0, 22.0);
    final avatarRadius = (screenW * 0.06).clamp(20.0, 26.0);

    final perfil = context.watch<ProfileProvider>().perfil;
    final tieneFotoPropia = perfil != null && perfil.ImgUrl.isNotEmpty;
    final avatarUrl = tieneFotoPropia
        ? perfil.ImgUrl
        : getIt<AvatarService>().avatarPorDefecto(
            seed: perfil?.nombre ?? perfil?.id ?? 'explorachiapas',
          );

    return AppBar(
      backgroundColor: AppColors.surface(context),
      elevation: 0,
      automaticallyImplyLeading: mostrarFlecha,
      // Separador sutil que delimita el AppBar del contenido
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(
          height: 1,
          thickness: 1,
          color: AppColors.borderSubtle(context),
        ),
      ),
      titleSpacing: screenW * 0.04,
      title: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo con relación 1:1 fija
              SizedBox(
                width: logoSize,
                height: logoSize,
                child: Image.asset(
                  'assets/images/ExploraChiapas Logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(width: screenW * 0.022),
              // Texto truncable si el espacio es angosto
              Flexible(
                child: Text(
                  'ExploraChiapas',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF2E7D32),
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: screenW * 0.04),
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/perfil'),
            child: Container(
              width: avatarRadius * 2,
              height: avatarRadius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Anillo exterior que destaca el avatar sobre cualquier fondo
                border: Border.all(
                  color: AppColors.primary(context).withValues(alpha: 0.35),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: avatarUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: AppColors.primaryContainer(context),
                    child: Icon(
                      Icons.person,
                      color: AppColors.primary(context),
                      size: avatarRadius * 0.9,
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.primaryContainer(context),
                    child: Icon(
                      Icons.person,
                      color: AppColors.primary(context),
                      size: avatarRadius * 0.9,
                    ),
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
