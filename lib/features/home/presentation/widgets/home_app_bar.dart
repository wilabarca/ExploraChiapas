import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/services/avatar/avatar_service.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Controla si se muestra la flecha de "volver".
  /// Por defecto es `false`: ninguna pantalla que use
  /// `const HomeAppBar()` sin parámetros mostrará la flecha. Si en algún
  /// punto necesitas la flecha de regreso en una pantalla específica,
  /// pásala explícitamente como `HomeAppBar(mostrarFlecha: true)`.
  final bool mostrarFlecha;

  const HomeAppBar({super.key, this.mostrarFlecha = false});

  @override
  Size get preferredSize => const Size.fromHeight(76);

  @override
  Widget build(BuildContext context) {
    // ✓ MediaQuery: en vez de solo 2 tamaños fijos (chico/normal), aquí
    // el tamaño escala proporcional al ancho real de pantalla y se
    // limita con .clamp() para que nunca se vea ni diminuto en un
    // teléfono angosto ni gigante en una tablet.
    final screenW = MediaQuery.of(context).size.width;

    final logoHeight = (screenW * 0.13).clamp(44.0, 60.0);
    final fontSize = (screenW * 0.055).clamp(20.0, 24.0);
    final avatarRadius = (screenW * 0.065).clamp(22.0, 28.0);

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
      // ✓ Sin esto, Flutter mostraría la flecha automáticamente cada vez
      // que la ruta puede hacer pop. Con esto, queda apagada salvo que
      // se pida explícitamente con mostrarFlecha: true.
      automaticallyImplyLeading: mostrarFlecha,
      titleSpacing: screenW * 0.04,
      // ✓ LayoutBuilder: da el ancho real disponible del título para
      // que el logo/texto puedan ajustarse si el espacio es angosto
      // (por ejemplo, cuando sí hay flecha de regreso).
      title: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✓ ConstrainedBox + AspectRatio: el logo mantiene una
              // relación 1:1 y nunca crece más allá de logoHeight.
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: logoHeight,
                  maxHeight: logoHeight,
                ),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset(
                    'assets/images/ExploraChiapas Logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(width: screenW * 0.02),
              // Flexible: el texto se trunca con "…" si el ancho es chico.
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
          );
        },
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
