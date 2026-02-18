import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/restaurant.dart';
import '../providers/roulette_provider.dart';

class RouletteWheelWidget extends ConsumerStatefulWidget {
  final List<Restaurant> restaurants;
  final Function(int) onFinished;
  final VoidCallback? onSpin;

  const RouletteWheelWidget({
    Key? key,
    required this.restaurants,
    required this.onFinished,
    this.onSpin,
  }) : super(key: key);

  @override
  ConsumerState<RouletteWheelWidget> createState() => _RouletteWheelWidgetState();
}

class _RouletteWheelWidgetState extends ConsumerState<RouletteWheelWidget> {
  final StreamController<int> _controller = StreamController<int>();

  // Modern Color Palette
  final List<Color> _colors = [
    const Color(0xFFE57373), // Red
    const Color(0xFF4DB6AC), // Teal
    const Color(0xFF64B5F6), // Blue
    const Color(0xFF7986CB), // Indigo
    const Color(0xFFFFB74D), // Orange
    const Color(0xFFFFF176), // Yellow
  ];

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
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
      height: 350,
      width: 350,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Border/Shadow
          Container(
            height: 330,
            width: 330,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ],
            ),
          ),
          
          FortuneWheel(
            selected: _controller.stream,
            animateFirst: false, // Wichtig: Nicht beim ersten Laden drehen
            duration: const Duration(seconds: 5), // Dreht sich 5 Sekunden lang
            physics: CircularPanPhysics(
              duration: const Duration(seconds: 5),
              curve: Curves.decelerate, // Wird langsam zum Ende hin
            ),
            // Custom Indikatoren (wir nutzen unseren eigenen im Stack)
            indicators: const <FortuneIndicator>[], 
            items: [
              for (var i = 0; i < widget.restaurants.length; i++)
                FortuneItem(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 60.0), // Mehr Platz für Center Button
                    child: Text(
                      widget.restaurants[i].name.length > 15 
                          ? '${widget.restaurants[i].name.substring(0, 13)}...' 
                          : widget.restaurants[i].name.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 14,
                        letterSpacing: 1.0,
                        color: Colors.black87, // Besserer Kontrast auf hellen/bunten Farben
                      ),
                    ),
                  ),
                  style: FortuneItemStyle(
                    color: _colors[i % _colors.length], 
                    borderColor: Colors.white.withOpacity(0.8),
                    borderWidth: 1, // Dünnere Ränder
                  ),
                ),
            ],
            onAnimationEnd: () {
              // Optional: Callback, wenn es steht
            },
          ),
          
          // Central Spin Button & Pointer
          GestureDetector(
             onTap: () {
                if (widget.onSpin != null) {
                  widget.onSpin!();
                }
             },
             child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
                border: Border.all(color: Colors.grey.shade200, width: 1),
              ),
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                   const Text(
                    "SPIN",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      fontSize: 16,
                      letterSpacing: 1.5,
                    ),
                  ),
                  // Pointer Triangle
                  Positioned(
                    top: -15, // Moves it to the edge pointing out/up
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle, // Small circle base for pointer or just custom shape
                      ),
                      child: CustomPaint(
                        painter: _TrianglePainter(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    // Draw a triangle pointing UP (towards the winning segment at top)
    // Actually FortuneWheel default alignment is topCenter.
    // So the pointer should point UP.
    final path = Path();
    path.moveTo(0, size.height); // Bottom Left
    path.lineTo(size.width, size.height); // Bottom Right
    path.lineTo(size.width / 2, 0); // Top Center
    path.close();

    // Adding shadow
    canvas.drawShadow(path, Colors.black.withOpacity(0.2), 2.0, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
