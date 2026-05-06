import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/env.dart';

class AuthService {
  AuthService() {
    _googleSignIn = GoogleSignIn(serverClientId: Env.googleWebClientId);
  }

  final SupabaseClient _supabase = Supabase.instance.client;
  late final GoogleSignIn _googleSignIn;

  // Stream, um den Auth-Status zu überwachen
  Stream<User?> get authStateChanges => _supabase.auth.onAuthStateChange.map((event) => event.session?.user);

  // Google Sign-In
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // Der User hat den Login abgebrochen
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        print("Kein ID Token erhalten.");
        return null;
      }

      final AuthResponse response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      return response.user;
    } catch (e) {
      print("Google Sign-In Fehler: $e");
      return null;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _supabase.auth.signOut();
  }
}

// --- Riverpod Providers ---

// Stellt die AuthService-Instanz bereit
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Stellt einen Stream bereit, der auf Auth-Änderungen lauscht
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});
