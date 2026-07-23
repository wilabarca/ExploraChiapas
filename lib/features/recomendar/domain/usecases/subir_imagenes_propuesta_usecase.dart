import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../repositories/recomendar_repository.dart';

@injectable
class SubirImagenesPropuestaUseCase {
  final RecomendarRepository _repository;
  const SubirImagenesPropuestaUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String proposalId,
    required List<XFile> imagenes,
  }) {
    return _repository.subirImagenes(
      proposalId: proposalId,
      imagenes: imagenes,
    );
  }
}
