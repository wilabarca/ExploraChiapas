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
import '../../features/auth/data/reposiories/auth_repository_impl.dart'
    as _i797;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/usecases/get_profile_usecase.dart' as _i568;
import '../../features/auth/domain/usecases/login_usecase.dart' as _i188;
import '../../features/auth/domain/usecases/register_usecase.dart' as _i941;
import '../../features/auth/presentation/providers/auth_provider.dart'
    as _i1054;
import '../../features/Chat/data/datasource/chat_remote_datasource.dart'
    as _i730;
import '../../features/Chat/data/repositories/chat_repository_impl.dart'
    as _i1018;
import '../../features/Chat/domain/repositories/i_chat_repository.dart'
    as _i124;
import '../../features/Chat/domain/usecases/enviar_mensaje_usecase.dart'
    as _i301;
import '../../features/Chat/presentation/providers/chat_provider.dart' as _i116;
import '../../features/home/data/datasuorce/home_remote_datasource.dart'
    as _i1017;
import '../../features/home/data/repositories/home_repository_impl.dart'
    as _i76;
import '../../features/home/domain/repositories/i_home_repository.dart'
    as _i274;
import '../../features/home/domain/usecases/get_destino_usecase.dart' as _i437;
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
import '../../features/profile/presentation/providers/profile_provider.dart'
    as _i919;
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
    gh.lazySingleton<_i730.IChatRemoteDatasource>(
      () => _i730.ChatRemoteDatasourceImpl(gh<_i322.MlApiClient>()),
    );
    gh.factory<_i1017.IHomeRemoteDatasource>(
      () => _i1017.HomeRemoteDatasourceImpl(),
    );
    gh.factory<_i274.IHomeRepository>(
      () => _i76.HomeRepositoryImpl(gh<_i1017.IHomeRemoteDatasource>()),
    );
    gh.lazySingleton<_i175.AuthRemoteDataSource>(
      () => _i175.AuthRemoteDataSourceImpl(gh<_i557.ApiClient>()),
    );
    gh.factory<_i437.GetDestinosUseCase>(
      () => _i437.GetDestinosUseCase(gh<_i274.IHomeRepository>()),
    );
    gh.lazySingleton<_i787.AuthRepository>(
      () => _i797.AuthRepositoryImpl(
        gh<_i175.AuthRemoteDataSource>(),
        gh<_i45.AvatarService>(),
      ),
    );
    gh.factory<_i124.IChatRepository>(
      () => _i1018.ChatRepositoryImpl(gh<_i730.IChatRemoteDatasource>()),
    );
    gh.factory<_i1031.IProfileRemoteDatasource>(
      () => _i1031.ProfileRemoteDatasourceImpl(gh<_i557.ApiClient>()),
    );
    gh.factory<_i301.EnviarMensajeUseCase>(
      () => _i301.EnviarMensajeUseCase(gh<_i124.IChatRepository>()),
    );
    gh.factory<_i116.ChatProvider>(
      () => _i116.ChatProvider(gh<_i301.EnviarMensajeUseCase>()),
    );
    gh.factory<_i568.GetProfileUseCase>(
      () => _i568.GetProfileUseCase(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i188.LoginUseCase>(
      () => _i188.LoginUseCase(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i941.RegisterUseCase>(
      () => _i941.RegisterUseCase(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i879.IProfileRepository>(
      () => _i334.ProfileRepositoryImpl(gh<_i1031.IProfileRemoteDatasource>()),
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
    gh.factory<_i1054.AuthProvider>(
      () => _i1054.AuthProvider(
        gh<_i188.LoginUseCase>(),
        gh<_i941.RegisterUseCase>(),
        gh<_i568.GetProfileUseCase>(),
      ),
    );
    gh.lazySingleton<_i919.ProfileProvider>(
      () => _i919.ProfileProvider(
        gh<_i32.GetPerfilUseCase>(),
        gh<_i226.UpdatePerfilUseCase>(),
        gh<_i331.DeletePerfilUseCase>(),
      ),
    );
    return this;
  }
}
