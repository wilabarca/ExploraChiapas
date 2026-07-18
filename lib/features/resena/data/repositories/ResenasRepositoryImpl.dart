import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/resena_entity.dart';
import '../../domain/repositories/ResenasRepository.dart';
import '../datasource/ResenasRemoteDataSource.dart';

@LazySingleton(as: ResenasRepository)
class ResenasRepositoryImpl implements ResenasRepository {
  final ResenasRemoteDataSource _remoteDataSource;

  ResenasRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<Resena>>> getResenas({
    required String targetType,
    required String targetId,
  }) async {
    try {
      final resenas = await _remoteDataSource.getResenas(
        targetType: targetType,
        targetId: targetId,
      );
      return Right(resenas);
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          message:
              e.response?.data?['message']?.toString() ??
              'No fue posible obtener las reseñas',
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Resena>> crearResena({
    required String targetType,
    required String targetId,
    required int rating,
    String? comment,
  }) async {
    try {
      final resena = await _remoteDataSource.crearResena(
        targetType: targetType,
        targetId: targetId,
        rating: rating,
        comment: comment,
      );
      return Right(resena);
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          message:
              e.response?.data?['message']?.toString() ??
              'No fue posible publicar la reseña',
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
