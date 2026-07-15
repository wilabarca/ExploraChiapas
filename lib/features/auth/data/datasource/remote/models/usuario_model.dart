import '../../../../domain/entities/usuario.dart';

class UsuarioModel extends Usuario {
  const UsuarioModel({
    required super.id,
    required super.name,
    required super.email,
    super.phone,
    required super.userTypeId,
    required super.registeredAt,
    required super.isPremium,
    required super.active,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id:           json['id'] as String,
      name:         json['name'] as String,
      email:        json['email'] as String,
      phone:        json['phone'] as String?,
      userTypeId:   json['userTypeId'] as String,
      registeredAt: DateTime.parse(json['registeredAt'] as String),
      isPremium:    json['isPremium'] as bool? ?? false,
      active:       json['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id':           id,
      'name':         name,
      'email':        email,
      'phone':        phone,
      'userTypeId':   userTypeId,
      'registeredAt': registeredAt.toIso8601String(),
      'isPremium':    isPremium,
      'active':       active,
    };
  }
}