import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/roulette_notifier.dart';
import '../../application/roulette_state.dart';

const _cuisines = <String, String>{
  'Italienisch': 'italian',
  'Asiatisch': 'asian',
  'Deutsch': 'german',
  'Chinesisch': 'chinese',
  'Japanisch': 'japanese',
  'Mexikanisch': 'mexican',
  'Indisch': 'indian',
  'Französisch': 'french',
  'Griechisch': 'greek',
  'Amerikanisch': 'american',
  'Burger': 'burger',
  'Pizza': 'pizza',
  'Sushi': 'sushi',
};

class FilterMenu extends ConsumerWidget {
  const FilterMenu({
    super.key,
    required this.isOpen,
    required this.onToggle,
  });

  final bool isOpen;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(rouletteProvider);
    final notifier = ref.read(rouletteProvider.notifier);

    return Positioned(
      top: 50,
      right: 20,
      bottom: 100,
      child: Align(
        alignment: Alignment.topRight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton.small(
              heroTag: 'filter_btn',
              backgroundColor: theme.colorScheme.surface,
              onPressed: onToggle,
              child: Icon(
                isOpen ? Icons.close : Icons.tune,
                color: theme.colorScheme.primary,
              ),
            ),
            if (isOpen)
              Flexible(
                child: Card(
                  margin: const EdgeInsets.only(top: 10),
                  child: Container(
                    padding: EdgeInsets.zero,
                    width: 300,
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.65,
                    ),
                    child: Scrollbar(
                      thumbVisibility: true,
                      thickness: 4,
                      radius: const Radius.circular(8),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: _FilterContent(state: state, notifier: notifier),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FilterContent extends StatelessWidget {
  const _FilterContent({required this.state, required this.notifier});

  final RouletteState state;
  final RouletteNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Suchradius', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              '${state.radiusKm.toStringAsFixed(1)} km',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Slider(
          value: state.radiusKm,
          min: 0.5,
          max: 20,
          divisions: 39,
          label: '${state.radiusKm.toStringAsFixed(1)} km',
          onChanged: notifier.setRadius,
        ),
        const Divider(height: 20),
        const Text('Filter', style: TextStyle(fontWeight: FontWeight.bold)),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Vegan verfügbar'),
          value: state.isVegan,
          activeColor: theme.colorScheme.primary,
          onChanged: notifier.toggleVegan,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Vegetarisch verfügbar'),
          value: state.isVegetarian,
          activeColor: theme.colorScheme.primary,
          onChanged: notifier.toggleVegetarian,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Besuchte ausblenden'),
          subtitle: const Text('Bereits besuchte Orte ausschließen'),
          value: state.excludeVisited,
          activeColor: theme.colorScheme.primary,
          onChanged: notifier.toggleExcludeVisited,
        ),
        const Text('Küche', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: _cuisines.entries.map((entry) {
            final isSelected = state.selectedCuisines.contains(entry.value);
            return FilterChip(
              label: Text(entry.key),
              selected: isSelected,
              onSelected: (_) => notifier.toggleCuisine(entry.value),
              selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
              checkmarkColor: theme.colorScheme.primary,
            );
          }).toList(),
        ),
      ],
    );
  }
}
