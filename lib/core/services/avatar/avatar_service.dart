abstract class AvatarService {
  Future<String> asignarAvatarPorNombre(String nombre);
  Future<String> getAvatarUrl();
  String avatarPorDefecto({required String seed});
}
