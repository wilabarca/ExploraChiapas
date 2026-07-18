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

      // Home
      'no_cargo_perfil':   'No se pudo cargar el perfil',
    },
    'en': {
      // General
      'app_name':          'ExploraChiapas',
      'reintentar':        'Retry',
      'cancelar':          'Cancel',
      'guardar':           'Save',
      'continuar':         'Continue',
      'cerrar':            'Close',

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

      // Home
      'no_cargo_perfil':   'Could not load profile',
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
