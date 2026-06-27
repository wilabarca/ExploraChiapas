import 'package:dartz/dartz.dart';
import '../error/failures.dart';

// Tipo de resultado: Either<Failure, T>
// Left  = error (Failure)
// Right = exito (T)
typedef Result<T> = Future<Either<Failure, T>>;