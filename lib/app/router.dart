import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/roulette/presentation/pages/home_page.dart';
import '../features/visited/presentation/pages/visited_page.dart';
import '../features/auth/data/auth_service.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/notifications/presentation/pages/notification_settings_page.dart';

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
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoute.visited,
        builder: (context, state) => const VisitedPage(),
      ),
      GoRoute(
        path: AppRoute.notificationSettings,
        builder: (context, state) => const NotificationSettingsPage(),
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
