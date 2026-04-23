import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../providers/roulette_provider.dart';
import '../widgets/roulette_wheel.dart';
import '../widgets/loading_animation.dart';
import 'visited_restaurants_screen.dart';
import 'notification_settings_screen.dart';
import 'package:url_launcher/url_launcher.dart';
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
        
        Future.delayed(const Duration(seconds: 8), () {
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
                        Icons.my_location,
                        color: theme.colorScheme.primary,
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
                              const Divider(),
                              ListTile(
                                leading: const Icon(Icons.privacy_tip),
                                title: const Text("Datenschutz"),
                                dense: true,
                                onTap: () {
                                  setState(() => _showProfile = false);
                                  launchUrl(Uri.parse('https://gonefabi.github.io/RestaurantRoulet/datenschutz.html'), mode: LaunchMode.externalApplication);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.info_outline),
                                title: const Text("Impressum"),
                                dense: true,
                                onTap: () {
                                  setState(() => _showProfile = false);
                                  launchUrl(Uri.parse('https://gonefabi.github.io/RestaurantRoulet/impressum.html'), mode: LaunchMode.externalApplication);
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
                      });
                    },
                  ),
                  if (_showSettings)
                    Flexible(
                      child: Card(
                        margin: const EdgeInsets.only(top: 10),
                        child: Container(
                          // Setzen des Paddings zurück für den Container, um den Scrollbalken an den Rand zu bekommen
                          padding: EdgeInsets.zero,
                          width: 300,
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.65,
                          ),
                          child: Scrollbar(
                            thumbVisibility: true,
                            thickness: 4.0,
                            radius: const Radius.circular(8.0),
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(16), // Padding verschoben ins Scrolling
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
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
                    ),
                ],
              ),
            ),
          );
  }

  Widget _buildRouletteOverlay(BuildContext context, RouletteState state, RouletteNotifier notifier, ThemeData theme) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const _NeonAmbientBackground(),
        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (state.selectedRestaurant == null || _isSpinning)
                    _NeonTitle(text: "WÄHLE DEIN SCHICKSAL"),

                  const SizedBox(height: 24),

                  if (state.selectedRestaurant == null || _isSpinning)
                    RouletteWheelWidget(
                      restaurants: state.restaurants,
                      onFinished: (index) {},
                      onSpin: () {
                        if (!_isSpinning && state.selectedRestaurant == null) {
                          notifier.selectWinner();
                        }
                      },
                    ),

                  const SizedBox(height: 24),

                  if (state.selectedRestaurant != null && !_isSpinning)
                    _buildWinnerCard(state, notifier, theme),

                  const SizedBox(height: 28),

                  _buildControlButtons(state, notifier, theme),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWinnerCard(RouletteState state, RouletteNotifier notifier, ThemeData theme) {
    const neonCyan = Color(0xFF00F5FF);
    const neonMagenta = Color(0xFFFF2D95);
    final visited = state.visitedIds.contains(state.selectedRestaurant!.id);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF110024), Color(0xFF050010)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: neonMagenta.withOpacity(0.7), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: neonMagenta.withOpacity(0.45),
            blurRadius: 26,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: neonCyan.withOpacity(0.28),
            blurRadius: 40,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: neonCyan,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: neonCyan, blurRadius: 8)],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "TREFFER",
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 6,
                  shadows: const [
                    Shadow(color: neonCyan, blurRadius: 8),
                    Shadow(color: neonMagenta, blurRadius: 12),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: neonMagenta,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: neonMagenta, blurRadius: 8)],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [neonCyan, neonMagenta],
            ).createShader(bounds),
            child: Text(
              state.selectedRestaurant!.name.toUpperCase(),
              style: GoogleFonts.orbitron(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.2,
                height: 1.1,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (state.selectedRestaurant!.address != null) ...[
            const SizedBox(height: 10),
            Text(
              state.selectedRestaurant!.address!,
              textAlign: TextAlign.center,
              style: GoogleFonts.rajdhani(
                color: Colors.white.withOpacity(0.72),
                fontSize: 15,
                letterSpacing: 0.6,
              ),
            ),
          ],
          const SizedBox(height: 22),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: neonCyan.withOpacity(0.55),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => notifier.launchGoogleMaps(),
              icon: const Icon(Icons.navigation_outlined, size: 24, color: Colors.black),
              label: Text(
                "ROUTE STARTEN",
                style: GoogleFonts.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: 2,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: neonCyan,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          if (visited)
            Padding(
              padding: const EdgeInsets.only(top: 14.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.verified, color: Color(0xFFB8FF3C), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    "BEREITS BESUCHT",
                    style: GoogleFonts.rajdhani(
                      color: const Color(0xFFB8FF3C),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControlButtons(RouletteState state, RouletteNotifier notifier, ThemeData theme) {
    if (_isSpinning) return const SizedBox.shrink();

    if (state.selectedRestaurant == null) {
      return _NeonGhostButton(
        label: "ABBRECHEN",
        icon: Icons.close,
        onTap: notifier.clearRestaurants,
      );
    }

    return Column(
      children: [
        _NeonOutlineButton(
          label: "NOCHMAL DREHEN",
          icon: Icons.replay,
          onTap: notifier.selectWinner,
        ),
        const SizedBox(height: 12),
        _NeonGhostButton(
          label: "NEUE SUCHE STARTEN",
          icon: Icons.restart_alt,
          onTap: notifier.clearRestaurants,
        ),
      ],
    );
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

class _NeonAmbientBackground extends StatefulWidget {
  const _NeonAmbientBackground();

  @override
  State<_NeonAmbientBackground> createState() => _NeonAmbientBackgroundState();
}

class _NeonAmbientBackgroundState extends State<_NeonAmbientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [
            Color(0xFF1B0036),
            Color(0xFF0A0014),
            Color(0xFF04000A),
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _NeonGridPainter(progress: _controller.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _NeonGridPainter extends CustomPainter {
  final double progress;

  _NeonGridPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final horizonY = size.height * 0.62;

    final skyGradient = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x00000000), Color(0x33FF2D95)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, horizonY));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, horizonY), skyGradient);

    final horizonLine = Paint()
      ..color = const Color(0xFF00F5FF).withOpacity(0.55)
      ..strokeWidth = 1.4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawLine(
      Offset(0, horizonY),
      Offset(size.width, horizonY),
      horizonLine,
    );

    final linePaint = Paint()
      ..color = const Color(0xFFFF2D95).withOpacity(0.35)
      ..strokeWidth = 1.0;

    final scroll = progress;
    for (int i = 0; i < 12; i++) {
      final t = ((i / 12.0) + scroll) % 1.0;
      final eased = t * t;
      final y = horizonY + eased * (size.height - horizonY);
      linePaint.color = const Color(0xFFFF2D95).withOpacity(0.12 + eased * 0.35);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    final vanish = Offset(size.width / 2, horizonY);
    final vPaint = Paint()
      ..color = const Color(0xFF00F5FF).withOpacity(0.28)
      ..strokeWidth = 1.0;
    for (int i = -6; i <= 6; i++) {
      final dx = size.width / 2 + i * (size.width / 6);
      canvas.drawLine(vanish, Offset(dx, size.height), vPaint);
    }

    final starPaint = Paint()..color = Colors.white.withOpacity(0.65);
    final rng = Random(42);
    for (int i = 0; i < 40; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * horizonY * 0.95;
      final twinkle =
          0.3 + 0.7 * ((sin(progress * 2 * pi + i) + 1) / 2);
      starPaint.color = Colors.white.withOpacity(0.25 + 0.35 * twinkle);
      canvas.drawCircle(Offset(x, y), rng.nextDouble() * 1.2 + 0.3, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _NeonGridPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _NeonTitle extends StatelessWidget {
  final String text;
  const _NeonTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [Color(0xFF00F5FF), Color(0xFFFF2D95)],
        ).createShader(bounds),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.orbitron(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 6,
            shadows: const [
              Shadow(color: Color(0xFF00F5FF), blurRadius: 12),
              Shadow(color: Color(0xFFFF2D95), blurRadius: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _NeonOutlineButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _NeonOutlineButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const cyan = Color(0xFF00F5FF);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: cyan.withOpacity(0.45), blurRadius: 18),
        ],
      ),
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: cyan),
        label: Text(
          label,
          style: GoogleFonts.orbitron(
            color: cyan,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            fontSize: 13,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding:
              const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          side: const BorderSide(color: cyan, width: 1.4),
          backgroundColor: const Color(0xFF0A0014).withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class _NeonGhostButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _NeonGhostButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white.withOpacity(0.75), size: 18),
      label: Text(
        label,
        style: GoogleFonts.orbitron(
          color: Colors.white.withOpacity(0.78),
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
          fontSize: 12,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      ),
    );
  }
}
