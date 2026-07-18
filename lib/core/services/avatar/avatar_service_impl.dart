import 'package:injectable/injectable.dart';
import 'avatar_service.dart';

@LazySingleton(as: AvatarService)
class AvatarServiceImpl implements AvatarService {
  static const String _dicebearUrl =
      'https://api.dicebear.com/9.x/adventurer/png';

  @override
  String avatarPorDefecto({required String seed}) {
    final semilla = seed.trim().isEmpty ? 'explorachiapas' : seed.trim();
    return '$_dicebearUrl?seed=${Uri.encodeComponent(semilla)}';
  }
}
