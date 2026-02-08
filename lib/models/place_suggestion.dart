class PlaceSuggestion {
  final String description;
  final double lat;
  final double lng;

  PlaceSuggestion({required this.description, required this.lat, required this.lng});

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    final props = json['properties'];
    return PlaceSuggestion(
      description: props['formatted'] ?? props['address_line1'] ?? 'Unbekannter Ort',
      lat: props['lat'],
      lng: props['lon'],
    );
  }
}
