import '../../../../core/utils/media_url_resolver.dart';
import '../../domain/entities/evento.dart';

class EventoModel extends Evento {
  const EventoModel({
    required super.id,
    required super.titulo,
    super.descripcion,
    super.imagenUrl,
    required super.fechaInicio,
    super.fechaFin,
    super.ubicacionId,
    super.categoriaId,
    super.categoriaNombre,
    super.municipio,
    required super.activo,
    required super.fechaCreacion,
  });

  factory EventoModel.fromJson(Map<String, dynamic> json) {
    return EventoModel(
      id: _parseRequiredString(_readValue(json, 'id'), fieldName: 'id'),
      titulo: _parseRequiredString(
        _readValue(json, 'titulo'),
        fieldName: 'titulo',
      ),
      descripcion: _parseOptionalString(_readValue(json, 'descripcion')),
      imagenUrl: resolveMediaUrl(
        _parseOptionalString(
          _readValue(json, 'imagenUrl', alternativeKey: 'imagen_url'),
        ),
      ),
      fechaInicio: _parseRequiredDateTime(
        _readValue(json, 'fechaInicio', alternativeKey: 'fecha_inicio'),
        fieldName: 'fechaInicio',
      ),
      fechaFin: _parseOptionalDateTime(
        _readValue(json, 'fechaFin', alternativeKey: 'fecha_fin'),
      ),
      ubicacionId: _parseOptionalString(
        _readValue(json, 'ubicacionId', alternativeKey: 'ubicacion_id'),
      ),
      categoriaId: _parseOptionalString(
        _readValue(json, 'categoriaId', alternativeKey: 'categoria_id'),
      ),
      categoriaNombre: _parseOptionalString(
        _readValue(json, 'categoriaNombre', alternativeKey: 'categoria_nombre'),
      ),
      municipio: _parseOptionalString(_readValue(json, 'municipio')),
      activo: _parseBool(_readValue(json, 'activo')),
      fechaCreacion: _parseRequiredDateTime(
        _readValue(json, 'fechaCreacion', alternativeKey: 'fecha_creacion'),
        fieldName: 'fechaCreacion',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'imagenUrl': imagenUrl,
      'fechaInicio': fechaInicio.toIso8601String(),
      'fechaFin': fechaFin?.toIso8601String(),
      'ubicacionId': ubicacionId,
      'categoriaId': categoriaId,
      'categoriaNombre': categoriaNombre,
      'municipio': municipio,
      'activo': activo,
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  static dynamic _readValue(
    Map<String, dynamic> json,
    String key, {
    String? alternativeKey,
  }) {
    if (json.containsKey(key)) {
      return json[key];
    }

    if (alternativeKey != null && json.containsKey(alternativeKey)) {
      return json[alternativeKey];
    }

    return null;
  }

  static String _parseRequiredString(
    dynamic value, {
    required String fieldName,
  }) {
    final parsedValue = value?.toString().trim();

    if (parsedValue == null || parsedValue.isEmpty) {
      throw FormatException('El campo obligatorio "$fieldName" no es válido');
    }

    return parsedValue;
  }

  static String? _parseOptionalString(dynamic value) {
    final parsedValue = value?.toString().trim();

    if (parsedValue == null || parsedValue.isEmpty) {
      return null;
    }

    return parsedValue;
  }

  static DateTime _parseRequiredDateTime(
    dynamic value, {
    required String fieldName,
  }) {
    if (value is DateTime) {
      return value;
    }

    final parsedValue = DateTime.tryParse(value?.toString() ?? '');

    if (parsedValue == null) {
      throw FormatException('La fecha obligatoria "$fieldName" no es válida');
    }

    return parsedValue;
  }

  static DateTime? _parseOptionalDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    final normalizedValue = value.toString().trim();

    if (normalizedValue.isEmpty) {
      return null;
    }

    return DateTime.tryParse(normalizedValue);
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    if (value is String) {
      final normalizedValue = value.trim().toLowerCase();

      return normalizedValue == 'true' ||
          normalizedValue == '1' ||
          normalizedValue == 'yes' ||
          normalizedValue == 'si' ||
          normalizedValue == 'sí';
    }

    return false;
  }
}
