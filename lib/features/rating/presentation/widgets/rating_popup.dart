import 'package:flutter/material.dart';

import '../../../../core/models/restaurant.dart';
import '../../../../core/widgets/star_rating.dart';

class RatingPopup extends StatefulWidget {
  final Restaurant restaurant;
  final VoidCallback onDismiss;
  final Function(int) onRatingSaved;

  const RatingPopup({
    Key? key,
    required this.restaurant,
    required this.onDismiss,
    required this.onRatingSaved,
  }) : super(key: key);

  @override
  State<RatingPopup> createState() => _RatingPopupState();
}

class _RatingPopupState extends State<RatingPopup> {
  late int _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.restaurant.userRating ?? 0;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onDismiss,
                ),
              ],
            ),
            Text(
              widget.restaurant.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (widget.restaurant.address != null)
              Text(
                widget.restaurant.address!,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            if (widget.restaurant.visitedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'Besucht am: ${_formatDate(widget.restaurant.visitedAt!)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            Center(
              child: StarRating(
                rating: _rating,
                size: 32,
                onChanged: (r) => setState(() => _rating = r),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_rating > 0) {
                  widget.onRatingSaved(_rating);
                }
              },
              child: const Text('Bewertung speichern'),
            ),
          ],
        ),
      ),
    );
  }
}
