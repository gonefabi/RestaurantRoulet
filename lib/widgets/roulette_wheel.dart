import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/restaurant.dart';
import '../providers/roulette_provider.dart';

class RouletteWheelWidget extends ConsumerStatefulWidget {
  final List<Restaurant> restaurants;
  final Function(int) onFinished;

  const RouletteWheelWidget({
    Key? key,
    required this.restaurants,
    required this.onFinished,
  }) : super(key: key);

  @override
  ConsumerState<RouletteWheelWidget> createState() => _RouletteWheelWidgetState();
}

class _RouletteWheelWidgetState extends ConsumerState<RouletteWheelWidget> {
  final StreamController<int> _controller = StreamController<int>();

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Wir hören auf Änderungen im State
    ref.listen<RouletteState>(rouletteProvider, (previous, next) {
      // Wenn ein NEUES Restaurant ausgewählt wurde (und es nicht null ist)
      if (next.selectedRestaurant != null && 
          previous?.selectedRestaurant != next.selectedRestaurant) {
         
         final selectedIndex = widget.restaurants.indexWhere((r) => r.id == next.selectedRestaurant!.id);
         
         if (selectedIndex != -1) {
            // Wir fügen den Index zum Stream hinzu -> Das Rad fängt an zu drehen
            // WICHTIG: Das Rad dreht sich zu diesem Index und stoppt dort.
            _controller.add(selectedIndex);
         }
      }
    });

    return SizedBox(
      height: 300,
      width: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          FortuneWheel(
            selected: _controller.stream,
            animateFirst: false, // Wichtig: Nicht beim ersten Laden drehen
            duration: const Duration(seconds: 5), // Dreht sich 5 Sekunden lang
            physics: CircularPanPhysics(
              duration: const Duration(seconds: 5),
              curve: Curves.decelerate, // Wird langsam zum Ende hin
            ),
            indicators: <FortuneIndicator>[
              FortuneIndicator(
                alignment: Alignment.topCenter,
                child: TriangleIndicator(
                  color: theme.colorScheme.secondary, 
                  width: 20,
                  height: 20,
                  elevation: 5,
                ),
              ),
            ],
            items: [
              for (var i = 0; i < widget.restaurants.length; i++)
                FortuneItem(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0), 
                    child: Text(
                      widget.restaurants[i].name.length > 15 
                          ? '${widget.restaurants[i].name.substring(0, 13)}...' 
                          : widget.restaurants[i].name.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 14,
                        letterSpacing: 1.2,
                        color: i % 2 == 0 ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                  style: FortuneItemStyle(
                    color: i % 2 == 0 ? Colors.white : theme.colorScheme.primary, 
                    borderColor: theme.colorScheme.background,
                    borderWidth: 3,
                  ),
                ),
            ],
            onAnimationEnd: () {
              // Optional: Callback, wenn es steht
            },
          ),
          
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: theme.colorScheme.background,
              shape: BoxShape.circle,
              border: Border.all(color: theme.colorScheme.primary, width: 4),
            ),
          ),
        ],
      ),
    );
  }
}
