import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/jaap/presentation/auto_jaap_controller.dart';
import '../features/jaap/presentation/jaap_controller.dart';
import '../features/reminders/presentation/reminder_controllers.dart';
import '../features/reminders/presentation/reminders_screen.dart';
import '../features/settings/presentation/settings_controller.dart';
import '../l10n/app_localizations.dart';
import 'router.dart';
import 'theme/app_theme.dart';
import 'theme/app_themes.dart';

class JapMalaApp extends ConsumerWidget {
  const JapMalaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: 'JapMala',
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(routerProvider),
      // A fixed colour theme is handed in as both, so the device's light/dark
      // setting cannot swap it out.
      theme: settings.themeId == AppThemeId.system
          ? AppTheme.light()
          : AppTheme.forId(settings.themeId),
      darkTheme: settings.themeId == AppThemeId.system
          ? AppTheme.dark()
          : AppTheme.forId(settings.themeId),
      themeMode: settings.themeMode,
      locale: settings.locale,
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      builder: (context, child) =>
          _AppLifecycle(child: child ?? const SizedBox.shrink()),
    );
  }
}

/// Watches the app's lifecycle so nothing is lost when it goes away, and so
/// the counter notices a day that turned over while it was in the background.
class _AppLifecycle extends ConsumerStatefulWidget {
  const _AppLifecycle({required this.child});

  final Widget child;

  @override
  ConsumerState<_AppLifecycle> createState() => _AppLifecycleState();
}

class _AppLifecycleState extends ConsumerState<_AppLifecycle>
    with WidgetsBindingObserver {
  bool _remindersSynced = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = ref.read(jaapControllerProvider.notifier);
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // Beads acknowledged on screen must be on disk before we lose the
        // process. Auto Jaap stops too: it should never count unseen.
        ref.read(autoJaapProvider.notifier).stop();
        controller.flushPendingWrites();
      case AppLifecycleState.resumed:
        controller.refreshForResume();
      case AppLifecycleState.inactive:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Reminder text is written into the platform schedule, so it is refreshed
    // once per launch in the app's current language.
    if (!_remindersSynced) {
      _remindersSynced = true;
      final l10n = AppL10n.of(context);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(remindersProvider.notifier)
            .reschedule(RemindersScreen.copyFrom(l10n));
      });
    }
    return widget.child;
  }
}
