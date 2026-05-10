import 'package:flutter/material.dart';

/// Eine Aktion in einem [AppActionSheet].
class AppAction {
  const AppAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.subtitleWidget,
    this.iconColor,
    this.iconBackground,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// Optionaler Subtitle-Text. Wird ignoriert, wenn [subtitleWidget] gesetzt ist.
  final String? subtitle;

  /// Custom Subtitle (z. B. eine Sterne-Reihe). Überschreibt [subtitle].
  final Widget? subtitleWidget;

  final Color? iconColor;
  final Color? iconBackground;
}

/// Einheitliches Bottom-Sheet mit Titel + Untertitel + n Aktionen.
///
/// Pop des Sheets passiert automatisch vor [AppAction.onTap], damit
/// Aufrufer den Context für Folge-Dialoge weiterverwenden können.
class AppActionSheet {
  AppActionSheet._();

  static Future<void> show(
    BuildContext context, {
    required String title,
    String? subtitle,
    required List<AppAction> actions,
  }) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
              const SizedBox(height: 20),
              const Divider(height: 1),
              const SizedBox(height: 8),
              for (final action in actions) ...[
                _ActionTile(action: action),
                const SizedBox(height: 4),
              ],
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.action});

  final AppAction action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconBg = action.iconBackground ??
        theme.colorScheme.primary.withValues(alpha: 0.08);
    final iconColor = action.iconColor ?? theme.colorScheme.primary;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(action.icon, color: iconColor, size: 26),
      ),
      title: Text(
        action.label,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: action.subtitleWidget ??
          (action.subtitle != null
              ? Text(action.subtitle!,
                  style: TextStyle(color: Colors.grey.shade500))
              : null),
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
      onTap: () {
        Navigator.of(context).pop();
        action.onTap();
      },
    );
  }
}
