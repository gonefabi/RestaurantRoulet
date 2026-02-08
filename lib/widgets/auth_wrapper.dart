import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/home_screen.dart';
import '../screens/login_page.dart';
import '../services/auth_service.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          // User ist eingeloggt -> HomeScreen anzeigen
          return const HomeScreen();
        } else {
          // User ist nicht eingeloggt -> LoginPage anzeigen
          return const LoginPage();
        }
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, stack) => const Scaffold(
        body: Center(
          child: Text('Etwas ist schief gelaufen!'),
        ),
      ),
    );
  }
}
