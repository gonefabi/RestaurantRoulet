import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/restaurant.dart';
import '../providers/roulette_provider.dart';
import '../services/database_service.dart';
import '../widgets/rating_popup.dart';

enum _SortOption {
  newestFirst,
  oldestFirst,
  bestRated,
  worstRated,
  unratedFirst,
  mostVisited,
}

extension _SortOptionLabel on _SortOption {
  String get label {
    switch (this) {
      case _SortOption.newestFirst:   return 'Neueste';
      case _SortOption.oldestFirst:   return 'Älteste';
      case _SortOption.bestRated:     return 'Beste';
      case _SortOption.worstRated:    return 'Schlechteste';
      case _SortOption.unratedFirst:  return 'Unbewertet';
      case _SortOption.mostVisited:   return 'Meist besucht';
    }
  }

  IconData get icon {
    switch (this) {
      case _SortOption.newestFirst:   return Icons.arrow_downward;
      case _SortOption.oldestFirst:   return Icons.arrow_upward;
      case _SortOption.bestRated:     return Icons.star;
      case _SortOption.worstRated:    return Icons.star_border;
      case _SortOption.unratedFirst:  return Icons.star_outline;
      case _SortOption.mostVisited:   return Icons.repeat;
    }
  }
}

class VisitedRestaurantsScreen extends ConsumerStatefulWidget {
  const VisitedRestaurantsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<VisitedRestaurantsScreen> createState() =>
      _VisitedRestaurantsScreenState();
}

class _VisitedRestaurantsScreenState
    extends ConsumerState<VisitedRestaurantsScreen> {
  late Future<List<Restaurant>> _visitedRestaurantsFuture;
  final DatabaseService _dbService = DatabaseService();
  _SortOption _sortOption = _SortOption.newestFirst;

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  void _refreshList() {
    setState(() {
      _visitedRestaurantsFuture = _dbService.getVisitedRestaurants();
    });
  }

  List<Restaurant> _sorted(List<Restaurant> list) {
    final sorted = List<Restaurant>.from(list);
    switch (_sortOption) {
      case _SortOption.newestFirst:
        sorted.sort((a, b) =>
            (b.visitedAt ?? DateTime(0)).compareTo(a.visitedAt ?? DateTime(0)));
      case _SortOption.oldestFirst:
        sorted.sort((a, b) =>
            (a.visitedAt ?? DateTime(0)).compareTo(b.visitedAt ?? DateTime(0)));
      case _SortOption.bestRated:
        sorted.sort((a, b) {
          if ((a.userRating ?? 0) == 0 && (b.userRating ?? 0) == 0) return 0;
          if ((a.userRating ?? 0) == 0) return 1;
          if ((b.userRating ?? 0) == 0) return -1;
          return b.userRating!.compareTo(a.userRating!);
        });
      case _SortOption.worstRated:
        sorted.sort((a, b) {
          if ((a.userRating ?? 0) == 0 && (b.userRating ?? 0) == 0) return 0;
          if ((a.userRating ?? 0) == 0) return 1;
          if ((b.userRating ?? 0) == 0) return -1;
          return a.userRating!.compareTo(b.userRating!);
        });
      case _SortOption.unratedFirst:
        sorted.sort((a, b) {
          final aRated = (a.userRating ?? 0) > 0;
          final bRated = (b.userRating ?? 0) > 0;
          if (!aRated && bRated) return -1;
          if (aRated && !bRated) return 1;
          return 0;
        });
      case _SortOption.mostVisited:
        sorted.sort((a, b) => b.visitCount.compareTo(a.visitCount));
    }
    return sorted;
  }

  void _showRatingDialog(Restaurant restaurant) {
    showDialog(
      context: context,
      builder: (context) => RatingPopup(
        restaurant: restaurant,
        onDismiss: () => Navigator.of(context).pop(),
        onRatingSaved: (rating) async {
          await _dbService.updateRating(restaurant.id, rating);
          if (mounted) Navigator.of(context).pop();
          _refreshList();
        },
      ),
    );
  }

  void _showActionSheet(BuildContext context, Restaurant restaurant) {
    final theme = Theme.of(context);
    final isRated = (restaurant.userRating ?? 0) > 0;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Restaurant name
                Text(
                  restaurant.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (restaurant.address != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    restaurant.address!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],

                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 8),

                // Rate action
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.star_rounded,
                        color: Colors.amber.shade700, size: 26),
                  ),
                  title: Text(
                    isRated ? 'Bewertung ändern' : 'Jetzt bewerten',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: isRated
                      ? Row(
                          children: List.generate(
                            5,
                            (i) => Icon(
                              i < restaurant.userRating!
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              size: 16,
                              color: Colors.amber.shade600,
                            ),
                          ),
                        )
                      : Text('Noch nicht bewertet',
                          style: TextStyle(color: Colors.grey.shade500)),
                  trailing:
                      Icon(Icons.chevron_right, color: Colors.grey.shade400),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _showRatingDialog(restaurant);
                  },
                ),

                const SizedBox(height: 4),

                // Navigate action
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.navigation_rounded,
                        color: theme.colorScheme.primary, size: 26),
                  ),
                  title: const Text(
                    'Erneut besuchen',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('Route in Google Maps öffnen',
                      style: TextStyle(color: Colors.grey.shade500)),
                  trailing:
                      Icon(Icons.chevron_right, color: Colors.grey.shade400),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    ref.read(rouletteProvider.notifier).navigateToRestaurant(restaurant);
                  },
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Besuchte Restaurants'),
      ),
      body: Column(
        children: [
          // Sort chips
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: _SortOption.values.map((option) {
                final selected = _sortOption == option;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: selected,
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(option.icon,
                            size: 14,
                            color: selected
                                ? Colors.white
                                : theme.colorScheme.primary),
                        const SizedBox(width: 4),
                        Text(option.label),
                      ],
                    ),
                    onSelected: (_) =>
                        setState(() => _sortOption = option),
                    selectedColor: theme.colorScheme.primary,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : null,
                      fontWeight: selected ? FontWeight.w600 : null,
                      fontSize: 13,
                    ),
                    showCheckmark: false,
                    side: BorderSide(
                      color: selected
                          ? theme.colorScheme.primary
                          : Colors.grey.shade300,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // List
          Expanded(
            child: FutureBuilder<List<Restaurant>>(
              future: _visitedRestaurantsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Fehler: ${snapshot.error}'));
                }

                final restaurants = _sorted(snapshot.data ?? []);

                if (restaurants.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.restaurant,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'Noch keine Restaurants besucht.',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  itemCount: restaurants.length,
                  itemBuilder: (context, index) {
                    final r = restaurants[index];
                    final isRated = (r.userRating ?? 0) > 0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _showActionSheet(context, r),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name + visit count badge
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      r.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (r.visitCount > 1)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.repeat,
                                              size: 12,
                                              color:
                                                  theme.colorScheme.primary),
                                          const SizedBox(width: 3),
                                          Text(
                                            '${r.visitCount}×',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),

                              // Address
                              if (r.address != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  r.address!,
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600),
                                ),
                              ],

                              const SizedBox(height: 10),

                              // Footer: date + rating button
                              Row(
                                children: [
                                  Icon(Icons.access_time,
                                      size: 13,
                                      color: Colors.grey.shade400),
                                  const SizedBox(width: 4),
                                  Text(
                                    r.visitedAt != null
                                        ? DateFormat('dd.MM.yyyy')
                                            .format(r.visitedAt!)
                                        : '–',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500),
                                  ),
                                  const Spacer(),
                                  // Rating button
                                  isRated
                                      ? _RatingBadge(rating: r.userRating!)
                                      : _RateButton(
                                          onTap: () =>
                                              _showRatingDialog(r),
                                        ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
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
}

/// Zeigt vorhandene Bewertung als Sterne-Badge
class _RatingBadge extends StatelessWidget {
  final int rating;
  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(
            rating,
            (_) => const Icon(Icons.star_rounded,
                size: 16, color: Colors.amber),
          ),
          ...List.generate(
            5 - rating,
            (_) => Icon(Icons.star_outline_rounded,
                size: 16, color: Colors.amber.shade300),
          ),
        ],
      ),
    );
  }
}

/// Bewerten-Button für unbewertete Restaurants
class _RateButton extends StatelessWidget {
  final VoidCallback onTap;
  const _RateButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: primary,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: primary.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_rounded, size: 16, color: Colors.white),
            SizedBox(width: 5),
            Text(
              'Bewerten',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
