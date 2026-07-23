import '../../../../../../core/utils/media_url_resolver.dart';
import '../../../../domain/entities/perfil_entity.dart';

class PerfilModel extends PerfilEntity {
  const PerfilModel({
    required super.id,
    required super.ImgUrl,
    required super.nombre,
    required super.email,
    super.telefono,
    required super.userTypeId,
    required super.isPremium,
    required super.active,
    required super.registeredAt,
  });

  factory PerfilModel.fromJson(Map<String, dynamic> json) => PerfilModel(
    id: json['id'] as String,
    ImgUrl: resolveMediaUrl(json['imgUrl'] as String?) ?? '',
    nombre: json['name'] as String,
    email: json['email'] as String,
    telefono: json['phone'] as String?,
    userTypeId: json['userType'] as String,
    isPremium: json['isPremium'] as bool? ?? false,
    active: json['active'] as bool? ?? true,
    registeredAt: DateTime.parse(json['registeredAt'] as String),
  );
}
