import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/models/restaurant.dart';
import '../../../services/notification_service.dart';
import '../../visited/data/visited_repository.dart';
import '../data/api_service.dart';
import '../data/search_filters.dart';
import 'roulette_state.dart';

/// State-Notifier für den Roulette-Flow.
///
/// Hält *ausschließlich* State + asynchrone Daten-Operationen (DB, API, GPS).
/// Externe Side-Effects wie das Öffnen von Maps-Routen liegen bewusst beim
/// aufrufenden Widget (siehe [LinkLauncherService]) — der Notifier ist damit
/// frei von `BuildContext`, `launchUrl`, `Navigator` usw. und gut testbar.
class RouletteNotifier extends StateNotifier<RouletteState> {
  RouletteNotifier(
    this._apiService,
    this._visitedRepo,
    this._notificationService,
  ) : super(const RouletteState()) {
    _init();
  }

  final ApiService _apiService;
  final VisitedRepository _visitedRepo;
  final NotificationService _notificationService;

  Future<void> _init() async {
    await updateLocation();
    await _loadVisitedRestaurants();
  }

  Future<void> _loadVisitedRestaurants() async {
    final ids = await _visitedRepo.getVisitedRestaurantIds();
    state = state.copyWith(visitedIds: ids);
  }

  // --- Filter ---
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

  void toggleExcludeVisited(bool value) =>
      state = state.copyWith(excludeVisited: value);

  void setRadius(double km) {
    final clamped = km.clamp(0.5, 20.0);
    state = state.copyWith(radiusKm: clamped);
  }

  // --- Visit-Tracking ---
  Future<void> markAsVisited(Restaurant restaurant) async {
    await _visitedRepo.addVisitedRestaurant(restaurant);
    try {
      await _notificationService.scheduleRatingNotification(restaurant);
    } catch (e) {
      print('Notification scheduling failed: $e');
    }
    final ids = await _visitedRepo.getVisitedRestaurantIds();
    state = state.copyWith(visitedIds: ids);
  }

  // --- GPS ---
  Future<void> updateLocation() async {
    try {
      final position = await _determinePosition();
      state = state.copyWith(currentPosition: position);
    } catch (e) {
      state = state.copyWith(error: 'Standortfehler: $e');
    }
  }

  Future<Position> _determinePosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Standortdienste sind deaktiviert.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Standortberechtigung verweigert.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Standortberechtigung dauerhaft verweigert.');
    }

    return Geolocator.getCurrentPosition();
  }

  // --- Suche / Auswahl ---
  Future<void> loadRestaurants() async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      clearSelectedRestaurant: true,
    );

    try {
      if (state.currentPosition == null) {
        await updateLocation();
      }
      if (state.currentPosition == null) {
        throw Exception('Kein Standort ausgewählt.');
      }

      final filters = SearchFilters(
        radiusKm: state.radiusKm,
        cuisines: state.selectedCuisines,
        isVegan: state.isVegan,
        isVegetarian: state.isVegetarian,
      );

      var results = await _apiService.fetchRestaurants(
        lat: state.currentPosition!.latitude,
        lng: state.currentPosition!.longitude,
        filters: filters,
      );

      if (state.excludeVisited) {
        await _loadVisitedRestaurants();
        results = results
            .where((r) => !state.visitedIds.contains(r.id))
            .toList();
      }

      if (results.isEmpty) {
        var msg = 'Keine Restaurants gefunden.';
        if (state.excludeVisited) msg += ' (Besuchte ausgeblendet)';
        state = state.copyWith(
          isLoading: false,
          restaurants: [],
          error: msg,
        );
      } else {
        state = state.copyWith(isLoading: false, restaurants: results);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Fehler: $e');
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
    NotificationService(),
  );
});
