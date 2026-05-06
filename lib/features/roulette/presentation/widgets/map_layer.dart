import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class RouletteMapLayer extends StatelessWidget {
  const RouletteMapLayer({
    super.key,
    required this.mapController,
    required this.currentPosition,
    required this.radiusKm,
    required this.initialCenter,
    required this.initialZoom,
    required this.onMapReady,
    required this.onTap,
  });

  final MapController mapController;
  final Position? currentPosition;
  final double radiusKm;
  final LatLng initialCenter;
  final double initialZoom;
  final VoidCallback onMapReady;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final point = currentPosition == null
        ? null
        : LatLng(currentPosition!.latitude, currentPosition!.longitude);

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: initialZoom,
        minZoom: 5,
        maxZoom: 18,
        onMapReady: onMapReady,
        onTap: (_, __) => onTap(),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.restaurant_roulette',
        ),
        if (point != null)
          CircleLayer(
            circles: [
              CircleMarker(
                point: point,
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                borderStrokeWidth: 2,
                borderColor: theme.colorScheme.primary,
                useRadiusInMeter: true,
                radius: radiusKm * 1000,
              ),
            ],
          ),
        if (point != null)
          MarkerLayer(
            markers: [
              Marker(
                point: point,
                width: 50,
                height: 50,
                child: Icon(
                  Icons.my_location,
                  color: theme.colorScheme.primary,
                  size: 40,
                  shadows: const [Shadow(color: Colors.black26, blurRadius: 4)],
                ),
              ),
            ],
          ),
      ],
    );
  }
}
