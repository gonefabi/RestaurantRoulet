import '../../../core/models/restaurant.dart';

/// Sortier-Optionen für die Visited-Liste.
/// Labels und Icons leben bewusst in der Presentation-Schicht.
enum SortOption {
  newestFirst,
  oldestFirst,
  bestRated,
  worstRated,
  unratedFirst,
  mostVisited,
}

/// Liefert eine sortierte Kopie von [list].
List<Restaurant> sortVisited(List<Restaurant> list, SortOption option) {
  final sorted = List<Restaurant>.from(list);
  switch (option) {
    case SortOption.newestFirst:
      sorted.sort((a, b) =>
          (b.visitedAt ?? DateTime(0)).compareTo(a.visitedAt ?? DateTime(0)));
    case SortOption.oldestFirst:
      sorted.sort((a, b) =>
          (a.visitedAt ?? DateTime(0)).compareTo(b.visitedAt ?? DateTime(0)));
    case SortOption.bestRated:
      sorted.sort(_byRating(descending: true));
    case SortOption.worstRated:
      sorted.sort(_byRating(descending: false));
    case SortOption.unratedFirst:
      sorted.sort((a, b) {
        final aRated = (a.userRating ?? 0) > 0;
        final bRated = (b.userRating ?? 0) > 0;
        if (!aRated && bRated) return -1;
        if (aRated && !bRated) return 1;
        return 0;
      });
    case SortOption.mostVisited:
      sorted.sort((a, b) => b.visitCount.compareTo(a.visitCount));
  }
  return sorted;
}

/// Vergleicher für Bewertungen — unbewertete (0) immer ans Ende.
int Function(Restaurant, Restaurant) _byRating({required bool descending}) {
  return (a, b) {
    final ar = a.userRating ?? 0;
    final br = b.userRating ?? 0;
    if (ar == 0 && br == 0) return 0;
    if (ar == 0) return 1;
    if (br == 0) return -1;
    return descending ? br.compareTo(ar) : ar.compareTo(br);
  };
}
