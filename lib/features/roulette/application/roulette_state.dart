import 'package:geolocator/geolocator.dart';

import '../../../core/models/restaurant.dart';

/// Immutabler State des Roulette-Flows (Standort, Filter, Suchergebnis,
/// Auswahl, bekannte Besuche).
class RouletteState {
  const RouletteState({
    this.isLoading = false,
    this.restaurants = const [],
    this.selectedRestaurant,
    this.error,
    this.currentPosition,
    this.radiusKm = 2.0,
    this.selectedCuisines = const [],
    this.isVegan = false,
    this.isVegetarian = false,
    this.excludeVisited = true,
    this.visitedIds = const {},
  });

  final bool isLoading;
  final List<Restaurant> restaurants;
  final Restaurant? selectedRestaurant;
  final String? error;
  final Position? currentPosition;
  final double radiusKm;
  final List<String> selectedCuisines;
  final bool isVegan;
  final bool isVegetarian;
  final bool excludeVisited;
  final Set<String> visitedIds;

  RouletteState copyWith({
    bool? isLoading,
    List<Restaurant>? restaurants,
    Restaurant? selectedRestaurant,
    String? error,
    Position? currentPosition,
    double? radiusKm,
    bool clearSelectedRestaurant = false,
    List<String>? selectedCuisines,
    bool? isVegan,
    bool? isVegetarian,
    bool? excludeVisited,
    Set<String>? visitedIds,
  }) {
    return RouletteState(
      isLoading: isLoading ?? this.isLoading,
      restaurants: restaurants ?? this.restaurants,
      selectedRestaurant: clearSelectedRestaurant
          ? null
          : selectedRestaurant ?? this.selectedRestaurant,
      error: error,
      currentPosition: currentPosition ?? this.currentPosition,
      radiusKm: radiusKm ?? this.radiusKm,
      selectedCuisines: selectedCuisines ?? this.selectedCuisines,
      isVegan: isVegan ?? this.isVegan,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      excludeVisited: excludeVisited ?? this.excludeVisited,
      visitedIds: visitedIds ?? this.visitedIds,
    );
  }
}
