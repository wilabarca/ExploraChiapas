abstract class Failure {
  final String message;
  const Failure({required this.message});
}

class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({required super.message, this.statusCode});
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    super.message = 'No autorizado. Por favor inicia sesion.',
  });
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Sin conexion a internet. Verifica tu red.',
  });
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Error al leer datos locales.'});
}
