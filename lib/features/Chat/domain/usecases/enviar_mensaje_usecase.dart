import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/recomendacion_entity.dart';
import '../repositories/i_chat_repository.dart';

@injectable
class EnviarMensajeUseCase {
  final IChatRepository _repository;
  EnviarMensajeUseCase(this._repository);

  Future<Either<Failure, RecomendacionEntity>> call(String texto) {
    return _repository.enviarMensaje(texto);
  }
}
