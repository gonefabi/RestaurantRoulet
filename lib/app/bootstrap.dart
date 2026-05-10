import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/env.dart';
import '../features/notifications/data/notification_service.dart';

/// Initialisiert Plattform-Bindings und externe Dienste vor [runApp].
/// Wird ausschließlich aus `main.dart` aufgerufen.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  Env.assertConfigured();

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermissions();
}
