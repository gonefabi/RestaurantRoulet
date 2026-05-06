import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/models/restaurant.dart';
import '../../../../core/services/link_launcher_service.dart';
import '../../../../core/widgets/app_action_sheet.dart';
import '../../../../core/widgets/star_rating.dart';
import '../../../rating/presentation/widgets/rating_popup.dart';
import '../../application/visited_providers.dart';
import '../../application/visited_sort.dart';
import '../../data/visited_repository.dart';
import '../widgets/sort_chip_row.dart';
import '../widgets/visited_list_tile.dart';

/// Liste aller besuchten Restaurants — sortierbar, mit Action-Sheet zum
/// Bewerten oder erneutem Anfahren.
class VisitedPage extends ConsumerWidget {
  const VisitedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final asyncList = ref.watch(visitedRestaurantsProvider);
    final sortOption = ref.watch(visitedSortOptionProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.visitedTitle)),
      body: Column(
        children: [
          const SortChipRow(),
          Expanded(
            child: asyncList.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(l.visitedError(e.toString()))),
              data: (list) {
                if (list.isEmpty) return const _EmptyState();
                final sorted = sortVisited(list, sortOption);
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: sorted.length,
                  itemBuilder: (context, index) {
                    final r = sorted[index];
                    return VisitedListTile(
                      restaurant: r,
                      onTap: () => _showActionSheet(context, ref, r),
                      onRate: () => _showRatingDialog(context, ref, r),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showActionSheet(
    BuildContext context,
    WidgetRef ref,
    Restaurant restaurant,
  ) {
    final l = AppLocalizations.of(context);
    final isRated = (restaurant.userRating ?? 0) > 0;
    AppActionSheet.show(
      context,
      title: restaurant.name.isNotEmpty
          ? restaurant.name
          : l.restaurantUnknownName,
      subtitle: restaurant.address,
      actions: [
        AppAction(
          icon: Icons.star_rounded,
          iconColor: Colors.amber.shade700,
          iconBackground: Colors.amber.shade50,
          label: isRated ? l.visitedRateChange : l.visitedRateNew,
          subtitle: isRated ? null : l.visitedNotRated,
          subtitleWidget: isRated
              ? StarRating(
                  rating: restaurant.userRating!,
                  size: 16,
                  filledColor: Colors.amber.shade600,
                )
              : null,
          onTap: () => _showRatingDialog(context, ref, restaurant),
        ),
        AppAction(
          icon: Icons.navigation_rounded,
          label: l.visitedReVisit,
          subtitle: l.visitedReVisitSubtitle,
          onTap: () => ref.read(linkLauncherServiceProvider).openMapsRoute(
                name: restaurant.name,
                address: restaurant.address,
              ),
        ),
      ],
    );
  }

  void _showRatingDialog(
    BuildContext context,
    WidgetRef ref,
    Restaurant restaurant,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => RatingPopup(
        restaurant: restaurant,
        onDismiss: () => Navigator.of(dialogContext).pop(),
        onRatingSaved: (rating) async {
          await ref
              .read(visitedRepositoryProvider)
              .updateRating(restaurant.id, rating);
          if (dialogContext.mounted) Navigator.of(dialogContext).pop();
          ref.invalidate(visitedRestaurantsProvider);
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.restaurant, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            l.visitedEmpty,
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
