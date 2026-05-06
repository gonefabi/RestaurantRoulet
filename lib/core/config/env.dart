/// Build-Time-Konfiguration aus `--dart-define` (oder `--dart-define-from-file`).
///
/// Lokal: `flutter run --dart-define-from-file=.env.json`
/// CI:    `--dart-define=KEY=VALUE` pro Wert.
///
/// Die Werte sind alle `const String.fromEnvironment(...)` — sie werden
/// zur Build-Zeit aufgelöst und sind tree-shakeable. Fehlt ein Wert beim
/// Build, schlägt [assertConfigured] beim App-Start fehl.
class Env {
  Env._();

  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );
  static const geoapifyKey = String.fromEnvironment(
    'GEOAPIFY_KEY',
    defaultValue: '',
  );
  static const googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '',
  );

  /// Vor [runApp] aufrufen. Wirft [StateError] mit allen fehlenden Keys —
  /// vermeidet kryptische Folgefehler in Supabase/Geoapify-Calls.
  static void assertConfigured() {
    final missing = <String>[
      if (supabaseUrl.isEmpty) 'SUPABASE_URL',
      if (supabaseAnonKey.isEmpty) 'SUPABASE_ANON_KEY',
      if (geoapifyKey.isEmpty) 'GEOAPIFY_KEY',
      if (googleWebClientId.isEmpty) 'GOOGLE_WEB_CLIENT_ID',
    ];
    if (missing.isEmpty) return;
    throw StateError(
      'Missing build-time config: ${missing.join(', ')}.\n'
      'Run with --dart-define-from-file=.env.json '
      '(see .env.example.json) or pass --dart-define=KEY=VALUE per value.',
    );
  }
}
