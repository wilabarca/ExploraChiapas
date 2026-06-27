class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => 'ServerException: $message (status: $statusCode)';
}

class UnauthorizedException implements Exception {
  final String message;

  const UnauthorizedException({
    this.message = 'No autorizado. Por favor inicia sesion.',
  });

  @override
  String toString() => 'UnauthorizedException: $message';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({
    this.message = 'Sin conexion a internet. Verifica tu red.',
  });

  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  final String message;

  const CacheException({
    this.message = 'Error al leer datos locales.',
  });

  @override
  String toString() => 'CacheException: $message';
}