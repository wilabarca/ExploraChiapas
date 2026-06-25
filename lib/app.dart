import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:device_preview/device_preview.dart';
import 'features/auth/presentation/pages/welcome_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/interests_page.dart';
import 'features/home/presentation/pages/home_page.dart'; // ← faltaba este
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/Chat/presentation/pages/chat_routes_page.dart';

class ExploraChiapasApp extends StatelessWidget {
  const ExploraChiapasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ExploraChiapas',
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: ThemeData(textTheme: GoogleFonts.poppinsTextTheme()),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(),
        '/registro': (context) => const RegisterPage(),
        '/login': (context) => const LoginPage(),
        '/intereses': (context) => const InterestsPage(),
        '/home': (context) => const HomePage(),
        '/perfil': (context) => const ProfilePage(),
        '/chat': (context) => const ChatRoutesPage(),
      },
    );
  }
}
