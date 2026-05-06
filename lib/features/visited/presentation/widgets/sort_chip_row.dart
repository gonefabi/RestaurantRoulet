import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../application/visited_providers.dart';
import '../../application/visited_sort.dart';

String _sortLabel(AppLocalizations l, SortOption option) {
  switch (option) {
    case SortOption.newestFirst:
      return l.sortNewest;
    case SortOption.oldestFirst:
      return l.sortOldest;
    case SortOption.bestRated:
      return l.sortBest;
    case SortOption.worstRated:
      return l.sortWorst;
    case SortOption.unratedFirst:
      return l.sortUnrated;
    case SortOption.mostVisited:
      return l.sortMostVisited;
  }
}

IconData _sortIcon(SortOption option) {
  switch (option) {
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

/// Horizontaler Filter-Chip-Streifen, gebunden an [visitedSortOptionProvider].
class SortChipRow extends ConsumerWidget {
  const SortChipRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
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
                    _sortIcon(option),
                    size: 14,
                    color: isSelected
                        ? Colors.white
                        : theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(_sortLabel(l, option)),
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
