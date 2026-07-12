import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/di/injector.dart';
import 'features/auth/presentation/pages/welcome_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/interests_page.dart';
import 'features/auth/presentation/pages/permitir_acceso_page.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/profile/presentation/providers/profile_provider.dart';
import 'features/Chat/presentation/providers/chat_provider.dart';
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
import 'features/explorar/presentation/pages/explorar_cerca_page.dart';
import 'features/explorar/presentation/pages/recomendar_lugar_page.dart';
import 'features/resenas/presentation/pages/home_resenas_page.dart';

class ExploraChiapasApp extends StatelessWidget {
  const ExploraChiapasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => getIt<AuthProvider>(),
        ),
        // ✅ lazySingleton: siempre la misma instancia en toda la app
        ChangeNotifierProvider<ProfileProvider>(
          create: (_) => getIt<ProfileProvider>(),
        ),
        ChangeNotifierProvider<ChatProvider>(
          create: (_) => getIt<ChatProvider>(),
        ),
      ],
      child: MaterialApp(
        title: 'ExploraChiapas',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(textTheme: GoogleFonts.poppinsTextTheme()),
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

            // ✅ /perfil usa la instancia singleton del MultiProvider root
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

            // ✅ NUEVA RUTA: /resenas para HomeResenasPage
            case '/resenas':
              return MaterialPageRoute(
                builder: (_) => const HomeResenasPage(),
                settings: settings,
              );

            case '/mapa':
              return MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider<MapProvider>(
                  create: (_) => MapProvider(
                    GetDestinationsUseCase(
                      MapRepositoryImpl(MapRemoteDatasourceImpl()),
                    ),
                    GetRouteUseCase(
                      MapRepositoryImpl(MapRemoteDatasourceImpl()),
                    ),
                  ),
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
            default:
              debugPrint('Ruta no encontrada: ${settings.name}');
              return MaterialPageRoute(builder: (_) => const WelcomePage());
          }
        },
      ),
    );
  }
}
