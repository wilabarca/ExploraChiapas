import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/destino_entity.dart';
import '../../domain/repositories/i_home_repository.dart';
import '../datasuorce/home_remote_datasource.dart';

@Injectable(as: IHomeRepository)
class HomeRepositoryImpl implements IHomeRepository {
  final IHomeRemoteDatasource _datasource;
  HomeRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, List<DestinoEntity>>> getDestinos({
    String? tipo,
  }) async {
    try {
      final destinos = await _datasource.getDestinos(tipo: tipo);
      return Right(destinos);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
