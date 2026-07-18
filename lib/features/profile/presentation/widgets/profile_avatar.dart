import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/services/avatar/avatar_service.dart';

class ProfileAvatar extends StatefulWidget {
  final double        radius;
  final VoidCallback? onTap;
  final bool          showEditButton;

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
  bool    _loading  = true;
  bool    _uploading = false;

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _cargarUrl();
  }

  Future<void> _cargarUrl() async {
    try {
      final url = await getIt<AvatarService>().getAvatarUrl();
      if (mounted) setState(() => _avatarUrl = url);
    } catch (_) {
      // muestra ícono por defecto
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Flujo de selección de imagen ────────────────────────────────────────────

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
                color: Colors.grey.shade300,
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
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE8F5E9),
                child: Icon(Icons.camera_alt_outlined, color: Color(0xFF2E7D32)),
              ),
              title: const Text('Tomar foto'),
              onTap: () {
                Navigator.pop(ctx);
                _seleccionarImagen(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE8F5E9),
                child: Icon(Icons.photo_library_outlined, color: Color(0xFF2E7D32)),
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
      source:       source,
      imageQuality: 80,
      maxWidth:     800,
    );
    if (foto == null) return;

    setState(() => _uploading = true);
    try {
      final url = await getIt<AvatarService>().subirFotoReal(foto);
      if (mounted) setState(() => _avatarUrl = url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:         Text('Error al subir la foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final hasAction = widget.onTap != null || widget.showEditButton;

    Widget avatar = AspectRatio(
      aspectRatio: 1,
      child: CircleAvatar(
        radius:          widget.radius,
        backgroundColor: const Color(0xFFE8F5E9),
        backgroundImage: (_avatarUrl != null && !_loading && !_uploading)
            ? NetworkImage(_avatarUrl!)
            : null,
        child: (_loading || _uploading)
            ? SizedBox(
                width:  widget.radius * 0.55,
                height: widget.radius * 0.55,
                child: CircularProgressIndicator(
                  color:       const Color(0xFF2E7D32),
                  strokeWidth: 2.5,
                  value:       _uploading ? null : null,
                ),
              )
            : (_avatarUrl == null
                ? Icon(
                    Icons.person,
                    size:  widget.radius * 0.85,
                    color: const Color(0xFF2E7D32),
                  )
                : null),
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
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_alt_outlined,
              color: Colors.white,
              size:  18,
            ),
          ),
        ],
      ),
    );
  }
}
