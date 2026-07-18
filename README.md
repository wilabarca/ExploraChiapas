# ExploraChiapas — Flutter App

Aplicación móvil de turismo para Chiapas. Permite al usuario descubrir destinos, generar itinerarios personalizados mediante IA (NLP + ML), gestionar favoritos, ver eventos y comunicarse con un asistente conversacional.

---

## Índice

- [Arquitectura](#arquitectura)
- [Requisitos](#requisitos)
- [Instalación](#instalación)
- [Variables de entorno y configuración](#variables-de-entorno-y-configuración)
- [Comandos](#comandos)
- [Estructura del proyecto](#estructura-del-proyecto)
- [Servicios externos](#servicios-externos)
- [Base de datos](#base-de-datos)
- [Autenticación](#autenticación)

---

## Arquitectura

El sistema completo tiene tres capas independientes:

```
┌─────────────────────────────────────────────────────────┐
│                  Flutter App (este repo)                │
│  Provider · Injectable · Dio · SharedPreferences        │
└────────────────────┬────────────────────────────────────┘
                     │ REST (JSON)
        ┌────────────┴────────────┐
        │                         │
┌───────▼────────┐     ┌──────────▼──────────────────────┐
│  Backend REST  │     │      Capa 1 — NLP Service        │
│  (Express/Node │     │  Node.js + TypeScript + Groq     │
│   o FastAPI)   │     │  llama-3.3-70b-versatile         │
│                │     └──────────┬───────────────────────┘
│  /users        │                │ REST (JSON)
│  /destinations │     ┌──────────▼───────────────────────┐
│  /events       │     │      Capa 2 — ML Engine           │
│  /favorites    │     │  Python · FastAPI · scikit-learn  │
│  /reviews      │     │  K-Means · Apriori · Knapsack 0/1│
└────────────────┘     └──────────────────────────────────┘
```

### Patrón de la app

Clean Architecture con 3 capas por feature:

```
feature/
├── data/
│   ├── datasource/     # llamadas HTTP (Dio)
│   ├── models/         # fromJson / toJson
│   └── repositories/   # implementaciones
├── domain/
│   ├── entities/       # clases puras
│   ├── repositories/   # interfaces
│   └── usecases/       # lógica de negocio
└── presentation/
    ├── pages/          # pantallas
    ├── providers/      # ChangeNotifier
    └── widgets/        # componentes
```

Inyección de dependencias con `injectable` + `get_it`.  
Estado global con `provider`.

---

## Requisitos

| Herramienta | Versión mínima |
|-------------|----------------|
| Flutter     | 3.47.0         |
| Dart        | 3.13.0         |
| Android SDK | API 21+        |
| Java        | 17             |

Verificar instalación:

```bash
flutter doctor
```

---

## Instalación

### 1. Clonar el repositorio

```bash
git clone https://github.com/wilabarca/ExploraChiapas.git
cd ExploraChiapas
git checkout richie-screens
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Generar código de inyección de dependencias

El proyecto usa `injectable` para DI. Cada vez que se agregan nuevos providers o datasources hay que regenerar:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Conectar con el backend

Edita `lib/core/utils/app_constants.dart` y actualiza las URLs si corres los servicios en local:

```dart
static const String baseUrl       = 'http://10.0.2.2:3000/v1/api'; // Android emulator
static const String mlServiceBaseUrl = 'http://10.0.2.2:3001';      // NLP local
```

Para producción las URLs apuntan a Render (ya configuradas por defecto).

---

## Variables de entorno y configuración

La app no usa un archivo `.env`; las URLs y claves viven en `AppConstants` y en los servicios de Render.

### Google OAuth (Ticket 6)

Para activar el login con Google necesitas:

1. Crear un proyecto en [Firebase Console](https://console.firebase.google.com).
2. Agregar la app Android (package: `com.example.explorachiapas`).
3. Descargar `google-services.json` y colocarlo en `android/app/`.
4. En Firebase → Authentication → habilitar proveedor **Google**.
5. El backend debe implementar `POST /users/google-auth` que reciba `{ idToken }` y devuelva un JWT.

### OneSignal (notificaciones)

Reemplaza el App ID en `lib/core/services/notifications/onesignal_service.dart` con el tuyo de [onesignal.com](https://onesignal.com).

---

## Comandos

### Desarrollo

```bash
# Correr en dispositivo/emulador conectado
flutter run

# Correr en modo release
flutter run --release

# Ver dispositivos disponibles
flutter devices

# Hot reload (dentro de flutter run)
r

# Hot restart
R
```

### Build

```bash
# APK debug
flutter build apk --debug

# APK release (requiere keystore configurado)
flutter build apk --release

# AAB para Google Play
flutter build appbundle --release
```

El APK de release queda en:
```
build/app/outputs/flutter-apk/app-release.apk
```

### Generación de código

```bash
# Una sola vez
dart run build_runner build --delete-conflicting-outputs

# Modo watch (regenera automáticamente al guardar)
dart run build_runner watch --delete-conflicting-outputs
```

### Limpieza

```bash
# Limpiar build anterior
flutter clean

# Reinstalar dependencias desde cero
flutter clean && flutter pub get
```

### Análisis

```bash
# Análisis estático
flutter analyze

# Tests
flutter test
```

---

## Estructura del proyecto

```
lib/
├── main.dart                        # Punto de entrada
├── app.dart                         # MaterialApp + rutas + providers globales
│
├── core/
│   ├── di/                          # Inyección de dependencias (get_it)
│   ├── error/                       # Excepciones y Failures
│   ├── l10n/
│   │   └── app_strings.dart         # Traducciones ES / EN
│   ├── network/
│   │   ├── api_client.dart          # Cliente Dio → Backend REST
│   │   └── ml_api_client.dart       # Cliente Dio → NLP Service
│   ├── permissions/                 # Permisos de ubicación
│   ├── providers/
│   │   ├── locale_provider.dart     # Idioma activo (Locale)
│   │   └── preferences_provider.dart# Preferencias persistidas
│   ├── services/
│   │   ├── google_auth_service.dart # Google Sign-In
│   │   └── notifications/          # OneSignal
│   └── utils/
│       └── app_constants.dart       # URLs, keys, constantes
│
└── features/
    ├── auth/                        # Login, Registro, Intereses, OAuth
    ├── Chat/                        # Asistente conversacional IA
    ├── destinos/                    # Catálogo de destinos
    ├── eventos/                     # Eventos en Chiapas
    ├── favoritos/                   # Favoritos del usuario
    ├── home/                        # Pantalla principal
    ├── maps/                        # Mapa interactivo (flutter_map + OSRM)
    ├── negocio/                     # Listado de negocios por tipo
    ├── profile/                     # Perfil, Preferencias, Privacidad
    └── resenas/                     # Reseñas de destinos
```

---

## Servicios externos

| Servicio | URL | Descripción |
|----------|-----|-------------|
| Backend REST | `https://explora-chiapas.onrender.com/v1/api` | Auth, usuarios, destinos, eventos, favoritos |
| NLP Service (Capa 1) | `https://nlp-service-6hvo.onrender.com` | Extracción de parámetros con Groq + redacción de itinerario |
| ML Engine (Capa 2) | *(configurar en `ML_ENGINE_URL`)* | K-Means, Apriori, Knapsack 0/1 |
| OSRM | `https://router.project-osrm.org` | Rutas reales en el mapa |

> Los servicios en Render free tier tienen cold start de ~50 s. El NLP service reintenta automáticamente hasta 3 veces si recibe 502.

---

## Base de datos

El schema completo está en `schema.sql` (entregado por separado). Tablas principales:

| Tabla | Descripción |
|-------|-------------|
| `users` | Usuarios con soporte OAuth (`provider`, `google_id`) |
| `user_types` | turista_nacional / turista_extranjero / habitante_local |
| `user_preferences` | Idioma, unidades, tema, moneda (por usuario) |
| `user_interests` | Categorías de turismo seleccionadas en onboarding |
| `user_privacy` | Configuración de privacidad |
| `destinations` | Catálogo de destinos y restaurantes |
| `events` | Eventos turísticos |
| `favorites` | Favoritos por usuario |
| `reviews` | Reseñas con rating 1-5 |
| `chat_history` | Historial de conversaciones con el asistente |

Aplicar schema en una base limpia:

```bash
psql -U postgres -d explorachiapas -f schema.sql
```

---

## Autenticación

La app usa JWT almacenado en `SharedPreferences`.

### Flujo email/password

```
RegisterPage → InterestsPage → /home
LoginPage → (verifica onboarding_completo) → /home o /intereses
WelcomePage → (verifica JWT existente) → /home automático
```

### Flujo Google OAuth

```
LoginPage (botón Google) → GoogleAuthService.signIn()
  → Google devuelve idToken
  → POST /users/google-auth { idToken }
  → Backend valida, crea/vincula usuario, devuelve JWT
  → App guarda JWT → /home
```

> Requiere configurar `google-services.json` y el endpoint en el backend.

---

## Dependencias principales

| Paquete | Versión | Uso |
|---------|---------|-----|
| `provider` | ^6.1.5 | Estado global |
| `injectable` / `get_it` | ^3.0.0 / ^9.2.1 | Inyección de dependencias |
| `dio` | ^5.9.2 | Cliente HTTP |
| `shared_preferences` | ^2.5.5 | Persistencia local |
| `flutter_map` | ^7.0.2 | Mapa interactivo (OpenStreetMap) |
| `google_sign_in` | ^6.2.2 | Autenticación con Google |
| `flutter_localizations` | sdk | Soporte multi-idioma |
| `google_fonts` | ^8.1.0 | Fuente Poppins |
| `onesignal_flutter` | ^5.2.6 | Notificaciones push |
| `geolocator` | ^14.0.3 | Ubicación del usuario |
| `url_launcher` | ^6.3.2 | Abrir URLs externas |
| `cached_network_image` | ^3.4.1 | Caché de imágenes |
| `dartz` | ^0.10.1 | Either para manejo de errores |
