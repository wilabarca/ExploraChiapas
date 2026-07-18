import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/app_constants.dart';

class CloudinaryService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  /// Sube [foto] a Cloudinary y devuelve la URL segura (CDN).
  /// [folder] define la carpeta en Cloudinary (usar AppConstants.cloudFolder*).
  static Future<String> subirImagen(XFile foto, {String folder = ''}) async {
    final url = 'https://api.cloudinary.com/v1_1'
        '/${AppConstants.cloudinaryCloudName}/image/upload';

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        foto.path,
        filename: foto.name,
      ),
      'upload_preset': AppConstants.cloudinaryUploadPreset,
      if (folder.isNotEmpty) 'folder': folder,
    });

    final response = await _dio.post(url, data: formData);
    final data = response.data as Map<String, dynamic>;
    return data['secure_url'] as String;
  }

  /// Devuelve una URL de transformación de Cloudinary con tamaño y calidad optimizados.
  /// Útil para mostrar miniaturas sin descargar la imagen original.
  static String thumbnail(String url, {int width = 200, int height = 200}) {
    // Inserta transformaciones en la URL de Cloudinary:
    // .../upload/c_fill,h_200,w_200,q_auto/...
    return url.replaceFirst(
      '/upload/',
      '/upload/c_fill,h_${height},w_${width},q_auto,f_auto/',
    );
  }
}
