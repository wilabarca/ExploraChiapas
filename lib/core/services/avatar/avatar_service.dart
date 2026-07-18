abstract class AvatarService {
  /// Genera una URL de avatar determinística a partir de una semilla
  /// (normalmente el nombre o id del usuario). Mismo seed → mismo avatar.
  /// No persiste nada — se usa como respaldo visual cuando el usuario
  /// no tiene foto propia en el backend.
  String avatarPorDefecto({required String seed});
}
