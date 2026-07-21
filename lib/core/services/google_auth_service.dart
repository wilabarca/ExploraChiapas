import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: '600216508344-arr16mlnv5g9ieh38dfbg9qmh1htslat.apps.googleusercontent.com',
  );

  // No atrapa la excepción: quien llama decide cómo mostrarla al usuario.
  // Antes se tragaba el error aquí y la app solo "regresaba al login" sin
  // explicación (ej. DEVELOPER_ERROR por SHA-1 no registrado en Firebase).
  static Future<GoogleSignInAccount?> signIn() async {
    try {
      return await _googleSignIn.signIn();
    } catch (e) {
      debugPrint('[GoogleAuthService] Error al iniciar sesión con Google: $e');
      rethrow;
    }
  }

  static Future<String?> getIdToken() async {
    try {
      final account = await _googleSignIn.signInSilently();
      if (account == null) return null;
      final auth = await account.authentication;
      return auth.idToken;
    } catch (e) {
      debugPrint('[GoogleAuthService] Error al obtener token: $e');
      return null;
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
