import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/navigation/app_router.dart';
import 'presentation/providers/providers.dart';
import 'presentation/theme/app_theme.dart';

class EllenaApp extends ConsumerWidget {
  const EllenaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final config = ref.watch(appConfigProvider);

    return MaterialApp.router(
      title: config.appName,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      themeAnimationDuration: const Duration(milliseconds: 180),
      themeAnimationCurve: Curves.easeOutCubic,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
