import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/api_keys.dart';
import '../models/restaurant.dart';

// Filter State
class SearchFilters {
  final double radiusKm;
  final double minRating;
  final String? priceLevel;

  const SearchFilters({
    this.radiusKm = 2.0,
    this.minRating = 0.0,
    this.priceLevel,
  });

  // Wenn User 4+ Sterne will oder Preise filtert -> Google (weil Geoapify das nicht gut kann im Free Tier)
  bool get requiresGoogleApi => minRating > 0.0 || priceLevel != null;
}

final apiServiceProvider = Provider((ref) => ApiService());

class ApiService {
  final Dio _dio = Dio();

  Future<List<Restaurant>> fetchRestaurants({
    required double lat,
    required double lng,
    required SearchFilters filters,
  }) async {
    try {
      if (filters.requiresGoogleApi) {
        return await _fetchFromGoogle(lat, lng, filters);
      } else {
        return await _fetchFromGeoapify(lat, lng, filters);
      }
    } catch (e) {
      print("API Error: $e");
      // Fallback: Wenn Geoapify failt, versuche Google (oder andersrum)
      return [];
    }
  }

  Future<List<Restaurant>> _fetchFromGeoapify(double lat, double lng, SearchFilters filters) async {
    final radiusMeters = (filters.radiusKm * 1000).toInt();
    // Geoapify Categories: catering.restaurant
    final url = 'https://api.geoapify.com/v2/places';
    
    final response = await _dio.get(url, queryParameters: {
      'categories': 'catering.restaurant',
      'filter': 'circle:$lng,$lat,$radiusMeters',
      'limit': 20,
      'apiKey': ApiKeys.geoapifyKey,
    });

    if (response.statusCode == 200) {
      final features = response.data['features'] as List;
      return features.map((json) => Restaurant.fromGeoapify(json)).toList();
    }
    return [];
  }

  Future<List<Restaurant>> _fetchFromGoogle(double lat, double lng, SearchFilters filters) async {
    final radiusMeters = (filters.radiusKm * 1000).toInt();
    final url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json';

    final params = {
      'location': '$lat,$lng',
      'radius': radiusMeters,
      'type': 'restaurant',
      'key': ApiKeys.googleMapsKey,
    };

    if (filters.minRating > 0) {
      // Google NearbySearch filtert nicht direkt nach Rating serverseitig, 
      // wir müssen client-seitig filtern oder TextSearch nutzen.
      // Hier filtern wir client-seitig nach dem Fetch.
    }

    final response = await _dio.get(url, queryParameters: params);

    if (response.statusCode == 200) {
      final results = response.data['results'] as List;
      var restaurants = results.map((json) => Restaurant.fromGoogle(json)).toList();

      // Client-Side Filter für Rating
      if (filters.minRating > 0) {
        restaurants = restaurants.where((r) => r.rating >= filters.minRating).toList();
      }
      return restaurants;
    }
    return [];
  }
}
