import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/visited_providers.dart';
import '../../application/visited_sort.dart';

extension on SortOption {
  String get label {
    switch (this) {
      case SortOption.newestFirst:
        return 'Neueste';
      case SortOption.oldestFirst:
        return 'Älteste';
      case SortOption.bestRated:
        return 'Beste';
      case SortOption.worstRated:
        return 'Schlechteste';
      case SortOption.unratedFirst:
        return 'Unbewertet';
      case SortOption.mostVisited:
        return 'Meist besucht';
    }
  }

  IconData get icon {
    switch (this) {
      case SortOption.newestFirst:
        return Icons.arrow_downward;
      case SortOption.oldestFirst:
        return Icons.arrow_upward;
      case SortOption.bestRated:
        return Icons.star;
      case SortOption.worstRated:
        return Icons.star_border;
      case SortOption.unratedFirst:
        return Icons.star_outline;
      case SortOption.mostVisited:
        return Icons.repeat;
    }
  }
}

/// Horizontaler Filter-Chip-Streifen, gebunden an [visitedSortOptionProvider].
class SortChipRow extends ConsumerWidget {
  const SortChipRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selected = ref.watch(visitedSortOptionProvider);

    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: SortOption.values.map((option) {
          final isSelected = selected == option;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    option.icon,
                    size: 14,
                    color: isSelected
                        ? Colors.white
                        : theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(option.label),
                ],
              ),
              onSelected: (_) =>
                  ref.read(visitedSortOptionProvider.notifier).state = option,
              selectedColor: theme.colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : null,
                fontWeight: isSelected ? FontWeight.w600 : null,
                fontSize: 13,
              ),
              showCheckmark: false,
              side: BorderSide(
                color: isSelected
                    ? theme.colorScheme.primary
                    : Colors.grey.shade300,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
