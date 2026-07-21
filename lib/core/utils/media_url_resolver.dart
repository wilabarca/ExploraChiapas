import 'app_constants.dart';

/// Convierte una ruta de imagen devuelta por el backend en una URL
/// absoluta y cargable.
///
/// El backend guarda las imágenes subidas (eventos, promociones,
/// negocios) como rutas relativas tipo `/uploads/eventos/foto.jpg`,
/// servidas desde la raíz del servidor (`serverBaseUrl`), NO desde
/// `{baseUrl}` (que ya incluye el prefijo `/v1/api` de la API REST).
/// Si se le antepone `baseUrl` por error, la URL queda mal formada
/// (`.../v1/api/uploads/...`) y la imagen nunca carga.
///
/// URLs que ya vienen absolutas (ej. Cloudinary, avatares) se devuelven
/// intactas.
String? resolveMediaUrl(String? path) {
  if (path == null) return null;

  final value = path.trim();
  if (value.isEmpty) return null;

  if (value.startsWith('http://') || value.startsWith('https://')) {
    return value;
  }

  return '${AppConstants.serverBaseUrl}${value.startsWith('/') ? value : '/$value'}';
}
