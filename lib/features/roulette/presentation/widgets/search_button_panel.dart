import 'package:flutter/material.dart';

class SearchButtonPanel extends StatelessWidget {
  const SearchButtonPanel({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 40,
      left: 20,
      right: 20,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.casino_outlined, color: Colors.white),
        label: const Text('Restaurant suchen'),
      ),
    );
  }
}
