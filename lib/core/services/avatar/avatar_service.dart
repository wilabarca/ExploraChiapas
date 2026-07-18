import 'package:image_picker/image_picker.dart';

abstract class AvatarService {
  Future<String> asignarAvatarPorNombre(String nombre);
  Future<String> getAvatarUrl();
  Future<String> subirFotoReal(XFile foto);
  String avatarPorDefecto({required String seed});
}
