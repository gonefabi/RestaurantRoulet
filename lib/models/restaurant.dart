class Restaurant {
  final String id;
  final String name;
  final String? address;
  // Rating entfernen wir vorerst, da Geoapify Free Tier das oft nicht liefert
  // oder wir machen es nullable, falls wir es später wieder nutzen.
  final double rating;
  final String? street;
  final String? city;

  Restaurant({
    required this.id,
    required this.name,
    this.address,
    this.rating = 0.0,
    this.street,
    this.city,
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

  @override
  String toString() {
    return 'Restaurant(name: $name, address: $address)';
  }
}
