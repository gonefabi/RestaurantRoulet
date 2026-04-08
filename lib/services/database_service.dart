import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/restaurant.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

  Future<void> addVisitedRestaurant(Restaurant restaurant) async {
    if (_userId == null) return;

    // Fetch current visit_count to increment it
    int currentCount = 0;
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
      'city': restaurant.city,
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

    final List<Restaurant> restaurants = [];
    for (var row in response) {
      final map = {
        'id': row['id'],
        'name': row['name'],
        'address': row['address'],
        'street': row['street'],
        'city': row['city'],
        'visited_at': row['visited_at'],
        'rating': row['rating'],
        'popup_dismissed': row['popup_dismissed'],
        'visit_count': row['visit_count'],
      };
      restaurants.add(Restaurant.fromMap(map));
    }
    return restaurants;
  }

  Future<Set<String>> getVisitedRestaurantIds() async {
    if (_userId == null) return {};

    final response = await _supabase
        .from('visited_restaurants')
        .select('id');

    return response.map((e) => e['id'] as String).toSet();
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

    await _supabase
        .from('visited_restaurants')
        .delete()
        .eq('id', id);
  }
}
