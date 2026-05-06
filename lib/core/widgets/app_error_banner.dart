import 'package:flutter/material.dart';

/// Einheitliche rote Error-Leiste mit optionalem Schließen-Button.
class AppErrorBanner extends StatelessWidget {
  const AppErrorBanner({
    super.key,
    required this.message,
    this.onClose,
  });

  final String message;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
            if (onClose != null)
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: onClose,
              ),
          ],
        ),
      ),
    );
  }
}
