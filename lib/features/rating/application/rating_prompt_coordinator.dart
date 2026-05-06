import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/restaurant.dart';
import '../../../services/notification_service.dart';
import '../../../widgets/rating_popup.dart';
import '../../visited/data/visited_repository.dart';

/// Findet Restaurants, die eine nachträgliche Bewertung verdient haben,
/// und zeigt das Bewertungs-Popup an.
///
/// Trennt die Auswahl-Logik (welches Restaurant?) von der UI-Orchestrierung
/// (showDialog) — beides war vorher in HomeScreen verquickt.
class RatingPromptCoordinator {
  const RatingPromptCoordinator({
    required VisitedRepository visitedRepo,
    required NotificationService notificationService,
  })  : _visitedRepo = visitedRepo,
        _notificationService = notificationService;

  final VisitedRepository _visitedRepo;
  final NotificationService _notificationService;

  /// Sucht das Restaurant, das aktuell ein Rating-Popup auslösen soll.
  /// Reihenfolge: 1) Notification-Tap, 2) DB-Kandidat (>3h besucht, unbewertet).
  Future<Restaurant?> findCandidate() async {
    final launch = await _notificationService
        .flutterLocalNotificationsPlugin
        .getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      final payload = launch!.notificationResponse?.payload;
      if (payload != null) {
        try {
          final visited = await _visitedRepo.getVisitedRestaurants();
          return visited.firstWhere((r) => r.id == payload);
        } catch (_) {
          // Kein passender Eintrag — Fallback auf DB-Heuristik.
        }
      }
    }
    final visited = await _visitedRepo.getVisitedRestaurants();
    try {
      return visited.firstWhere(
        (r) =>
            !r.popupDismissed &&
            r.userRating == null &&
            r.visitedAt != null &&
            DateTime.now().difference(r.visitedAt!) > const Duration(hours: 3),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> show(BuildContext context, Restaurant restaurant) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => RatingPopup(
        restaurant: restaurant,
        onDismiss: () async {
          await _visitedRepo.markPopupDismissed(restaurant.id);
          if (dialogContext.mounted) Navigator.of(dialogContext).pop();
        },
        onRatingSaved: (rating) async {
          await _visitedRepo.updateRating(restaurant.id, rating);
          if (dialogContext.mounted) Navigator.of(dialogContext).pop();
        },
      ),
    );
  }
}

final ratingPromptCoordinatorProvider = Provider<RatingPromptCoordinator>(
  (ref) => RatingPromptCoordinator(
    visitedRepo: ref.watch(visitedRepositoryProvider),
    notificationService: NotificationService(),
  ),
);
