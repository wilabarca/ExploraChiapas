import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/recomendacion_entity.dart';
import '../repositories/i_chat_repository.dart';

@injectable
class EnviarMensajeUseCase {
  final IChatRepository _repository;
  EnviarMensajeUseCase(this._repository);

  Future<Either<Failure, RecomendacionEntity>> call(
    String texto, {
    List<Map<String, String>> historial = const [],
    double? userLat,
    double? userLng,
  }) {
    return _repository.enviarMensaje(
      texto,
      historial: historial,
      userLat: userLat,
      userLng: userLng,
    );
  }
}
