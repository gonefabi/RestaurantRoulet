import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../screens/home_screen.dart';
import '../screens/login_page.dart';
import '../screens/notification_settings_screen.dart';
import '../screens/visited_restaurants_screen.dart';
import '../services/auth_service.dart';

/// Bekannte Routen — als Konstanten, damit Aufrufer keine Strings duplizieren.
class AppRoute {
  AppRoute._();
  static const home = '/';
  static const login = '/login';
  static const visited = '/visited';
  static const notificationSettings = '/notifications/settings';
}

/// Globaler Router. Refresht automatisch bei Auth-Änderungen und leitet
/// nicht eingeloggte Nutzer zur Login-Seite, eingeloggte weg von Login.
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRefreshNotifier(
    ref.watch(authServiceProvider).authStateChanges,
  );
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AppRoute.home,
    refreshListenable: refresh,
    redirect: (context, state) {
      final loggedIn = Supabase.instance.client.auth.currentUser != null;
      final goingToLogin = state.matchedLocation == AppRoute.login;

      if (!loggedIn && !goingToLogin) return AppRoute.login;
      if (loggedIn && goingToLogin) return AppRoute.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoute.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoute.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoute.visited,
        builder: (context, state) => const VisitedRestaurantsScreen(),
      ),
      GoRoute(
        path: AppRoute.notificationSettings,
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
    ],
  );
});

/// Brücke zwischen Auth-Stream und go_routers `refreshListenable`.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Stream<dynamic> stream) {
    notifyListeners();
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
