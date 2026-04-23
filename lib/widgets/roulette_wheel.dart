import 'dart:async';
import 'dart:math' as math;
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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

  late AnimationController _haloController;
  late AnimationController _orbitController;
  late AnimationController _pulseController;
  late ConfettiController _confettiController;

  static const Color _neonCyan = Color(0xFF00F5FF);
  static const Color _neonMagenta = Color(0xFFFF2D95);
  static const Color _neonViolet = Color(0xFF8A2BE2);
  static const Color _neonLime = Color(0xFFB8FF3C);
  static const Color _neonAmber = Color(0xFFFFB400);
  static const Color _neonPink = Color(0xFFFF6EC7);
  static const Color _voidBlack = Color(0xFF0A0014);

  static const List<Color> _segmentColors = [
    _neonMagenta,
    _neonCyan,
    _neonViolet,
    _neonLime,
    _neonAmber,
    _neonPink,
  ];

  @override
  void initState() {
    super.initState();

    _haloController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _controller.close();
    _haloController.dispose();
    _orbitController.dispose();
    _pulseController.dispose();
    _confettiController.dispose();
    super.dispose();
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
          AnimatedBuilder(
            animation: Listenable.merge([_haloController, _orbitController]),
            builder: (context, _) {
              final halo = 0.55 + _haloController.value * 0.45;
              return CustomPaint(
                size: const Size(460, 460),
                painter: _NeonHaloPainter(
                  rotation: _orbitController.value * 2 * math.pi,
                  intensity: _isSpinning ? halo : halo * 0.7,
                  primary: _neonCyan,
                  secondary: _neonMagenta,
                ),
              );
            },
          ),

          Container(
            width: 428,
            height: 428,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0xFF150026), _voidBlack],
                stops: [0.0, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: _neonMagenta.withOpacity(0.35),
                  blurRadius: 40,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: _neonCyan.withOpacity(0.25),
                  blurRadius: 60,
                  spreadRadius: 6,
                ),
              ],
            ),
          ),

          SizedBox(
            width: 404,
            height: 404,
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
                        style: GoogleFonts.orbitron(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          letterSpacing: 1.2,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: _segmentColors[i % _segmentColors.length],
                              blurRadius: 8,
                            ),
                            const Shadow(
                              color: Colors.black,
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    style: FortuneItemStyle(
                      color: _segmentColors[i % _segmentColors.length]
                          .withOpacity(0.18),
                      borderColor: _segmentColors[i % _segmentColors.length],
                      borderWidth: 2,
                    ),
                  ),
              ],
            ),
          ),

          AnimatedBuilder(
            animation: _orbitController,
            builder: (context, _) {
              return Transform.rotate(
                angle: _orbitController.value * 2 * math.pi,
                child: CustomPaint(
                  size: const Size(440, 440),
                  painter: _OrbitalRingPainter(
                    color: _neonCyan,
                  ),
                ),
              );
            },
          ),

          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, _) {
              final scale = 1.0 + _pulseController.value * 0.08;
              return Transform.scale(
                scale: scale,
                child: _buildSpinCore(),
              );
            },
          ),

          Positioned(
            top: -6,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _NeonPointerPainter(
                      glow: 0.6 + _pulseController.value * 0.4,
                    ),
                    size: const Size(34, 34),
                  );
                },
              ),
            ),
          ),

          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Center(
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                emissionFrequency: 0.06,
                numberOfParticles: 22,
                gravity: 0.2,
                colors: const [
                  _neonMagenta,
                  _neonCyan,
                  _neonViolet,
                  _neonLime,
                  _neonAmber,
                  _neonPink,
                ],
                shouldLoop: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpinCore() {
    return GestureDetector(
      onTap: () {
        if (!_isSpinning && widget.onSpin != null) {
          widget.onSpin!();
        }
      },
      child: Container(
        width: 104,
        height: 104,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            colors: [Color(0xFF1B0033), _voidBlack],
            stops: [0.0, 1.0],
          ),
          border: Border.all(color: _neonCyan, width: 2),
          boxShadow: [
            BoxShadow(
              color: _neonCyan.withOpacity(0.8),
              blurRadius: 24,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: _neonMagenta.withOpacity(0.6),
              blurRadius: 36,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [_neonCyan, _neonMagenta],
              ).createShader(bounds),
              child: const Icon(
                Icons.bolt,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'SPIN',
              style: GoogleFonts.orbitron(
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontSize: 14,
                letterSpacing: 3,
                shadows: [
                  Shadow(color: _neonCyan, blurRadius: 8),
                  Shadow(color: _neonMagenta.withOpacity(0.8), blurRadius: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NeonHaloPainter extends CustomPainter {
  final double rotation;
  final double intensity;
  final Color primary;
  final Color secondary;

  _NeonHaloPainter({
    required this.rotation,
    required this.intensity,
    required this.primary,
    required this.secondary,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final sweep = Paint()
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: 2 * math.pi,
        transform: GradientRotation(rotation),
        colors: [
          primary.withOpacity(0.0),
          primary.withOpacity(0.55 * intensity),
          secondary.withOpacity(0.55 * intensity),
          primary.withOpacity(0.0),
        ],
        stops: const [0.0, 0.35, 0.65, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);

    canvas.drawCircle(center, radius - 18, sweep);
  }

  @override
  bool shouldRepaint(covariant _NeonHaloPainter oldDelegate) =>
      oldDelegate.rotation != rotation || oldDelegate.intensity != intensity;
}

class _OrbitalRingPainter extends CustomPainter {
  final Color color;

  _OrbitalRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    final tickPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 60; i++) {
      final angle = (i / 60) * 2 * math.pi;
      final isMajor = i % 5 == 0;
      final length = isMajor ? 10.0 : 4.0;
      final width = isMajor ? 2.2 : 1.0;
      final inner = Offset(
        center.dx + math.cos(angle) * (radius - length),
        center.dy + math.sin(angle) * (radius - length),
      );
      final outer = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      tickPaint
        ..strokeWidth = width
        ..color = color.withOpacity(isMajor ? 0.9 : 0.45);
      canvas.drawLine(inner, outer, tickPaint..strokeWidth = width);
    }

    final ringPaint = Paint()
      ..color = color.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius, ringPaint);
  }

  @override
  bool shouldRepaint(covariant _OrbitalRingPainter oldDelegate) => false;
}

class _NeonPointerPainter extends CustomPainter {
  final double glow;

  _NeonPointerPainter({required this.glow});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    final glowPaint = Paint()
      ..color = const Color(0xFF00F5FF).withOpacity(glow)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawPath(path, glowPaint);

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00F5FF), Color(0xFFFF2D95)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(path, fillPaint);

    final strokePaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _NeonPointerPainter oldDelegate) =>
      oldDelegate.glow != glow;
}
