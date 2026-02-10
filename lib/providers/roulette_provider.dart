import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart'; 
import '../models/restaurant.dart';
import '../models/place_suggestion.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';

// State Class
class RouletteState {
  final bool isLoading;
  final List<Restaurant> restaurants;
  final Restaurant? selectedRestaurant;
  final String? error;
  final Position? currentPosition;
  final double radiusKm;
  final bool isUsingCustomLocation;
  final List<PlaceSuggestion> addressSuggestions;
 
  final List<String> selectedCuisines;
  final bool isVegan; // Wieder hinzugefügt
  final bool isVegetarian;
  final bool excludeVisited;
  final Set<String> visitedIds;

  RouletteState({
    this.isLoading = false,
    this.restaurants = const [],
    this.selectedRestaurant,
    this.error,
    this.currentPosition,
    this.radiusKm = 2.0, 
    this.isUsingCustomLocation = false,
    this.addressSuggestions = const [],
    this.selectedCuisines = const [],
    this.isVegan = false, // Wieder hinzugefügt
    this.isVegetarian = false,
    this.excludeVisited = true,
    this.visitedIds = const {},
  });

  RouletteState copyWith({
    bool? isLoading,
    List<Restaurant>? restaurants,
    Restaurant? selectedRestaurant,
    String? error,
    Position? currentPosition,
    double? radiusKm,
    bool clearSelectedRestaurant = false,
    bool? isUsingCustomLocation,
    List<PlaceSuggestion>? addressSuggestions,
    List<String>? selectedCuisines,
    bool? isVegan, // Wieder hinzugefügt
    bool? isVegetarian,
    bool? excludeVisited,
    Set<String>? visitedIds,
  }) {
    return RouletteState(
      isLoading: isLoading ?? this.isLoading,
      restaurants: restaurants ?? this.restaurants,
      selectedRestaurant: clearSelectedRestaurant ? null : selectedRestaurant ?? this.selectedRestaurant,
      error: error,
      currentPosition: currentPosition ?? this.currentPosition,
      radiusKm: radiusKm ?? this.radiusKm,
      isUsingCustomLocation: isUsingCustomLocation ?? this.isUsingCustomLocation,
      addressSuggestions: addressSuggestions ?? this.addressSuggestions,
      selectedCuisines: selectedCuisines ?? this.selectedCuisines,
      isVegan: isVegan ?? this.isVegan, // Wieder hinzugefügt
      isVegetarian: isVegetarian ?? this.isVegetarian,
      excludeVisited: excludeVisited ?? this.excludeVisited,
      visitedIds: visitedIds ?? this.visitedIds,
    );
  }
}

// Notifier
class RouletteNotifier extends StateNotifier<RouletteState> {
  final ApiService _apiService;
  final DatabaseService _dbService;

  RouletteNotifier(this._apiService, this._dbService) : super(RouletteState()) {
    _init();
  }

  Future<void> _init() async {
    await updateLocation();
    await _loadVisitedRestaurants();
  }

  Future<void> _loadVisitedRestaurants() async {
    final ids = await _dbService.getVisitedRestaurantIds();
    state = state.copyWith(visitedIds: ids);
  }

  // --- Filter ---
  void toggleCuisine(String cuisine) {
    var currentCuisines = List<String>.from(state.selectedCuisines);
    if (currentCuisines.contains(cuisine)) {
      currentCuisines.remove(cuisine);
    } else {
      currentCuisines.add(cuisine);
    }
    state = state.copyWith(selectedCuisines: currentCuisines);
  }

  void toggleVegan(bool value) {
    state = state.copyWith(isVegan: value);
  }

  void toggleVegetarian(bool value) {
    state = state.copyWith(isVegetarian: value);
  }

  void toggleExcludeVisited(bool value) {
    state = state.copyWith(excludeVisited: value);
  }

  Future<void> markAsVisited(Restaurant restaurant) async {
    await _dbService.addVisitedRestaurant(restaurant);
    final ids = await _dbService.getVisitedRestaurantIds();
    state = state.copyWith(visitedIds: ids);
  }

  // --- Navigation & Externe Links ---
  Future<void> launchGoogleMaps() async {
    final restaurant = state.selectedRestaurant;
    if (restaurant == null) return;

    // Automatisch als besucht markieren
    await markAsVisited(restaurant);
    
    final query = Uri.encodeComponent("${restaurant.name}, ${restaurant.address ?? ''}");
    final googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$query");

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      print("Konnte Karten-App nicht öffnen: $googleMapsUrl");
    }
  }
  
  Future<void> searchOnLieferando() async {
    final restaurant = state.selectedRestaurant;
    if (restaurant == null) return;
    
    // Suche auf Google nach "Lieferando [Name] [Stadt]"
    final searchTerm = "Lieferando ${restaurant.name} ${restaurant.city ?? ''} ${restaurant.street ?? ''}";
    final query = Uri.encodeComponent(searchTerm);
    final url = Uri.parse("https://www.google.com/search?q=$query");
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> searchOnUberEats() async {
    final restaurant = state.selectedRestaurant;
    if (restaurant == null) return;
    
    // Suche auf Google nach "Uber Eats [Name] [Stadt]"
    final searchTerm = "Uber Eats ${restaurant.name} ${restaurant.city ?? ''} ${restaurant.street ?? ''}";
    final query = Uri.encodeComponent(searchTerm);
    final url = Uri.parse("https://www.google.com/search?q=$query");
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  // --- Adress-Suche ---
  Future<void> searchAddress(String query) async {
    if (query.length < 3) {
      state = state.copyWith(addressSuggestions: []);
      return;
    }

    try {
      final suggestions = await _apiService.searchPlaces(query);
      state = state.copyWith(addressSuggestions: suggestions);
    } catch (e) {
      print("Autocomplete Fehler: $e");
    }
  }

  void selectAddress(PlaceSuggestion place) {
    final newPosition = Position(
      longitude: place.lng,
      latitude: place.lat,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );

    state = state.copyWith(
      currentPosition: newPosition,
      isUsingCustomLocation: true,
      addressSuggestions: [],
      restaurants: [],
      clearSelectedRestaurant: true,
    );
  }

  Future<void> useCurrentLocation() async {
    state = state.copyWith(isLoading: true);
    try {
      final position = await _determinePosition();
      state = state.copyWith(
        currentPosition: position,
        isUsingCustomLocation: false,
        isLoading: false,
        restaurants: [],
        clearSelectedRestaurant: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: "Standortfehler: $e");
    }
  }

  // --- GPS ---
  Future<void> updateLocation() async {
    try {
      final position = await _determinePosition();
      state = state.copyWith(
        currentPosition: position,
        isUsingCustomLocation: false,
      );
    } catch (e) {
      state = state.copyWith(error: "Standortfehler: $e");
    }
  }

  void setRadius(double km) {
    if (km < 0.5) km = 0.5;
    if (km > 20) km = 20; 
    state = state.copyWith(radiusKm: km);
  }

  Future<void> loadRestaurants() async {
    state = state.copyWith(isLoading: true, error: null, clearSelectedRestaurant: true);

    try {
      if (state.currentPosition == null) {
        await updateLocation();
      }
      
      if (state.currentPosition == null) {
        throw Exception("Kein Standort ausgewählt.");
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

      // Filter visited restaurants if enabled
      if (state.excludeVisited) {
        // Refresh visited IDs just in case
        await _loadVisitedRestaurants();
        results = results.where((r) => !state.visitedIds.contains(r.id)).toList();
      }

      if (results.isEmpty) {
         String errorMsg = 'Keine Restaurants gefunden.';
         if (state.excludeVisited) errorMsg += ' (Besuchte ausgeblendet)';
         state = state.copyWith(
          isLoading: false, 
          restaurants: [], 
          error: errorMsg,
        );
      } else {
        state = state.copyWith(isLoading: false, restaurants: results);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: "Fehler: ${e.toString()}");
    }
  }

  void selectWinner() async {
    if (state.restaurants.isNotEmpty) {
      state = state.copyWith(clearSelectedRestaurant: true);
      await Future.delayed(const Duration(milliseconds: 100));
      final randomIndex = Random().nextInt(state.restaurants.length);
      state = state.copyWith(selectedRestaurant: state.restaurants[randomIndex]);
    }
  }
  
  void clearRestaurants() {
    state = state.copyWith(restaurants: [], clearSelectedRestaurant: true);
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Standortdienste sind deaktiviert.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Standortberechtigung verweigert.');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Standortberechtigung dauerhaft verweigert.');
    }

    return await Geolocator.getCurrentPosition();
  }
}

final rouletteProvider = StateNotifierProvider<RouletteNotifier, RouletteState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  // Wir erstellen hier eine Instanz von DatabaseService
  final dbService = DatabaseService();
  return RouletteNotifier(apiService, dbService);
});
