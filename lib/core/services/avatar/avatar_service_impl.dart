import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_constants.dart';
import '../cloudinary/cloudinary_service.dart';
import 'avatar_service.dart';

@LazySingleton(as: AvatarService)
class AvatarServiceImpl implements AvatarService {
  static const String _dicebearUrl =
      'https://api.dicebear.com/9.x/adventurer/png';

  @override
  Future<String> asignarAvatarPorNombre(String nombre) async {
    final seed = nombre.trim().isEmpty
        ? 'explorachiapas'
        : nombre.trim().split(' ').first.toLowerCase();
    final url = '$_dicebearUrl?seed=${Uri.encodeComponent(seed)}';
    await _guardarUrl(url);
    return url;
  }

  @override
  Future<String> getAvatarUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.fotoPerfil) ??
        '$_dicebearUrl?seed=default';
  }

  @override
  Future<String> subirFotoReal(XFile foto) async {
    final url = await CloudinaryService.subirImagen(
      foto,
      folder: AppConstants.cloudFolderAvatares,
    );
    await _guardarUrl(url);
    return url;
  }

  @override
  String avatarPorDefecto({required String seed}) {
    final semilla = seed.trim().isEmpty ? 'explorachiapas' : seed.trim();
    return '$_dicebearUrl?seed=${Uri.encodeComponent(semilla)}';
  }

  Future<void> _guardarUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.fotoPerfil, url);
  }
}
