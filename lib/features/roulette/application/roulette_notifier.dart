import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/models/restaurant.dart';
import '../../visited/data/visited_repository.dart';
import '../data/api_service.dart';
import '../data/search_filters.dart';
import 'roulette_state.dart';

/// State-Notifier für den Roulette-Flow.
///
/// Hält *ausschließlich* State + asynchrone Daten-Operationen (DB, API, GPS).
/// Externe Side-Effects wie Maps/Notifications liegen bewusst beim aufrufenden
/// Widget — der Notifier ist damit frei von BuildContext, l10n, launchUrl,
/// und gut testbar.
class RouletteNotifier extends StateNotifier<RouletteState> {
  RouletteNotifier(this._apiService, this._visitedRepo)
      : super(const RouletteState()) {
    _init();
  }

  final ApiService _apiService;
  final VisitedRepository _visitedRepo;

  Future<void> _init() async {
    await updateLocation();
    await _loadVisitedRestaurants();
  }

  Future<void> _loadVisitedRestaurants() async {
    final ids = await _visitedRepo.getVisitedRestaurantIds();
    state = state.copyWith(visitedIds: ids);
  }

  // --- Filter ---
  void togglePlaceType(String type) {
    final types = List<String>.from(state.placeTypes);
    if (types.contains(type)) {
      if (types.length == 1) return;
      types.remove(type);
    } else {
      types.add(type);
    }
    state = state.copyWith(placeTypes: types);
  }

  void toggleCuisine(String cuisine) {
    final cuisines = List<String>.from(state.selectedCuisines);
    if (cuisines.contains(cuisine)) {
      cuisines.remove(cuisine);
    } else {
      cuisines.add(cuisine);
    }
    state = state.copyWith(selectedCuisines: cuisines);
  }

  void toggleVegan(bool value) =>
      state = state.copyWith(isVegan: value);

  void toggleVegetarian(bool value) =>
      state = state.copyWith(isVegetarian: value);

  void toggleWheelchair(bool value) =>
      state = state.copyWith(wheelchairAccessible: value);

  void toggleExcludeVisited(bool value) =>
      state = state.copyWith(excludeVisited: value);

  void setRadius(double km) {
    final clamped = km.clamp(0.5, 20.0);
    state = state.copyWith(radiusKm: clamped);
  }

  // --- Visit-Tracking ---
  Future<void> markAsVisited(Restaurant restaurant) async {
    await _visitedRepo.addVisitedRestaurant(restaurant);
    final ids = await _visitedRepo.getVisitedRestaurantIds();
    state = state.copyWith(visitedIds: ids);
  }

  // --- GPS ---
  Future<void> updateLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      state = state.copyWith(errorCode: RouletteError.locationServicesDisabled);
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        state =
            state.copyWith(errorCode: RouletteError.locationPermissionDenied);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      state = state.copyWith(
        errorCode: RouletteError.locationPermissionDeniedForever,
      );
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      state = state.copyWith(currentPosition: position);
    } catch (_) {
      state = state.copyWith(errorCode: RouletteError.noLocation);
    }
  }

  // --- Suche / Auswahl ---
  Future<void> loadRestaurants() async {
    state = state.copyWith(
      isLoading: true,
      clearSelectedRestaurant: true,
    );

    if (state.currentPosition == null) {
      await updateLocation();
    }
    if (state.currentPosition == null) {
      state = state.copyWith(
        isLoading: false,
        errorCode: RouletteError.noLocation,
      );
      return;
    }

    final filters = SearchFilters(
      radiusKm: state.radiusKm,
      placeTypes: state.placeTypes,
      cuisines: state.selectedCuisines,
      isVegan: state.isVegan,
      isVegetarian: state.isVegetarian,
      wheelchairAccessible: state.wheelchairAccessible,
    );

    try {
      var results = await _apiService.fetchRestaurants(
        lat: state.currentPosition!.latitude,
        lng: state.currentPosition!.longitude,
        filters: filters,
      );

      if (state.excludeVisited) {
        await _loadVisitedRestaurants();
        results =
            results.where((r) => !state.visitedIds.contains(r.id)).toList();
      }

      if (results.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          restaurants: [],
          errorCode: state.excludeVisited
              ? RouletteError.noRestaurantsFoundExcludingVisited
              : RouletteError.noRestaurantsFound,
        );
      } else {
        state = state.copyWith(isLoading: false, restaurants: results);
      }
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorCode: RouletteError.apiError,
      );
    }
  }

  Future<void> selectWinner() async {
    if (state.restaurants.isEmpty) return;
    state = state.copyWith(clearSelectedRestaurant: true);
    await Future.delayed(const Duration(milliseconds: 100));
    final randomIndex = Random().nextInt(state.restaurants.length);
    state = state.copyWith(selectedRestaurant: state.restaurants[randomIndex]);
  }

  void clearRestaurants() {
    state = state.copyWith(restaurants: [], clearSelectedRestaurant: true);
  }
}

final rouletteProvider =
    StateNotifierProvider<RouletteNotifier, RouletteState>((ref) {
  return RouletteNotifier(
    ref.watch(apiServiceProvider),
    ref.watch(visitedRepositoryProvider),
  );
});
