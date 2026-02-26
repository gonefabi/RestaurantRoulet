import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math';
import '../providers/roulette_provider.dart';
import '../widgets/roulette_wheel.dart';
import '../widgets/loading_animation.dart';
import 'visited_restaurants_screen.dart';
import 'notification_settings_screen.dart';
import '../widgets/rating_popup.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../models/restaurant.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final NotificationService _notificationService = NotificationService();
  final DatabaseService _dbService = DatabaseService();
  bool _showSettings = false;
  bool _isMapReady = false; 
  bool _isSpinning = false; 

  bool _showProfile = false;

  double _calculateZoomLevel(double radiusKm) {
    double zoom = 14.0 - (log(radiusKm) / log(2));
    return zoom.clamp(5.0, 18.0); 
  }

  @override
  void initState() {
    super.initState();
    _checkForRatingPopup();
  }

  Future<void> _checkForRatingPopup() async {
    // 1. Check if app launched continuously from notification
    final launchDetails = await _notificationService.flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      final payload = launchDetails?.notificationResponse?.payload;
      if (payload != null) {
        _showPopupForId(payload);
        return;
      }
    }

    // 2. Check for time-based popup
    final visited = await _dbService.getVisitedRestaurants();
    final now = DateTime.now();

    for (var r in visited) {
      if (r.visitedAt == null) continue;
      
      // Filter: Unrated and not dismissed
      // UserRating is null or 0 means unrated
      bool isUnrated = (r.userRating == null || r.userRating == 0);
      if (!isUnrated || r.popupDismissed) continue;

      final diff = now.difference(r.visitedAt!);
      // "nach 15 min ... aber nicht mehr nach 42 Stunden"
      // Assuming 42 hours = 2 days minus a bit, user said 42h explicitly.
      if (diff.inMinutes > 15 && diff.inHours < 42) {
        if (mounted) {
           _showRatingDialog(r);
           return; // Show only one at a time
        }
      }
    }
  }

  Future<void> _showPopupForId(String id) async {
    final visited = await _dbService.getVisitedRestaurants();
    try {
      final restaurant = visited.firstWhere((r) => r.id == id);
      if (mounted) _showRatingDialog(restaurant);
    } catch (e) {
      print("Restaurant for popup not found: $id");
    }
  }

  void _showRatingDialog(Restaurant restaurant) {
    showDialog(
      context: context,
      barrierDismissible: false, // Force user to use X or Save
      builder: (context) => RatingPopup(
        restaurant: restaurant,
        onDismiss: () async {
          await _dbService.markPopupDismissed(restaurant.id);
          Navigator.of(context).pop();
        },
        onRatingSaved: (rating) async {
          await _dbService.updateRating(restaurant.id, rating);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rouletteProvider);
    final notifier = ref.read(rouletteProvider.notifier);
    final theme = Theme.of(context);
    
    ref.listen<RouletteState>(rouletteProvider, (previous, next) {
      if (_isMapReady) {
        if (next.currentPosition != null && 
            (previous?.currentPosition != next.currentPosition)) {
          
          final newCenter = LatLng(next.currentPosition!.latitude, next.currentPosition!.longitude);
          final newZoom = _calculateZoomLevel(next.radiusKm);
          _mapController.move(newCenter, newZoom);
        }
        
        if (next.currentPosition != null && previous != null && previous.radiusKm != next.radiusKm) {
           final center = LatLng(next.currentPosition!.latitude, next.currentPosition!.longitude);
           final newZoom = _calculateZoomLevel(next.radiusKm);
           _mapController.move(center, newZoom);
        }
      }

      if (next.selectedRestaurant != null && previous?.selectedRestaurant != next.selectedRestaurant) {
        setState(() {
          _isSpinning = true;
        });
        
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _isSpinning = false;
            });
          }
        });
      }
      
      if (next.restaurants.isEmpty) {
         setState(() {
           _isSpinning = false;
         });
      }
    });

    final LatLng initialCenter = state.currentPosition != null
        ? LatLng(state.currentPosition!.latitude, state.currentPosition!.longitude)
        : const LatLng(52.5200, 13.4050); 
    
    final double initialZoom = _calculateZoomLevel(state.radiusKm);

    return Scaffold(
      body: Stack(
        children: [
          // 1. Layer: Karte (Hell/Standard)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter, 
              initialZoom: initialZoom,
              minZoom: 5.0, 
              maxZoom: 18.0,
              onMapReady: () => setState(() { _isMapReady = true; }),
              onTap: (_, __) {
                if (_showSettings || _showProfile) setState(() { 
                  _showSettings = false; 
                  _showProfile = false;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.restaurant_roulette',
              ),
              if (state.currentPosition != null)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: LatLng(state.currentPosition!.latitude, state.currentPosition!.longitude),
                      color: theme.colorScheme.primary.withOpacity(0.15),
                      borderStrokeWidth: 2,
                      borderColor: theme.colorScheme.primary,
                      useRadiusInMeter: true,
                      radius: state.radiusKm * 1000, 
                    ),
                  ],
                ),
              if (state.currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(state.currentPosition!.latitude, state.currentPosition!.longitude),
                      width: 50,
                      height: 50,
                      child: Icon(
                        state.isUsingCustomLocation ? Icons.location_on : Icons.my_location, 
                        color: state.isUsingCustomLocation ? Colors.deepOrange : theme.colorScheme.primary,
                        size: 40,
                        shadows: const [Shadow(color: Colors.black26, blurRadius: 4)],
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // 2. Layer: Bottom Action Button (Moved behind settings menu)
          if (state.restaurants.isEmpty && !state.isLoading)
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: ElevatedButton.icon(
                onPressed: () => notifier.loadRestaurants(),
                icon: const Icon(Icons.casino_outlined, color: Colors.white),
                label: const Text("Restaurant suchen"),
              ),
            ),

          // 2.5. Layer: Top Left Profile Menu
          _buildProfileMenu(theme),

          // 3. Layer: Top Controls (Settings Menu) - NOW ON TOP of button
          _buildSettingsMenu(state, notifier, theme),

          // 4. Layer: Lade-Animation
          if (state.isLoading)
            Positioned.fill(
              child: LoadingAnimation(isLoading: state.isLoading),
            ),

          // 5. Layer: Roulette Overlay
          if (state.restaurants.isNotEmpty)
            Positioned.fill(
              child: _buildRouletteOverlay(context, state, notifier, theme),
            ),

          // 6. Layer: Fehlermeldung
          if (state.error != null && !state.isLoading && state.restaurants.isEmpty)
            _buildErrorWidget(state.error!, () => notifier.clearRestaurants()),
        ],
      ),
    );
  }

  Widget _buildProfileMenu(ThemeData theme) {
     return Positioned(
            top: 50,
            left: 20,
            bottom: 100, // Platz lassen
            child: Align(
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton.small(
                    heroTag: 'profile_btn',
                    backgroundColor: theme.colorScheme.surface,
                    child: Icon(_showProfile ? Icons.close : Icons.person, color: theme.colorScheme.primary),
                    onPressed: () {
                      setState(() {
                        _showProfile = !_showProfile;
                        if (_showProfile && _showSettings) {
                           _showSettings = false;
                        }
                      });
                    },
                  ),
                  if (_showProfile)
                    Flexible(
                      child: Card(
                        margin: const EdgeInsets.only(top: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          width: 250,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Text("Profil", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              ),
                              const Divider(),
                              ListTile(
                                leading: const Icon(Icons.history),
                                title: const Text("Besuchte Restaurants"),
                                dense: true,
                                onTap: () {
                                  setState(() => _showProfile = false);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const VisitedRestaurantsScreen()),
                                  );
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.notifications),
                                title: const Text("Benachrichtigungen"),
                                dense: true,
                                onTap: () {
                                  setState(() => _showProfile = false);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
  }

  Widget _buildSettingsMenu(RouletteState state, RouletteNotifier notifier, ThemeData theme) {
     return Positioned(
            top: 50,
            right: 20,
            bottom: 100, // Platz lassen, aber max Höhe begrenzen
            child: Align(
              alignment: Alignment.topRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton.small(
                    heroTag: 'filter_btn',
                    backgroundColor: theme.colorScheme.surface,
                    child: Icon(_showSettings ? Icons.close : Icons.tune, color: theme.colorScheme.primary),
                    onPressed: () {
                      setState(() {
                        _showSettings = !_showSettings;
                        if (_showSettings && _showProfile) {
                           _showProfile = false;
                        }
                        if (!_showSettings) {
                          _searchController.clear();
                          notifier.searchAddress(""); 
                        }
                      });
                    },
                  ),
                  if (_showSettings)
                    Flexible(
                      child: Card(
                        margin: const EdgeInsets.only(top: 10),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          width: 300,
                          // Making it constrained and scrollable
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.65,
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text("Anderen Ort suchen", style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    hintText: "Stadt oder Adresse...",
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    suffixIcon: _searchController.text.isNotEmpty 
                                      ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                                        _searchController.clear();
                                        notifier.searchAddress("");
                                      }) : const Icon(Icons.search),
                                  ),
                                  onChanged: notifier.searchAddress,
                                ),
                                
                                if (state.addressSuggestions.isNotEmpty)
                                  Container(
                                    constraints: const BoxConstraints(maxHeight: 150),
                                    margin: const EdgeInsets.only(top: 8),
                                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(), // Scroll via parent
                                      itemCount: state.addressSuggestions.length,
                                      itemBuilder: (context, index) {
                                        final place = state.addressSuggestions[index];
                                        return ListTile(
                                          title: Text(place.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                                          onTap: () {
                                            notifier.selectAddress(place);
                                            FocusScope.of(context).unfocus();
                                            _searchController.clear();
                                            setState(() { _showSettings = false; });
                                          },
                                        );
                                      },
                                    ),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: TextButton.icon(
                                      onPressed: () => notifier.useCurrentLocation(), 
                                      icon: const Icon(Icons.my_location),
                                      label: const Text("Meinen Standort verwenden"),
                                    ),
                                  ),

                                const Divider(height: 20),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Suchradius", style: TextStyle(fontWeight: FontWeight.bold)),
                                    Text("${state.radiusKm.toStringAsFixed(1)} km", style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Slider(
                                  value: state.radiusKm,
                                  min: 0.5,
                                  max: 20.0,
                                  divisions: 39,
                                  label: "${state.radiusKm.toStringAsFixed(1)} km",
                                  onChanged: notifier.setRadius,
                                ),
                                
                                const Divider(height: 20),
                                
                                const Text("Filter", style: TextStyle(fontWeight: FontWeight.bold)),
                                SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text("Vegan verfügbar"),
                                  value: state.isVegan,
                                  activeColor: theme.colorScheme.primary,
                                  onChanged: (val) => notifier.toggleVegan(val),
                                ),
                                SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text("Vegetarisch verfügbar"),
                                  value: state.isVegetarian,
                                  activeColor: theme.colorScheme.primary,
                                  onChanged: (val) => notifier.toggleVegetarian(val),
                                ),
                                SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text("Besuchte ausblenden"),
                                  subtitle: const Text("Bereits besuchte Orte ausschließen"),
                                  value: state.excludeVisited,
                                  activeColor: theme.colorScheme.primary,
                                  onChanged: (val) => notifier.toggleExcludeVisited(val),
                                ),

                                const Text("Küche", style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8.0,
                                  runSpacing: 4.0,
                                  children: {
                                    'Italienisch': 'italian',
                                    'Asiatisch': 'asian',
                                    'Deutsch': 'german',
                                    'Chinesisch': 'chinese',
                                    'Japanisch': 'japanese',
                                    'Mexikanisch': 'mexican',
                                    'Indisch': 'indian',
                                    'Französisch': 'french',
                                    'Griechisch': 'greek',
                                    'Amerikanisch': 'american',
                                    'Burger': 'burger',
                                    'Pizza': 'pizza',
                                    'Sushi': 'sushi',
                                  }.entries.map((entry) {
                                    final isSelected = state.selectedCuisines.contains(entry.value);
                                    return FilterChip(
                                      label: Text(entry.key),
                                      selected: isSelected,
                                      onSelected: (_) => notifier.toggleCuisine(entry.value),
                                      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                                      checkmarkColor: theme.colorScheme.primary,
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
  }

  Widget _buildRouletteOverlay(BuildContext context, RouletteState state, RouletteNotifier notifier, ThemeData theme) {
    return Container(
      color: theme.scaffoldBackgroundColor.withOpacity(0.95),
      child: Center(
        child: SingleChildScrollView( 
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (state.selectedRestaurant == null || _isSpinning)
                const Text(
                  "Wähle dein Schicksal!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              
              const SizedBox(height: 20),

              if (state.selectedRestaurant == null || _isSpinning)
                RouletteWheelWidget(
                  restaurants: state.restaurants,
                  onFinished: (index) {},
                  onSpin: () {
                    // Only allow spin if not already spinning and no winner selected (or re-spin logic)
                    if (!_isSpinning && state.selectedRestaurant == null) {
                       notifier.selectWinner();
                    }
                  },
                ),
          
              const SizedBox(height: 20),
          
              if (state.selectedRestaurant != null && !_isSpinning)
                _buildWinnerCard(state, notifier, theme),
          
              const SizedBox(height: 30),
          
              _buildControlButtons(state, notifier, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWinnerCard(RouletteState state, RouletteNotifier notifier, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              "🎉 GEWINNER 🎉",
              style: TextStyle(color: theme.colorScheme.secondary, fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
            const SizedBox(height: 16),
            Text(
              state.selectedRestaurant!.name,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            if(state.selectedRestaurant!.address != null)
              Text(
                state.selectedRestaurant!.address!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54, fontSize: 16),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => notifier.launchGoogleMaps(),
                icon: const Icon(Icons.navigation_outlined, size: 28),
                label: const Text("ROUTE STARTEN", style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.colorScheme.primary,
                ),
              ),
            ),
            
            // Lieferando/Uber Eats Buttons - IMMER sichtbar
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final success = await notifier.searchOnLieferando();
                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.content_copy, color: Colors.white),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '"${state.selectedRestaurant?.name}" in Zwischenablage kopiert',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 4),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.delivery_dining, color: Colors.white),
                label: const Text("AUF LIEFERANDO SUCHEN", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // Lieferando Orange
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            // Status "Bereits besucht"
            if (state.visitedIds.contains(state.selectedRestaurant!.id))
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.check, color: Colors.green),
                    SizedBox(width: 8),
                    Text("Bereits besucht", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButtons(RouletteState state, RouletteNotifier notifier, ThemeData theme) {
    if (_isSpinning) return const SizedBox.shrink();

    if (state.selectedRestaurant == null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // "DREHEN" button removed as we have a central spin button now
          TextButton(
            onPressed: notifier.clearRestaurants,
            child: const Text("Abbrechen", style: TextStyle(fontSize: 16)),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: notifier.selectWinner,
                icon: const Icon(Icons.replay),
                label: const Text("Nochmal drehen"),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: notifier.clearRestaurants,
            child: const Text("Neue Suche starten"),
          ),
        ],
      );
    }
  }

  Widget _buildErrorWidget(String error, VoidCallback onClose) {
    return Positioned(
      bottom: 40,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text(error, style: const TextStyle(color: Colors.white))),
              IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: onClose),
            ],
          ),
        ),
      ),
    );
  }
}
