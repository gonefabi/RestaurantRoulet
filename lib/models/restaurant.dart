class Restaurant {
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final double rating;
  final int userRatingsTotal;
  final String? photoUrl;
  final String source; // 'google' or 'geoapify'

  Restaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    this.rating = 0.0,
    this.userRatingsTotal = 0,
    this.photoUrl,
    required this.source,
  });

  // Factory für Google Places API
  factory Restaurant.fromGoogle(Map<String, dynamic> json) {
    final location = json['geometry']['location'];
    String? photoRef;
    if (json['photos'] != null && (json['photos'] as List).isNotEmpty) {
      photoRef = json['photos'][0]['photo_reference'];
    }

    return Restaurant(
      id: json['place_id'],
      name: json['name'],
      address: json['vicinity'] ?? 'Keine Adresse',
      lat: location['lat'],
      lng: location['lng'],
      rating: (json['rating'] ?? 0.0).toDouble(),
      userRatingsTotal: json['user_ratings_total'] ?? 0,
      photoUrl: photoRef, // URL muss später mit API Key gebaut werden
      source: 'google',
    );
  }

  // Factory für Geoapify API
  factory Restaurant.fromGeoapify(Map<String, dynamic> json) {
    final props = json['properties'];
    final geometry = json['geometry']['coordinates']; // [lng, lat]

    return Restaurant(
      id: props['place_id'] ?? DateTime.now().toString(),
      name: props['name'] ?? 'Unbekanntes Restaurant',
      address: props['address_line2'] ?? props['formatted'] ?? '',
      lat: geometry[1],
      lng: geometry[0],
      rating: 0.0, // Geoapify Free hat oft keine Ratings
      source: 'geoapify',
    );
  }
}
