import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/services/link_launcher_service.dart';

class ProfileMenu extends ConsumerWidget {
  const ProfileMenu({
    super.key,
    required this.isOpen,
    required this.onToggle,
    required this.onClose,
  });

  final bool isOpen;
  final VoidCallback onToggle;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Positioned(
      top: 50,
      left: 20,
      bottom: 100,
      child: Align(
        alignment: Alignment.topLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton.small(
              heroTag: 'profile_btn',
              backgroundColor: theme.colorScheme.surface,
              onPressed: onToggle,
              child: Icon(
                isOpen ? Icons.close : Icons.person,
                color: theme.colorScheme.primary,
              ),
            ),
            if (isOpen)
              Flexible(
                child: Card(
                  margin: const EdgeInsets.only(top: 10),
                  child: SizedBox(
                    width: 250,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            'Profil',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                        const Divider(),
                        _MenuItem(
                          icon: Icons.history,
                          label: 'Besuchte Restaurants',
                          onTap: () {
                            onClose();
                            context.push(AppRoute.visited);
                          },
                        ),
                        _MenuItem(
                          icon: Icons.notifications,
                          label: 'Benachrichtigungen',
                          onTap: () {
                            onClose();
                            context.push(AppRoute.notificationSettings);
                          },
                        ),
                        const Divider(),
                        _MenuItem(
                          icon: Icons.privacy_tip,
                          label: 'Datenschutz',
                          onTap: () {
                            onClose();
                            ref.read(linkLauncherServiceProvider).openExternal(
                                  Uri.parse('https://gonefabi.github.io/RestaurantRoulet/datenschutz.html'),
                                );
                          },
                        ),
                        _MenuItem(
                          icon: Icons.info_outline,
                          label: 'Impressum',
                          onTap: () {
                            onClose();
                            ref.read(linkLauncherServiceProvider).openExternal(
                                  Uri.parse('https://gonefabi.github.io/RestaurantRoulet/impressum.html'),
                                );
                          },
                        ),
                      ],
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

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      dense: true,
      onTap: onTap,
    );
  }
}
