import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/notification_service.dart';

/// Initialisiert Plattform-Bindings und externe Dienste vor [runApp].
/// Wird ausschließlich aus `main.dart` aufgerufen.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://kashnqsqrltdhehjrzzt.supabase.co',
    anonKey: 'sb_publishable_TTahnRlQFFqx1E2OHFEhKQ_gtd7P_G0',
  );

  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermissions();
}
