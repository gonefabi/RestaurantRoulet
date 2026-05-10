import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Dünner Wrapper um `url_launcher` mit App-spezifischen Helfern.
///
/// Ein-/Ausschalter für alle externen Links der App, damit Side-Effects
/// nicht in State-Notifier oder Widget-Builder duplizieren.
class LinkLauncherService {
  const LinkLauncherService();

  Future<bool> openExternal(Uri url) {
    return launchUrl(url, mode: LaunchMode.externalApplication);
  }

  /// Öffnet Google Maps mit Routenplanung zu [name] + [address].
  Future<bool> openMapsRoute({required String name, String? address}) {
    final destination = Uri.encodeComponent("$name, ${address ?? ''}");
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=$destination&travelmode=driving',
    );
    return openExternal(url);
  }
}

final linkLauncherServiceProvider = Provider<LinkLauncherService>(
  (ref) => const LinkLauncherService(),
);
