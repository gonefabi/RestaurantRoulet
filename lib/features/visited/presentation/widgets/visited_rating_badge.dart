import 'package:flutter/material.dart';

import '../../../../core/widgets/star_rating.dart';

/// Sterne-Badge mit amber-Pille — zeigt eine vergebene Bewertung.
class VisitedRatingBadge extends StatelessWidget {
  const VisitedRatingBadge({super.key, required this.rating});

  final int rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: StarRating(
        rating: rating,
        emptyColor: Colors.amber.shade300,
      ),
    );
  }
}
