import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/services/avatar/avatar_service.dart';

class HomeAppBar extends StatefulWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  String _avatarUrl = '';
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _cargarAvatar();
  }

  Future<void> _cargarAvatar() async {
    final url = await getIt<AvatarService>().getAvatarUrl();
    if (mounted) {
      setState(() {
        _avatarUrl = url;
        _loaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final isSmall = screenW < 360;
    final logoHeight = isSmall ? 28.0 : 34.0;
    final fontSize = isSmall ? 16.0 : 19.0;
    final avatarRadius = isSmall ? 17.0 : 20.0;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: screenW * 0.04,
      // ✅ Sin LayoutBuilder, sin AspectRatio — solo Row con SizedBox fijo
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
          child: CircleAvatar(
            radius: avatarRadius,
            backgroundColor: const Color(0xFFD8F5D8),
            child: ClipOval(
              child: _loaded && _avatarUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: _avatarUrl,
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
                    )
                  : Icon(
                      Icons.person,
                      color: const Color(0xFF2E7D32),
                      size: avatarRadius,
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
