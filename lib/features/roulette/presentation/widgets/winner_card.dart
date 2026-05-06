import 'package:flutter/material.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/models/restaurant.dart';

class WinnerCard extends StatelessWidget {
  const WinnerCard({
    super.key,
    required this.restaurant,
    required this.alreadyVisited,
    required this.onStartRoute,
  });

  final Restaurant restaurant;
  final bool alreadyVisited;
  final ValueChanged<Restaurant> onStartRoute;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    final name =
        restaurant.name.isNotEmpty ? restaurant.name : l.restaurantUnknownName;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              l.winner,
              style: TextStyle(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            if (restaurant.address != null)
              Text(
                restaurant.address!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54, fontSize: 16),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => onStartRoute(restaurant),
                icon: const Icon(Icons.navigation_outlined, size: 28),
                label: Text(
                  l.startRoute,
                  style: const TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.colorScheme.primary,
                ),
              ),
            ),
            if (alreadyVisited)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      l.alreadyVisited,
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
