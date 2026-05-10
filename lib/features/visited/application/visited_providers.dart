import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/restaurant.dart';
import '../data/visited_repository.dart';
import 'visited_sort.dart';

/// Aktuelle Sortier-Option der Visited-Liste.
final visitedSortOptionProvider = StateProvider.autoDispose<SortOption>(
  (ref) => SortOption.newestFirst,
);

/// Liste aller besuchten Restaurants. Mit `ref.invalidate` neu laden.
final visitedRestaurantsProvider =
    FutureProvider.autoDispose<List<Restaurant>>((ref) {
  return ref.watch(visitedRepositoryProvider).getVisitedRestaurants();
});
