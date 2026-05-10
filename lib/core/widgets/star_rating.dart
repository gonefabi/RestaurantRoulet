import 'package:flutter/material.dart';

/// Reihe aus 1–[max] Sternen.
///
/// - Read-only: [onChanged] = null → reine Anzeige.
/// - Interaktiv: [onChanged] != null → tappbar, liefert die neue Bewertung.
class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.rating,
    this.max = 5,
    this.size = 16,
    this.filledColor = Colors.amber,
    this.emptyColor,
    this.onChanged,
  });

  final int rating;
  final int max;
  final double size;
  final Color filledColor;

  /// Default: [filledColor] mit reduzierter Opacity.
  final Color? emptyColor;

  /// Wenn null, ist das Widget read-only.
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    final empty = emptyColor ?? filledColor.withValues(alpha: 0.35);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(max, (i) {
        final filled = i < rating;
        final icon = Icon(
          filled ? Icons.star_rounded : Icons.star_outline_rounded,
          color: filled ? filledColor : empty,
          size: size,
        );
        if (onChanged == null) return icon;
        return IconButton(
          padding: EdgeInsets.zero,
          constraints: BoxConstraints.tightFor(
            width: size + 12,
            height: size + 12,
          ),
          icon: icon,
          onPressed: () => onChanged!(i + 1),
        );
      }),
    );
  }
}
