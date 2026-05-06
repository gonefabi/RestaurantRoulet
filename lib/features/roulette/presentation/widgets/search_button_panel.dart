import 'package:flutter/material.dart';

import '../../../../core/localization/generated/app_localizations.dart';

class SearchButtonPanel extends StatelessWidget {
  const SearchButtonPanel({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Positioned(
      bottom: 40,
      left: 20,
      right: 20,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.casino_outlined, color: Colors.white),
        label: Text(l.searchRestaurants),
      ),
    );
  }
}
