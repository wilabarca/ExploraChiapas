// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/auth/data/datasource/auth_remote_datasource.dart'
    as _i175;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/usecases/get_profile_usecase.dart' as _i568;
import '../../features/auth/domain/usecases/get_user_interests_usecase.dart'
    as _i128;
import '../../features/auth/domain/usecases/login_usecase.dart' as _i188;
import '../../features/auth/domain/usecases/register_usecase.dart' as _i941;
import '../../features/auth/domain/usecases/update_user_interests_usecase.dart'
    as _i70;
import '../../features/auth/presentation/providers/auth_provider.dart'
    as _i1054;
import '../../features/categorias/data/datasource/categorias_remote_datasource.dart'
    as _i150;
import '../../features/categorias/data/repositories_impl/categorias_repository_impl.dart'
    as _i558;
import '../../features/categorias/domain/repositories/categorias_repository.dart'
    as _i285;
import '../../features/categorias/domain/usecases/get_categorias_usecase.dart'
    as _i90;
import '../../features/categorias/presentation/providers/categorias_provider.dart'
    as _i426;
import '../../features/Chat/data/datasource/chat_remote_datasource.dart'
    as _i730;
import '../../features/Chat/data/datasource/conversacion_remote_datasource.dart'
    as _i498;
import '../../features/Chat/data/repositories/chat_repository_impl.dart'
    as _i1018;
import '../../features/Chat/domain/repositories/i_chat_repository.dart'
    as _i124;
import '../../features/Chat/domain/usecases/enviar_mensaje_usecase.dart'
    as _i301;
import '../../features/Chat/presentation/providers/chat_provider.dart' as _i116;
import '../../features/destinos/data/datasource/destinos_remote_datasource.dart'
    as _i484;
import '../../features/destinos/data/repositories_impl/destinos_repository_impl.dart'
    as _i641;
import '../../features/destinos/domain/repositories/destinos_repository.dart'
    as _i991;
import '../../features/destinos/domain/usecases/get_destino_by_id_usecase.dart'
    as _i429;
import '../../features/destinos/domain/usecases/list_destinos_usecase.dart.dart'
    as _i488;
import '../../features/destinos/presentation/providers/destinos_provider.dart'
    as _i232;
import '../../features/eventos/data/datasource/eventos_remote_datasource.dart'
    as _i747;
import '../../features/eventos/data/repositories/eventos_repository_impl.dart'
    as _i696;
import '../../features/eventos/domain/repositories/eventos_repository.dart'
    as _i683;
import '../../features/eventos/domain/usecases/get_evento_by_id_usecase.dart'
    as _i247;
import '../../features/eventos/domain/usecases/get_eventos_usecase.dart'
    as _i703;
import '../../features/eventos/presentation/providers/eventos_provider.dart'
    as _i902;
import '../../features/favoritos/data/datasource/favoritos_remote_datasource.dart'
    as _i768;
import '../../features/favoritos/data/repositories/favoritos_repository_impl.dart'
    as _i857;
import '../../features/favoritos/domain/repositories/favoritos_repository.dart'
    as _i743;
import '../../features/favoritos/domain/usecases/add_favorito_usecase.dart'
    as _i536;
import '../../features/favoritos/domain/usecases/get_favoritos_usecase.dart'
    as _i629;
import '../../features/favoritos/domain/usecases/remove_favorito_usecase.dart'
    as _i662;
import '../../features/favoritos/presentation/providers/favoritos_provider.dart'
    as _i63;
import '../../features/home/data/datasuorce/home_remote_datasource.dart'
    as _i1017;
import '../../features/home/data/repositories/home_repository_impl.dart'
    as _i76;
import '../../features/home/domain/repositories/i_home_repository.dart'
    as _i274;
import '../../features/home/domain/usecases/get_destino_usecase.dart' as _i437;
import '../../features/negocio/data/datasource/negocio_remote_datasource.dart'
    as _i907;
import '../../features/negocio/data/datasource/remote/models/tipo_negocio_models.dart'
    as _i820;
import '../../features/negocio/data/repositories/negocio_repository_impl.dart'
    as _i722;
import '../../features/negocio/domain/repositories/negocio_repository.dart'
    as _i252;
import '../../features/negocio/domain/usecases/buscar_negocio.dart' as _i901;
import '../../features/negocio/domain/usecases/obtener_negocio.dart' as _i933;
import '../../features/negocio/domain/usecases/obtener_negocio_por_id.dart'
    as _i810;
import '../../features/profile/data/datasource/profile_remote_datasource.dart'
    as _i1031;
import '../../features/profile/data/repositories/profile_repository_impl.dart'
    as _i334;
import '../../features/profile/domain/repositories/i_profile_repository.dart'
    as _i879;
import '../../features/profile/domain/usecases/delete_perfil_usecase.dart'
    as _i331;
import '../../features/profile/domain/usecases/get_perfil_usecase.dart' as _i32;
import '../../features/profile/domain/usecases/update_perfil_usecase.dart'
    as _i226;
import '../../features/profile/domain/usecases/upload_foto_perfil_usecase.dart'
    as _i453;
import '../../features/profile/presentation/providers/profile_provider.dart'
    as _i919;
import '../../features/promociones/data/datasource/remote/promociones_remote_datasource.dart'
    as _i1;
import '../../features/promociones/data/repositories/promociones_repository_impl.dart'
    as _i28;
import '../../features/promociones/domain/repositories/promociones_repository.dart'
    as _i559;
import '../../features/promociones/domain/usecases/get_promociones_usecase.dart'
    as _i905;
import '../../features/promociones/presentation/providers/promociones_provider.dart'
    as _i309;
import '../../features/resena/data/datasource/ResenasRemoteDataSource.dart'
    as _i402;
import '../../features/resena/data/repositories/ResenasRepositoryImpl.dart'
    as _i913;
import '../../features/resena/domain/repositories/ResenasRepository.dart'
    as _i908;
import '../../features/resena/domain/usecases/CrearResenaUseCase.dart' as _i392;
import '../../features/resena/domain/usecases/GetResenasUseCase.dart' as _i33;
import '../../features/resena/presentation/providers/ResenasProvider.dart'
    as _i112;
import '../network/api_client.dart' as _i557;
import '../network/ml_api_client.dart' as _i322;
import '../services/avatar/avatar_service.dart' as _i45;
import '../services/avatar/avatar_service_impl.dart' as _i149;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i557.ApiClient>(() => _i557.ApiClient());
    gh.lazySingleton<_i322.MlApiClient>(() => _i322.MlApiClient());
    gh.lazySingleton<_i45.AvatarService>(() => _i149.AvatarServiceImpl());
    gh.lazySingleton<_i498.ConversacionRemoteDatasource>(
      () => _i498.ConversacionRemoteDatasource(gh<_i557.ApiClient>()),
    );
    gh.lazySingleton<_i730.IChatRemoteDatasource>(
      () => _i730.ChatRemoteDatasourceImpl(gh<_i322.MlApiClient>()),
    );
    gh.factory<_i1017.IHomeRemoteDatasource>(
      () => _i1017.HomeRemoteDatasourceImpl(),
    );
    gh.factory<_i274.IHomeRepository>(
      () => _i76.HomeRepositoryImpl(gh<_i1017.IHomeRemoteDatasource>()),
    );
    gh.lazySingleton<_i150.CategoriasRemoteDataSource>(
      () => _i150.CategoriasRemoteDataSourceImpl(gh<_i557.ApiClient>()),
    );
    gh.lazySingleton<_i285.CategoriasRepository>(
      () => _i558.CategoriasRepositoryImpl(
        gh<_i150.CategoriasRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i175.AuthRemoteDataSource>(
      () => _i175.AuthRemoteDataSourceImpl(gh<_i557.ApiClient>()),
    );
    gh.factory<_i437.GetDestinosUseCase>(
      () => _i437.GetDestinosUseCase(gh<_i274.IHomeRepository>()),
    );
    gh.lazySingleton<_i402.ResenasRemoteDataSource>(
      () => _i402.ResenasRemoteDataSourceImpl(gh<_i557.ApiClient>()),
    );
    gh.lazySingleton<_i484.DestinoRemoteDataSource>(
      () => _i484.DestinoRemoteDataSourceImpl(gh<_i557.ApiClient>()),
    );
    gh.factory<_i124.IChatRepository>(
      () => _i1018.ChatRepositoryImpl(gh<_i730.IChatRemoteDatasource>()),
    );
    gh.lazySingleton<_i747.EventosRemoteDataSource>(
      () => _i747.EventosRemoteDataSourceImpl(gh<_i557.ApiClient>()),
    );
    gh.factory<_i90.GetCategoriasUseCase>(
      () => _i90.GetCategoriasUseCase(gh<_i285.CategoriasRepository>()),
    );
    gh.lazySingleton<_i787.AuthRepository>(
      () => _i153.AuthRepositoryImpl(gh<_i175.AuthRemoteDataSource>()),
    );
    gh.lazySingleton<_i907.NegocioRemoteDataSource>(
      () => _i907.NegocioRemoteDataSourceImpl(gh<_i557.ApiClient>()),
    );
    gh.factory<_i1031.IProfileRemoteDatasource>(
      () => _i1031.ProfileRemoteDatasourceImpl(gh<_i557.ApiClient>()),
    );
    gh.lazySingleton<_i1.PromocionesRemoteDataSource>(
      () => _i1.PromocionesRemoteDataSourceImpl(gh<_i557.ApiClient>()),
    );
    gh.factory<_i426.CategoriasProvider>(
      () => _i426.CategoriasProvider(gh<_i90.GetCategoriasUseCase>()),
    );
    gh.lazySingleton<_i768.FavoritosRemoteDataSource>(
      () => _i768.FavoritosRemoteDataSourceImpl(gh<_i557.ApiClient>()),
    );
    gh.lazySingleton<_i991.DestinoRepository>(
      () => _i641.DestinoRepositoryImpl(gh<_i484.DestinoRemoteDataSource>()),
    );
    gh.lazySingleton<_i559.PromocionesRepository>(
      () =>
          _i28.PromocionesRepositoryImpl(gh<_i1.PromocionesRemoteDataSource>()),
    );
    gh.factory<_i301.EnviarMensajeUseCase>(
      () => _i301.EnviarMensajeUseCase(gh<_i124.IChatRepository>()),
    );
    gh.lazySingleton<_i252.NegocioRepository>(
      () => _i722.NegocioRepositoryImpl(gh<_i907.NegocioRemoteDataSource>()),
    );
    gh.factory<_i905.GetPromocionesUseCase>(
      () => _i905.GetPromocionesUseCase(gh<_i559.PromocionesRepository>()),
    );
    gh.factory<_i116.ChatProvider>(
      () => _i116.ChatProvider(
        gh<_i301.EnviarMensajeUseCase>(),
        gh<_i498.ConversacionRemoteDatasource>(),
      ),
    );
    gh.factory<_i820.BuscarNegocios>(
      () => _i820.BuscarNegocios(gh<_i252.NegocioRepository>()),
    );
    gh.factory<_i901.BuscarNegocios>(
      () => _i901.BuscarNegocios(gh<_i252.NegocioRepository>()),
    );
    gh.factory<_i933.ObtenerNegocios>(
      () => _i933.ObtenerNegocios(gh<_i252.NegocioRepository>()),
    );
    gh.factory<_i810.ObtenerNegocioPorId>(
      () => _i810.ObtenerNegocioPorId(gh<_i252.NegocioRepository>()),
    );
    gh.lazySingleton<_i743.FavoritosRepository>(
      () =>
          _i857.FavoritosRepositoryImpl(gh<_i768.FavoritosRemoteDataSource>()),
    );
    gh.factory<_i429.GetDestinoByIdUseCase>(
      () => _i429.GetDestinoByIdUseCase(gh<_i991.DestinoRepository>()),
    );
    gh.factory<_i488.ListDestinosUseCase>(
      () => _i488.ListDestinosUseCase(gh<_i991.DestinoRepository>()),
    );
    gh.factory<_i309.PromocionesProvider>(
      () => _i309.PromocionesProvider(gh<_i905.GetPromocionesUseCase>()),
    );
    gh.factory<_i568.GetProfileUseCase>(
      () => _i568.GetProfileUseCase(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i128.GetUserInterestsUseCase>(
      () => _i128.GetUserInterestsUseCase(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i188.LoginUseCase>(
      () => _i188.LoginUseCase(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i941.RegisterUseCase>(
      () => _i941.RegisterUseCase(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i70.UpdateUserInterestsUseCase>(
      () => _i70.UpdateUserInterestsUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i908.ResenasRepository>(
      () => _i913.ResenasRepositoryImpl(gh<_i402.ResenasRemoteDataSource>()),
    );
    gh.factory<_i1054.AuthProvider>(
      () => _i1054.AuthProvider(
        gh<_i188.LoginUseCase>(),
        gh<_i941.RegisterUseCase>(),
        gh<_i568.GetProfileUseCase>(),
        gh<_i787.AuthRepository>(),
        gh<_i128.GetUserInterestsUseCase>(),
        gh<_i70.UpdateUserInterestsUseCase>(),
      ),
    );
    gh.factory<_i879.IProfileRepository>(
      () => _i334.ProfileRepositoryImpl(gh<_i1031.IProfileRemoteDatasource>()),
    );
    gh.factory<_i536.AddFavoritoUseCase>(
      () => _i536.AddFavoritoUseCase(gh<_i743.FavoritosRepository>()),
    );
    gh.factory<_i629.GetFavoritosUseCase>(
      () => _i629.GetFavoritosUseCase(gh<_i743.FavoritosRepository>()),
    );
    gh.factory<_i662.RemoveFavoritoUseCase>(
      () => _i662.RemoveFavoritoUseCase(gh<_i743.FavoritosRepository>()),
    );
    gh.lazySingleton<_i683.EventosRepository>(
      () => _i696.EventosRepositoryImpl(gh<_i747.EventosRemoteDataSource>()),
    );
    gh.factory<_i247.GetEventoByIdUseCase>(
      () => _i247.GetEventoByIdUseCase(gh<_i683.EventosRepository>()),
    );
    gh.factory<_i703.GetEventosUseCase>(
      () => _i703.GetEventosUseCase(gh<_i683.EventosRepository>()),
    );
    gh.factory<_i331.DeletePerfilUseCase>(
      () => _i331.DeletePerfilUseCase(gh<_i879.IProfileRepository>()),
    );
    gh.factory<_i32.GetPerfilUseCase>(
      () => _i32.GetPerfilUseCase(gh<_i879.IProfileRepository>()),
    );
    gh.factory<_i226.UpdatePerfilUseCase>(
      () => _i226.UpdatePerfilUseCase(gh<_i879.IProfileRepository>()),
    );
    gh.factory<_i453.UploadFotoPerfilUseCase>(
      () => _i453.UploadFotoPerfilUseCase(gh<_i879.IProfileRepository>()),
    );
    gh.factory<_i232.DestinoProvider>(
      () => _i232.DestinoProvider(
        gh<_i488.ListDestinosUseCase>(),
        gh<_i429.GetDestinoByIdUseCase>(),
      ),
    );
    gh.factory<_i63.FavoritosProvider>(
      () => _i63.FavoritosProvider(
        gh<_i629.GetFavoritosUseCase>(),
        gh<_i536.AddFavoritoUseCase>(),
        gh<_i662.RemoveFavoritoUseCase>(),
      ),
    );
    gh.factory<_i392.CrearResenaUseCase>(
      () => _i392.CrearResenaUseCase(gh<_i908.ResenasRepository>()),
    );
    gh.factory<_i33.GetResenasUseCase>(
      () => _i33.GetResenasUseCase(gh<_i908.ResenasRepository>()),
    );
    gh.factory<_i902.EventosProvider>(
      () => _i902.EventosProvider(
        gh<_i703.GetEventosUseCase>(),
        gh<_i247.GetEventoByIdUseCase>(),
      ),
    );
    gh.lazySingleton<_i919.ProfileProvider>(
      () => _i919.ProfileProvider(
        gh<_i32.GetPerfilUseCase>(),
        gh<_i226.UpdatePerfilUseCase>(),
        gh<_i331.DeletePerfilUseCase>(),
        gh<_i453.UploadFotoPerfilUseCase>(),
      ),
    );
    gh.factory<_i112.ResenasProvider>(
      () => _i112.ResenasProvider(
        gh<_i33.GetResenasUseCase>(),
        gh<_i392.CrearResenaUseCase>(),
      ),
    );
    return this;
  }
}
