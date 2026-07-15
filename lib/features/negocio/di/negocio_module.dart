import 'package:injectable/injectable.dart';

// Este archivo existe para que build_runner
// registre automáticamente las dependencias del feature negocio.
// No necesita contenido adicional si usas @injectable / @LazySingleton
// en datasource, repository y usecases.
@module
abstract class NegocioModule {}