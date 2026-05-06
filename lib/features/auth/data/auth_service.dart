import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // TODO: Trage hier deine Web Client ID aus der Google Cloud Console ein.
  // Das ist NICHT die Android-Client-ID.
  final String _webClientId = '882794991997-aupn8mghfid3eciabjf4c8s3m4sdvs76.apps.googleusercontent.com';

  late final GoogleSignIn _googleSignIn;

  AuthService() {
    _googleSignIn = GoogleSignIn(
      serverClientId: _webClientId,
    );
  }

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
