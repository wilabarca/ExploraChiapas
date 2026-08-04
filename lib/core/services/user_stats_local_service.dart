import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Contador local de reseñas creadas por el usuario desde este dispositivo.
///
/// La API no expone un endpoint de "mis reseñas": `GET /reviews` exige
/// `targetType` + `targetId` de un lugar puntual (ambos obligatorios), no
/// hay forma de pedir "todas las reseñas de este usuario" en una sola
/// llamada. Este contador es la fuente honesta disponible sin tocar el
/// backend: solo cuenta reseñas realmente publicadas a través de la app
/// (se incrementa justo cuando `POST /reviews` responde éxito), nunca un
/// valor inventado — aunque, por la misma razón, no puede reflejar
/// reseñas creadas antes de que este contador existiera.
@lazySingleton
class UserStatsLocalService {
  static const _keyResenasCreadas = 'stats_resenas_creadas';

  Future<int> obtenerResenasCreadas() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyResenasCreadas) ?? 0;
  }

  Future<int> incrementarResenasCreadas() async {
    final prefs = await SharedPreferences.getInstance();
    final actual = (prefs.getInt(_keyResenasCreadas) ?? 0) + 1;
    await prefs.setInt(_keyResenasCreadas, actual);
    return actual;
  }

  /// Este contador vive en `SharedPreferences`, que es POR DISPOSITIVO,
  /// no por usuario — si no se limpia al cerrar sesión (o al iniciar una
  /// nueva), un usuario distinto en el mismo dispositivo hereda el
  /// conteo del usuario anterior. Se llama desde `AuthProvider` en cada
  /// cambio de sesión.
  Future<void> resetResenasCreadas() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyResenasCreadas);
  }
}
