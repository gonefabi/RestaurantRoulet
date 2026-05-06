import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/restaurant.dart';

/// Persistenz für besuchte Restaurants in Supabase (`visited_restaurants`-Tabelle).
class VisitedRepository {
  VisitedRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  String? get _userId => _supabase.auth.currentUser?.id;

  Future<void> addVisitedRestaurant(Restaurant restaurant) async {
    if (_userId == null) return;

    var currentCount = 0;
    try {
      final existing = await _supabase
          .from('visited_restaurants')
          .select('visit_count')
          .eq('user_id', _userId!)
          .eq('id', restaurant.id)
          .maybeSingle();
      currentCount = (existing?['visit_count'] as int?) ?? 0;
    } catch (_) {}

    await _supabase.from('visited_restaurants').upsert({
      'id': restaurant.id,
      'user_id': _userId,
      'name': restaurant.name,
      'address': restaurant.address,
      'street': restaurant.street,
      'visited_at': DateTime.now().toIso8601String(),
      'rating': restaurant.userRating,
      'popup_dismissed': restaurant.popupDismissed ? 1 : 0,
      'visit_count': currentCount + 1,
    });
  }

  Future<List<Restaurant>> getVisitedRestaurants() async {
    if (_userId == null) return [];

    final response = await _supabase
        .from('visited_restaurants')
        .select()
        .order('visited_at', ascending: false);

    return [
      for (final row in response)
        Restaurant.fromMap({
          'id': row['id'],
          'name': row['name'],
          'address': row['address'],
          'street': row['street'],
          'visited_at': row['visited_at'],
          'rating': row['rating'],
          'popup_dismissed': row['popup_dismissed'],
          'visit_count': row['visit_count'],
        }),
    ];
  }

  Future<Set<String>> getVisitedRestaurantIds() async {
    if (_userId == null) return {};

    final response =
        await _supabase.from('visited_restaurants').select('id');
    return {for (final e in response) e['id'] as String};
  }

  Future<void> updateRating(String id, int rating) async {
    if (_userId == null) return;
    await _supabase
        .from('visited_restaurants')
        .update({'rating': rating})
        .eq('id', id);
  }

  Future<void> markPopupDismissed(String id) async {
    if (_userId == null) return;
    await _supabase
        .from('visited_restaurants')
        .update({'popup_dismissed': 1})
        .eq('id', id);
  }

  Future<void> removeVisitedRestaurant(String id) async {
    if (_userId == null) return;
    await _supabase.from('visited_restaurants').delete().eq('id', id);
  }
}

final visitedRepositoryProvider = Provider<VisitedRepository>(
  (ref) => VisitedRepository(),
);
