import 'dart:async'; // Timer importiert
import 'dart:math';
import 'package:flutter/material.dart';

class LoadingAnimation extends StatefulWidget {
  final bool isLoading;
  const LoadingAnimation({Key? key, required this.isLoading}) : super(key: key);

  @override
  State<LoadingAnimation> createState() => _LoadingAnimationState();
}

class _LoadingAnimationState extends State<LoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _showSlowLoadingText = false;
  
  // Timer für die "langsame Suche" Nachricht
  late final Timer _slowLoadingTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500), 
    )..repeat(); 

    _slowLoadingTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _showSlowLoadingText = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _slowLoadingTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const int iconCount = 8;

    return Container(
      color: Colors.white.withOpacity(0.9), 
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: WheelBuilderPainter(
                    animationValue: _controller.value,
                    color: theme.colorScheme.primary,
                    iconCount: iconCount,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: List.generate(iconCount, (index) {
                      final progress = (_controller.value * iconCount - index)
                          .clamp(0.0, 1.0);
                      
                      if (progress == 0.0) return const SizedBox.shrink();

                      final angle = (index / iconCount) * 2 * pi;
                      final startRadius = 200.0; 
                      final endRadius = 70.0; 

                      final currentRadius = startRadius - (startRadius - endRadius) * Curves.easeOutCubic.transform(progress);

                      return Transform.translate(
                        offset: Offset(
                          currentRadius * cos(angle),
                          currentRadius * sin(angle),
                        ),
                        child: Icon(
                          Icons.restaurant_menu,
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                      );
                    }),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            "Suche Restaurants...",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: _showSlowLoadingText && widget.isLoading ? 1.0 : 0.0,
            child: const Text(
              "Einen Moment Geduld, die Suche dauert etwas länger.",
              style: TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}

class WheelBuilderPainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final int iconCount;

  WheelBuilderPainter({required this.animationValue, required this.color, required this.iconCount});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;
    final rect = Rect.fromCircle(center: center, radius: radius);
    
    final backgroundPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    canvas.drawCircle(center, radius, backgroundPaint);
    
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round; 
      
    final segmentsToShow = (animationValue * iconCount).floor();
    final anglePerSegment = (2 * pi) / iconCount;

    for (int i = 0; i < segmentsToShow; i++) {
       canvas.drawArc(
         rect, 
         -pi / 2 + i * anglePerSegment, 
         anglePerSegment * 0.8,
         false, 
         progressPaint
       );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
