import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../application/roulette_notifier.dart';
import '../../application/roulette_state.dart';

class _PlaceType {
  const _PlaceType(this.value, this.icon);
  final String value;
  final IconData icon;
}

const _placeTypes = <_PlaceType>[
  _PlaceType('restaurant', Icons.restaurant),
  _PlaceType('fast_food', Icons.fastfood),
  _PlaceType('cafe', Icons.local_cafe),
  _PlaceType('bar', Icons.local_bar),
  _PlaceType('pub', Icons.sports_bar),
  _PlaceType('biergarten', Icons.deck),
  _PlaceType('ice_cream', Icons.icecream),
];

const _cuisines = <String>[
  'italian',
  'pizza',
  'pasta',
  'asian',
  'chinese',
  'japanese',
  'sushi',
  'korean',
  'thai',
  'vietnamese',
  'indian',
  'turkish',
  'kebab',
  'greek',
  'french',
  'german',
  'regional',
  'mexican',
  'american',
  'burger',
  'steak_house',
  'barbecue',
  'fish_and_chips',
  'seafood',
  'noodle',
];

String _placeTypeLabel(AppLocalizations l, String code) {
  switch (code) {
    case 'restaurant':
      return l.placeTypeRestaurant;
    case 'fast_food':
      return l.placeTypeFastFood;
    case 'cafe':
      return l.placeTypeCafe;
    case 'bar':
      return l.placeTypeBar;
    case 'pub':
      return l.placeTypePub;
    case 'biergarten':
      return l.placeTypeBiergarten;
    case 'ice_cream':
      return l.placeTypeIceCream;
  }
  return code;
}

String _cuisineLabel(AppLocalizations l, String code) {
  switch (code) {
    case 'italian':
      return l.cuisineItalian;
    case 'pizza':
      return l.cuisinePizza;
    case 'pasta':
      return l.cuisinePasta;
    case 'asian':
      return l.cuisineAsian;
    case 'chinese':
      return l.cuisineChinese;
    case 'japanese':
      return l.cuisineJapanese;
    case 'sushi':
      return l.cuisineSushi;
    case 'korean':
      return l.cuisineKorean;
    case 'thai':
      return l.cuisineThai;
    case 'vietnamese':
      return l.cuisineVietnamese;
    case 'indian':
      return l.cuisineIndian;
    case 'turkish':
      return l.cuisineTurkish;
    case 'kebab':
      return l.cuisineKebab;
    case 'greek':
      return l.cuisineGreek;
    case 'french':
      return l.cuisineFrench;
    case 'german':
      return l.cuisineGerman;
    case 'regional':
      return l.cuisineRegional;
    case 'mexican':
      return l.cuisineMexican;
    case 'american':
      return l.cuisineAmerican;
    case 'burger':
      return l.cuisineBurger;
    case 'steak_house':
      return l.cuisineSteakhouse;
    case 'barbecue':
      return l.cuisineBarbecue;
    case 'fish_and_chips':
      return l.cuisineFishAndChips;
    case 'seafood':
      return l.cuisineSeafood;
    case 'noodle':
      return l.cuisineNoodle;
  }
  return code;
}

class FilterMenu extends StatelessWidget {
  const FilterMenu({super.key, required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
      top: 50,
      right: 20,
      child: FloatingActionButton.small(
        heroTag: 'filter_btn',
        backgroundColor: theme.colorScheme.surface,
        onPressed: () {
          onOpen();
          _showFilterSheet(context);
        },
        child: Icon(Icons.tune, color: theme.colorScheme.primary),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _FilterSheet(),
    );
  }
}

class _FilterSheet extends ConsumerWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(rouletteProvider);
    final notifier = ref.read(rouletteProvider.notifier);
    final l = AppLocalizations.of(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, scrollController) {
        return Column(
          children: [
            const _SheetHandle(),
            _SheetHeader(
              title: l.filterTitle,
              closeTooltip: l.filterClose,
              onClose: () => Navigator.of(ctx).pop(),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  _RadiusSection(state: state, notifier: notifier, l: l),
                  const SizedBox(height: 24),
                  _DietSection(state: state, notifier: notifier, l: l),
                  const SizedBox(height: 24),
                  _MiscSection(state: state, notifier: notifier, l: l),
                  const SizedBox(height: 24),
                  _PlaceTypeSection(state: state, notifier: notifier, l: l),
                  const SizedBox(height: 24),
                  _CuisineSection(state: state, notifier: notifier, l: l),
                  const SizedBox(height: 24),
                  _ComfortSection(state: state, notifier: notifier, l: l),
                  const SizedBox(height: 24),
                  _OsmFooter(state: state, l: l),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({
    required this.title,
    required this.closeTooltip,
    required this.onClose,
  });

  final String title;
  final String closeTooltip;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose,
            tooltip: closeTooltip,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _RadiusSection extends StatelessWidget {
  const _RadiusSection({
    required this.state,
    required this.notifier,
    required this.l,
  });

  final RouletteState state;
  final RouletteNotifier notifier;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatted = state.radiusKm.toStringAsFixed(1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _SectionHeader(
                title: l.filterRadiusTitle,
                subtitle: l.filterRadiusSubtitle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                l.filterRadiusValue(formatted),
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        Slider(
          value: state.radiusKm,
          min: 0.5,
          max: 20,
          divisions: 39,
          label: l.filterRadiusValue(formatted),
          onChanged: notifier.setRadius,
        ),
      ],
    );
  }
}

class _PlaceTypeSection extends StatelessWidget {
  const _PlaceTypeSection({
    required this.state,
    required this.notifier,
    required this.l,
  });

  final RouletteState state;
  final RouletteNotifier notifier;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: l.filterPlaceTypeTitle,
          subtitle: l.filterPlaceTypeSubtitle,
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _placeTypes.map((type) {
            final selected = state.placeTypes.contains(type.value);
            return FilterChip(
              avatar: Icon(
                type.icon,
                size: 18,
                color: selected
                    ? theme.colorScheme.primary
                    : Colors.grey.shade600,
              ),
              label: Text(_placeTypeLabel(l, type.value)),
              selected: selected,
              onSelected: (_) => notifier.togglePlaceType(type.value),
              selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
              checkmarkColor: theme.colorScheme.primary,
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _CuisineSection extends StatelessWidget {
  const _CuisineSection({
    required this.state,
    required this.notifier,
    required this.l,
  });

  final RouletteState state;
  final RouletteNotifier notifier;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final restaurantSelected = state.placeTypes.contains('restaurant');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: l.filterCuisineTitle,
          subtitle: l.filterCuisineSubtitle,
        ),
        if (!restaurantSelected)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    size: 18, color: Colors.amber.shade800),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l.filterCuisineHint,
                    style: TextStyle(
                        fontSize: 12, color: Colors.amber.shade900),
                  ),
                ),
              ],
            ),
          ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _cuisines.map((code) {
            final isSelected = state.selectedCuisines.contains(code);
            return FilterChip(
              label: Text(_cuisineLabel(l, code)),
              selected: isSelected,
              onSelected: restaurantSelected
                  ? (_) => notifier.toggleCuisine(code)
                  : null,
              selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
              checkmarkColor: theme.colorScheme.primary,
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _DietSection extends StatelessWidget {
  const _DietSection({
    required this.state,
    required this.notifier,
    required this.l,
  });

  final RouletteState state;
  final RouletteNotifier notifier;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: l.filterDietTitle,
          subtitle: l.filterDietSubtitle,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l.filterDietVegan),
          value: state.isVegan,
          activeColor: theme.colorScheme.primary,
          onChanged: notifier.toggleVegan,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l.filterDietVegetarian),
          value: state.isVegetarian,
          activeColor: theme.colorScheme.primary,
          onChanged: notifier.toggleVegetarian,
        ),
      ],
    );
  }
}

class _ComfortSection extends StatelessWidget {
  const _ComfortSection({
    required this.state,
    required this.notifier,
    required this.l,
  });

  final RouletteState state;
  final RouletteNotifier notifier;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: l.filterComfortTitle,
          subtitle: l.filterComfortSubtitle,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l.filterComfortWheelchair),
          value: state.wheelchairAccessible,
          activeColor: theme.colorScheme.primary,
          onChanged: notifier.toggleWheelchair,
        ),
      ],
    );
  }
}

class _MiscSection extends StatelessWidget {
  const _MiscSection({
    required this.state,
    required this.notifier,
    required this.l,
  });

  final RouletteState state;
  final RouletteNotifier notifier;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: l.filterMiscTitle,
          subtitle: l.filterMiscSubtitle,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l.filterMiscExcludeVisited),
          subtitle: Text(l.filterMiscExcludeVisitedSubtitle),
          value: state.excludeVisited,
          activeColor: theme.colorScheme.primary,
          onChanged: notifier.toggleExcludeVisited,
        ),
      ],
    );
  }
}

class _OsmFooter extends StatelessWidget {
  const _OsmFooter({required this.state, required this.l});

  final RouletteState state;
  final AppLocalizations l;

  Future<void> _openOsmEditor() async {
    final pos = state.currentPosition;
    final url = pos != null
        ? Uri.parse(
            'https://www.openstreetmap.org/edit?editor=id'
            '#map=18/${pos.latitude}/${pos.longitude}',
          )
        : Uri.parse('https://www.openstreetmap.org/');
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.public, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                l.filterOsmHeader,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l.filterOsmDescription,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: _openOsmEditor,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(Icons.edit_location_alt,
                      size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l.filterOsmContribute,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(Icons.open_in_new,
                      size: 14, color: theme.colorScheme.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
