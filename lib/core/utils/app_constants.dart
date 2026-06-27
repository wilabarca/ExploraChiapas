class AppConstants {
  AppConstants._();

  static const String baseUrl = 'https://explora-chiapas.onrender.com/v1/api';

  static const String registerEndpoint = '/users/register';
  static const String loginEndpoint = '/users/login';
  static const String profileEndpoint = '/users/profile';
  static const String userTypesEndpoint = '/user-types'; // ← si existe

  static const String jwtTokenKey = 'jwt_token';
  static const String tipoUsuarioKey = 'tipo_usuario';
  static const String onboardingKey = 'onboarding_completo';
  static const String interesesKey = 'intereses';
  static const String ubicacionKey = 'ubicacion_concedida';
  static const String fotoPerfil = 'foto_perfil';
  static const String userNameKey = 'user_name';
  static const String userEmailKey = 'user_email';

  // Tipos de usuario como strings legibles
  // guardados en SharedPreferences durante registro
  static const String tipoTuristaNacional = 'turista_nacional';
  static const String tipoTuristaExtranjero = 'turista_extranjero';
  static const String tipoHabitanteLocal = 'habitante_local';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
}
