import 'dart:async';
import 'dart:math' as math;
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
  late AnimationController _ringController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late ConfettiController _confettiController;

  // Neon cyberpunk palette - vibrant, saturated, futuristic
  static const Color _neonCyan = Color(0xFF00F0FF);
  static const Color _neonMagenta = Color(0xFFFF1FA8);
  static const Color _neonPurple = Color(0xFF9B51FF);
  static const Color _neonLime = Color(0xFFB6FF3C);
  static const Color _neonAmber = Color(0xFFFFB627);
  static const Color _neonPink = Color(0xFFFF4D6D);
  static const Color _voidBlack = Color(0xFF05010F);

  static const List<Color> _segmentColors = [
    _neonCyan,
    _neonMagenta,
    _neonPurple,
    _neonLime,
    _neonAmber,
    _neonPink,
  ];

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _glowAnimation = Tween<double>(begin: 8.0, end: 34.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _controller.close();
    _glowController.dispose();
    _ringController.dispose();
    _pulseController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Color _textOn(Color bg) {
    return bg.computeLuminance() > 0.45 ? _voidBlack : Colors.white;
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
      width: 480,
      height: 480,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Layer 0: Outer rotating HUD ring (tick marks, corner brackets)
          AnimatedBuilder(
            animation: _ringController,
            builder: (context, _) {
              return Transform.rotate(
                angle: _ringController.value * 2 * math.pi,
                child: CustomPaint(
                  size: const Size(470, 470),
                  painter: _HudRingPainter(
                    accent: _neonCyan,
                    secondary: _neonMagenta,
                  ),
                ),
              );
            },
          ),

          // Layer 1: Static bracket frame (doesn't rotate, gives "locked target" feel)
          CustomPaint(
            size: const Size(460, 460),
            painter: _CornerBracketPainter(
              color: _neonCyan,
              isActive: _isSpinning,
            ),
          ),

          // Layer 2: Animated plasma glow ring
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: _isSpinning
                      ? [
                          BoxShadow(
                            color: _neonMagenta.withOpacity(0.55),
                            blurRadius: _glowAnimation.value,
                            spreadRadius: _glowAnimation.value * 0.35,
                          ),
                          BoxShadow(
                            color: _neonCyan.withOpacity(0.45),
                            blurRadius: _glowAnimation.value * 1.4,
                            spreadRadius: _glowAnimation.value * 0.2,
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: _neonCyan.withOpacity(0.28),
                            blurRadius: 22,
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: _neonPurple.withOpacity(0.22),
                            blurRadius: 38,
                            spreadRadius: 4,
                          ),
                        ],
                ),
              );
            },
          ),

          // Layer 3: Dark backing disc to sit the wheel in (depth)
          Container(
            width: 408,
            height: 408,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0xFF120A2A), _voidBlack],
                stops: [0.0, 1.0],
              ),
            ),
          ),

          // Layer 4: The Fortune Wheel itself
          SizedBox(
            width: 400,
            height: 400,
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
                      padding: const EdgeInsets.only(left: 58.0),
                      child: Text(
                        widget.restaurants[i].name.length > 15
                            ? '${widget.restaurants[i].name.substring(0, 13)}...'
                            : widget.restaurants[i].name.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          letterSpacing: 1.6,
                          color: _textOn(_segmentColors[i % _segmentColors.length]),
                          shadows: const [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                    style: FortuneItemStyle(
                      color: _segmentColors[i % _segmentColors.length],
                      borderColor: _voidBlack,
                      borderWidth: 2.0,
                    ),
                  ),
              ],
            ),
          ),

          // Layer 5: Inner rim overlay - thin neon ring on top of the wheel edge
          IgnorePointer(
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _neonCyan.withOpacity(0.7), width: 1.2),
              ),
            ),
          ),

          // Layer 6: Center spin button
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              final pulse = _isSpinning ? 1.0 : _pulseAnimation.value;
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
                      colors: [Color(0xFF1A0A3B), _voidBlack],
                      stops: [0.0, 1.0],
                    ),
                    border: Border.all(
                      color: _isSpinning ? _neonMagenta : _neonCyan,
                      width: 2.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (_isSpinning ? _neonMagenta : _neonCyan)
                            .withOpacity(0.55 * pulse),
                        blurRadius: 24 * pulse,
                        spreadRadius: 1.5,
                      ),
                      const BoxShadow(
                        color: Colors.black87,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isSpinning ? Icons.sync : Icons.play_arrow_rounded,
                        color: _isSpinning ? _neonMagenta : _neonCyan,
                        size: 34,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _isSpinning ? 'SPINNING' : 'SPIN',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: _isSpinning ? _neonMagenta : _neonCyan,
                          fontSize: 11,
                          letterSpacing: 2.4,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Layer 7: External pointer (neon arrow with glow halo)
          Positioned(
            top: -6,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _NeonPointerPainter(
                      color: _isSpinning ? _neonMagenta : _neonCyan,
                      glowIntensity: _pulseAnimation.value,
                    ),
                    size: const Size(36, 44),
                  );
                },
              ),
            ),
          ),

          // Layer 8: Confetti emitter at top center
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
                gravity: 0.18,
                colors: const [
                  _neonCyan,
                  _neonMagenta,
                  _neonPurple,
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
}

// Painter: rotating outer HUD ring with tick marks and arc segments
class _HudRingPainter extends CustomPainter {
  final Color accent;
  final Color secondary;

  const _HudRingPainter({required this.accent, required this.secondary});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerR = size.width / 2;

    // Thin outer arc segments (3 arcs, gapped)
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = accent.withOpacity(0.55);

    for (int i = 0; i < 3; i++) {
      final start = (i * 2 * math.pi / 3) + 0.25;
      const sweep = (2 * math.pi / 3) - 0.5;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: outerR - 1),
        start,
        sweep,
        false,
        arcPaint,
      );
    }

    // Tick marks
    final tickPaint = Paint()
      ..strokeWidth = 1.2
      ..color = accent.withOpacity(0.5);
    const tickCount = 60;
    for (int i = 0; i < tickCount; i++) {
      final angle = (i / tickCount) * 2 * math.pi;
      final isMajor = i % 5 == 0;
      final inset = isMajor ? 14.0 : 6.0;
      final p1 = center + Offset(math.cos(angle), math.sin(angle)) * (outerR - 6);
      final p2 = center + Offset(math.cos(angle), math.sin(angle)) * (outerR - 6 - inset);
      tickPaint.color = isMajor ? accent.withOpacity(0.85) : accent.withOpacity(0.4);
      canvas.drawLine(p1, p2, tickPaint);
    }

    // Three magenta "orbit markers" at 120° spacing
    final markerPaint = Paint()..color = secondary;
    final markerGlow = Paint()
      ..color = secondary.withOpacity(0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    for (int i = 0; i < 3; i++) {
      final angle = i * 2 * math.pi / 3 - math.pi / 2;
      final pos = center + Offset(math.cos(angle), math.sin(angle)) * (outerR - 14);
      canvas.drawCircle(pos, 5, markerGlow);
      canvas.drawCircle(pos, 2.8, markerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HudRingPainter oldDelegate) =>
      oldDelegate.accent != accent || oldDelegate.secondary != secondary;
}

// Painter: 4 static corner brackets that frame the wheel (targeting look)
class _CornerBracketPainter extends CustomPainter {
  final Color color;
  final bool isActive;

  const _CornerBracketPainter({required this.color, required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isActive ? color : color.withOpacity(0.75)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const armLength = 22.0;
    const inset = 4.0;

    // Top-left
    canvas.drawLine(Offset(inset, inset + armLength), const Offset(inset, inset), paint);
    canvas.drawLine(const Offset(inset, inset), Offset(inset + armLength, inset), paint);
    // Top-right
    canvas.drawLine(Offset(size.width - inset - armLength, inset), Offset(size.width - inset, inset), paint);
    canvas.drawLine(Offset(size.width - inset, inset), Offset(size.width - inset, inset + armLength), paint);
    // Bottom-left
    canvas.drawLine(Offset(inset, size.height - inset - armLength), Offset(inset, size.height - inset), paint);
    canvas.drawLine(Offset(inset, size.height - inset), Offset(inset + armLength, size.height - inset), paint);
    // Bottom-right
    canvas.drawLine(Offset(size.width - inset - armLength, size.height - inset), Offset(size.width - inset, size.height - inset), paint);
    canvas.drawLine(Offset(size.width - inset, size.height - inset), Offset(size.width - inset, size.height - inset - armLength), paint);
  }

  @override
  bool shouldRepaint(covariant _CornerBracketPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.isActive != isActive;
}

// Painter: downward-pointing neon arrow with soft glow halo
class _NeonPointerPainter extends CustomPainter {
  final Color color;
  final double glowIntensity;

  const _NeonPointerPainter({required this.color, required this.glowIntensity});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(size.width * 0.15, size.height * 0.15)
      ..lineTo(size.width * 0.5, size.height * 0.35)
      ..lineTo(size.width * 0.85, size.height * 0.15)
      ..close();

    // Glow halo
    final glow = Paint()
      ..color = color.withOpacity(0.6 * glowIntensity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10 * glowIntensity);
    canvas.drawPath(path, glow);

    // Core fill
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );

    // Dark inner outline for depth
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black.withOpacity(0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(covariant _NeonPointerPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.glowIntensity != glowIntensity;
}
