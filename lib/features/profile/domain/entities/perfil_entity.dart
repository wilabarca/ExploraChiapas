class PerfilEntity {
  final String id;
  final String nombre;
  final String email;
  final String? telefono;
  final String ImgUrl;
  final String userTypeId;
  final bool isPremium;
  final bool active;
  final DateTime registeredAt;

  const PerfilEntity({
    required this.id,
    required this.nombre,
    required this.ImgUrl,
    required this.email,
    this.telefono,
    required this.userTypeId,
    required this.isPremium,
    required this.active,
    required this.registeredAt,
  });

  String get tipoUsuarioLabel {
    final prefs = userTypeId.toLowerCase();
    if (prefs.contains('local')) return 'Habitante Local';
    if (prefs.contains('extranjero')) return 'Turista Extranjero';
    return 'Turista Nacional';
  }
}
