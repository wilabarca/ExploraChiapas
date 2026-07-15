import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/destino_entity.dart';
import '../repositories/i_home_repository.dart';

@injectable
class GetDestinosUseCase {
  final IHomeRepository _repository;
  GetDestinosUseCase(this._repository);

  Future<Either<Failure, List<DestinoEntity>>> call({String? tipo}) {
    return _repository.getDestinos(tipo: tipo);
  }
}