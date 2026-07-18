import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/i_profile_repository.dart';

@injectable
class UploadFotoPerfilUseCase {
  final IProfileRepository _repository;
  UploadFotoPerfilUseCase(this._repository);

  Future<Either<Failure, String>> call(File file) =>
      _repository.uploadFotoPerfil(file);
}
