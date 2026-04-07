import 'dart:async';
import 'package:confetti/confetti.dart';
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

class _RouletteWheelWidgetState extends ConsumerState<RouletteWheelWidget>
    with TickerProviderStateMixin {

  final StreamController<int> _controller = StreamController<int>();
  bool _isSpinning = false;
  int _lastSelectedIndex = 0;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late ConfettiController _confettiController;

  // Earth tone / Food-themed palette
  static const List<Color> _colors = [
    Color(0xFFC1654A), // Terracotta
    Color(0xFF7D9B76), // Sage Green
    Color(0xFFE8D5B7), // Crème
    Color(0xFF8B5E3C), // Warm Brown
    Color(0xFFD4A017), // Amber
    Color(0xFFC9929A), // Dusty Rose
  ];

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _glowAnimation = Tween<double>(begin: 6.0, end: 22.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _controller.close();
    _glowController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Color _getTextColor(Color bg) {
    return bg.computeLuminance() > 0.35
        ? const Color(0xFF3B2310)
        : Colors.white;
  }

  @override
  Widget build(BuildContext context) {

    ref.listen<RouletteState>(rouletteProvider, (previous, next) {
      if (next.selectedRestaurant != null &&
          previous?.selectedRestaurant != next.selectedRestaurant) {
        final idx = widget.restaurants
            .indexWhere((r) => r.id == next.selectedRestaurant!.id);
        if (idx != -1 && widget.restaurants.isNotEmpty) {
          _lastSelectedIndex = idx;
          setState(() => _isSpinning = true);
          _confettiController.stop();
          _glowController.stop();
          _glowController.repeat(reverse: true);
          _controller.add(idx);
        }
      }
    });

    return SizedBox(
      width: 460,
      height: 460,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Layer 1: Animated glow ring around wheel
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                width: 420,
                height: 420,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: _isSpinning
                      ? [
                          BoxShadow(
                            color: const Color(0xFFD4A017).withOpacity(0.55),
                            blurRadius: _glowAnimation.value,
                            spreadRadius: _glowAnimation.value * 0.3,
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                ),
              );
            },
          ),

          // Layer 2: The Fortune Wheel
          SizedBox(
            width: 420,
            height: 420,
            child: FortuneWheel(
              selected: _controller.stream,
              animateFirst: false,
              duration: const Duration(seconds: 8),
              physics: CircularPanPhysics(
                duration: const Duration(seconds: 8),
                curve: Curves.fastLinearToSlowEaseIn,
              ),
              indicators: const <FortuneIndicator>[],
              onAnimationEnd: () {
                setState(() => _isSpinning = false);
                _glowController.stop();
                _glowController.reset();
                _confettiController.play();
                widget.onFinished(_lastSelectedIndex);
              },
              items: [
                for (var i = 0; i < widget.restaurants.length; i++)
                  FortuneItem(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 60.0),
                      child: Text(
                        widget.restaurants[i].name.length > 15
                            ? '${widget.restaurants[i].name.substring(0, 13)}...'
                            : widget.restaurants[i].name.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 0.8,
                          color: _getTextColor(_colors[i % _colors.length]),
                        ),
                      ),
                    ),
                    style: FortuneItemStyle(
                      color: _colors[i % _colors.length],
                      borderColor: Colors.white.withOpacity(0.5),
                      borderWidth: 1.5,
                    ),
                  ),
              ],
            ),
          ),

          // Layer 3: Center spin button
          GestureDetector(
            onTap: () {
              if (!_isSpinning && widget.onSpin != null) {
                widget.onSpin!();
              }
            },
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFF007BFF).withOpacity(0.25),
                  width: 2,
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    color: Color(0xFF007BFF),
                    size: 28,
                  ),
                  SizedBox(height: 2),
                  Text(
                    'SPIN',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF007BFF),
                      fontSize: 13,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Layer 4: External pointer (top of wheel, points down into winning segment)
          const Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: Center(
              child: CustomPaint(
                painter: _ExternalPointerPainter(
                  color: Color(0xFF007BFF),
                  shadowColor: Colors.black38,
                ),
                size: Size(28, 20),
              ),
            ),
          ),

          // Layer 5: Confetti emitter at top center
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Center(
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                emissionFrequency: 0.06,
                numberOfParticles: 18,
                gravity: 0.2,
                colors: const [
                  Color(0xFFC1654A), // Terracotta
                  Color(0xFF7D9B76), // Sage Green
                  Color(0xFFD4A017), // Amber
                  Color(0xFFC9929A), // Dusty Rose
                  Color(0xFF007BFF), // App Blue
                ],
                shouldLoop: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExternalPointerPainter extends CustomPainter {
  final Color color;
  final Color shadowColor;

  const _ExternalPointerPainter({
    required this.color,
    required this.shadowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Downward-pointing triangle (base at top, tip at bottom → points into wheel)
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawShadow(path, shadowColor, 4.0, false);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _ExternalPointerPainter oldDelegate) =>
      oldDelegate.color != color;
}
