class Restaurant {
  final String id;
  final String name;
  final String? address;
  // Rating entfernen wir vorerst, da Geoapify Free Tier das oft nicht liefert
  // oder wir machen es nullable, falls wir es später wieder nutzen.
  final DateTime? visitedAt;
  final int? userRating;
  final bool popupDismissed;

  final String? street;
  final String? city;
  final double rating;

  Restaurant({
    required this.id,
    required this.name,
    this.address,
    this.rating = 0.0,
    this.street,
    this.city,
    this.visitedAt,
    this.userRating,
    this.popupDismissed = false,
  });

  // Factory für Geoapify API
  factory Restaurant.fromGeoapify(Map<String, dynamic> feature) {
    final properties = feature['properties'];
    return Restaurant(
      id: properties['place_id'],
      name: properties['name'] ?? 'Unbekanntes Restaurant',
      address: properties['address_line2'] ?? properties['address_line1'] ?? 'Keine Adresse verfügbar',
      // Geoapify liefert im Free Tier selten Ratings, wir setzen es auf 0
      rating: 0.0,
      street: properties['street'],
      city: properties['city'],
    );
  }

  factory Restaurant.fromMap(Map<String, dynamic> map) {
    return Restaurant(
      id: map['id'],
      name: map['name'],
      address: map['address'],
      visitedAt: map['visited_at'] != null ? DateTime.parse(map['visited_at']) : null,
      userRating: map['rating'],
      popupDismissed: map['popup_dismissed'] == 1,
      street: map['street'],
      city: map['city'],
      rating: map['api_rating'] ?? 0.0, // distinction for db
    );
  }

  Restaurant copyWith({
    String? id,
    String? name,
    String? address,
    double? rating,
    String? street,
    String? city,
    DateTime? visitedAt,
    int? userRating,
    bool? popupDismissed,
  }) {
    return Restaurant(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      rating: rating ?? this.rating,
      street: street ?? this.street,
      city: city ?? this.city,
      visitedAt: visitedAt ?? this.visitedAt,
      userRating: userRating ?? this.userRating,
      popupDismissed: popupDismissed ?? this.popupDismissed,
    );
  }

  @override
  String toString() {
    return 'Restaurant(name: $name, address: $address, visited: $visitedAt, rating: $userRating)';
  }
}
