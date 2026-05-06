/// Filterkriterien für die Restaurant-Suche.
class SearchFilters {
  const SearchFilters({
    this.radiusKm = 2.0,
    this.cuisines = const [],
    this.isVegan = false,
    this.isVegetarian = false,
  });

  final double radiusKm;
  final List<String> cuisines;
  final bool isVegan;
  final bool isVegetarian;
}
