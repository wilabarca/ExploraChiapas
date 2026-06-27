// Mapea el PublicUser que devuelve la API
class Usuario {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String userTypeId;
  final DateTime registeredAt;
  final bool isPremium;
  final bool active;

  const Usuario({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.userTypeId,
    required this.registeredAt,
    required this.isPremium,
    required this.active,
  });
}
