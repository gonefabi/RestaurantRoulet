import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/models/restaurant.dart';
import '../../application/roulette_notifier.dart';
import 'control_buttons.dart';
import 'roulette_wheel.dart';
import 'winner_card.dart';

/// Vollbild-Overlay über der Karte: Spinning Wheel, Gewinner-Karte, Steuerung.
class RouletteOverlay extends ConsumerWidget {
  const RouletteOverlay({
    super.key,
    required this.isSpinning,
    required this.onStartRoute,
  });

  final bool isSpinning;
  final ValueChanged<Restaurant> onStartRoute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    final state = ref.watch(rouletteProvider);
    final notifier = ref.read(rouletteProvider.notifier);
    final winner = state.selectedRestaurant;
    final showWheel = winner == null || isSpinning;

    return Container(
      color: theme.scaffoldBackgroundColor.withValues(alpha: 0.95),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showWheel)
                Text(
                  l.chooseYourFate,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 20),
              if (showWheel)
                RouletteWheelWidget(
                  restaurants: state.restaurants,
                  onFinished: (_) {},
                  onSpin: () {
                    if (!isSpinning && winner == null) {
                      notifier.selectWinner();
                    }
                  },
                ),
              const SizedBox(height: 20),
              if (winner != null && !isSpinning)
                WinnerCard(
                  restaurant: winner,
                  alreadyVisited: state.visitedIds.contains(winner.id),
                  onStartRoute: onStartRoute,
                ),
              const SizedBox(height: 30),
              ControlButtons(
                isSpinning: isSpinning,
                hasSelection: winner != null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
