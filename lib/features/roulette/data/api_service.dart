import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/env.dart';
import '../../../core/models/restaurant.dart';
import 'search_filters.dart';

/// Geoapify-basierte Restaurant-Suche.
class ApiService {
  ApiService(this._dio);

  final Dio _dio;
  final String _geoapifyApiKey = Env.geoapifyKey;

  Future<List<Restaurant>> fetchRestaurants({
    required double lat,
    required double lng,
    SearchFilters filters = const SearchFilters(),
  }) async {
    const url = 'https://api.geoapify.com/v2/places';
    final radiusMeters = (filters.radiusKm * 1000).toInt();

    final categories = <String>{};
    final types = filters.placeTypes.isEmpty
        ? const ['restaurant']
        : filters.placeTypes;
    for (final type in types) {
      if (type == 'restaurant' && filters.cuisines.isNotEmpty) {
        for (final c in filters.cuisines) {
          categories.add('catering.restaurant.$c');
        }
      } else {
        categories.add('catering.$type');
      }
    }

    final queryParams = <String, dynamic>{
      'categories': categories.join(','),
      'filter': 'circle:$lng,$lat,$radiusMeters',
      'bias': 'proximity:$lng,$lat',
      'limit': 50,
      'apiKey': _geoapifyApiKey,
    };

    final conditions = <String>[];
    if (filters.isVegan) conditions.add('vegan');
    if (filters.isVegetarian) conditions.add('vegetarian');
    if (filters.wheelchairAccessible) conditions.add('wheelchair');
    if (conditions.isNotEmpty) {
      queryParams['conditions'] = conditions.join(',');
    }

    try {
      final response = await _dio.get(url, queryParameters: queryParams);
      if (response.statusCode == 200 && response.data['features'] != null) {
        final features = response.data['features'] as List;
        return features
            .map((feature) => Restaurant.fromGeoapify(feature))
            .toList();
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

final apiServiceProvider = Provider<ApiService>((ref) => ApiService(Dio()));
