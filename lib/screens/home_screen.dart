import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:async';

import '../providers/roulette_provider.dart';
import '../models/restaurant.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  StreamController<int> selected = StreamController<int>();
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    // Start Loading Restaurants immediately
    Future.microtask(() => ref.read(rouletteProvider.notifier).loadRestaurants());
    _loadAd();
  }

  void _loadAd() {
    // TEST ID for AdMob Banner
    // Real ID: ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY
    final adUnitId = 'ca-app-pub-3940256099942544/6300978111'; 

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    selected.close();
    _bannerAd?.dispose();
    super.dispose();
  }

  void _spinWheel(List<Restaurant> items) {
    // Zufälligen Index wählen
    final winnerIndex = Fortune.randomInt(0, items.length);
    selected.add(winnerIndex);
    
    // State updaten (Gewinner setzen)
    ref.read(rouletteProvider.notifier).selectWinner(winnerIndex);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rouletteProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🍔 Restaurant Roulette'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(rouletteProvider.notifier).loadRestaurants(),
          )
        ],
      ),
      body: Column(
        children: [
          // 🎰 ROULETTE BEREICH
          Expanded(
            child: Center(
              child: state.isLoading
                  ? const CircularProgressIndicator()
                  : state.error != null
                      ? Text(state.error!, style: const TextStyle(color: Colors.red))
                      : state.restaurants.isEmpty
                          ? const Text('Keine Restaurants gefunden.')
                          : Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: FortuneWheel(
                                selected: selected.stream,
                                items: [
                                  for (var r in state.restaurants)
                                    FortuneItem(child: Text(r.name)),
                                ],
                                onAnimationEnd: () {
                                  // Zeige Dialog wenn Rad stoppt
                                  if (state.selectedRestaurant != null) {
                                    _showWinnerDialog(state.selectedRestaurant!);
                                  }
                                },
                              ),
                            ),
            ),
          ),

          // 🎛️ BUTTON
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: FilledButton.icon(
              onPressed: state.restaurants.isNotEmpty && !state.isLoading
                  ? () => _spinWheel(state.restaurants)
                  : null,
              icon: const Icon(Icons.casino),
              label: const Text('SPIN!'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 20),
              ),
            ),
          ),

          // 📢 AD BANNER PLATZHALTER
          if (_bannerAd != null && _isAdLoaded)
            SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            )
          else
            const SizedBox(height: 50), // Platzhalter damit UI nicht springt
        ],
      ),
    );
  }

  void _showWinnerDialog(Restaurant r) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('🎉 Wir haben einen Gewinner!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(r.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(r.address),
            if (r.rating > 0) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  Text(' ${r.rating} (${r.userRatingsTotal})'),
                ],
              )
            ]
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Nochmal')),
          FilledButton(onPressed: () {
            // TODO: Open Google Maps Navigation
            Navigator.pop(ctx);
          }, child: const Text('Hinbringen!')),
        ],
      ),
    );
  }
}
