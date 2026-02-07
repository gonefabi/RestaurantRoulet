import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../models/restaurant.dart';
import '../services/api_service.dart';

// State State Class
class RouletteState {
  final bool isLoading;
  final List<Restaurant> restaurants;
  final Restaurant? selectedRestaurant;
  final String? error;

  RouletteState({
    this.isLoading = false,
    this.restaurants = const [],
    this.selectedRestaurant,
    this.error,
  });

  RouletteState copyWith({
    bool? isLoading,
    List<Restaurant>? restaurants,
    Restaurant? selectedRestaurant,
    String? error,
  }) {
    return RouletteState(
      isLoading: isLoading ?? this.isLoading,
      restaurants: restaurants ?? this.restaurants,
      selectedRestaurant: selectedRestaurant ?? this.selectedRestaurant,
      error: error,
    );
  }
}

// Notifier
class RouletteNotifier extends StateNotifier<RouletteState> {
  final ApiService _apiService;

  RouletteNotifier(this._apiService) : super(RouletteState());

  Future<void> loadRestaurants({SearchFilters filters = const SearchFilters()}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // 1. Get Location
      Position position = await _determinePosition();

      // 2. Fetch Data
      final results = await _apiService.fetchRestaurants(
        lat: position.latitude,
        lng: position.longitude,
        filters: filters,
      );

      if (results.isEmpty) {
        state = state.copyWith(isLoading: false, error: 'Keine Restaurants gefunden.');
      } else {
        state = state.copyWith(isLoading: false, restaurants: results);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectWinner(int index) {
    if (state.restaurants.isNotEmpty && index < state.restaurants.length) {
      state = state.copyWith(selectedRestaurant: state.restaurants[index]);
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Standortdienste sind deaktiviert.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Standortberechtigung verweigert.');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Standortberechtigung dauerhaft verweigert.');
    }

    return await Geolocator.getCurrentPosition();
  }
}

// Provider Definition
final rouletteProvider = StateNotifierProvider<RouletteNotifier, RouletteState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return RouletteNotifier(apiService);
});
