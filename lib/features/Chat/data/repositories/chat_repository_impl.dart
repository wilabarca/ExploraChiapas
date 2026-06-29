import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/recomendacion_entity.dart';
import '../../domain/repositories/i_chat_repository.dart';
import '../datasource/chat_remote_datasource.dart';

@Injectable(as: IChatRepository)
class ChatRepositoryImpl implements IChatRepository {
  final IChatRemoteDatasource _datasource;

  ChatRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, RecomendacionEntity>> enviarMensaje(String texto) async {
    try {
      final recomendacion = await _datasource.enviarMensaje(texto);
      return Right(recomendacion);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
