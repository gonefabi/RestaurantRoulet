import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/models/restaurant.dart';
import '../../../../core/services/link_launcher_service.dart';
import '../../../../core/widgets/app_error_banner.dart';
import '../../../../core/widgets/loading_animation.dart';
import '../../../rating/application/rating_prompt_coordinator.dart';
import '../../application/roulette_notifier.dart';
import '../../application/roulette_state.dart';
import '../widgets/filter_menu.dart';
import '../widgets/map_layer.dart';
import '../widgets/profile_menu.dart';
import '../widgets/roulette_overlay.dart';
import '../widgets/search_button_panel.dart';

/// Hauptbildschirm: Karte + Filter-/Profil-Menüs + Suchbutton + Roulette-Overlay.
///
/// Hält ausschließlich UI-State (Map-Controller, Spin-Animation, Menü-Toggles)
/// sowie die Rating-Popup-Orchestrierung. Daten- und Filter-Logik leben in
/// [rouletteProvider]; Side-Effects (Maps öffnen) im [LinkLauncherService].
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final MapController _mapController = MapController();

  bool _showProfile = false;
  bool _isMapReady = false;
  bool _isSpinning = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_checkForRatingPopup);
  }

  double _zoomFor(double radiusKm) {
    final zoom = 14.0 - (log(radiusKm) / log(2));
    return zoom.clamp(5.0, 18.0);
  }

  Future<void> _checkForRatingPopup() async {
    final coordinator = ref.read(ratingPromptCoordinatorProvider);
    final candidate = await coordinator.findCandidate();
    if (candidate != null && mounted) {
      await coordinator.show(context, candidate);
    }
  }

  Future<void> _startRouteAndMarkVisited(Restaurant restaurant) async {
    try {
      await ref.read(rouletteProvider.notifier).markAsVisited(restaurant);
    } catch (e) {
      print('markAsVisited fehlgeschlagen: $e');
    }
    await ref.read(linkLauncherServiceProvider).openMapsRoute(
          name: restaurant.name,
          address: restaurant.address,
        );
  }

  void _onStateChanged(RouletteState? previous, RouletteState next) {
    if (_isMapReady && next.currentPosition != null) {
      final positionChanged = previous?.currentPosition != next.currentPosition;
      final radiusChanged =
          previous != null && previous.radiusKm != next.radiusKm;
      if (positionChanged || radiusChanged) {
        _mapController.move(
          LatLng(
            next.currentPosition!.latitude,
            next.currentPosition!.longitude,
          ),
          _zoomFor(next.radiusKm),
        );
      }
    }

    if (next.selectedRestaurant != null &&
        previous?.selectedRestaurant != next.selectedRestaurant) {
      setState(() => _isSpinning = true);
      Future.delayed(const Duration(seconds: 8), () {
        if (mounted) setState(() => _isSpinning = false);
      });
    }

    if (next.restaurants.isEmpty && _isSpinning) {
      setState(() => _isSpinning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rouletteProvider);
    final notifier = ref.read(rouletteProvider.notifier);

    ref.listen<RouletteState>(rouletteProvider, _onStateChanged);

    final initialCenter = state.currentPosition != null
        ? LatLng(
            state.currentPosition!.latitude,
            state.currentPosition!.longitude,
          )
        : const LatLng(52.5200, 13.4050);

    return Scaffold(
      body: Stack(
        children: [
          RouletteMapLayer(
            mapController: _mapController,
            currentPosition: state.currentPosition,
            radiusKm: state.radiusKm,
            initialCenter: initialCenter,
            initialZoom: _zoomFor(state.radiusKm),
            onMapReady: () => setState(() => _isMapReady = true),
            onTap: () {
              if (_showProfile) {
                setState(() => _showProfile = false);
              }
            },
          ),
          if (state.restaurants.isEmpty && !state.isLoading)
            SearchButtonPanel(onPressed: notifier.loadRestaurants),
          ProfileMenu(
            isOpen: _showProfile,
            onToggle: () => setState(() => _showProfile = !_showProfile),
            onClose: () => setState(() => _showProfile = false),
          ),
          FilterMenu(
            onOpen: () => setState(() => _showProfile = false),
          ),
          if (state.isLoading)
            Positioned.fill(
              child: LoadingAnimation(isLoading: state.isLoading),
            ),
          if (state.restaurants.isNotEmpty)
            Positioned.fill(
              child: RouletteOverlay(
                isSpinning: _isSpinning,
                onStartRoute: _startRouteAndMarkVisited,
              ),
            ),
          if (state.error != null &&
              !state.isLoading &&
              state.restaurants.isEmpty)
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: AppErrorBanner(
                message: state.error!,
                onClose: notifier.clearRestaurants,
              ),
            ),
        ],
      ),
    );
  }
}
