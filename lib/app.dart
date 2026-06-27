import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/di/injector.dart';
import 'features/auth/presentation/pages/welcome_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/interests_page.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/profile/presentation/providers/profile_provider.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/Chat/presentation/pages/chat_routes_page.dart';

class ExploraChiapasApp extends StatelessWidget {
  const ExploraChiapasApp({super.key});

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
      ],
      child: MaterialApp(
        title: 'ExploraChiapas',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(textTheme: GoogleFonts.poppinsTextTheme()),
        initialRoute: '/',
        onGenerateRoute: (settings) {
          debugPrint('➡️ Navegando a: ${settings.name}');

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
            case '/home':
              return MaterialPageRoute(
                builder: (_) => const HomePage(),
                settings: settings,
              );
            case '/perfil':
              return MaterialPageRoute(
                builder: (_) => const ProfilePage(),
                settings: settings,
              );
            case '/chat':
              return MaterialPageRoute(
                builder: (_) => const ChatRoutesPage(),
                settings: settings,
              );
            default:
              debugPrint('❌ Ruta no encontrada: ${settings.name}');
              return MaterialPageRoute(builder: (_) => const WelcomePage());
          }
        },
      ),
    );
  }
}
