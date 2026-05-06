import 'package:geolocator/geolocator.dart';

import '../../../core/models/restaurant.dart';

enum RouletteError {
  locationServicesDisabled,
  locationPermissionDenied,
  locationPermissionDeniedForever,
  noLocation,
  noRestaurantsFound,
  noRestaurantsFoundExcludingVisited,
  apiError,
}

/// Immutabler State des Roulette-Flows (Standort, Filter, Suchergebnis,
/// Auswahl, bekannte Besuche).
class RouletteState {
  const RouletteState({
    this.isLoading = false,
    this.restaurants = const [],
    this.selectedRestaurant,
    this.errorCode,
    this.currentPosition,
    this.radiusKm = 2.0,
    this.placeTypes = const ['restaurant'],
    this.selectedCuisines = const [],
    this.isVegan = false,
    this.isVegetarian = false,
    this.wheelchairAccessible = false,
    this.excludeVisited = true,
    this.visitedIds = const {},
  });

  final bool isLoading;
  final List<Restaurant> restaurants;
  final Restaurant? selectedRestaurant;
  final RouletteError? errorCode;
  final Position? currentPosition;
  final double radiusKm;
  final List<String> placeTypes;
  final List<String> selectedCuisines;
  final bool isVegan;
  final bool isVegetarian;
  final bool wheelchairAccessible;
  final bool excludeVisited;
  final Set<String> visitedIds;

  RouletteState copyWith({
    bool? isLoading,
    List<Restaurant>? restaurants,
    Restaurant? selectedRestaurant,
    RouletteError? errorCode,
    Position? currentPosition,
    double? radiusKm,
    bool clearSelectedRestaurant = false,
    List<String>? placeTypes,
    List<String>? selectedCuisines,
    bool? isVegan,
    bool? isVegetarian,
    bool? wheelchairAccessible,
    bool? excludeVisited,
    Set<String>? visitedIds,
  }) {
    return RouletteState(
      isLoading: isLoading ?? this.isLoading,
      restaurants: restaurants ?? this.restaurants,
      selectedRestaurant: clearSelectedRestaurant
          ? null
          : selectedRestaurant ?? this.selectedRestaurant,
      errorCode: errorCode,
      currentPosition: currentPosition ?? this.currentPosition,
      radiusKm: radiusKm ?? this.radiusKm,
      placeTypes: placeTypes ?? this.placeTypes,
      selectedCuisines: selectedCuisines ?? this.selectedCuisines,
      isVegan: isVegan ?? this.isVegan,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      wheelchairAccessible: wheelchairAccessible ?? this.wheelchairAccessible,
      excludeVisited: excludeVisited ?? this.excludeVisited,
      visitedIds: visitedIds ?? this.visitedIds,
    );
  }
}
