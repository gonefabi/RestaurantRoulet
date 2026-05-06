import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/roulette_notifier.dart';

class ControlButtons extends ConsumerWidget {
  const ControlButtons({
    super.key,
    required this.isSpinning,
    required this.hasSelection,
  });

  final bool isSpinning;
  final bool hasSelection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isSpinning) return const SizedBox.shrink();
    final notifier = ref.read(rouletteProvider.notifier);

    if (!hasSelection) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: notifier.clearRestaurants,
            child: const Text('Abbrechen', style: TextStyle(fontSize: 16)),
          ),
        ],
      );
    }

    return Column(
      children: [
        OutlinedButton.icon(
          onPressed: notifier.selectWinner,
          icon: const Icon(Icons.replay),
          label: const Text('Nochmal drehen'),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: notifier.clearRestaurants,
          child: const Text('Neue Suche starten'),
        ),
      ],
    );
  }
}
