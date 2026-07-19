import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';

class AppStrings {
  static const Map<String, Map<String, String>> _t = {
    'es': {
      // General
      'app_name':          'ExploraChiapas',
      'reintentar':        'Reintentar',
      'cancelar':          'Cancelar',
      'guardar':           'Guardar',
      'continuar':         'Continuar',
      'cerrar':            'Cerrar',
      'ver_todos':         'Ver todos',
      'error_red':         'Sin conexión. Verifica tu red.',

      // Perfil
      'perfil':             'Perfil',
      'editar_perfil':      'Editar perfil',
      'cerrar_sesion':      'Cerrar sesión',
      'mis_intereses':      'Mis Intereses',
      'editar':             'Editar',
      'menu':               'Menú',

      // Preferencias
      'preferencias':       'Preferencias',
      'idioma':             'Idioma',
      'unidades':           'Unidades',
      'tema':               'Tema',
      'moneda':             'Moneda',
      'claro':              'Claro',
      'oscuro':             'Oscuro',

      // Privacidad
      'privacidad':                'Privacidad',
      'compartir_ubicacion':       'Compartir ubicación',
      'compartir_historial':       'Compartir historial',
      'mostrar_perfil_publico':    'Mostrar perfil público',
      'descargar_datos':           'Descargar mis datos',
      'eliminar_cuenta':           'Eliminar cuenta',
      'proximamente':              'Función próximamente disponible',

      // Diálogos
      'cerrar_sesion_titulo':      'Cerrar sesión',
      'cerrar_sesion_msg':         '¿Estás seguro que deseas cerrar sesión?',
      'eliminar_cuenta_titulo':    'Eliminar cuenta',
      'eliminar_cuenta_msg':       '¿Estás seguro? Esta acción es permanente y no se puede deshacer.',
      'eliminar':                  'Eliminar',

      // Auth
      'iniciar_sesion':    'Iniciar sesión',
      'registrarse':       'Registrarse',
      'continuar_google':  'Continuar con Google',
      'o':                 'o',

      // Home – perfil
      'no_cargo_perfil':   'No se pudo cargar el perfil',

      // Home – secciones
      'destinos_para_ti':         'Destinos para ti',
      'error_destinos':           'No fue posible obtener los destinos',
      'sin_destinos':             'No hay destinos disponibles',
      'destino_turistico':        'Destino turístico',
      'promociones_activas':      'Promociones activas',
      'error_eventos_carga':      'No fue posible obtener los eventos',
      'proximos_eventos':         'Próximos eventos',
      'restaurantes_destacados':  'Restaurantes destacados',
      'hoteles_recomendados':     'Hoteles recomendados',
      'restaurantes':             'Restaurantes',
      'hoteles':                  'Hoteles',
      'ver_promociones':          'Ver promociones',
      'promociones_label':        'PROMOCIONES',
      'promociones_desc':         'Descubre descuentos exclusivos de hoteles, restaurantes, tours y más.',

      // Eventos
      'eventos_y_actividades':    'Eventos y Actividades',
      'buscar_eventos':           'Buscar eventos...',
      'error_cargar_eventos':     'Error al cargar eventos',
      'sin_eventos':              'No hay eventos disponibles',
      'filtro_todos':             'Todos',
      'filtro_festivales':        'Festivales',
      'filtro_talleres':          'Talleres',
      'filtro_gastronomia':       'Gastronomía',
      'filtro_cultura':           'Cultura',

      // Favoritos
      'favoritos_titulo':         'Favoritos',
      'favoritos_subtitulo':      'Tus destinos y negocios guardados',
      'filtro_general':           'General',
      'filtro_destinos':          'Destinos',
      'filtro_negocios':          'Negocios',
      'error_favoritos':          'No fue posible obtener tus favoritos',
      'sin_favoritos':            'Aún no tienes favoritos aquí',
      'error_quitar_favorito':    'No se pudo quitar de favoritos',
    },
    'en': {
      // General
      'app_name':          'ExploraChiapas',
      'reintentar':        'Retry',
      'cancelar':          'Cancel',
      'guardar':           'Save',
      'continuar':         'Continue',
      'cerrar':            'Close',
      'ver_todos':         'See all',
      'error_red':         'No connection. Check your network.',

      // Profile
      'perfil':             'Profile',
      'editar_perfil':      'Edit profile',
      'cerrar_sesion':      'Log out',
      'mis_intereses':      'My Interests',
      'editar':             'Edit',
      'menu':               'Menu',

      // Preferences
      'preferencias':       'Preferences',
      'idioma':             'Language',
      'unidades':           'Units',
      'tema':               'Theme',
      'moneda':             'Currency',
      'claro':              'Light',
      'oscuro':             'Dark',

      // Privacy
      'privacidad':                'Privacy',
      'compartir_ubicacion':       'Share location',
      'compartir_historial':       'Share history',
      'mostrar_perfil_publico':    'Show public profile',
      'descargar_datos':           'Download my data',
      'eliminar_cuenta':           'Delete account',
      'proximamente':              'Feature coming soon',

      // Dialogs
      'cerrar_sesion_titulo':      'Log out',
      'cerrar_sesion_msg':         'Are you sure you want to log out?',
      'eliminar_cuenta_titulo':    'Delete account',
      'eliminar_cuenta_msg':       'Are you sure? This action is permanent and cannot be undone.',
      'eliminar':                  'Delete',

      // Auth
      'iniciar_sesion':    'Log in',
      'registrarse':       'Sign up',
      'continuar_google':  'Continue with Google',
      'o':                 'or',

      // Home – profile
      'no_cargo_perfil':   'Could not load profile',

      // Home – sections
      'destinos_para_ti':         'Destinations for you',
      'error_destinos':           'Could not load destinations',
      'sin_destinos':             'No destinations available',
      'destino_turistico':        'Tourist destination',
      'promociones_activas':      'Active promotions',
      'error_eventos_carga':      'Could not load events',
      'proximos_eventos':         'Upcoming events',
      'restaurantes_destacados':  'Featured restaurants',
      'hoteles_recomendados':     'Recommended hotels',
      'restaurantes':             'Restaurants',
      'hoteles':                  'Hotels',
      'ver_promociones':          'See promotions',
      'promociones_label':        'PROMOTIONS',
      'promociones_desc':         'Discover exclusive discounts on hotels, restaurants, tours and more.',

      // Events
      'eventos_y_actividades':    'Events & Activities',
      'buscar_eventos':           'Search events...',
      'error_cargar_eventos':     'Error loading events',
      'sin_eventos':              'No events available',
      'filtro_todos':             'All',
      'filtro_festivales':        'Festivals',
      'filtro_talleres':          'Workshops',
      'filtro_gastronomia':       'Gastronomy',
      'filtro_cultura':           'Culture',

      // Favorites
      'favoritos_titulo':         'Favorites',
      'favoritos_subtitulo':      'Your saved destinations and businesses',
      'filtro_general':           'All',
      'filtro_destinos':          'Destinations',
      'filtro_negocios':          'Businesses',
      'error_favoritos':          'Could not load your favorites',
      'sin_favoritos':            'No favorites here yet',
      'error_quitar_favorito':    'Could not remove from favorites',
    },
  };

  static String of(BuildContext context, String key) {
    final lang = context.read<LocaleProvider>().langCode;
    return _t[lang]?[key] ?? _t['es']?[key] ?? key;
  }

  static String tr(String key, String lang) {
    return _t[lang]?[key] ?? _t['es']?[key] ?? key;
  }
}
