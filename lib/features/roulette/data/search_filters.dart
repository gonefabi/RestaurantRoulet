/// Filterkriterien für die Restaurant-Suche.
class SearchFilters {
  const SearchFilters({
    this.radiusKm = 2.0,
    this.placeTypes = const ['restaurant'],
    this.cuisines = const [],
    this.isVegan = false,
    this.isVegetarian = false,
    this.wheelchairAccessible = false,
  });

  final double radiusKm;
  final List<String> placeTypes;
  final List<String> cuisines;
  final bool isVegan;
  final bool isVegetarian;
  final bool wheelchairAccessible;
}
