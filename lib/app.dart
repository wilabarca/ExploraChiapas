import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/di/injector.dart';
import 'core/navigation/app_navigator.dart';
import 'core/providers/preferences_provider.dart';
import 'core/providers/locale_provider.dart';
import 'core/theme/app_theme.dart';

import 'features/auth/presentation/pages/welcome_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/interests_page.dart';
import 'features/auth/presentation/pages/permitir_acceso_page.dart';

import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/profile/presentation/providers/profile_provider.dart';
import 'features/Chat/presentation/providers/chat_provider.dart';
import 'features/destinos/presentation/providers/destinos_provider.dart';
import 'features/eventos/presentation/providers/eventos_provider.dart';
import 'features/promociones/presentation/providers/promociones_provider.dart';
import 'features/resena/presentation/providers/ResenasProvider.dart';
import 'features/favoritos/presentation/providers/favoritos_provider.dart';

import 'features/home/presentation/pages/home_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/Chat/presentation/pages/chat_routes_page.dart';
import 'features/favoritos/presentation/pages/favoritos_page.dart';
import 'features/eventos/presentation/pages/eventos_page.dart';

import 'features/maps/presentation/pages/map_page.dart';

import 'features/maps/presentation/providers/map_provider.dart';
import 'features/maps/domain/usecases/get_destinations_usecase.dart';
import 'features/maps/domain/usecases/get_routes_usecase.dart';
import 'features/maps/data/repositories/map_repository_impl.dart';
import 'features/maps/data/datasources/map_remote_datasource.dart';
import 'core/network/api_client.dart';
import 'features/destinos/presentation/pages/explorar_cerca_page.dart';
import 'features/destinos/presentation/pages/recomendar_lugar_page.dart';
import 'features/resena/presentation/pages/home_resenas_page.dart';
import 'features/negocio/presentation/pages/negocio_lista_page.dart';
import 'features/promociones/presentation/pages/promociones_page.dart';

class ExploraChiapasApp extends StatefulWidget {
  const ExploraChiapasApp({super.key});

  @override
  State<ExploraChiapasApp> createState() => _ExploraChiapasAppState();
}

class _ExploraChiapasAppState extends State<ExploraChiapasApp> {
  final _prefsProvider  = PreferencesProvider();
  final _localeProvider = LocaleProvider();

  @override
  void initState() {
    super.initState();
    _prefsProvider.cargar();
    _localeProvider.cargar();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => getIt<AuthProvider>(),
        ),
        ChangeNotifierProvider<ProfileProvider>(
          create: (_) => getIt<ProfileProvider>(),
        ),
        ChangeNotifierProvider<ChatProvider>(
          create: (_) => getIt<ChatProvider>(),
        ),
        ChangeNotifierProvider<DestinoProvider>(
          create: (_) => getIt<DestinoProvider>(),
        ),
        ChangeNotifierProvider<EventosProvider>(
          create: (_) => getIt<EventosProvider>(),
        ),
        ChangeNotifierProvider<PromocionesProvider>(
          create: (_) => getIt<PromocionesProvider>(),
        ),
        ChangeNotifierProvider<ResenasProvider>(
          create: (_) => getIt<ResenasProvider>(),
        ),
        ChangeNotifierProvider<FavoritosProvider>(
          create: (_) => getIt<FavoritosProvider>(),
        ),
        ChangeNotifierProvider<PreferencesProvider>.value(
          value: _prefsProvider,
        ),
        ChangeNotifierProvider<LocaleProvider>.value(
          value: _localeProvider,
        ),
      ],
      child: Consumer2<PreferencesProvider, LocaleProvider>(
        builder: (context, prefs, locale, _) {
          return MaterialApp(
            navigatorKey: AppNavigator.key,
            title: 'ExploraChiapas',
            debugShowCheckedModeBanner: false,
            locale: locale.locale,
            supportedLocales: const [Locale('es'), Locale('en')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            themeMode: prefs.themeMode,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            initialRoute: '/',
            onGenerateRoute: (settings) {
              debugPrint('Navegando a: ${settings.name}');

              switch (settings.name) {
                case '/':
                  return MaterialPageRoute(
                    builder: (_) => const WelcomePage(),
                    settings: settings,
                  );

                case '/registro':
                  return MaterialPageRoute(
                    builder: (_) => const RegisterPage(),
                    settings: settings,
                  );

                case '/login':
                  return MaterialPageRoute(
                    builder: (_) => const LoginPage(),
                    settings: settings,
                  );

                case '/intereses':
                  return MaterialPageRoute(
                    builder: (_) => const InterestsPage(),
                    settings: settings,
                  );

                case '/permisos':
                  return MaterialPageRoute(
                    builder: (_) => const PermitirAccesoPage(),
                    settings: settings,
                  );

                case '/home':
                  return MaterialPageRoute(
                    builder: (_) => const HomePage(),
                    settings: settings,
                  );

                case '/perfil':
                  return MaterialPageRoute(
                    builder: (ctx) => ChangeNotifierProvider<ProfileProvider>.value(
                      value: getIt<ProfileProvider>(),
                      child: const ProfilePage(),
                    ),
                    settings: settings,
                  );

                case '/chat':
                  return MaterialPageRoute(
                    builder: (_) => const ChatRoutesPage(),
                    settings: settings,
                  );

                case '/favoritos':
                  return MaterialPageRoute(
                    builder: (_) => const FavoritosPage(),
                    settings: settings,
                  );

                case '/eventos':
                  return MaterialPageRoute(
                    builder: (_) => const EventosPage(),
                    settings: settings,
                  );

                case '/resenas':
                  return MaterialPageRoute(
                    builder: (_) => const HomeResenasPage(),
                    settings: settings,
                  );

                case '/mapa':
                  return MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider<MapProvider>(
                      create: (_) {
                        final ds = MapRemoteDatasourceImpl(getIt<ApiClient>());
                        final repo = MapRepositoryImpl(ds);
                        return MapProvider(
                          GetDestinationsUseCase(repo),
                          GetRouteUseCase(repo),
                        );
                      },
                      child: const MapPage(),
                    ),
                    settings: settings,
                  );

                case '/cerca':
                  return MaterialPageRoute(
                    builder: (_) => const ExplorarCercaPage(),
                    settings: settings,
                  );

                case '/recomendar':
                  return MaterialPageRoute(
                    builder: (_) => const RecomendarLugarPage(),
                    settings: settings,
                  );

                case '/negocios':
                  final args = settings.arguments as Map<String, dynamic>;
                  return MaterialPageRoute(
                    builder: (_) => NegocioListaPage(
                      tipoNegocioId: args['tipoNegocioId'] as String,
                      tituloTipo:    args['tituloTipo'] as String,
                    ),
                    settings: settings,
                  );

                case '/promociones':
                  final args = settings.arguments as Map<String, dynamic>?;
                  return MaterialPageRoute(
                    builder: (_) => PromocionesPage(
                      negocioId: args?['negocioId'] as String?,
                    ),
                    settings: settings,
                  );

                default:
                  debugPrint('Ruta no encontrada: ${settings.name}');
                  return MaterialPageRoute(
                    builder: (_) => const WelcomePage(),
                    settings: settings,
                  );
              }
            },
          );
        },
      ),
    );
  }
}
