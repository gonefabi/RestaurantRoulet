import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/api_keys.dart';
import '../models/restaurant.dart';
import '../models/place_suggestion.dart';

// Einfache Filter für die Geoapify-Suche
class SearchFilters {
  final double radiusKm;
  final List<String> cuisines;
  final bool isVegan;
  final bool isVegetarian;

  const SearchFilters({
    this.radiusKm = 2.0,
    this.cuisines = const [],
    this.isVegan = false,
    this.isVegetarian = false,
  });
}

class ApiService {
  final Dio _dio;
  final String _geoapifyApiKey = ApiKeys.geoapifyKey;

  ApiService(this._dio);

  // --- Adress-Suche (Autocomplete) ---
  Future<List<PlaceSuggestion>> searchPlaces(String query) async {
    if (query.length < 3) return []; 

    const url = 'https://api.geoapify.com/v1/geocode/autocomplete';
    
    try {
      final response = await _dio.get(url, queryParameters: {
        'text': query,
        'apiKey': _geoapifyApiKey,
        'limit': 5, 
        'lang': 'de', 
      });

      if (response.statusCode == 200 && response.data['features'] != null) {
        final features = response.data['features'] as List;
        return features.map((f) => PlaceSuggestion.fromJson(f)).toList();
      }
      return [];
    } catch (e) {
      print('Autocomplete Fehler: $e');
      return [];
    }
  }

  // --- Restaurant-Suche (Nur Geoapify) ---
  Future<List<Restaurant>> fetchRestaurants({
    required double lat,
    required double lng,
    SearchFilters filters = const SearchFilters(),
  }) async {
    const url = 'https://api.geoapify.com/v2/places';
    final radiusMeters = (filters.radiusKm * 1000).toInt();
    
    // Basis-Kategorie
    List<String> categories = ['catering.restaurant'];
    
    // Cuisines hinzufügen
    if (filters.cuisines.isNotEmpty) {
      categories = filters.cuisines.map((c) => 'catering.restaurant.$c').toList();
    }

    final queryParams = {
      'categories': categories.join(','),
      'filter': 'circle:$lng,$lat,$radiusMeters',
      'bias': 'proximity:$lng,$lat',
      'limit': 50, 
      'apiKey': _geoapifyApiKey,
    };

    List<String> conditions = [];
    if (filters.isVegan) {
      conditions.add('vegan');
    }
    if (filters.isVegetarian) {
      conditions.add('vegetarian');
    }

    if (conditions.isNotEmpty) {
      queryParams['conditions'] = conditions.join(',');
    }

    try {
      final response = await _dio.get(url, queryParameters: queryParams);

      if (response.statusCode == 200 && response.data['features'] != null) {
        final features = response.data['features'] as List;
        return features.map((feature) => Restaurant.fromGeoapify(feature)).toList();
      }
      return [];
    } on DioException catch (e) {
      print('Geoapify API Fehler: $e');
      throw Exception('Fehler bei der Abfrage von Geoapify: ${e.message}');
    } catch (e) {
      print('Allgemeiner API Fehler: $e');
      throw Exception('Unbekannter Fehler bei der Abfrage.');
    }
  }
}

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(Dio());
});
