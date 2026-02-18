import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/restaurant.dart';
import '../services/database_service.dart';
import '../widgets/rating_popup.dart';

class VisitedRestaurantsScreen extends StatefulWidget {
  const VisitedRestaurantsScreen({Key? key}) : super(key: key);

  @override
  State<VisitedRestaurantsScreen> createState() => _VisitedRestaurantsScreenState();
}

class _VisitedRestaurantsScreenState extends State<VisitedRestaurantsScreen> {
  late Future<List<Restaurant>> _visitedRestaurantsFuture;
  final DatabaseService _dbService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  void _refreshList() {
    setState(() {
      _visitedRestaurantsFuture = _dbService.getVisitedRestaurants();
    });
  }

  void _showRatingDialog(Restaurant restaurant) {
    showDialog(
      context: context,
      builder: (context) => RatingPopup(
        restaurant: restaurant,
        onDismiss: () => Navigator.of(context).pop(),
        onRatingSaved: (rating) async {
          await _dbService.updateRating(restaurant.id, rating);
          Navigator.of(context).pop();
          _refreshList();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Besuchte Restaurants'),
      ),
      body: FutureBuilder<List<Restaurant>>(
        future: _visitedRestaurantsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Fehler: ${snapshot.error}'));
          }

          final restaurants = snapshot.data ?? [];

          if (restaurants.isEmpty) {
            return const Center(child: Text('Noch keine Restaurants besucht.'));
          }

          return ListView.builder(
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              final restaurant = restaurants[index];
              final visitDate = restaurant.visitedAt != null
                  ? DateFormat('dd.MM.yyyy HH:mm').format(restaurant.visitedAt!)
                  : 'Unbekanntes Datum';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(restaurant.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (restaurant.address != null) Text(restaurant.address!),
                      Text('Besucht am: $visitDate', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (restaurant.userRating != null && restaurant.userRating! > 0)
                        Row(
                          children: List.generate(restaurant.userRating!, (index) => const Icon(Icons.star, size: 16, color: Colors.amber)),
                        )
                      else
                        const Text('Bewerten', style: TextStyle(color: Colors.blue)),
                      const SizedBox(width: 8),
                      // Edit Button
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => _showRatingDialog(restaurant),
                      ),
                    ],
                  ),
                  onTap: () => _showRatingDialog(restaurant),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
