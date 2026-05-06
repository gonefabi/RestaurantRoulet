import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/restaurant.dart';
import 'rate_button.dart';
import 'visited_rating_badge.dart';

/// Eine Karte in der Visited-Liste: Name, optionale Adresse, Datum,
/// Visit-Count und Bewerten-Button bzw. Bewertungsanzeige.
class VisitedListTile extends StatelessWidget {
  const VisitedListTile({
    super.key,
    required this.restaurant,
    required this.onTap,
    required this.onRate,
  });

  final Restaurant restaurant;
  final VoidCallback onTap;
  final VoidCallback onRate;

  @override
  Widget build(BuildContext context) {
    final isRated = (restaurant.userRating ?? 0) > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      restaurant.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (restaurant.visitCount > 1)
                    _VisitCountBadge(count: restaurant.visitCount),
                ],
              ),
              if (restaurant.address != null) ...[
                const SizedBox(height: 4),
                Text(
                  restaurant.address!,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.access_time, size: 13, color: Colors.grey.shade400),
                  const SizedBox(width: 4),
                  Text(
                    restaurant.visitedAt != null
                        ? DateFormat('dd.MM.yyyy').format(restaurant.visitedAt!)
                        : '–',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const Spacer(),
                  if (isRated)
                    VisitedRatingBadge(rating: restaurant.userRating!)
                  else
                    RateButton(onTap: onRate),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VisitCountBadge extends StatelessWidget {
  const _VisitCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.repeat, size: 12, color: primary),
          const SizedBox(width: 3),
          Text(
            '$count×',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primary,
            ),
          ),
        ],
      ),
    );
  }
}
