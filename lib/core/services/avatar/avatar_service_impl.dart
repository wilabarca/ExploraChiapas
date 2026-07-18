import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_constants.dart';
import '../cloudinary/cloudinary_service.dart';
import 'avatar_service.dart';

@LazySingleton(as: AvatarService)
class AvatarServiceImpl implements AvatarService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  static const String _genderizeUrl = 'https://api.genderize.io';
  static const String _dicebearUrl  =
      'https://api.dicebear.com/9.x/adventurer/png';
  static const double _minProbability = 0.60;

  @override
  Future<String> asignarAvatarPorNombre(String nombre) async {
    try {
      final primerNombre = nombre.trim().split(' ').first.toLowerCase();

      final response = await _dio.get(
        _genderizeUrl,
        queryParameters: {'name': primerNombre},
      );

      final data   = response.data as Map<String, dynamic>;
      final gender = data['gender'] as String?;
      final prob   = (data['probability'] as num?)?.toDouble() ?? 0.0;

      String generoParam;
      if (gender == 'male' && prob >= _minProbability) {
        generoParam = 'male';
      } else if (gender == 'female' && prob >= _minProbability) {
        generoParam = 'female';
      } else {
        generoParam = '';
      }

      final avatarUrl = _buildAvatarUrl(seed: primerNombre, gender: generoParam);
      await _guardarUrl(avatarUrl);
      return avatarUrl;
    } catch (_) {
      final urlDefault = _buildAvatarUrl(
        seed:   nombre.toLowerCase(),
        gender: '',
      );
      await _guardarUrl(urlDefault);
      return urlDefault;
    }
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

  Future<void> _guardarUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.fotoPerfil, url);
  }

  String _buildAvatarUrl({required String seed, required String gender}) {
    final buffer = StringBuffer('$_dicebearUrl?seed=$seed');
    if (gender.isNotEmpty) {
      buffer.write('&gender[]=$gender');
    }
    return buffer.toString();
  }
}
