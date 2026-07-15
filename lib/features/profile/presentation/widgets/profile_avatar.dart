import 'package:flutter/material.dart';
import '../../../../core/di/injector.dart'; // ajusta al path real de getIt
import '../../../../core/services/avatar/avatar_service.dart';

/// Widget reutilizable que muestra el avatar del usuario.
/// Carga la URL desde [AvatarService] (SharedPreferences).
/// Se usa en ProfilePage y EditProfilePage.
class ProfileAvatar extends StatefulWidget {
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
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  String? _avatarUrl;
  bool    _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final service = getIt<AvatarService>();
      final url     = await service.getAvatarUrl();
      if (mounted) setState(() => _avatarUrl = url);
    } catch (_) {
      // _avatarUrl queda null → muestra ícono
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasAction = widget.onTap != null;

    final avatar = AspectRatio(
      aspectRatio: 1,
      child: CircleAvatar(
        radius: widget.radius,
        backgroundColor: const Color(0xFFE8F5E9),
        backgroundImage:
            (_avatarUrl != null && !_loading) ? NetworkImage(_avatarUrl!) : null,
        child: _loading
            ? SizedBox(
                width: widget.radius * 0.55,
                height: widget.radius * 0.55,
                child: const CircularProgressIndicator(
                  color: Color(0xFF2E7D32),
                  strokeWidth: 2.5,
                ),
              )
            : (_avatarUrl == null
                ? Icon(
                    Icons.person,
                    size: widget.radius * 0.85,
                    color: const Color(0xFF2E7D32),
                  )
                : null),
      ),
    );

    if (!hasAction) return avatar;

    return GestureDetector(
      onTap: widget.onTap,
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
              widget.showEditButton
                  ? Icons.edit
                  : Icons.camera_alt_outlined,
              color: Colors.white,
              size: widget.showEditButton ? 14 : 18,
            ),
          ),
        ],
      ),
    );
  }
}