import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/perfil_entity.dart';
import '../repositories/i_profile_repository.dart';

@injectable
class UpdatePerfilUseCase {
  final IProfileRepository _repository;
  UpdatePerfilUseCase(this._repository);

  Future<Either<Failure, PerfilEntity>> call({
    String? nombre,
    String? telefono,
    String? fotoPerfilUrl,
  }) => _repository.updateProfile(
    nombre: nombre,
    telefono: telefono,
    fotoPerfilUrl: fotoPerfilUrl,
  );
}
