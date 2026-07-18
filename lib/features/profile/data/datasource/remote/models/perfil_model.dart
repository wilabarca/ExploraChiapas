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
    // ⚠️ La API no siempre incluye este campo (usuarios sin foto no lo
    // mandan). Usamos String? + fallback a '' en vez de `as String` para
    // no tronar con el TypeError que estabas viendo.
    // Ajusté también la clave a camelCase ('imgUrl'), igual que el resto
    // de los campos de la API (userTypeId, isPremium, registeredAt).
    // Si al subir una foto por /v1/api/uploads/usuarios/perfil el backend
    // devuelve la clave con otro nombre exacto, avísame y la corrijo.
    ImgUrl: json['imgUrl'] as String? ?? '',
    nombre: json['name'] as String,
    email: json['email'] as String,
    telefono: json['phone'] as String?,
    userTypeId: json['userType'] as String, // ← 'userType', no 'userTypeId'
    isPremium: json['isPremium'] as bool? ?? false,
    active: json['active'] as bool? ?? true,
    registeredAt: DateTime.parse(json['registeredAt'] as String),
  );
}
