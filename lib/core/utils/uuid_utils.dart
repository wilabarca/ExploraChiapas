final RegExp _uuidRegExp = RegExp(
  r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
);

/// Indica si [value] tiene el formato de un UUID real del backend.
///
/// Se usa para distinguir identificadores que provienen de una fila real
/// de PostgreSQL (siempre UUID) de identificadores que provienen de un
/// motor externo (ML de recomendaciones, chat) y que no corresponden a
/// ninguna entidad reseñable en el backend.
bool esUuidValido(String value) => _uuidRegExp.hasMatch(value);
