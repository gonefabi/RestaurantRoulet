import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../application/roulette_notifier.dart';
import '../../application/roulette_state.dart';

class _PlaceType {
  const _PlaceType(this.value, this.label, this.icon);
  final String value;
  final String label;
  final IconData icon;
}

const _placeTypes = <_PlaceType>[
  _PlaceType('restaurant', 'Restaurant', Icons.restaurant),
  _PlaceType('fast_food', 'Fast Food', Icons.fastfood),
  _PlaceType('cafe', 'Café', Icons.local_cafe),
  _PlaceType('bar', 'Bar', Icons.local_bar),
  _PlaceType('pub', 'Pub', Icons.sports_bar),
  _PlaceType('biergarten', 'Biergarten', Icons.deck),
  _PlaceType('ice_cream', 'Eisdiele', Icons.icecream),
];

const _cuisines = <String, String>{
  'Italienisch': 'italian',
  'Pizza': 'pizza',
  'Pasta': 'pasta',
  'Asiatisch': 'asian',
  'Chinesisch': 'chinese',
  'Japanisch': 'japanese',
  'Sushi': 'sushi',
  'Koreanisch': 'korean',
  'Thailändisch': 'thai',
  'Vietnamesisch': 'vietnamese',
  'Indisch': 'indian',
  'Türkisch': 'turkish',
  'Kebab': 'kebab',
  'Griechisch': 'greek',
  'Französisch': 'french',
  'Deutsch': 'german',
  'Regional': 'regional',
  'Mexikanisch': 'mexican',
  'Amerikanisch': 'american',
  'Burger': 'burger',
  'Steakhouse': 'steak_house',
  'Barbecue': 'barbecue',
  'Fish & Chips': 'fish_and_chips',
  'Seafood': 'seafood',
  'Nudeln': 'noodle',
};

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

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, scrollController) {
        return Column(
          children: [
            const _SheetHandle(),
            _SheetHeader(onClose: () => Navigator.of(ctx).pop()),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  _RadiusSection(state: state, notifier: notifier),
                  const SizedBox(height: 24),
                  _DietSection(state: state, notifier: notifier),
                  const SizedBox(height: 24),
                  _MiscSection(state: state, notifier: notifier),
                  const SizedBox(height: 24),
                  _PlaceTypeSection(state: state, notifier: notifier),
                  const SizedBox(height: 24),
                  _CuisineSection(state: state, notifier: notifier),
                  const SizedBox(height: 24),
                  _ComfortSection(state: state, notifier: notifier),
                  const SizedBox(height: 24),
                  _OsmFooter(state: state),
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
  const _SheetHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 12, 12),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Filter',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose,
            tooltip: 'Schließen',
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
  const _RadiusSection({required this.state, required this.notifier});

  final RouletteState state;
  final RouletteNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: _SectionHeader(
                title: 'Suchradius',
                subtitle: 'Wie weit darf das Restaurant entfernt sein?',
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${state.radiusKm.toStringAsFixed(1)} km',
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
          label: '${state.radiusKm.toStringAsFixed(1)} km',
          onChanged: notifier.setRadius,
        ),
      ],
    );
  }
}

class _PlaceTypeSection extends StatelessWidget {
  const _PlaceTypeSection({required this.state, required this.notifier});

  final RouletteState state;
  final RouletteNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          title: 'Lokal-Typ',
          subtitle: 'Wonach suchst du? Mehrfachauswahl möglich.',
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
              label: Text(type.label),
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
  const _CuisineSection({required this.state, required this.notifier});

  final RouletteState state;
  final RouletteNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final restaurantSelected = state.placeTypes.contains('restaurant');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          title: 'Küche',
          subtitle:
              'Schränkt die Auswahl auf Restaurants mit dieser Küche ein. '
              'Greift nur, wenn „Restaurant" als Lokal-Typ aktiv ist.',
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
                    'Aktiviere „Restaurant" oben, damit Küchen-Filter wirken.',
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
          children: _cuisines.entries.map((entry) {
            final isSelected = state.selectedCuisines.contains(entry.value);
            return FilterChip(
              label: Text(entry.key),
              selected: isSelected,
              onSelected: restaurantSelected
                  ? (_) => notifier.toggleCuisine(entry.value)
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
  const _DietSection({required this.state, required this.notifier});

  final RouletteState state;
  final RouletteNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          title: 'Ernährung',
          subtitle: 'Zeigt nur Lokale, die diese Optionen anbieten.',
        ),
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
      ],
    );
  }
}

class _ComfortSection extends StatelessWidget {
  const _ComfortSection({required this.state, required this.notifier});

  final RouletteState state;
  final RouletteNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          title: 'Komfort',
          subtitle: 'Ausstattung & Zugänglichkeit, sofern in OSM erfasst.',
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Rollstuhl-zugänglich'),
          value: state.wheelchairAccessible,
          activeColor: theme.colorScheme.primary,
          onChanged: notifier.toggleWheelchair,
        ),
      ],
    );
  }
}

class _MiscSection extends StatelessWidget {
  const _MiscSection({required this.state, required this.notifier});

  final RouletteState state;
  final RouletteNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          title: 'Sonstiges',
          subtitle: 'Verfeinere das Roulette-Ergebnis.',
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Besuchte ausblenden'),
          subtitle: const Text('Bereits besuchte Orte ausschließen'),
          value: state.excludeVisited,
          activeColor: theme.colorScheme.primary,
          onChanged: notifier.toggleExcludeVisited,
        ),
      ],
    );
  }
}

class _OsmFooter extends StatelessWidget {
  const _OsmFooter({required this.state});

  final RouletteState state;

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
              const Text(
                'Datenquelle: OpenStreetMap',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Restaurants & Filter-Eigenschaften (Vegan, WLAN, Rollstuhl …) '
            'stammen aus der freien OSM-Datenbank — gepflegt von Freiwilligen. '
            'Daten sind nicht zu 100 % vollständig oder aktuell.',
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
                      'Fehlt was? Selbst eintragen auf openstreetmap.org',
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
