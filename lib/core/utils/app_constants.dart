class AppConstants {
  AppConstants._();

  static const String baseUrl =
      'https://explora-chiapas.onrender.com/v1/api';

  // Endpoints de autenticación y usuarios
  static const String registerEndpoint = '/users/register';
  static const String loginEndpoint = '/users/login';
  static const String profileEndpoint = '/users/profile';
  static const String userTypesEndpoint = '/user-types';

  // Endpoints principales
  static const String destinationsEndpoint = '/destinations';
  static const String eventsEndpoint = '/events';
  static const String favoritesEndpoint = '/favorites';

  static const String mlServiceBaseUrl = 'https://nlp-service-6hvo.onrender.com';
  static const String planearEndpoint = '/planear';

  // Endpoints de preferencias
  static const String preferencesEndpoint = '/users/preferences';

  // Cloudinary — solo Cloud Name y Upload Preset (sin API Secret en la app)
  static const String cloudinaryCloudName    = 'otx0evtj';
  static const String cloudinaryUploadPreset = 'explorachiapas_unsigned';
  static const String cloudinaryBaseUrl      =
      'https://api.cloudinary.com/v1_1/otx0evtj/image/upload';

  // Carpetas en Cloudinary
  static const String cloudFolderAvatares  = 'explorachiapas/avatares';
  static const String cloudFolderNegocios  = 'explorachiapas/negocios';
  static const String cloudFolderDestinos  = 'explorachiapas/destinos';

  // SharedPreferences keys
  static const String jwtTokenKey = 'jwt_token';
  static const String tipoUsuarioKey = 'tipo_usuario';
  static const String onboardingKey = 'onboarding_completo';
  static const String interesesKey = 'intereses';
  static const String ubicacionKey = 'ubicacion_concedida';
  static const String fotoPerfil = 'foto_perfil';
  static const String userNameKey   = 'user_name';
  static const String userEmailKey  = 'user_email';

  // Preference keys (persistidas localmente)
  static const String prefIdioma   = 'pref_idioma';
  static const String prefUnidades = 'pref_unidades';
  static const String prefTema     = 'pref_tema';
  static const String prefMoneda   = 'pref_moneda';
  static const String prefLocale   = 'pref_locale';

  // Tipos de usuario
  static const String tipoTuristaNacional = 'turista_nacional';
  static const String tipoTuristaExtranjero = 'turista_extranjero';
  static const String tipoHabitanteLocal = 'habitante_local';

  // URLs legales
  static const String terminosUrl =
      'https://explorachiapas-legal.vercel.app/terminos-condiciones';

  static const String privacidadUrl =
      'https://explorachiapas-legal.vercel.app/politica-privacidad';

  // Configuración de red
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 60);
}