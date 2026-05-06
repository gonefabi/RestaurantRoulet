import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme.dart';

class RestaurantRouletteApp extends ConsumerWidget {
  const RestaurantRouletteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Restaurant Roulette',
      theme: AppTheme.light(),
      routerConfig: router,
    );
  }
}
